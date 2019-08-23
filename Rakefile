require "rake/testtask"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "lib"))
loader.setup

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.test_files = FileList["lib/**/*_test.rb"]
end

task :default => :test
