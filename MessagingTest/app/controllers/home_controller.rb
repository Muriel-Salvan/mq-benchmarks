class HomeController < ApplicationController

  def queue_tester_call
    @queue_tester_run_idx = 0
    cmd_parameters_lst = params_for_queue_tester(params[:q_action])
    exec_queue_tester params[:engine], params[:q_action], cmd_parameters_lst.join(' ')
    flash[:notice] = 'Launched Queue tester correctly'

    redirect_to operations_path
  end

  def parallel_queue_tester_call
    @queue_tester_run_idx = 0
    count = 0
    ((params[:q_action] == 'both') ? [ 'enqueue', 'dequeue' ] : [ params[:q_action] ]).each do |action_name|
      cmd_parameters_lst = params_for_queue_tester(action_name)
      params.each do |attribute, value|
        if (attribute.to_s[0..6] == 'engine_')
          engine = attribute.to_s[7..-1]
          ([ (action_name == 'enqueue') ? params[:nbr_enqueuers].to_i : ((action_name == 'dequeue') ? params[:nbr_dequeuers].to_i : 1), 1 ].max).times do |idx|
            exec_queue_tester engine, action_name, cmd_parameters_lst.join(' ')
            count += 1
          end
        end
      end
    end
    flash[:notice] = "Launched #{count} Queue testers correctly"

    redirect_to operations_path
  end

  private

  # Exec queue tester
  #
  # Parameters:
  # * *engine* (_String_): Engine
  # * *action* (_String_): Action
  # * *params* (_String_): Parameters to give to the queue tester
  def exec_queue_tester(engine, action, params)
    cmd = "bundle exec ruby -Ilib bin/run.rb --engine #{engine} --action #{action} #{params} 2>&1 >output_#{engine}_#{action}_#{@queue_tester_run_idx}.log"
    @queue_tester_run_idx += 1
    prev_dir = Dir.getwd
    Rails.logger.info "Spawning '#{cmd}' ..."
    Dir.chdir(QUEUE_TESTER_PATH)
    Bundler.with_clean_env { Kernel.spawn(cmd) }
    Dir.chdir(prev_dir)
  end

  # Construct parameters list based on action and parameters given
  #
  # Parameters:
  # * *action* (_String_): Action
  # Return:
  # * <em>list<String></em>: The list of parameters to give Queue Tester
  def params_for_queue_tester(action)
    cmd_parameters_lst = []

    #cmd_parameters_lst << '--debug'
    case action
    when 'enqueue'
      cmd_parameters_lst << "--max_enqueue_nbr #{params[:max_enqueue_nbr]}" if ((params[:max_enqueue_nbr] != nil) and (!params[:max_enqueue_nbr].empty?))
      cmd_parameters_lst << "--enqueue_times #{params[:enqueue_times]}" if ((params[:enqueue_times] != nil) and (!params[:enqueue_times].empty?))
      cmd_parameters_lst << "--fromid #{params[:fromid]}" if ((params[:fromid] != nil) and (!params[:fromid].empty?))
      cmd_parameters_lst << "--toid #{params[:toid]}" if ((params[:toid] != nil) and (!params[:toid].empty?))
    when 'dequeue'
      cmd_parameters_lst << "--dequeue_nbr #{params[:dequeue_nbr]}" if ((params[:dequeue_nbr] != nil) and (!params[:dequeue_nbr].empty?))
    end

    return cmd_parameters_lst
  end

end
