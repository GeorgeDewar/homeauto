class Message < ActiveRecord::Base
  belongs_to :device

  def to_raw
    'IF' + FujitsuAC.generate(JSON.parse(message, symbolize_names: true))
  end

end
