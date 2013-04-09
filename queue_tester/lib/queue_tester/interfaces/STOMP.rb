require 'stomp'

module QueueTester

  module Interfaces

    module STOMP

      def enqueue_stomp(options)
        client = Stomp::Client.new options[:username], options[:password], options[:host], options[:port], true

        client.begin('enqueue')
        options[:messages].each do |message|
          log_debug "[STOMP] Publish message #{message}"
          client.publish options[:queue], message, :persistent => (options[:transient] != true)
          progress(1)
        end
        client.commit('enqueue')

        client.close
      end

      def dequeue_stomp(options)
        messages = []

        client = Stomp::Client.new options[:username], options[:password], options[:host], options[:port], true
        client.begin('dequeue')
        client.subscribe options[:queue], :ack => :client do |message|
          if (messages.size < options[:number])
            log_debug "[STOMP] Received message #{message}"
            messages << message.body
            client.acknowledge(message)
            progress(1)
          end
          if (messages.size == options[:number])
            client.commit('dequeue')
            client.close
          end
        end
        client.join
        client.close

        return messages
      end

      def flush_stomp(options)
        client = Stomp::Client.new options[:username], options[:password], options[:host], options[:port], true
        client.begin('flush')
        last_message_at = Time.now
        Thread.new do
          while (Time.now - last_message_at < 5)
            sleep 1
          end
          log_debug '[STOMP] Flush performed.'
          client.commit('flush')
          client.close
        end
        client.subscribe options[:queue] do |message|
          last_message_at = Time.now
        end
        client.join

        progress(1)
      end

    end

  end

end
