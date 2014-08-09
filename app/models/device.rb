class Device < ActiveRecord::Base
  has_many :tasks
  has_many :messages

  def last_state
    messages.last ? JSON.parse(messages.last.message) : FujitsuAC.defaults
  end

  def attributes
    attributes = {
        :temp => OpenStruct.new({
            name: 'Temperature',
            type: :range,
            min: 16,
            max: 30
        }),
        :mode => OpenStruct.new({
            name: 'Mode',
            type: :discrete,
            options: FujitsuAC.modes
        }),
        :fan => OpenStruct.new({
            name: 'Fan',
            type: :discrete,
            options: FujitsuAC.fan_settings
        }),
        :state => OpenStruct.new({
            name: 'State',
            type: :discrete,
            role: :command,
            horizontal: true,
            options: [:on, :off]
        })
    }
    attributes
  end

end
