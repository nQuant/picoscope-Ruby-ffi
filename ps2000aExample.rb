require './ps2000a.rb'
require 'ffi'
require 'io/console'
require './libC.rb'

include PS2000A


# $values_a = Array.new(BUFFER_SIZE)
# $values_b = Array.new(BUFFER_SIZE)

# $overflow = 0
# $scale_to_mv = 1

# $channel_mv = Array.new(4) # PS2000_MAX_CHANNELS=4

$timebase = 8 #:uint32
$oversample = 1 #:int16
$scaleVoltages = 1 #TRUE=1

# $g_overflow = 0

#Streaming datas parameters

$g_ready = false
$g_times = Array.new(4){0} # int32_t 	g_times [PS2000A_MAX_CHANNELS=4];
$g_timeUnit = 0 #:int16
$g_sampleCount = 0 #:int32
$g_startIndex = 0 #:uint32
$g_autoStopped = 0 #:int16
$g_trig = 0 #:int16
$g_trigAt = 0 #:uint32
$g_overflow = 0 #:int16
# $g_triggered = 0
# $g_triggeredAt = 0
# $g_nValues =0
# $g_startIndex = 0
# $g_prevStartIndex = 0
# $g_appBufferFull = 0

$blockFileName = "block.txt"
$digiBlockFileName = "digiblock.txt"
$streamFileName = "stream.txt"

$cycles = 0

# $unitOpened = UNIT_MODEL.new

# $bufferInfo = BUFFER_INFO.new

# $times = Array.new(BUFFER_SIZE){0}

$input_ranges = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000]

# def CallBackBlock( handle, status, pParameter)
	# if status!=PICO_CANCELLED
		# $g_ready = 1
	# end
# end

CallBackBlock = Proc.new do | handle, status, pParameter|
	if status!=PICO_CANCELLED
		$g_ready = 1
	end
end

def CloseDevice(unit)
	ps2000aCloseUnit(unit[:handle])
end

def SetDefaults(unit)
	status = ps2000aSetEts(unit[:handle], PS2000A_ETS_OFF, 0, 0, nil)
	for i in (0..unit[:channelCount]-1]
		status = ps2000aSetChannel( unit[:handle], (PS2000A_CHANNEL_A+i), unit[:channelSettings][PS2000A_CHANNEL_A+i][:enabled], unit[:channelSettings][PS2000A_CHANNEL_A + i][:DCcoupled], unit[:channelSettings][PS2000A_CHANNEL_A + i][:range], 0)
	end
end

# def adc_units (time_units)
# {
	# time_units+=1
	# //print ( "time unit:  %d\n" % time_units ) 
	# case ( time_units )
	# {
		# when 0;
			# return "ADC";
		# when 1;
			# return "fs";
		# when 2;
			# return "ps";
		# when 3;
			# return "ns";
		# when 4;
			# return "us";
		# when 5;
			# return "ms";
	# }
	
	# return "Not Known"
# }

def adc_to_mv(raw,ch,unit)
	return raw*$input_ranges[ch])/unit[:maxValue]
end

