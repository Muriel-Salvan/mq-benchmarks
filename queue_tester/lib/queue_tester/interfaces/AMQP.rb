require 'amqp'

module QueueTester

  module Interfaces

    module AMQP

      def enqueue_amqp(options)
        ::AMQP.start(
          :host => options[:host],
          :port => options[:port],
          :user => options[:username],
          :pass => options[:password]
        ) do |connection|
          ::AMQP::Channel.new(connection) do |channel, open_ok|
            channel.on_error(&method(:handle_channel_exception))
            exchange = channel.default_exchange
            channel.queue(options[:queue], :durable => (options[:transient] != true)) do |queue, declare_ok|

              options[:messages].each do |message|
                log_debug "[AMQP] Publish message #{message}"
                exchange.publish message, :routing_key => queue.name, :persistent => (options[:transient] != true)
                progress(1)
              end

              EventMachine.add_timer(0.5) do
                connection.disconnect { EventMachine.stop }
              end

            end
          end
        end
      end

      def dequeue_amqp(options)
        messages = []

        ::AMQP.start(
          :host => options[:host],
          :port => options[:port],
          :user => options[:username],
          :pass => options[:password]
        ) do |connection|
          ::AMQP::Channel.new(connection) do |channel, open_ok|
            channel.on_error(&method(:handle_channel_exception))
            log_debug "[AMQP] Prefetch #{options[:number]}"
            channel.prefetch(options[:number])
            channel.queue(options[:queue], :durable => (options[:transient] != true)) do |queue, declare_ok|

              queue.subscribe(:ack => true) do |header, message|
                header.ack
                messages << message
                log_debug "[AMQP] Received message #{message}"
                progress(1)
                if (messages.size == options[:number])
                  queue.unsubscribe
                  connection.disconnect { EventMachine.stop }
                end
              end

            end
          end
        end

        return messages
      end

      def flush_amqp(options)
        ::AMQP.start(
          :host => options[:host],
          :port => options[:port],
          :user => options[:username],
          :pass => options[:password]
        ) do |connection|
          ::AMQP::Channel.new(connection) do |channel, open_ok|
            channel.on_error(&method(:handle_channel_exception))
            channel.queue(options[:queue], :durable => (options[:transient] != true)) do |queue, declare_ok|

              EventMachine.add_timer(0.5) do
                queue.purge
                log_debug '[AMQP] Flush performed.'
                progress(1)
                connection.disconnect { EventMachine.stop }
              end

            end
          end
        end
      end

      def handle_channel_exception(channel, channel_close)
        msg = "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
        puts msg
        raise RuntimeError, msg
      end

    end

  end

end
