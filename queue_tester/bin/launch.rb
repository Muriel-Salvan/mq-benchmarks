# This file launches enqueuers and dequeuers in an automated way.
# It is not used by the Rails application.
# Can be invoked by command line: results will still be updated in the Rails application.
# Adapt to your needs.

QUEUE_TESTER_PATH = File.expand_path("#{File.dirname(__FILE__)}/..")

ENGINES_LST = Dir.glob("#{QUEUE_TESTER_PATH}/lib/queue_tester/engines/*.rb").map do |file_name|
  File.basename(file_name)[0..-4]
end
ENGINES_TRANSIENT_LST = Dir.glob("#{QUEUE_TESTER_PATH}/lib/queue_tester/engines/*_Transient.rb").map do |file_name|
  File.basename(file_name)[0..-4]
end

(ENGINES_LST).sort.each do |engine|
  puts "===== Engine #{engine}"
  system("ruby -Ilib bin\\run.rb --action flush --engine #{engine}")
  [
    Kernel.spawn("ruby -Ilib bin\\run.rb --action enqueue --max_enqueue_nbr 10 --enqueue_times 20 --engine #{engine}"),
    Kernel.spawn("ruby -Ilib bin\\run.rb --action dequeue --dequeue_nbr 200 --engine #{engine}")
  ].each { |p| Process.wait(p) }
  # system("ruby -Ilib bin\\run.rb --action enqueue --max_enqueue_nbr 10 --enqueue_times 2000 --engine #{engine}")
  # system("ruby -Ilib bin\\run.rb --action dequeue --dequeue_nbr 20000 --engine #{engine}")
  puts '====='
  puts
end
