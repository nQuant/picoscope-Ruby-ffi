require './ps2000.rb'
require 'ffi'
require 'io/console'

TRUE_=1
FALSE_=0

class Main
	
	include PS2000

	$values_a = Array.new(BUFFER_SIZE)
	$values_b = Array.new(BUFFER_SIZE)

	$overflow = 0
	$scale_to_mv = 1

	$channel_mv = Array.new(4) # PS2000_MAX_CHANNELS=4
	$timebase = 8

	$g_overflow = 0

	##Streaming datas parameters

	$g_triggered = 0
	$g_triggeredAt = 0
	$g_nValues =0
	$g_startIndex = 0
	$g_prevStartIndex = 0
	$g_appBufferFull = 0

	$unitOpened = UNIT_MODEL.new

	$bufferInfo = BUFFER_INFO.new

	$times_ptr=FFI::MemoryPointer.new(:int32, BUFFER_SIZE)
	# $times = Array.new(BUFFER_SIZE){0}

	$input_ranges = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000]



	def adc_units (time_units)
		
		time_units+=1
		# //printf ( "time unit:  %d\n" % time_units ) 
		case time_units
			when 0;
				return "ADC";
			when 1;
				return "fs";
			when 2;
				return "ps";
			when 3;
				return "ns";
			when 4;
				return "us";
			when 5;
				return "ms";
		end
		return "Not Known"
	end

	def adc_to_mv(raw,ch)
		return $scale_to_mv==1 ? (raw*$input_ranges[ch])/32767 : raw
	end

	def set_defaults()
		ch = 0
		ps2000_set_ets($unitOpened[:handle], PS2000_ETS_OFF, 0, 0)
		for ch in (0..$unitOpened[:noOfChannels]-1)
			ps2000_set_channel($unitOpened[:noOfChannels], ch, $unitOpened[:channelSettings][ch][:enabled], $unitOpened[:channelSettings][ch][:DCcoupled], $unitOpened[:channelSettings][ch][:range])
		end
	end

	def collect_block_immediate()
		
		i=0
		time_interval_ptr = FFI::MemoryPointer.new(:int32,1)
		time_units_ptr = FFI::MemoryPointer.new(:int16,1)
		# time_interval=0 #need pointer
		# time_units=0 #need pointer
		oversample = 0
		no_of_samples = BUFFER_SIZE
		file = File.open("data.txt", 'w')
		auto_trigger_ms = 0
		time_indisposed_ms_ptr = FFI::MemoryPointer.new(:int32,1)
		# time_indisposed_ms = 0
		overflow_ptr = FFI::MemoryPointer.new(:int16,1)
		# overflow = 0
		max_samples_ptr = FFI::MemoryPointer.new(:int32,1)
		# max_samples=0
		ch = 0
		
		print("Collect block immediate... \n")
		# print("Press a key to start\n")
		
		# STDIN.getch()
		
		set_defaults()
		
		ps2000_set_trigger($unitOpened[:handle], PS2000_NONE, 0, PS2000_RISING, 0, auto_trigger_ms)
		
		oversample = 1
		
		puts("check e")
		
		while ( (h = ps2000_get_timebase($unitOpened[:handle], $timebase, no_of_samples, time_interval_ptr, time_units_ptr, oversample, max_samples_ptr))!=0)
			sleep 1
			puts(" Handle : %d " % h)
		end
		
		puts("check d")
		
		$timebase+=1
		
		print("timebase: %d\toversample:%d\n" % [$timebase, oversample])
		
		ps2000_run_block($unitOpened[:handle], no_of_samples, $timebase, oversample, time_indisposed_ms_ptr)
		
		puts("check c")
		
		while ps2000_ready($unitOpened[:handle])!=0
			sleep 1
		end
		
		puts("check b")
		
		ps2000_stop($unitOpened[:handle])
		
		puts("check a")
		
		channelA_values_ptr = FFI::Pointer.new(:int16, $unitOpened[:channelSettings][PS2000_CHANNEL_A].to_ptr + CHANNEL_SETTINGS.offset_of(:values))
		channelB_values_ptr = FFI::Pointer.new(:int16, $unitOpened[:channelSettings][PS2000_CHANNEL_B].to_ptr + CHANNEL_SETTINGS.offset_of(:values))
		
		ps2000_get_times_and_values($unitOpened[:handle], $times_ptr, channelA_values_ptr, channelB_values_ptr, nil, nil, overflow_ptr, time_units_ptr.read_int16, no_of_samples)
		
		print( "First 10 readings\n\n" )
		print( "Time(%s) Values\n" % adc_units(time_units_ptr.read_int16()))
		for i in (0..9)
			print("%d\t" % $times_ptr.read_array_of_int32(BUFFER_SIZE)[i])
			
			for ch in (0..$unitOpened[:noOfChannels]-1)
				if $unitOpened[:channelSettings][ch][:enabled]
					print("%d\t" % adc_to_mv($unitOpened[:channelSettings][ch][:values][i],$unitOpened[:channelSettings][ch][:range]))
				end
			end
			print("\n")
		end
		
		for i in (0..BUFFER_SIZE-1)
			file.print("%d" % $times_ptr.read_array_of_int32(BUFFER_SIZE)[i])
			for ch in (0..$unitOpened[:noOfChannels]-1)
				file.print(", %d, %d" % [$unitOpened[:channelSettings][ch][:values][i], adc_to_mv($unitOpened[:channelSettings][ch][:values][i],$unitOpened[:channelSettings][ch][:range])])
			end
		end
		
		file.close
		
	end

	def get_info()
		
		description = [ "Driver Version   ", "USB Version      ", "Hardware Version ", "Variant Info     ", "Serial           ",  "Cal Date         ",  "Error Code       ", "Kernel Driver    "]
		i = 0 #:int16
		# line = " "*80 # int8_t		line [80];
		# line = " "*80
		# line_ptr = FFI::MemoryPointer.from_string(line)
		line_ptr = FFI::MemoryPointer.new(:int8,80)
		line_ptr.write_string(" "*80)
		variant = 0 #int32_t		variant;
		
		if $unitOpened[:handle]!=0
			
			for i in (0..7)
				# ps2000_get_unit_info($unitOpened[:handle], FFI::MemoryPointer.from_string(line), line.length, i) # 80 = sizeof(line)
				ps2000_get_unit_info($unitOpened[:handle], line_ptr, 80, i) # 80 = sizeof(line)
				if i==3
					variant = line_ptr.read_string().to_i
					if line_ptr.read_string().length == 5
						line=line_ptr.read_string().upcase
						if line[1]=='2'&&line[4]=='A'
							variant+=0x9968
						end
					end
				end
				
				if i!=6
					print("%s: %s\n" % [description[i], line_ptr.read_string()])
				end
			end
			
			# puts(variant) #verify the A letter handling
			
			case variant
				when MODEL_PS2104;
					$unitOpened[:model] = MODEL_PS2104
					$unitOpened[:firstRange] = PS2000_100MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2104_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = 1
					$unitOpened[:hasAdvancedTriggering] = FALSE_
					$unitOpened[:hasSignalGenerator] = FALSE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = FALSE_
				
				when MODEL_PS2105;
					$unitOpened[:model] = MODEL_PS2105
					$unitOpened[:firstRange] = PS2000_100MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2105_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = 1
					$unitOpened[:hasAdvancedTriggering] = FALSE_
					$unitOpened[:hasSignalGenerator] = FALSE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = FALSE_
				
				when MODEL_PS2202;
					$unitOpened[:model] = MODEL_PS2202
					$unitOpened[:firstRange] = PS2000_100MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2200_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = 2
					$unitOpened[:hasAdvancedTriggering] = TRUE_
					$unitOpened[:hasSignalGenerator] = FALSE_
					$unitOpened[:hasEts] = FALSE_
					$unitOpened[:hasFastStreaming] = TRUE_
				
				when MODEL_PS2203;
					$unitOpened[:model] = MODEL_PS2203
					$unitOpened[:firstRange] = PS2000_50MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2200_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = 2
					$unitOpened[:hasAdvancedTriggering] = FALSE_
					$unitOpened[:hasSignalGenerator] = TRUE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = TRUE_
				
				when MODEL_PS2204;
					$unitOpened[:model] = MODEL_PS2204
					$unitOpened[:firstRange] = PS2000_50MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2200_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = 2
					$unitOpened[:hasAdvancedTriggering] = TRUE_
					$unitOpened[:hasSignalGenerator] = TRUE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = TRUE_
				
				when MODEL_PS2204A;
					$unitOpened[:model] = MODEL_PS2204A
					$unitOpened[:firstRange] = PS2000_50MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2200_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = DUAL_SCOPE
					$unitOpened[:hasAdvancedTriggering] = TRUE_
					$unitOpened[:hasSignalGenerator] = TRUE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = TRUE_
					$unitOpened[:awgBufferSize] = 4096
				
				when MODEL_PS2205;
					$unitOpened[:model] = MODEL_PS2205
					$unitOpened[:firstRange] = PS2000_50MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2200_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = 2
					$unitOpened[:hasAdvancedTriggering] = TRUE_
					$unitOpened[:hasSignalGenerator] = TRUE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = TRUE_
					
				when MODEL_PS2205A;
					$unitOpened[:model] = MODEL_PS2205A
					$unitOpened[:firstRange] = PS2000_50MV
					$unitOpened[:lastRange] = PS2000_20V
					$unitOpened[:maxTimebase] = PS2200_MAX_TIMEBASE
					$unitOpened[:timebases] = $unitOpened[:maxTimebase]
					$unitOpened[:noOfChannels] = DUAL_SCOPE
					$unitOpened[:hasAdvancedTriggering] = TRUE_
					$unitOpened[:hasSignalGenerator] = TRUE_
					$unitOpened[:hasEts] = TRUE_
					$unitOpened[:hasFastStreaming] = TRUE_
					$unitOpened[:awgBufferSize] = 4096
				
				else 
					print("Unit not supported");
			end
			
			$unitOpened[:channelSettings][PS2000_CHANNEL_A][:enabled] = 1
			$unitOpened[:channelSettings][PS2000_CHANNEL_A][:DCcoupled] = 1
			$unitOpened[:channelSettings][PS2000_CHANNEL_A][:range] = PS2000_5V
			
			if $unitOpened[:noOfChannels] == DUAL_SCOPE
				$unitOpened[:channelSettings][PS2000_CHANNEL_B][:enabled] = 1
			else
				$unitOpened[:channelSettings][PS2000_CHANNEL_B][:enabled] = 0
			end
			
			$unitOpened[:channelSettings][PS2000_CHANNEL_B][:DCcoupled] = 1
			$unitOpened[:channelSettings][PS2000_CHANNEL_B][:range] = PS2000_5V
			
			set_defaults()
			
		else
			
			print("Unit Not Opened\n")
			
			ps2000_get_unit_info($unitOpened[:handle], line_ptr, 80, 5 )
			
			print("%s: %s\n" % [description[5], line_ptr.read_string()])
			$unitOpened[:model] = MODEL_NONE
			$unitOpened[:firstRange] = PS2000_100MV
			$unitOpened[:lastRange] = PS2000_20V
			$unitOpened[:timebases] = PS2105_MAX_TIMEBASE
			$unitOpened[:noOfChannels] = SINGLE_CH_SCOPE
			
		end
	end

	def main()
		
		ch = 0
		
		print("PicoScope 2000 Series (ps2000) Driver Example Program\n")

		print("\n\nOpening the device...\n")
		
		$unitOpened[:handle] = ps2000_open_unit()
		
		print("Handler: %d\n" % $unitOpened[:handle])
		
		if $unitOpened[:handle]==0
			print("Unable to open device\n")
			get_info
			puts ("Press <Enter> to continue\n")
			STDIN.gets
		
		else
			print("Device opened successfully\n\n")
			get_info
			$timebase = 0
			
			ch=''
			while (ch!='X')
				
				#displaySettings($unitOpened);
				
				print("\n")
				print( "B - Immediate block                V - Set voltages\n" )
				print( "T - Triggered block                I - Set timebase\n" )
				print( "Y - Advanced triggered block       A - ADC counts/mV\n" )
				print( "E - ETS block\n" )
				print( "S - Streaming\n")
				print( "F - Fast streaming\n")
				print( "D - Fast streaming triggered\n")
				print( "C - Fast streaming triggered 2\n")
				print( "G - Signal generator\n")
				print( "H - Arbitrary signal generator\n")
				print( "X - Exit\n" )
				print( "Operation:" )
				
				ch = STDIN.getch().upcase
				printf ( "\n\n" );
				
				
				case ch
					
					when 'B';
						collect_block_immediate()
						# break
						
					when 'X';
						break
					
					else ;
						puts("Invalid operation")
					
				end
				
			end
			
			ps2000_close_unit($unitOpened[:handle])
			
		end
	end
	
	def self.const_missing(sym)
		
		return PS2000.const_missing(sym)
	
	end
end

unit=Main.new
unit.main