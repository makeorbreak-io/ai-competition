require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.inflector.inflect("job_aws" => "JobAWS")
loader.push_dir(File.join(__dir__, "../lib"))
loader.setup
