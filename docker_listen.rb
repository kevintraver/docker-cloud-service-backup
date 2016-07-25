require 'docker_cloud'
require 'rest-client'

client = DockerCloud::Client.new(ENV['DOCKER_CLOUD_USERNAME'], ENV['DOCKER_CLOUD_API_KEY'])
events = client.events


# Event listeners
events.on(:message) do |event|
  uri = "https://cloud.docker.com/" + event.resource_uri
  headers = { 'Authorization' => "Basic #{Base64.strict_encode64(ENV['DOCKER_CLOUD_USERNAME'] + ':' + ENV['DOCKER_CLOUD_API_KEY'])}", 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
  response = JSON.parse(RestClient.get(uri, headers))
  File.open("responses/#{event.uuid}.json","w") do |f|
    details = {type: event.type, action: event.action, parents: event.parents, state: event.state}
    f.write(JSON.pretty_generate(details) + "\n")
    f.write(JSON.pretty_generate(response))
  end

end

events.run!
