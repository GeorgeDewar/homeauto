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

    message = messages_for(devices).first
    return head :no_content if !message

    puts message.inspect

    content = message.to_raw
    puts content

    message.sent_at = Time.now
    message.save

    render :text => content
  end

  protected

  def messages_for(devices)
    Message.where({ :sent_at => nil })
  end

end
