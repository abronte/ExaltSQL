require 'stringio'
require "yaml"
require "sinatra"
require "sinatra/reloader"
require "presto-client"
require_relative "lib/result_set"
require_relative "lib/query"

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

  b = binding

  eval(payload["code"], b)

  output = {}

  $result_sets.each do |rs|
    if rs.show_called
      output[:show] = {cols: rs.cols, rows: rs.rows}
    end
  end

  output.to_json
end
