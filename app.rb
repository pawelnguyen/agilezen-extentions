require 'sinatra'
require 'sinatra/json'
require_relative 'lib/agilezen'

get '/:project_id/overflows/:api_key' do
  json Agilezen.overflows(params[:project_id], params[:api_key])
end