def ClearDataBuffers(unit)
	
	for i in (0..unit[:channelCount]-1)
		if (status = ps2000aSetDataBuffers(unit[:handle], i, nil, nil, 0, 0, PS2000A_RATIO_MODE_NONE)) != PICO_OK
			print("ClearDataBuffers:ps2000aSetDataBuffers(channel %d) ------ 0x%08x \n" % [i ,status]);
		end
	end
	
	for i in (0..unit[:digitalPorts]-1)
		if (status = ps2000aSetDataBuffer(unit[:handle], (i + PS2000A_DIGITAL_PORT0), nil, 0, 0, PS2000A_RATIO_MODE_NONE) != PICO_OK
			print("ClearDataBuffers:ps2000aSetDataBuffer(port 0x%X) ------ 0x%08x \n", i + PS2000A_DIGITAL_PORT0, status)
		end
	end
	
	return status
end

def BlockDataHandler(unit, text, offset, mode, etsModeSet)
	
	sampleCount_ptr = FFI::MemoryPointer(:uint32, 1) #in ps2000acon.c, sampleCount_ptr was declared int32 but the pointer to this is cast to a uint32
	sampleCount_ptr.write_int32(BUFFER_SIZE)
	# sampleCount = BUFFER_SIZE
	timeInterval_ptr = FFI::MemoryPointer(:int32, 1)
	maxSamples_ptr = FFI::MemoryPointer(:int32, 1)
	timeIndisposed_ptr = FFI::MemoryPointer(:int32, 1)
	
	buffers = Array.new(PS2000A_MAX_CHANNEL_BUFFERS){nil}
	digiBuffer = Array.new(PS2000A_MAX_DIGITAL_PORTS){0}
	
	ratioMode = PS2000A_RATIO_MODE_NONE
	
	blockFile = nil
	digiBlockFile = nil
	
	begin
		if (mode == ANALOGUE || mode == MIXED)
			for i in (0..unit[:channelCount]-1)
				if (unit[:channelSettings][i][:enabled]!=0)
					buffers[i*2] = LibC.malloc(sampleCount_ptr.read_int32 * INT16.size)
					buffers[i*2+1] = LibC.malloc(sampleCount_ptr.read_int32 * INT16.size)
					# buffers[i*2] = LibC.malloc(sampleCount_ptr.read_int32 * 2) # sizeof(int16) = 2 ??
					# buffers[i*2+1] = LibC.malloc(sampleCount_ptr.read_int32 * 2) # sizeof(int16) = 2 ??
					
					status = ps2000aSetDataBuffers(unit[:handle], i, buffers[i*2], buffers[i*2+1], sampleCount_ptr.read_int32, segmentIndex, ratioMode)
					
					print((status!=0 ? ("BlockDataHandler:ps2000aSetDataBuffers(channel %d) ------ 0x%08x \n" % status) : ""))
				end
			end
		end
		
		if (mode == ANALOGUE && etsModeSet == 1)
			etsTime = LibC.calloc(sampleCount_ptr.read_int32 * INT64.size)
			status = ps2000aSetEtsTimeBuffer(unit[:handle], etsTime, sampleCount_ptr.read_int32)
		end
		
		if (mode == DIGITAL || mode == MIXED)
			for i in (0..unit[:digitalPorts]-1)
				digiBuffer[i] = LibC.malloc(sampleCount_ptr.read_int32 * INT16.size)
				status = ps2000aSetDataBuffer(unit[:handle], (i+PS2000A_DIGITAL_PORT0), digiBuffer[i], sampleCount_ptr.read_int32, 0, ratioMode)
				print((status!=0 ? ("BlockDataHandler:ps2000aSetDataBuffer(port 0x%X) ------ 0x%08x \n" % [i+PS2000A_DIGITAL_PORT0, status]) : ""))
			end
		end
		
		#Validate the current timebase index, and find the maximum number of samples and the time interval (in nanoseconds)
		
		while (ps2000aGetTimebase(unit[:handle], $timebase, sampleCount_ptr.read_int32, timeInterval_ptr, $oversample, maxSamples_ptr, 0) != PICO_OK)
			$timebase+=1
		end
		
		if etsModeSet == 0
			print("\nTimebase: %u  SampleInterval: %d nS  oversample: %d\n"% [$timebase, timeInterval, $oversample])
		end
		
		$g_ready = 0
		status = ps2000aRunBlock(unit[:handle], 0, sampleCount_ptr.read_int32, $timebase, $oversample, timeIndisposed_ptr, 0, CallBackBlock, nil)
		
		print((status!=0 ? ("BlockDataHandler:ps2000aRunBlock ------ 0x%08x \n" % status) : ""))
		
		print("Waiting for trigger...Press a key to abort\n")
		
		while ($g_ready == 0) #add key press detect
			sleep 1
		end
		
		if $g_ready == 1
			status = ps2000aGetValues(unit[:handle], 0, sampleCount_ptr, 10, ratioMode, 0, nil))
			print( status!=0 ? ("BlockDataHandler:ps2000aGetValues ------ 0x%08lx \n" % status) : "")
			print("%s\n" % text)
			if (mode == ANALOGUE || mode == MIXED)
				print("Channels are in (%s) \n\n" % ($scaleVoltages!=0 ? "mV" : "ADC Counts"))
				for j in (0..unit[:channelCount]-1)
					if unit[:channelSettings][j][:enabled] == 1
						print("Channel%c:\t" % (65+j).chr)
					end
				end
				print("\n")
			end
			
			if (mode == DIGITAL || mode == MIXED)
				print("Digital\n")
			end
			
			print("\n")
			
			for i in (offset..offset+10-1)
				
				if (mode == ANALOGUE ||mode == MIXED)
					for j in (0..unit[:channelCount]-1)
						if (unit[:channelSettings][j][:enabled] == 1)
							print("  %6d        " % ($scaleVoltages!=0 ? adc_to_mv( buffers[j*2][i], unit[:channelSettings][PS2000A_CHANNEL_A+j][:range], unit) : buffers[j*2][i])
						end
					end
				end
				
				if (mode == DIGITAL || mode == MIXED)
					digiValue = 0x00ff & digiBuffer[1][i]
					digiValue <<= 8
					digiValue |= digiBuffer[0][i]
					print("0x%04X" % digiValue)
				end
			
			print("\n")
		end
		
		if ( mode == ANALOGUE || mode == MIXED)
			
			sampleCount_ptr.write_int32([sampleCount_ptr.read_int32(), BUFFER_SIZE].min)
			
			blockFile = File.open($blockFileName, "w")
			
			if blockFile!=nil
				if etsModeSet == 1
					blockFile.print("ETS Block Data log\n\n");
				else
					blockFile.print("Block Data log\n");
				end
				
				blockFile.print("Results shown for each of the %d Channels are......\n" % unit[:channelCount])
				blockFile.print("Maximum Aggregated value ADC Count & mV, Minimum Aggregated value ADC Count & mV\n\n")
				
				if etsModeSet == 1
					blockFile.print("Time (fs) ")
				else
					blockFile.print("Time (ns) ")
				end
			
				for i in (0..unit[:channelCount]-1)
					blockFile.print(" Ch   Max ADC  Max mV   Min ADC  Min mV  ")
				end
				
				blockFile.print("\n")
				
				for i in (0..sampleCount_ptr.read_int32()-1)
					if (mode == ANALOGUE && etsModeSet == 1)
						blockFile.print("%d " % etsTime[i])
					else
						blockFile.print("%7d " % ($g_times[0]+i*timeInterval)
					end
					for j in (0..unit[:channelCount]-1)
						if unit[:channelSettings][j][:enabled] == 1
							blockFile.print("Ch%C  %5d = %+5dmV, %5d = %+5dmV   " % [(65+j).chr, buffers[j*2][i], adc_to_mv(buffers[j*2][i], unit[:channelSettings][PS2000A_CHANNEL_A + j][:range], unit), buffers[j*2+1][i], adc_to_mv(buffers[j*2+1][i], unit[:channelSettings][PS2000A_CHANNEL_A + j][:range], unit))
						end
					end
					
					blockFile.print("\n")
				end
				
			else
				print(	"Cannot open the file block.txt for writing.\n Please ensure that you have permission to access.\n")
			end
		end
			
		if (mode == DIGITAL || mode == MIXED)
			digiBlockFile = File.open($digiBlockFileName, "w")
			if digiBlockFile!=nil
				digiBlockFile.print("Block Digital Data log.\n")
				digiBlockFile.print("Results shown for D15 - D8 and D7 to D0.\n\n")
				
				for i in (0..sampleCount_ptr.read_int32()-1)
					digiValue = 0x00ff & digiBuffer[1][i]
					digiValue <<=8
					digiValue |= digiBuffer[0][i]
					
					for bit in (0..16-1)
						bitValue = ((0x8000 >> bit) & (digiValue))!= 0 ? 1 : 0
						digiBlockFile.print("%u " % bitValue)
					end
					
					digiBlockFile.print("\n")
				end
			
			else
				print("Cannot open the file digiblock.txt for writing.\n Please ensure that you have permission to access.\n")
			end
		end
	else
		print("data collection aborted\n");
		STDIN.getch();
	end
			
	ensure
		status = ps2000aStop(unit[:handle])
		print(status!=0 ? "BlockDataHandler:ps2000aStop ------ 0x%08x \n" % status : "")
		
		if blockFile!=nil
			blockFile.close()
		end
		
		if digiBlockFile!=nil
			digiBlockFile.close()
		end
		
		if (mode == ANALOGUE || mode == MIXED)		
			for i in (0..unit[:channelCount]-1) 
				if (unit[:channelSettings][i][:enabled] == 1)
					LibC.free(buffers[i * 2])
					LibC.free(buffers[i * 2 + 1])
				end
			end
		end
		
		if (mode == ANALOGUE && etsModeSet == 1)	
			LibC.free(etsTime);
		end
		
		if (mode == DIGITAL || mode == MIXED)
			for i in (0..unit[:digitalPorts]-1)
				LibC.free(digiBuffer[i])
			end
		end
		
		ClearDataBuffers(unit)
		
	end
end

def SetTrigger(unit, channelProperties, nChannelproperties, triggerConditions, nTriggerConditions, directions, pwq, delay, auxOutputEnabled, autoTriggerMs, digitalDirections, nDigitalDirections)
	
	if (status = ps2000aSetTriggerChannelProperties(unit[:handle], channelProperties, nChannelproperties, auxOutputEnabled, autoTriggerMs))!=PICO_OK
		print("SetTrigger:ps2000aSetTriggerChannelProperties ------ Ox%08x \n" % status)
		return status
	end
	
	if (status = ps2000aSetTriggerConditions(unit[:handle], triggerConditions, nTriggerConditions)) != PICO_OK
		print("SetTrigger:ps2000aSetTriggerChannelConditions ------ 0x%08x \n" % status)
		return status
	end
	
	if (status = ps2000aSetTriggerChannelDirections(unit[:handle], directions[:channelA], directions[:channelB], directions[:channelC], directions[:channelD], directions[:ext], directions[:aux])) != PICO_OK
		print("SetTrigger:ps2000aSetTriggerChannelDirections ------ 0x%08x \n" % status)
		return status
	end
	
	if (status = ps2000aSetTriggerDelay(unit[:handle], delay)) != PICO_OK
		print("SetTrigger:ps2000aSetTriggerDelay ------ 0x%08x \n" % status)
		return status
	end
	
	if ((status = ps2000aSetPulseWidthQualifier(unit[:handle], pwq[:conditions], pwq[:nConditions], pwq[:direction], pwq[:lower], pwq[:upper], pwq[:type])) != PICO_OK)
		print("SetTrigger:ps2000aSetPulseWidthQualifier ------ 0x%08x \n" % status)
		return status
	end
	
	if unit[:digitalPorts]!=0
		if ((status = ps2000aSetTriggerDigitalPortProperties(unit[:handle], digitalDirections, nDigitalDirections)) != PICO_OK)
			print("SetTrigger:ps2000aSetTriggerDigitalPortProperties ------ 0x%08x \n" % status)
			return status
		end
	end
	
	return status
	
end

def CollectBlockImmediate(unit)
	pulseWidth = PWQ.new
	directions = TRIGGER_DIRECTIONS.new
	
	# directions.ptr.write(TRIGGER_DIRECTIONS.size)
	
	print("Collect block immediate\n")
	print("Data is written to disk file (%s)\n" % $blockFileName)
	print("Press a key to start...\n");
	
	STDIN.getch()
	
	SetDefaults(unit)
	
	SetTrigger(unit, nil, 0, nil, directions, pulseWidth, 0, 0, 0, 0)
	
	BlockDataHandler(unit, "\nFirst 10 readings:\n", 0, ANALOGUE, 0)
end

def CollectBlockTriggered(unit)
	
end

def CollectRapidBlock(unit)
	
end

def get_info(unit)
		
	description = [ "Driver Version",
					"USB Version",
					"Hardware Version",
					"Variant Info",
					"Serial",
					"Cal Date",
					"Kernel",
					"Digital H/W",
					"Analogue H/W",
					"Firmware 1",
					"Firmware 2"]
	
	line_ptr = FFI:MemoryPointer.new(:char, 80) # 80 = line size
	status = PICO_OK
	numChannels = DUALSCOPE
	character = 'A'
	r_ptr = FFI::MemoryPointer(:int16, 1)
	
	unit[:signalGenerator] = 1
	unit[:ETS] = 0
	unit[:firstRange] = PS2000A_20MV
	unit[:lastRange] = PS2000A_20V
	unit[:channelCount] = DUAL_SCOPE
	unit[:digitalPorts] = 0
	unit[:awgBufferSize] = PS2000A_MAX_SIG_GEN_BUFFER_SIZE
	
	if (unit[:handle])
		for i in (0..11-1)			#11 = description.size
			status = ps2000aGetUnitInfo(unit[:handle], line_ptr, 80, r_ptr, i) # 80 = line size
			
			if i == PICO_VARIANT_INFO
				line = line_ptr.read_string()
				numChannels = line[1].to_i
				if numChannels == QUAD_SCOPE
					unit[:channelCount] = QUAD_SCOPE
				end
				if numChannels == DUAL_SCOPE
					if (line.strip.length == 4)||(line.strip.length == 5 && line[4]=="A")||(line == "2205")
						unit[:firstRange] = PS2000A_50MV
					end
				end
				if (/MSO/=~line)!=nil
					unit[:digitalPorts] = 2
				end
			end
			
			print("%s: %s\n" % [description[i], line])
		end
	end
end

def SetTimebase(unit)

end

def OpenDevice(unit)
	
	# value = 0 #int16_t value = 0;
	value_ptr = FFI::MemoryPointer(:int16, 1)
	value_ptr.write_int16(0)
	i=0 #int32_t i;
	pulseWidth = PWQ.new
	directions = TRIGGER_DIRECTIONS.new
	
	unit_handle_ptr = FFI::Pointer.new(:uint8, unit.to_ptr.address + unit.offset_of(:handle))
	status = ps2000aOpenUnit(unit_handle_ptr ,nil)
	
	print("Handle : %d\n" % unit[:handle])
	
	if status!=PICO_OK
		print("Unable to open device\n")
		print("Error code : %d\n" % status);
		ch = STDIN.getch().upcase
		exit
	end
	
	print("Device opened successfully, cycle %d\n\n" % ($cycles = $cycles+1))
	
	##Setup device
	
	get_info(unit)
	$timebase = 1
	
	ps2000aMaximumValue(unit[:handle], value_ptr)
	unit[:maxValue] = value_ptr.read_int16()
	
	for i in (0..unit[:channelCount]-1)
		unit[:channelSettings][i][:enabled] = 1 # Should be equal to true?
		unit[:channelSettings][i][:DCcoupled] = 1 # Should be equal to true?
		unit[:channelSettings][i][:range] = PS2000A_5V
	end
	
	
	###Struct init with ffi automatically clear memory to zero
	# directions.ptr.write_bytes("0")
	# directions.ptr.write_array_of_uint8(Array.new(TRIGGER_DIRECTIONS.size){0})	# memset(directions, 0, sizeof(TRIGGER_DIRECTIONS))
	# pulseWidth.ptr.write_array_of_uint8(Array.new(PWQ.size){0})					# memset(pulseWidth, 0, sizeof(PWQ))
	
	SetDefaults(unit)
	
	#SetTrigger(unit, nil, 0, nil, 0, directions.to_ptr, pulseWidth.to_ptr, 0, 0, 0, 0, 0) #SetTrigger(unit, NULL, 0, NULL, 0, &directions, &pulseWidth, 0, 0, 0, 0, 0) directions and pulseWidth stay in Ruby environment
	SetTrigger(unit, nil, 0, nil, 0, directions, pulseWidth, 0, 0, 0, 0, 0)
	
	return status
	
end

def DisplaySettings(unit)
	
	print("\n\n Readings will be scaled in (%s)\n" % ($scaleVoltages ? ("mV") : ("ADC counts") )
	
	for ch in (0..unit[:channelCount]-1]
		if (!unit[:channelSettings][ch][:enabled]!=0)
			print("Channel %c Voltage Range = Off\n" % (65 + ch).chr)
		else
			voltage = $input_Ranges[ unit[:channelSettings][ch][:range] ]
			print("Channel %c Voltage Range = " % (65 + ch).chr)
			if voltage<1000
				print("%d mV\n" % voltage)
			else
				print("%d V\n" % voltage / 1000)
			end
		end
	end
	
	print("\n")
	
	if unit[:digitalPorts]>0
		print("Digital Ports switched off. \n\n")
	end
	
end

def main()
	
	print("PicoScope 2000 Series (A API) Driver Example Program\n")
	print("\n\nOpening the device...\n")
	
	unit = UNIT.new
	
	status = OpenDevice(unit)
	
	ch = ' '
	
	print("Handler: %d\n" % unit[:handle])
	
	while (ch!='X')
	{
		DisplaySettings(unit);
		
		print("\n");
		print("B - Immediate block                           V - Set voltages\n");
		print("T - Triggered block                           I - Set timebase\n");
		print("E - Collect a block of data using ETS         A - ADC counts/mV\n");
		print("R - Collect set of rapid captures             G - Signal generator\n");
		print("S - Immediate streaming\n");
		print("W - Triggered streaming\n");
		print((unit[:digitalPorts]!=0 ? "D - Digital Ports menu\n" : ""));
		print("                                              X - Exit\n\n");
		print("Operation:");
		
		ch = STDIN.getch().upcase
		print ( "\n\n" );
		
		
		case ch
			
			when 'B';
				CollectBlockImmediate(unit)
			
			when 'T';
				CollectBlockTriggered(unit)
			
			when 'R';
				CollectRapidBlock(unit)
				
			else
		end
		
	end
	
	CloseDevice(unit)
	
	end
end