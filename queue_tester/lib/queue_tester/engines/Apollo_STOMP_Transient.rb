require 'stomp'

module QueueTester

  module Engines

    class Apollo_STOMP_Transient

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61617,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_stomp_queue_transient',
          :messages => messages,
          :transient => true
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61617,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_stomp_queue_transient',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61617,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_stomp_queue_transient'
        )
      end

    end

  end

end
