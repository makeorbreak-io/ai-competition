ENV["APP_ENV"] = "test"
ENV["AUTHORIZATION_TOKEN"] = "potato"
ENV["JOB_PROCESSOR"] = "file"

require File.join(__dir__, "main")

require "minitest/autorun"
