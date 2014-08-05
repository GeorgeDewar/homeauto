class ControlController < ApplicationController



  def index

  end

  def new_message

    if params[:device] = 'H'
      temp = params[:temperature]
      mode = params[:mode]
      fan = params[:fan]
      code = FujitsuAC.generate(temp.to_i, ac.modes[mode.to_i], ac.fan_settings[fan.to_i])
      message = Message.new created_at: Time.now, message: {device: 'IF', message: code}.to_json
      message.save
    end

    redirect_to '/?OK'
  end

end
