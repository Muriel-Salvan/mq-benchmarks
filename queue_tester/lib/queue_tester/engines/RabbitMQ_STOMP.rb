require 'stomp'

module QueueTester

  module Engines

    class RabbitMQ_STOMP

      include Interfaces::STOMP

      def enqueue(messages)
        enqueue_stomp(
          :host => 'localhost',
          :port => 61613,
          :username => 'guest',
          :password => 'guest',
          :queue => '/queue/rabbitmq_stomp_queue',
          :messages => messages
        )
      end

      def dequeue(number)
        return dequeue_stomp(
          :host => 'localhost',
          :port => 61613,
          :username => 'guest',
          :password => 'guest',
          :queue => '/queue/rabbitmq_stomp_queue',
          :number => number
        )
      end

      def flush
        return flush_stomp(
          :host => 'localhost',
          :port => 61613,
          :username => 'guest',
          :password => 'guest',
          :queue => '/queue/rabbitmq_stomp_queue'
        )
      end

    end

  end

end
