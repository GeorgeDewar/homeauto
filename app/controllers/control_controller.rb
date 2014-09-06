class ControlController < ApplicationController

  def index
    @devices = Device.all
    @tasks = Task.all
  end

  def new_message
    device = Device.find(params[:device])
    message_content = device.attributes.keys.map { |x| { x => params[x] } }.reduce(:merge)
    message = Message.new(device: device, message: message_content.to_json)
    message.save!

    redirect_to '/?OK'
  end

end
