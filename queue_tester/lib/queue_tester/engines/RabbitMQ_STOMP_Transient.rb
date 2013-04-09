require 'stomp'

module QueueTester

  module Engines

    class RabbitMQ_STOMP_Transient

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61613,
          :username => 'guest',
          :password => 'guest',
          :queue => '/queue/rabbitmq_stomp_queue_transient',
          :messages => messages,
          :transient => true
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61613,
          :username => 'guest',
          :password => 'guest',
          :queue => '/queue/rabbitmq_stomp_queue_transient',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61613,
          :username => 'guest',
          :password => 'guest',
          :queue => '/queue/rabbitmq_stomp_queue_transient'
        )
      end

    end

  end

end
