require 'rmodbus'
require 'rrd'

RRD_FILE     = 'ts-mppt-60_daily.rrd'

vb_min_daily = nil
vb_max_daily = nil
va_max_daily = nil
ahc_daily = nil
whc_daily = nil
pout_max_daily = nil
tb_min_daily = nil
tb_max_daily = nil
time_ab_daily = nil
time_eq_daily = nil
time_fl_daily = nil

rrd = RRD::Base.new(RRD_FILE)

unless File.exist?(RRD_FILE)
  # Creating a new rrd
  rrd = RRD::Base.new(RRD_FILE)
  rrd.create :start => Time.now - 10.seconds, :step => 1.day do
    datasource 'vb_min_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'vb_max_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'va_max_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'ahc_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'whc_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'pout_max_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'tb_min_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'tb_max_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'time_ab_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'time_eq_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited
    datasource 'time_fl_daily', :type => :gauge, :heartbeat => 1.day, :min => 0, :max => :unlimited

    archive :average, :every => 1.minutes, :during => 100.years
  end

end

ModBus::TCPClient.new('192.168.1.253', 502) do |cl|
  cl.with_slave(1) do |slave|
    # Read all the holding registers we care about, convert from hex and scale
    vb_min_daily = ( (slave.holding_registers[65].to_i(16) * 180) * (2**-15) )
    vb_max_daily = ( (slave.holding_registers[66].to_i(16) * 180) * (2**-15) )
    va_max_daily = ( (slave.holding_registers[67].to_i(16) * 180) * (2**-15) )


    # these numbers require no scaling, only hex to decimal
    ahc_daily = slave.holding_registers[68].to_i(16)
    whc_daily = slave.holding_registers[69].to_i(16)
    pout_max_daily = slave.holding_registers[71].to_i(16)
    tb_min_daily = slave.holding_registers[72].to_i(16)
    tb_max_daily = slave.holding_registers[73].to_i(16)
    time_ab_daily = slave.holding_registers[78].to_i(16)
    time_eq_daily = slave.holding_registers[79].to_i(16)
    time_fl_daily = slave.holding_registers[80].to_i(16)
  end
end

puts "Vb_min_daily: #{vb_min_daily}V Today’s minimum battery voltage."
puts "Vb_max_daily: #{vb_max_daily}V Today’s maximum battery voltage."
puts "Va_max_daily: #{va_max_daily}V Today’s maximum array voltage."
puts "Ahc_daily: #{ahc_daily}Ah Today’s total charge amp-hours."
puts "whc_daily: #{whc_daily}Wh Today’s total charge watt--hours."
puts "Pout_max_daily: #{pout_max_daily} Maximum power out today."
puts "Tb_min_daily: #{tb_min_daily}C Today’s minimum battery temperature."
puts "Tb_max_daily: #{tb_max_daily}C Today’s maximum battery temperature."
puts "time_ab_daily: #{time_ab_daily}s Cumulative time in Absorption today."
puts "time_eq_daily: #{time_eq_daily}s Cumulative time in Equalization today."
puts "time_fl_daily: #{time_fl_daily}s Cumulative time in Float today."

#rrd.update Time.now, vb_min_daily, vb_max_daily, va_max_daily, ahc_daily, whc_daily, pout_max_daily, tb_min_daily, tb_max_daily, time_ab_daily, time_eq_daily, time_fl_daily
