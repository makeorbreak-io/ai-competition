## Web server

### Setup

Start by installing the dependencies and run the webserver

```shell
bundle install
bundle exec foreman start
# or:
# bundle exec bin/web
# bundle exec bin/worker
```

This runs the web server. It uses `dotenv`, so you can set the required configs
in `.env`. There's an `env.example` that should work for local development.

* `AUTHORIZATION_TOKEN`: Token for HTTP authentication, used to protect the
  endpoints of `bin/web`;
* `BASE_URL`: The base URL, with protocol and optional port, for the webserver.
  Used by `bin/submit-job`;
* `JOB_PROCESSOR`: `file` or `aws`. Determines what kind of queueing system
  we're using. `file` is very hacky and single consumer;
* `JOB_FILE_PATH`: Base path where the file processor stores job information,
  defaults to `"tmp"`;
* `JOB_QUEUE_REGION`: AWS region for the queue used by the aws processor;
* `JOB_QUEUE_URL`: AWS queue URL used by the aws processor;
* `JOB_STORAGE_BUCKET_NAME`: AWS bucket name used by the aws processor;
* `JOB_STORAGE_REGION`: AWS region for thebucket  used by the aws processor;


### API

The API is quite generic. It works with the concept of jobs. You can submit new
jobs and you can check the status of a job. In this edition, the only type of
job available is running a game match. In previous editions, you could compile
bots as a separate job type.

When you submit a job, you can specify a callback URL, and the server will
notify the URL when the job finishes (webhook style). You can also specify a
authorization token to be used when notifying the URL. You can add query
parameters to the specified callback URLs to be able to cross-reference your
identifiers with the job identifiers, in case you're unableto store them upon
creation.


#### Submitting a job

Here's an example of an HTTP request submitting a job. The types of jobs will
be specified below.

Request:

```
POST /jobs
Authorization: Bearer server-authorization-token
Content-Type: application/json
Accept: application/json

{
  "type": "bomberman.match",
  "payload": {"players":[],"state":"1\nw"},
  "callback": {
    "url": "https://consumer.example/job-completion",
    "authorization": "your-secret-authorization-token"
  }
}
```

Response:

```
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "70d77c52-20c7-4794-8af7-d30f4a39fc5b",
  "type": "bomberman.match",
  "payload": {"players":[],"state":"1\nw\n"},
  "callback": {
    "url": "https://consumer.example/job-completion?id=your-internal-id",
    "authorization": "your-secret-authorization-token"
  }
}
```

Webhook request:

```
POST /job-completion?id=your-internal-id
Host: consumer.example
Content-Type: application/json
Authorization: Bearer your-secret-authorization-token

{
  "id": "70d77c52-20c7-4794-8af7-d30f4a39fc5b"
}
```

Expected webhook response:

```
HTTP/1.1 200 OK
```

You can use `bin/submit-job` to submit a job via the API:

```
bundle exec bin/submit-job states/bomberman/example.txt scripts/bomberman/{fixed,example}.lua
```

It uses HTTParty to make the HTTP request. You can check out its source code if
you're having trouble implementing the API.


#### Querying a job

After you get a job identifier, you can check its status directly instead of
using webhooks.

Request:

```
GET /jobs/70d77c52-20c7-4794-8af7-d30f4a39fc5b
Authorization: Bearer server-authorization-token
Content-Type: application/json
Accept: application/json
```

Response:

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "type": "bomberman.match",
  "payload": {
    "players": [],
    "state": "1\nw\n"
  },
  "callback": {
    "url": "https://consumer.example/job-completion?id=your-internal-id",
    "authorization": "your-secret-authorization-token"
  },
  "id": "70d77c52-20c7-4794-8af7-d30f4a39fc5b",
  "results": [
    [
      null,
      "1\nw\n"
    ]
  ]
}
```


## Command line PvP

You can take a initial game state and two lua bots and run the full game with `bin/pvp`:

```shell
bundle exec bin/pvp states/bomberman/example.txt scripts/bomberman/{fixed,example}.lua
```
