require 'stomp'

module QueueTester

  module Engines

    class Apollo_STOMP

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61617,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_stomp_queue',
          :messages => messages
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61617,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_stomp_queue',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61617,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_stomp_queue'
        )
      end

    end

  end

end
