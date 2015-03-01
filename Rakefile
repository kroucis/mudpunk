require 'rake/testtask'

task :default => [ :run ]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :run do
	# if sh 'which rbx' and /1\.9/.match(`rbx --version`)
 #        sh "rbx -X19 mud/mudpunk.rb"
 #    else
        sh "ruby mud/mudpunk.rb"
    # end
end
