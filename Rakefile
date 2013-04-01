require 'rake/testtask'

task :default => [ :run ]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :run do
	sh "rbx -X19 mud/mudpunk.rb"
end
