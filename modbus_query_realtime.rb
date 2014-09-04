require 'rmodbus'
require 'rrd'

RRD_FILE     = 'ts-mppt-60.rrd'
adc_vb_f     = nil  #voltage battery, filtered
adc_va_f     = nil  #voltage array, filtered
adc_ib_f     = nil  #current battery
adc_ia_f     = nil  #current array
power_out    = nil  #output power (Watts)
power_in     = nil  #array input power (Watts)
t_hs         = nil  #Heatsink temperature
t_batt       = nil  #battery temp
charge_state = nil  #charger charging state

## Charging states:
#  0: Start
#  1: Night check
#  2: Disconnect
#  3: Night
#  4: Fault
#  5: MPPT
#  6: Absorption
#  7: Float
#  8: Equalize
#  9: Slave



rrd = RRD::Base.new(RRD_FILE)

unless File.exist?(RRD_FILE)
  # Creating a new rrd
  rrd = RRD::Base.new(RRD_FILE)
  rrd.create :start => Time.now - 10.seconds, :step => 1.minute do
    datasource 'adc_vb_f', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 'adc_va_f', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 'adc_ib_f', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 'adc_ia_f', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 'power_out', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 'power_in', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 't_hs', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 't_batt', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited
    datasource 'charge_state', :type => :gauge, :heartbeat => 1.minute, :min => 0, :max => :unlimited

    archive :average, :every => 1.minutes, :during => 1.year
    archive :average, :every => 5.minutes, :during => 5.years
    archive :average, :every => 1.hour, :during => 100.years
  end

end

ModBus::TCPClient.new('192.168.1.253', 502) do |cl|
  cl.with_slave(1) do |slave|
    # Read all the holding registers we care about, convert from hex and scale
    adc_vb_f = ( (slave.holding_registers[25].to_i(16) * 180) * (2**-15) )
    adc_va_f = ( (slave.holding_registers[28].to_i(16) * 180) * (2**-15) )
    adc_ib_f = ( (slave.holding_registers[29].to_i(16) * 80) * (2**-15) )
    adc_ia_f = ( (slave.holding_registers[30].to_i(16) * 80) * (2**-15) )

    # these numbers require no scaling, only hex to decimal
    power_out = slave.holding_registers[59].to_i(16)
    power_in = slave.holding_registers[60].to_i(16)
    charge_state = slave.holding_registers[51].to_i(16)

  end
end

puts "Vb: #{adc_vb_f}V battery voltage, filtered"
puts "Va: #{adc_va_f}V solar input voltage, filtered"
puts "Ib: #{adc_ib_f}A battery charge current, filtered. "
puts "Ia: #{adc_ia_f}A solar input current, filtered (+/- 20%). "
puts "Power_out: #{power_out}W Charge output power."
puts "Power_in: #{power_in}W Array input power (+/- 20%). "
case charge_state
  when 0
    puts "Charge state: START"
  when 1
    puts "Charge state: NIGHT_CHECK"
  when 2
    puts "Charge state: DISCONNECT"
  when 3
    puts "Charge state: NIGHT"
  when 4
    puts "Charge state: FAULT"
  when 5
    puts "Charge state: MPPT"
  when 6
    puts "Charge state: ABSORPTION"
  when 7
    puts "Charge state: FLOAT"
  when 8
    puts "Charge state: EQUALIZE"
  when 9
    puts "Charge state: SLAVE"
  else
    puts "Charge state: UNKNOWN"
end
puts "T_hs: #{t_hs}C Heatsink Temperature. "
puts "T_batt: #{t_batt}C Battery Temperature. "


#rrd.update Time.now, adc_vb_f, adc_va_f, adc_ib_f, adc_ia_f, power_out, power_in, t_hs, t_batt, charge_state
