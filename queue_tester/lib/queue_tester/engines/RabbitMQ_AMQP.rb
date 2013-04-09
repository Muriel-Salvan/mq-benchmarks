require 'amqp'

module QueueTester

  module Engines

    class RabbitMQ_AMQP

      include Interfaces::AMQP

      def enqueue(messages)
        enqueue_amqp(
          :host => '127.0.0.1',
          :port => 5672,
          :username => 'guest',
          :password => 'guest',
          :queue => 'rabbitmq_amqp_queue',
          :messages => messages
        )
      end

      def dequeue(number)
        return dequeue_amqp(
          :host => '127.0.0.1',
          :port => 5672,
          :username => 'guest',
          :password => 'guest',
          :queue => 'rabbitmq_amqp_queue',
          :number => number
        )
      end

      def flush
        return flush_amqp(
          :host => '127.0.0.1',
          :port => 5672,
          :username => 'guest',
          :password => 'guest',
          :queue => 'rabbitmq_amqp_queue'
        )
      end

    end

  end

end
