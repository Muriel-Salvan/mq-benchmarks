require 'ffi-rzmq'

module QueueTester

  module Engines

    class ZeroMQ_Transient

      def enqueue(messages)
        context = ZMQ::Context.new 1
        requester = context.socket ZMQ::PUSH
        error_check(requester.connect('tcp://127.0.0.1:5555'))
        log_debug '[0MQ] Connected to broker'
        messages.each do |message|
          error_check(requester.send_string("ENQU#{message}"))
          progress(1)
        end
        log_debug '[0MQ] Sent'
        error_check(requester.close)
      end

      def dequeue(number)
        messages = []

        context = ZMQ::Context.new 1
        # Setup listening port
        port = 5556
        receiver = context.socket ZMQ::PULL
        while error_check(receiver.bind("tcp://127.0.0.1:#{port}"))
          port += 1
          log_debug "[0MQ] Failed to bind on port #{port}. Trying further."
        end
        log_debug "[0MQ] Listening on port #{port}..."
        # Create thread to inform broker
        broker_thread = Thread.new do
          requester = context.socket ZMQ::PUSH
          error_check(requester.connect('tcp://127.0.0.1:5555'))
          log_debug '[0MQ] Connected to broker'
          error_check(requester.send_string("SUBS[#{port},#{number}]"))
          log_debug "[0MQ] Sent subscription [#{port},#{number}]"
          error_check(requester.close)
        end
        number.times do |idx|
          message = ''
          error_check(receiver.recv_string(message))
          log_debug "[0MQ] Received message #{message}"
          messages << message
          progress(1)
        end
        error_check(receiver.close)
        broker_thread.join

        return messages
      end

      def flush
        context = ZMQ::Context.new 1
        requester = context.socket ZMQ::PUSH
        error_check(requester.connect('tcp://127.0.0.1:5555'))
        log_debug '[0MQ] Connected to broker'
        error_check(requester.send_string("FLUS"))
        log_debug '[0MQ] Sent'
        error_check(requester.close)
        progress(1)
      end

      private

      def error_check(rc)
        if ZMQ::Util.resultcode_ok?(rc)
          false
        else
          STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
          caller(1).each { |callstack| STDERR.puts(callstack) }
          true
        end
      end

    end

  end

end
