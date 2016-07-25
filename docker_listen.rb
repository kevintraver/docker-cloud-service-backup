require 'docker_cloud'
require 'git'
require 'rest-client'
require 'yaml'

@repo_dir = ENV['REPO_DIR']
@repo_name = ENV['REPO_NAME']
@repo_full_path = @repo_dir + @repo_name

if Dir.exists?(@repo_full_path)
  repo = Git.open(@repo_full_path, :log => Logger.new(STDOUT))
else
  FileUtils.mkdir_p @repo_full_path
  repo = Git.clone(ENV['REPO_URL'], @repo_name, :path => @repo_dir, :log => Logger.new(STDOUT))
end

repo.config('user.name', ENV['GIT_REPO_USERNAME'])
repo.config('user.email', ENV['GIT_REPO_EMAIL'])

FileUtils.mkdir_p @repo_full_path + '/config'

client = DockerCloud::Client.new(ENV['DOCKER_CLOUD_USERNAME'], ENV['DOCKER_CLOUD_API_KEY'])
headers = { 'Authorization' => "Basic #{Base64.strict_encode64(ENV['DOCKER_CLOUD_USERNAME'] + ':' + ENV['DOCKER_CLOUD_API_KEY'])}", 'Accept' => 'application/json', 'Content-Type' => 'application/json' }

events = client.events

@base_url = "https://cloud.docker.com/"
puts @base_url

events.on(:message) do |event|
  puts event
  uri = @base_url + event.resource_uri
  response = JSON.parse(RestClient.get(uri, headers))
  if event.type == "service" && event.action == "update"
    service = client.services.get(response["uuid"])
    if stack = service.stack
      File.open(@repo_full_path + "/config/#{stack.name}.yaml","w") do |f|
        f.write(stack.export.to_yaml)
      end
      repo.add(:all=>true)
      repo.commit("#{stack.name} updated")
      repo.push
    end
  end

end

if __FILE__ == $0
  events.run!
end
