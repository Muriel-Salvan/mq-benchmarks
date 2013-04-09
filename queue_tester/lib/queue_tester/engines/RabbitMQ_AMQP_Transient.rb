require 'amqp'

module QueueTester

  module Engines

    class RabbitMQ_AMQP_Transient

      include Interfaces::AMQP

      def enqueue(messages)
        enqueue_amqp(
          :host => '127.0.0.1',
          :port => 5672,
          :username => 'guest',
          :password => 'guest',
          :queue => 'rabbitmq_amqp_queue_transient',
          :messages => messages,
          :transient => true
        )
      end

      def dequeue(number)
        return dequeue_amqp(
          :host => '127.0.0.1',
          :port => 5672,
          :username => 'guest',
          :password => 'guest',
          :queue => 'rabbitmq_amqp_queue_transient',
          :number => number,
          :transient => true
        )
      end

      def flush
        return flush_amqp(
          :host => '127.0.0.1',
          :port => 5672,
          :username => 'guest',
          :password => 'guest',
          :queue => 'rabbitmq_amqp_queue_transient',
          :transient => true
        )
      end

    end

  end

end
