class SolarController
  require 'rmodbus'

  MPTT_HOST = '192.168.1.253'

  class << self
    def get_stats
      adc_vb_f     = nil  #voltage battery, filtered
      adc_va_f     = nil  #voltage array, filtered
      adc_ib_f     = nil  #current battery
      adc_ia_f     = nil  #current array
      power_out    = nil  #output power (Watts)
      power_in     = nil  #array input power (Watts)
      t_hs         = nil  #Heatsink temperature
      t_batt       = nil  #battery temp
      charge_state = nil  #charger charging state
      holding_registers = nil
      ModBus::TCPClient.new(MPTT_HOST, 502) do |cl|
        cl.with_slave(1) do |slave|
          holding_registers = slave.holding_registers[0..59]
        end
      end
      if holding_registers.is_a?(Array)
        v_PU_hi = holding_registers[0].to_i
        v_PU_lo = holding_registers[1].to_i
        v_scaling = v_PU_hi.to_f + (v_PU_lo.to_f/(2**15))

        i_PU_hi = holding_registers[2].to_i
        i_PU_lo = holding_registers[3].to_i
        i_scaling = "#{i_PU_hi}.#{i_PU_lo}".to_f
        # Read all the holding registers we care about, convert from hex and scale

        adc_vb_f = ( holding_registers[24].to_i * v_scaling / (2**15) ).to_f
        adc_va_f = ( holding_registers[27].to_i * v_scaling / (2**15) ).to_f
        adc_ib_f = ( holding_registers[28].to_i * i_scaling / (2**15) ).to_f
        adc_ia_f = ( holding_registers[29].to_i * i_scaling / (2**15) ).to_f

        # these numbers require no scaling, only hex to decimal
        t_hs = holding_registers[35].to_i
        t_batt = holding_registers[36].to_i
        charge_state = holding_registers[50].to_i

        power_out = holding_registers[58].to_i * v_scaling * i_scaling / (2**17)
        power_in = holding_registers[59].to_i * v_scaling * i_scaling / (2**17)
      end

      return {
          battery_current: adc_ib_f,
          battery_temp: t_batt,
          battery_voltage: adc_vb_f,
          battery_watt: power_out,
          charge_state: charge_state,
          heatsink_temp: t_hs,
          solar_current: adc_ia_f,
          solar_voltage: adc_va_f,
          solar_watt: power_in
      }
    end
  end
end
