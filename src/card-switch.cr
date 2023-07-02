require "pigpio"

version = Pigpio::LibPigpio.gpio_version
puts "pigpio version: v#{version}"
