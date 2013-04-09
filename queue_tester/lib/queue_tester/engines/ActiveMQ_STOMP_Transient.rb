require 'stomp'

module QueueTester

  module Engines

    class ActiveMQ_STOMP_Transient

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61614,
          :username => 'admin',
          :password => 'admin',
          :queue => 'activemq_stomp_queue_transient',
          :messages => messages,
          :transient => true
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61614,
          :username => 'admin',
          :password => 'admin',
          :queue => 'activemq_stomp_queue_transient',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61614,
          :username => 'admin',
          :password => 'admin',
          :queue => 'activemq_stomp_queue_transient'
        )
      end

    end

  end

end
