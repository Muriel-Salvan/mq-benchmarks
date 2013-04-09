#!env ruby
#--
# Copyright (c) 2013 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# This file is just a simple listener, created to test ZeroMQ API.
# It is not the broker itself. Use run.rb to run the broker.

require 'ffi-rzmq'

def error_check(rc)
  if ZMQ::Util.resultcode_ok?(rc)
    false
  else
    STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    caller(1).each { |callstack| STDERR.puts(callstack) }
    true
  end
end

messages = []

context = ZMQ::Context.new 1
receiver = context.socket ZMQ::PULL
error_check(receiver.setsockopt(ZMQ::LINGER, 0))
sleep 3
error_check(receiver.connect('tcp://127.0.0.1:5555'))
quit = false
puts '[0MQ] Listening ...'
message = ''
rc = 0
while ((!quit) and ZMQ::Util.resultcode_ok?(rc))
  rc = receiver.recv_string(message)
  puts "[0MQ] Received message #{message}"
  messages << message
  quit = (message == 'CLOSE')
end
error_check(receiver.close)
