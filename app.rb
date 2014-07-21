require 'sinatra'
require './common.rb'
require './fujitsu_ac.rb'

NO_CONTENT = 204
POLL_TIMEOUT = 10 # seconds
CHECK_INTERVAL = 0.5 # seconds

after { ActiveRecord::Base.connection.close }

def messages_for(devices)
  Message.where({ :sent_at => nil })
end

get '/' do
  @messages = Message.where({ :acknowledged_at => nil })
  erb :index
end

post '/' do
  message = Message.new created_at: Time.now, message: {device: params[:device], message: params[:message]}.to_json
  message.save
  redirect '/?OK'
end

i = 0

get '/get' do
  devices = params[:devices].split ','
  i = 0.0
  while messages_for(devices).empty? && i < POLL_TIMEOUT do
    sleep CHECK_INTERVAL if params[:long]
    i += CHECK_INTERVAL
  end

  messages = messages_for(devices)
  return NO_CONTENT if messages.empty?

  messages.each do |m|
    m.sent_at = Time.now
    m.save
  end
  content = messages.map { |m| JSON.parse(m.message) }
  content = content.map { |m| "#{m['device']}#{m['message']}" }.join ' '
  puts content
  content
end

