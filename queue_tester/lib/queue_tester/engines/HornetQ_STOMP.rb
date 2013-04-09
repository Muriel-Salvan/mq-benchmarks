require 'stomp'

module QueueTester

  module Engines

    class HornetQ_STOMP

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61615,
          :username => 'guest',
          :password => 'guest',
          :queue => 'jms.queue.HornetqStompQueue',
          :messages => messages
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61615,
          :username => 'guest',
          :password => 'guest',
          :queue => 'jms.queue.HornetqStompQueue',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61615,
          :username => 'guest',
          :password => 'guest',
          :queue => 'jms.queue.HornetqStompQueue'
        )
      end

    end

  end

end
