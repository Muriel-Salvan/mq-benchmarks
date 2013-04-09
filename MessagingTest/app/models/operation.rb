class Operation < ActiveRecord::Base
  attr_accessible :action, :begin_time, :end_time, :engine, :nbr_messages
end
