require 'amqp'

module QueueTester

  module Engines

    class QPID_AMQP_Transient

      include Interfaces::AMQP

      def enqueue(messages)
        enqueue_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'admin',
          :queue => 'qpid_amqp_queue_transient',
          :messages => messages,
          :transient => true
        )
      end

      def dequeue(number)
        return dequeue_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'admin',
          :queue => 'qpid_amqp_queue_transient',
          :number => number,
          :transient => true
        )
      end

      def flush
        flush_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'admin',
          :queue => 'qpid_amqp_queue_transient',
          :transient => true
        )
      end

    end

  end

end
