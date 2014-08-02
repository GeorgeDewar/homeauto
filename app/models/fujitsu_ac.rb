class FujitsuAC
  BASE = '1463001010FE0930410400000000206B' # 20 degrees, heat
  TEMP_OFFSET = 16

  TEMP_MIN = 16, TEMP_MAX = 30

  MODES = [:auto, :cool, :dry, :fan, :heat]
  FAN_SETTINGS = [:auto, :high, :med, :low, :quiet]

  def self.modes
    MODES
  end

  def self.fan_settings
    FAN_SETTINGS
  end

  def generate(temp, mode=:auto, fan=:auto)
    temp_val = temp - TEMP_OFFSET
    mode_val = MODES.index mode
    fan_val = FAN_SETTINGS.index fan

    code = BASE
    code[16] = temp_val.to_s(16)
    code[19] = mode_val.to_s(16)
    code[21] = fan_val.to_s(16)
    code[30..31] = generate_checksum code[16..29]

    code.upcase
  end

protected

  def generate_checksum(code)
    bytes = code.scan(/.{2}/)
    numbers = bytes.map { |byte| byte.to_i(16) }
    sum = numbers.inject { |sum, x| sum + x }
    "%02x" % ((208 - sum) % 256)
  end

end