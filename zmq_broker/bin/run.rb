#!env ruby
#--
# Copyright (c) 2013 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Main file

require 'ffi-rzmq'
require 'monitor'

class InternalQueue

  def initialize
    @messages = []
    @lock = Monitor.new
  end

  def enqueue(messages_lst)
    @lock.synchronize do
      @messages.concat(messages_lst)
    end
  end

  def dequeue(number)
    messages_lst = []

    @lock.synchronize do
      messages_lst = @messages.shift(number)
    end

    return messages_lst
  end

  def empty
    messages_lst = []

    @lock.synchronize do
      messages_lst = @messages.clone
      @messages.replace([])
    end

    return messages_lst
  end

end

def error_check(rc)
  if ZMQ::Util.resultcode_ok?(rc)
    false
  else
    STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    caller(1).each { |callstack| STDERR.puts(callstack) }
    true
  end
end

messages = InternalQueue.new
subscribers = InternalQueue.new

context = ZMQ::Context.new 1
waiting_threads = []
@quit = false

# Thread that handles clients wanting messages
waiting_threads << Thread.new do
  while (!@quit)
    subscribers_lst = subscribers.empty
    subscribers_lst.each do |subscriber_str|
      waiting_threads << Thread.new do
        port, number = eval(subscriber_str)
        # Create a 0MQ push
        requester = context.socket ZMQ::PUSH
        error_check(requester.connect("tcp://127.0.0.1:#{port}"))
        puts "[0MQ] Connected to subscriber client on port #{port}"
        count = 0
        while (count < number)
          messages.dequeue(number).each do |message_to_send|
            error_check(requester.send_string(message_to_send))
            #puts "[0MQ] Sent message #{message_to_send}"
            count += 1
          end
          sleep 1
        end
        puts "[0MQ] Finished sending #{number} messages to subscriber on #{port}"
        error_check(requester.close)
      end
    end
    sleep 1
  end
end

receiver = context.socket ZMQ::PULL
error_check(receiver.bind('tcp://127.0.0.1:5555'))
puts '[0MQ] Listening ...'
rc = 0
while ((!@quit) and ZMQ::Util.resultcode_ok?(rc))
  message = ''
  rc = receiver.recv_string(message)
  case message[0..3]
  when 'ENQU'
    real_message = message[4..-1]
    #puts "[0MQ] Enqueuing message #{real_message} ..."
    messages.enqueue([real_message])
  when 'SUBS'
    puts "[0MQ] Received subscriber: #{message}"
    subscribers.enqueue([message[4..-1]])
  when 'FLUS'
    puts '[0MQ] Flushing ...'
    messages.empty
  when 'CLOS'
    puts '[0MQ] Closing ...'
    @quit = true
  else
    raise RuntimeError, "Unknown message: #{message}"
  end
end
error_check(receiver.close)

puts '[0MQ] Joining waiting threads ...'
waiting_threads.each do |thread|
  thread.join
end
