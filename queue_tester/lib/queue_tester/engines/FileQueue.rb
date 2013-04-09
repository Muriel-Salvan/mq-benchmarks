require 'fileutils'
require 'lockfile'

module QueueTester

  module Engines

    class FileQueue

      def enqueue(messages)
        FileUtils::mkdir_p 'filequeue'
        change_dir('filequeue') do
          lock do
            queue_content = (::File.exists?('FileQueue')) ? Marshal.load(::File.read('FileQueue')) : []
            queue_content.concat(messages)
            ::File.open('FileQueue','wb') do |file|
              file.write(Marshal.dump(queue_content))
            end
          end
          progress(messages.size)
        end
      end

      def dequeue(number)
        messages = []

        FileUtils::mkdir_p 'filequeue'
        change_dir('filequeue') do
          while (messages.size < number)
            retrieved_messages = nil
            lock do
              queue_content = (::File.exists?('FileQueue')) ? Marshal.load(::File.read('FileQueue')) : []
              retrieved_messages = queue_content[0..number-1]
              ::File.open('FileQueue','wb') do |file|
                file.write(Marshal.dump((queue_content[number..-1] == nil) ? [] : queue_content[number..-1]))
              end
            end
            messages.concat(retrieved_messages)
            progress(retrieved_messages.count)
            sleep 1 if (messages.size < number)
          end
        end

        return messages
      end

      def flush
        FileUtils::mkdir_p 'filequeue'
        change_dir('filequeue') do
          lock do
            File::unlink('FileQueue') if File.exist?('FileQueue')
          end
          progress(1)
        end
      end

      private

      def lock
        File.open('lock.lock','w') do |f|
          f.flock(File::LOCK_EX)
          yield
        end
      end

    end

  end

end
