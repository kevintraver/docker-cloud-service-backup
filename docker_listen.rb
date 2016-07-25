require 'docker_cloud'
require 'rest-client'

client = DockerCloud::Client.new(ENV['DOCKER_CLOUD_USERNAME'], ENV['DOCKER_CLOUD_API_KEY'])
headers = { 'Authorization' => "Basic #{Base64.strict_encode64(ENV['DOCKER_CLOUD_USERNAME'] + ':' + ENV['DOCKER_CLOUD_API_KEY'])}", 'Accept' => 'application/json', 'Content-Type' => 'application/json' }

events = client.events

@base_url = "https://cloud.docker.com/"

# Event listeners
events.on(:message) do |event|
  uri = @base_url + event.resource_uri
  response = JSON.parse(RestClient.get(uri, headers))
  if event.type == "service" && event.action == "update"
    # File.open("responses/#{event.uuid}.json","w") do |f|
    #   details = {type: event.type, action: event.action, parents: event.parents, state: event.state}
    #   f.write(JSON.pretty_generate(details) + "\n")
    #   f.write(JSON.pretty_generate(response))
    # end
    service = client.services.get(response["uuid"])
    if stack = service.stack
      File.open("config/#{stack.name}.yaml","w") do |f|
        f.write(stack.export.to_yaml)
      end
    end
  end


end

events.run!
