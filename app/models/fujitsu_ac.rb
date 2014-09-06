class FujitsuAC
  BASE = '1463001010FE0930410400000000206B' # 20 degrees, heat
  OFF  = '146300101002FD'
  TEMP_OFFSET = 16

  TEMP_MIN = 16, TEMP_MAX = 30

  DEFAULTS = { :state => :off, :temp => 21, :mode => :auto, :fan => :auto }
  MODES = [:auto, :cool, :dry, :fan, :heat]
  FAN_SETTINGS = [:auto, :high, :med, :low, :quiet]

  class << self

    def defaults
      DEFAULTS
    end

    def modes
      MODES
    end

    def fan_settings
      FAN_SETTINGS
    end

    def generate(options)
      case options[:state].to_sym
        when :on
          generate_on(options)
        when :off
          generate_off
        else
          raise 'Unknown value for state'
      end
    end

    def generate_on(options)
      temp_val = options[:temp].to_i - TEMP_OFFSET
      mode_val = MODES.index options[:mode].to_sym
      fan_val = FAN_SETTINGS.index options[:fan].to_sym

      code = BASE
      code[16] = temp_val.to_s(16)
      code[19] = mode_val.to_s(16)
      code[21] = fan_val.to_s(16)
      code[30..31] = generate_checksum code[16..29]

      code.upcase
    end

    def generate_off

    end

  protected

    def generate_checksum(code)
      bytes = code.scan(/.{2}/)
      numbers = bytes.map { |byte| byte.to_i(16) }
      sum = numbers.inject { |sum, x| sum + x }
      "%02x" % ((208 - sum) % 256)
    end
  end
end
