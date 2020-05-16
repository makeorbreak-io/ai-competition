require "sinatra/base"

module Web
  class Server < Sinatra::Application
    def authorization_token(request)
      /Bearer (.*)/.match(request.env["HTTP_AUTHORIZATION"])&.[](1)
    end

    before do
      halt 403 unless authorization_token(request) == ENV.fetch("AUTHORIZATION_TOKEN")

      content_type 'application/json'
    end

    post "/jobs" do
      job = Job.from_http(request.body.read)

      Job.enqueue(job)

      [201, job.to_json]
    end

    get "/jobs/:id" do
      job_id = params[:id]

      [200, Job.fetch(job_id)]
    rescue Job::NotFound
      404
    end
  end
end
