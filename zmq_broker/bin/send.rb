#!env ruby
#--
# Copyright (c) 2013 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# This file is just a simple publisher, created to test ZeroMQ API.
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

context = ZMQ::Context.new 1
requester = context.socket ZMQ::PUSH
error_check(requester.setsockopt(ZMQ::LINGER, 0))
error_check(requester.bind('tcp://127.0.0.1:5555'))
puts '[0MQ] Connected'
error_check(requester.send_string('CLOSE'))
puts '[0MQ] Sent'
error_check(requester.close)
