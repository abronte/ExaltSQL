require "yaml"
require "sinatra"
require "presto-client"
require_relative "lib/result_set"
require_relative "lib/query"
require_relative "lib/job_manager"

$config = YAML.load_file("config.yml")
$presto = Presto::Client.new($config[:presto])

set :public_folder, Proc.new { File.join(root, "static") }
set :views, Proc.new { File.join(root, "templates") }

get "/" do
  erb :index
end

post "/run" do
  $result_sets = []
  payload = JSON.parse(request.body.read)
  puts payload

  JobManager.run(payload)

  {result: "OK"}.to_json
end

get "/check" do
  output = {running: false}

  if JobManager.running?
    output[:running] = true
  elsif !JobManager.running?
    output = output.merge(JobManager.output)

    $result_sets.each do |rs|
      if rs.show_called
        output[:show] = {cols: rs.cols, rows: rs.rows}
      end
    end
  end

  output.to_json
end
