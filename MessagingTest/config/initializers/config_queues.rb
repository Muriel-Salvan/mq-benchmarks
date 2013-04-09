QUEUE_TESTER_PATH = File.expand_path("#{Rails.root}/../queue_tester")

ENGINES_LST = Dir.glob("#{QUEUE_TESTER_PATH}/lib/queue_tester/engines/*.rb").sort.map do |file_name|
  File.basename(file_name)[0..-4]
end
