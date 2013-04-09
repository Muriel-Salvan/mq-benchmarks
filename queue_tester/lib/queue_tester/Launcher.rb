#--
# Copyright (c) 2013 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'optparse'
require 'time'

# Notification through Faye
require 'faye'
require 'json'
require 'net/http'

require 'rUtilAnts/Logging'
RUtilAnts::Logging::install_logger_on_object
require 'rUtilAnts/MySQLPool'
RUtilAnts::MySQLPool::install_mysql_pool_on_object
require 'rUtilAnts/Misc'
RUtilAnts::Misc::install_misc_on_object

require 'queue_tester/EngineDSL'
require 'queue_tester/interfaces/STOMP'
require 'queue_tester/interfaces/AMQP'

class Time

  # Convert the current Time to a Mysql::Time object
  #
  # Return:
  # * <em>Mysql::Time</em>: The corresponding MySQL Time
  def to_mysql
    return Mysql::Time.new(self.year, self.month, self.day, self.hour, self.min, self.sec)
  end

end

module QueueTester

  class Launcher

    # Constructor
    def initialize
      # Options set by the command line parser
      @action = nil
      @engine = nil
      @max_nbr_enqueue = nil
      @from_id = nil
      @to_id = nil
      @display_help = false
      @debug = false
      @enqueue_times = 1

      parse_plugins

      # The command line parser
      @options = OptionParser.new
      @options.banner = 'run.rb [--help] [--debug] --action <ActionName> --engine <EngineName> [--max_enqueue_nbr <NumberOfEnqueueOperations>] [--enqueue_times <NumberOfTimes>] [--dequeue_nbr <NumberOfDequeueOperations>] [--fromid <ID>] [--toid <ID>]'
      @options.on( '--max_enqueue_nbr <NumberOfEnqueueOperations>', Integer,
        '<NumberOfEnqueueOperations>: Max number of enqueue operations to perform',
        'Specify a maximal number of operations to perform. Used only if action is enqueue') do |arg|
        @max_nbr_enqueue = arg
      end
      @options.on( '--enqueue_times <NumberOfTimes>', Integer,
        '<NumberOfTimes>: Number of times we repeat the enqueuing process',
        'Specify the number of times the enqueuing process repeats. Used only if action is enqueue') do |arg|
        @enqueue_times = arg
      end
      @options.on( '--dequeue_nbr <NumberOfDequeueOperations>', Integer,
        '<NumberOfDequeueOperations>: Number of dequeue operations to perform',
        'Specify a number of operations to perform. Used and mandatory only if action is enqueue') do |arg|
        @nbr_dequeue = arg
      end
      @options.on( '--action <ActionName>', String,
        '<ActionName>: Name of action to perform: "enqueue" | "dequeue" | "flush"',
        'Specify action to perform') do |arg|
        @action = arg.to_sym
      end
      @options.on( '--engine <EngineName>', String,
        "<EngineName>: Name of the engine to process action. Available Engines: #{get_plugins_names('Engines').sort.join(', ')}",
        'Specify the engine') do |arg|
        @engine = arg
      end
      @options.on( '--fromid <ID>', Integer,
        '<ID>: Starting ID of Messages to enqueue',
        'Specify the starting ID. Used only if action is enqueue') do |arg|
        @from_id = arg
      end
      @options.on( '--toid <ID>', Integer,
        '<ID>: Ending ID of Messages to enqueue',
        'Specify the ending ID. Used only if action is enqueue') do |arg|
        @to_id = arg
      end
      @options.on( '--help',
        'Display help') do
        @display_help = true
      end
      @options.on( '--debug',
        'Activate debug logs') do
        @debug = true
      end
    end

    # Execute command line arguments
    #
    # Parameters::
    # * *args* (<em>list<String></em>): Command line arguments
    # Return::
    # * _Integer_: The error code to return to the terminal
    def execute(args)
      remaining_args = @options.parse(args)
      raise RuntimeError.new("Unknown arguments: #{remaining_args.join(' ')}") if (!remaining_args.empty?)

      if (@display_help)
        puts @options
      else
        if (@debug)
          activate_log_debug(true)
        end
        log_debug "Invoked with #{args.join(' ')}"
        # Check mandatory arguments were given
        raise RuntimeError.new('Missing --engine option.') if (@engine == nil)
        raise RuntimeError.new('Missing --action option.') if (@action == nil)
        raise RuntimeError.new("Invalid action: #{@action}") if (![:enqueue, :dequeue, :flush].include?(@action))
        # Set Faye URI for notifications
        @faye_uri = URI.parse('http://localhost:3000/faye')
        # Access the database
        setup_mysql_connection('localhost', 'queues_test', 'root', 'cadaeibfed') do |mysql|
          @mysql = mysql
          # Avoid timeouts
          @mysql.query('SET SESSION wait_timeout = 28800')
          # Access the Engine
          access_plugin('Engines', @engine) do |engine_plugin|
            # Decorate the plugin with specific DSL methods
            engine_plugin.extend EngineDSL
            engine_plugin.init
            # Run the engine
            if (@action == :enqueue)
              # Select messages to enqueue
              setup_prepared_statement(@mysql, 'SELECT body FROM messages WHERE id >= ? AND id <= ? LIMIT ?') do |statement_select_messages|
                statement_select_messages.execute(
                  (@from_id == nil) ? 0 : @from_id,
                  (@to_id == nil) ? 1048576 : @to_id,
                  (@max_nbr_enqueue == nil) ? 1048576 : @max_nbr_enqueue
                )
                messages_to_enqueue_lst = []
                statement_select_messages.each do |row|
                  messages_to_enqueue_lst << row[0]
                end
                messages_to_enqueue_lst *= @enqueue_times
                log_info "Enqueuing #{messages_to_enqueue_lst.size} messages ..."
                timely_execute_with_progress(messages_to_enqueue_lst.size, engine_plugin) do
                  engine_plugin.enqueue(messages_to_enqueue_lst)
                end
              end
            elsif (@action == :dequeue)
              dequeued_messages_lst = []
              timely_execute_with_progress(@nbr_dequeue, engine_plugin) do
                dequeued_messages_lst = engine_plugin.dequeue(@nbr_dequeue)
              end
              log_info "Dequeued #{dequeued_messages_lst.size} messages."
              # Insert those messages
              @mysql.query('BEGIN')
              begin
                setup_prepared_statement(@mysql, "INSERT INTO dequeued_messages (body, engine, created_at, updated_at) VALUES (?, ?, ?, ?)") do |statement_insert_dequeued|
                  dequeued_messages_lst.each do |message|
                    statement_insert_dequeued.execute(
                      message,
                      @engine,
                      Time.now.to_mysql,
                      Time.now.to_mysql
                    )
                  end
                end
                @mysql.query('COMMIT')
              rescue Exception
                @mysql.query('ROLLBACK')
                raise
              end
            else
              timely_execute_with_progress(1, engine_plugin) do
                engine_plugin.flush
              end
            end
            log_info 'Execution finished correctly.'
          end
        end
      end
    end

    private

    # Parse plugins
    def parse_plugins
      lib_dir = File.expand_path(File.dirname(__FILE__))
      require 'rUtilAnts/Plugins'
      RUtilAnts::Plugins::install_plugins_on_object
      parse_plugins_from_dir('Engines', "#{lib_dir}/engines", 'QueueTester::Engines')
    end

    # Notify progression
    def notify_progress(max_messages, nbr_messages)
      message = {
        :channel => '/operations',
        :data => {
          'id' => Process.pid,
          'engine' => @engine,
          'action' => @action,
          'max_messages' => max_messages,
          'nbr_messages' => nbr_messages
        }
      }
      Net::HTTP.post_form(@faye_uri, :message => message.to_json)
    end

    # Execute with a timing and progression thread
    #
    # Parameters:
    # * *max_progress* (_String_): Maximal progression
    # * *engine_plugin* (_Object_): Plugin giving progress
    def timely_execute_with_progress(max_progress, engine_plugin)
      # Launch a thread that outputs progress
      progress_thread = Thread.new do |thread|
        while (!engine_plugin.get_finished)
          notify_progress(max_progress, engine_plugin.get_progress)
          sleep 1
        end
        notify_progress(max_progress, engine_plugin.get_progress)
      end

      begin_time = Time.now
      yield
      end_time = Time.now
      engine_plugin.set_finished(true)
      progress_thread.join

      # Store the processing times
      setup_prepared_statement(@mysql, 'INSERT INTO operations (elapsed_time, engine, action, nbr_messages, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)') do |statement_add_process|
        statement_add_process.execute(
          ((end_time.to_f - begin_time.to_f)*1000000).to_i.to_s,
          @engine,
          @action.to_s,
          max_progress,
          Time.now.to_mysql,
          Time.now.to_mysql
        )
      end
    end

  end

end
