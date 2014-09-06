class Message < ActiveRecord::Base
  belongs_to :device

  def to_raw
    device.encode_message(JSON.parse(message, symbolize_names: true))
  end

end
