require 'amqp'

module QueueTester

  module Engines

    class Apollo_AMQP

      # NEEDS AMQP 1.0

      include Interfaces::AMQP

      def enqueue(messages)
        enqueue_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_amqp_queue',
          :messages => messages
        )
      end

      def dequeue(number)
        return dequeue_amqp(
          :host => '127.0.0.1',
          :port => 5673,
          :username => 'admin',
          :password => 'password',
          :queue => '/queue/apollo_amqp_queue',
          :number => number
        )
      end

    end

  end

end
