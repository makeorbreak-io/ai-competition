require File.join(__dir__, "../test_helper")
require "rack/test"

module Web
  class ServerTest < Minitest::Test
    include Rack::Test::Methods

    def app
      Web::Server
    end

    def test_non_existing_job
      get "/jobs/1234", {}, { "HTTP_AUTHORIZATION" => "Bearer potato" }

      assert_equal 404, last_response.status
    end

    def test_submit_new_job
      params = {
        type: "bomberman.match",
        payload: {
          players: [],
          state: "1\nw",
        },
        callback: {
          url: "https://consumer.example/job-completion",
          authorization: "your-secret-token",
        }
      }

      post(
        "/jobs",
        params.to_json,
        {
          "HTTP_AUTHORIZATION" => "Bearer potato",
          "HTTP_CONTENT_TYPE" => "application/json",
        },
      )

      assert_equal 201, last_response.status
      assert_includes JSON.parse(last_response.body).keys, "id"

      id = JSON.parse(last_response.body)["id"]
      job = Web::Job.fetch(id)

      assert_equal params[:type], job[:type]
      assert_equal params[:callback], job[:callback]
      assert_equal params[:payload], job[:payload]
    end
  end
end
