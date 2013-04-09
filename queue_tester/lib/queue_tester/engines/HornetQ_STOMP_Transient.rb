require 'stomp'

module QueueTester

  module Engines

    class HornetQ_STOMP_Transient

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61615,
          :username => 'guest',
          :password => 'guest',
          :queue => 'jms.queue.HornetqStompQueueTransient',
          :messages => messages,
          :transient => true
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61615,
          :username => 'guest',
          :password => 'guest',
          :queue => 'jms.queue.HornetqStompQueueTransient',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61615,
          :username => 'guest',
          :password => 'guest',
          :queue => 'jms.queue.HornetqStompQueueTransient'
        )
      end

    end

  end

end
