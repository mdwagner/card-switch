require "pigpio"

class CardSwitch
  include Pigpio

  enum Board
    Type1
    Type2
    Type3
  end

  getter! handle : UInt32?

  def main
    puts "pigpio: v#{LibPigpio.gpio_version}-#{revision}"

    if LibPigpio.gpio_init < 0
      raise "Failed to initialize pigpio"
    end

    i2c_bus = 1
    i2c_addr = 0x00 # i2c addr (can be found with: i2cdetect -y 1)
    i2c_flags = 0

    if (h = LibPigpio.i2c_open(i2c_bus, i2c_addr, i2c_flags)) >= 0
      @handle = h.to_u
    else
      raise "Failed to open i2c device"
    end

    puts "Handle: #{handle}"

    if (byte = LibPigpio.i2c_read_byte(handle)) >= 0
      start_bit = byte.bit(0)
      addr_bit = byte.bits(1..7)
      read_bit = byte.bit(8)
      accept_bit = byte.bit(9)
      data_bit = byte.bits(10..17)
      not_accept_bit = byte.bit(18)
      stop_bit = byte.bit(19)

      puts "Byte: #{byte.to_s(2, precision: 32)}"
    else
      raise "Failed to read i2c device"
    end
  ensure
    LibPigpio.i2c_close(handle) if handle?
    LibPigpio.gpio_terminate
  end

  def revision
    case get_hardware_revision
    in .type1?
      "1"
    in .type2?
      "2"
    in .type3?
      "3"
    end
  end

  private def get_hardware_revision
    case revision = LibPigpio.gpio_hardware_revision
    when 2, 3
      Board::Type1
    when 4, 5, 6, 15
      Board::Type2
    when 16..
      Board::Type3
    else
      raise "Hardware revision not found"
    end
  end
end

CardSwitch.new.main
