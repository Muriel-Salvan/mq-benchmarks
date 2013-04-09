module ApplicationHelper

  # Return an elapsed time in human readable format
  #
  # Parameters:
  # * *time* (_String_): String representation of the time
  # Return:
  # * _String_: Human readable form
  def format_elapsed(time)
    return (time.to_f/1000000).to_s
    # time_str_lst = []

    # real_time = Time.at(time.to_f/1000000).utc
    # time_str_lst << "#{real_time.hour}h" if real_time.hour > 0
    # time_str_lst << "#{real_time.min}m" if real_time.min > 0
    # time_str_lst << "#{real_time.sec}.#{sprintf('%.3d', ((real_time.to_f - real_time.to_i)*1000).to_i)}s"

    # return time_str_lst.join(' ')
  end

end
