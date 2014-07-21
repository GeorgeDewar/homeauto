class ArduinoController < ApplicationController

  #NO_CONTENT = 204
  POLL_TIMEOUT = 10 # seconds
  CHECK_INTERVAL = 0.5 # seconds

  def messages
    devices = params[:devices].split ','
    i = 0.0
    while messages_for(devices).empty? && i < POLL_TIMEOUT do
      sleep CHECK_INTERVAL if params[:long]
      i += CHECK_INTERVAL
    end

    messages = messages_for(devices)
    return head :no_content if messages.empty?

    messages.each do |m|
      m.sent_at = Time.now
      m.save
    end
    content = messages.map { |m| JSON.parse(m.message) }
    content = content.map { |m| "#{m['device']}#{m['message']}" }.join ' '
    puts content
    render :text => content
  end

  protected

  def messages_for(devices)
    Message.where({ :sent_at => nil })
  end

end
