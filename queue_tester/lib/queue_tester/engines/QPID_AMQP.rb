require 'amqp'

module QueueTester

  module Engines

    class QPID_AMQP

      include Interfaces::AMQP

      def enqueue(messages)
        enqueue_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'admin',
          :queue => 'qpid_amqp_queue',
          :messages => messages
        )
      end

      def dequeue(number)
        return dequeue_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'admin',
          :queue => 'qpid_amqp_queue',
          :number => number
        )
      end

      def flush
        flush_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'admin',
          :queue => 'qpid_amqp_queue'
        )
      end

    end

  end

end
