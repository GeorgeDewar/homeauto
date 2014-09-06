class Device < ActiveRecord::Base
  has_many :tasks
  has_many :messages

  def last_state
    messages.last ? JSON.parse(messages.last.message, symbolize_names: true) : defaults
  end

  def defaults
    return FujitsuAC.defaults if definition == 'FujitsuAC'
    return {:state => :on} if definition == 'WattsClever'
    raise "Unknown definition: #{definition}"
  end

  def encode_message(message)
    puts message.inspect
    puts self.inspect
    case definition
      when 'FujitsuAC'
        return 'IF' + FujitsuAC.generate(message)
      when 'WattsClever'
        return 'RS' + JSON.parse(properties, symbolize_names: true)[message[:state].to_sym]
      else
        raise "Unknown definition: #{definition}"
    end
  end

  def attributes
    fuj_attributes = {
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
    sw_attributes = {
        :state => OpenStruct.new({
           name: 'State',
           type: :discrete,
           role: :command,
           horizontal: true,
           options: [:on, :off]
        })
    }

    definition == 'FujitsuAC' ? fuj_attributes : sw_attributes
  end

end
