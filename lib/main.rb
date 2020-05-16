require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("job_aws" => "JobAWS")
loader.ignore(File.join(__dir__, "**/*_test.rb"))
loader.setup
