class ControlController < ApplicationController

  def index

  end

  def new_message
    message = Message.new created_at: Time.now, message: {device: params[:device], message: params[:message]}.to_json
    message.save
    redirect_to '/?OK'
  end

end
