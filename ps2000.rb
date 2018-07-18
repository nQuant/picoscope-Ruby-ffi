require 'ffi'
require './picostatus.rb'

##
#Picostatus constants definition
PICO_OK = 0x00000000  # The PicoScope is functioning correctly.
PICO_MAX_UNITS_OPENED = 0x00000001  # An attempt has been made to open more than <API>_MAX_UNITS.
PICO_MEMORY_FAIL = 0x00000002  # Not enough memory could be allocated on the host machine.
PICO_NOT_FOUND = 0x00000003  # No Pico Technology device could be found.
PICO_FW_FAIL = 0x00000004  # Unable to download firmware.
PICO_OPEN_OPERATION_IN_PROGRESS = 0x00000005  # The driver is busy opening a device.
PICO_OPERATION_FAILED = 0x00000006  # An unspecified failure occurred.
PICO_NOT_RESPONDING = 0x00000007  # The PicoScope is not responding to commands from the PC.
PICO_CONFIG_FAIL = 0x00000008  # The configuration information in the PicoScope is corrupt or missing.
PICO_KERNEL_DRIVER_TOO_OLD = 0x00000009  # The picopp.sys file is too old to be used with the device driver.
PICO_EEPROM_CORRUPT = 0x0000000A  # The EEPROM has become corrupt, so the device will use a default setting.
PICO_OS_NOT_SUPPORTED = 0x0000000B  # The operating system on the PC is not supported by this driver.
PICO_INVALID_HANDLE = 0x0000000C  # There is no device with the handle value passed.
PICO_INVALID_PARAMETER = 0x0000000D  # A parameter value is not valid.
PICO_INVALID_TIMEBASE = 0x0000000E  # The timebase is not supported or is invalid.
PICO_INVALID_VOLTAGE_RANGE = 0x0000000F  # The voltage range is not supported or is invalid.
PICO_INVALID_CHANNEL = 0x00000010  # The channel number is not valid on this device or no channels have been set.
PICO_INVALID_TRIGGER_CHANNEL = 0x00000011  # The channel set for a trigger is not available on this device.
PICO_INVALID_CONDITION_CHANNEL = 0x00000012  # The channel set for a condition is not available on this device.
PICO_NO_SIGNAL_GENERATOR = 0x00000013  # The device does not have a signal generator.
PICO_STREAMING_FAILED = 0x00000014  # Streaming has failed to start or has stopped without user request.
PICO_BLOCK_MODE_FAILED = 0x00000015  # Block failed to start - a parameter may have been set wrongly.
PICO_NULL_PARAMETER = 0x00000016  # A parameter that was required is NULL.
PICO_ETS_MODE_SET = 0x00000017  # The current functionality is not available while using ETS capture mode.
PICO_DATA_NOT_AVAILABLE = 0x00000018  # No data is available from a run block call.
PICO_STRING_BUFFER_TO_SMALL = 0x00000019  # The buffer passed for the information was too small.
PICO_ETS_NOT_SUPPORTED = 0x0000001A  # ETS is not supported on this device.
PICO_AUTO_TRIGGER_TIME_TO_SHORT = 0x0000001B  # The auto trigger time is less than the time it will take to collect the pre-trigger data.
PICO_BUFFER_STALL = 0x0000001C  # The collection of data has stalled as unread data would be overwritten.
PICO_TOO_MANY_SAMPLES = 0x0000001D  # Number of samples requested is more than available in the current memory segment.
PICO_TOO_MANY_SEGMENTS = 0x0000001E  # Not possible to create number of segments requested.
PICO_PULSE_WIDTH_QUALIFIER = 0x0000001F  # A null pointer has been passed in the trigger function or one of the parameters is out of range.
PICO_DELAY = 0x00000020  # One or more of the hold-off parameters are out of range.
PICO_SOURCE_DETAILS = 0x00000021  # One or more of the source details are incorrect.
PICO_CONDITIONS = 0x00000022  # One or more of the conditions are incorrect.
PICO_USER_CALLBACK = 0x00000023  # The driver's thread is currently in the <API>Ready callback function and therefore the action cannot be carried out.
PICO_DEVICE_SAMPLING = 0x00000024  # An attempt is being made to get stored data while streaming. Either stop streaming by calling <API>Stop, or use <API>GetStreamingLatestValues.
PICO_NO_SAMPLES_AVAILABLE = 0x00000025  # Data is unavailable because a run has not been completed.
PICO_SEGMENT_OUT_OF_RANGE = 0x00000026  # The memory segment index is out of range.
PICO_BUSY = 0x00000027  # The device is busy so data cannot be returned yet.
PICO_STARTINDEX_INVALID = 0x00000028  # The start time to get stored data is out of range.
PICO_INVALID_INFO = 0x00000029  # The information number requested is not a valid number.
PICO_INFO_UNAVAILABLE = 0x0000002A  # The handle is invalid so no information is available about the device. Only PICO_DRIVER_VERSION is available.
PICO_INVALID_SAMPLE_INTERVAL = 0x0000002B  # The sample interval selected for streaming is out of range.
PICO_TRIGGER_ERROR = 0x0000002C  # ETS is set but no trigger has been set. A trigger setting is required for ETS.
PICO_MEMORY = 0x0000002D  # Driver cannot allocate memory.
PICO_SIG_GEN_PARAM = 0x0000002E  # Incorrect parameter passed to the signal generator.
PICO_SHOTS_SWEEPS_WARNING = 0x0000002F  # Conflict between the shots and sweeps parameters sent to the signal generator.
PICO_SIGGEN_TRIGGER_SOURCE = 0x00000030  # A software trigger has been sent but the trigger source is not a software trigger. 
PICO_AUX_OUTPUT_CONFLICT = 0x00000031  # An <API>SetTrigger call has found a conflict between the trigger source and the AUX output enable.
PICO_AUX_OUTPUT_ETS_CONFLICT = 0x00000032  # ETS mode is being used and AUX is set as an input.
PICO_WARNING_EXT_THRESHOLD_CONFLICT = 0x00000033  # Attempt to set different EXT input thresholds set for signal generator and oscilloscope trigger.
PICO_WARNING_AUX_OUTPUT_CONFLICT = 0x00000034  # An <API>SetTrigger... function has set AUX as an output and the signal generator is using it as a trigger.
PICO_SIGGEN_OUTPUT_OVER_VOLTAGE = 0x00000035  # The combined peak to peak voltage and the analog offset voltage exceed the maximum voltage the signal generator can produce.
PICO_DELAY_NULL = 0x00000036  # NULL pointer passed as delay parameter.
PICO_INVALID_BUFFER = 0x00000037  # The buffers for overview data have not been set while streaming.
PICO_SIGGEN_OFFSET_VOLTAGE = 0x00000038  # The analog offset voltage is out of range.
PICO_SIGGEN_PK_TO_PK = 0x00000039  # The analog peak-to-peak voltage is out of range.
PICO_CANCELLED = 0x0000003A  # A block collection has been cancelled.
PICO_SEGMENT_NOT_USED = 0x0000003B  # The segment index is not currently being used.
PICO_INVALID_CALL = 0x0000003C  # The wrong GetValues function has been called for the collection mode in use.
PICO_GET_VALUES_INTERRUPTED = 0x0000003D  
PICO_NOT_USED = 0x0000003F  # The function is not available.
PICO_INVALID_SAMPLERATIO = 0x00000040  # The aggregation ratio requested is out of range.
PICO_INVALID_STATE = 0x00000041  # Device is in an invalid state.
PICO_NOT_ENOUGH_SEGMENTS = 0x00000042  # The number of segments allocated is fewer than the number of captures requested.
PICO_DRIVER_FUNCTION = 0x00000043  # A driver function has already been called and not yet finished. Only one call to the driver can be made at any one time.
PICO_RESERVED = 0x00000044  # Not used
PICO_INVALID_COUPLING = 0x00000045  # An invalid coupling type was specified in <API>SetChannel.
PICO_BUFFERS_NOT_SET = 0x00000046  # An attempt was made to get data before a data buffer was defined.
PICO_RATIO_MODE_NOT_SUPPORTED = 0x00000047  # The selected downsampling mode (used for data reduction) is not allowed.
PICO_RAPID_NOT_SUPPORT_AGGREGATION = 0x00000048  # Aggregation was requested in rapid block mode.
PICO_INVALID_TRIGGER_PROPERTY = 0x00000049  # An invalid parameter was passed to <API>SetTriggerChannelProperties.
PICO_INTERFACE_NOT_CONNECTED = 0x0000004A  # The driver was unable to contact the oscilloscope.
PICO_RESISTANCE_AND_PROBE_NOT_ALLOWED = 0x0000004B  # Resistance-measuring mode is not allowed in conjunction with the specified probe.
PICO_POWER_FAILED = 0x0000004C  # The device was unexpectedly powered down.
PICO_SIGGEN_WAVEFORM_SETUP_FAILED = 0x0000004D  # A problem occurred in <API>SetSigGenBuiltIn or <API>SetSigGenArbitrary.
PICO_FPGA_FAIL = 0x0000004E  # FPGA not successfully set up.
PICO_POWER_MANAGER = 0x0000004F  
PICO_INVALID_ANALOGUE_OFFSET = 0x00000050  # An impossible analog offset value was specified in <API>SetChannel.
PICO_PLL_LOCK_FAILED = 0x00000051  # There is an error within the device hardware.
PICO_ANALOG_BOARD = 0x00000052  # There is an error within the device hardware.
PICO_CONFIG_FAIL_AWG = 0x00000053  # Unable to configure the signal generator.
PICO_INITIALISE_FPGA = 0x00000054  # The FPGA cannot be initialized, so unit cannot be opened.
PICO_EXTERNAL_FREQUENCY_INVALID = 0x00000056  # The frequency for the external clock is not within 15% of the nominal value.
PICO_CLOCK_CHANGE_ERROR = 0x00000057  # The FPGA could not lock the clock signal.
PICO_TRIGGER_AND_EXTERNAL_CLOCK_CLASH = 0x00000058  # You are trying to configure the AUX input as both a trigger and a reference clock.
PICO_PWQ_AND_EXTERNAL_CLOCK_CLASH = 0x00000059  # You are trying to congfigure the AUX input as both a pulse width qualifier and a reference clock.
PICO_UNABLE_TO_OPEN_SCALING_FILE = 0x0000005A  # The requested scaling file cannot be opened.
PICO_MEMORY_CLOCK_FREQUENCY = 0x0000005B  # The frequency of the memory is reporting incorrectly.
PICO_I2C_NOT_RESPONDING = 0x0000005C  # The I2C that is being actioned is not responding to requests.
PICO_NO_CAPTURES_AVAILABLE = 0x0000005D  # There are no captures available and therefore no data can be returned.
PICO_NOT_USED_IN_THIS_CAPTURE_MODE = 0x0000005E  # The capture mode the device is currently running in does not support the current request.
PICO_TOO_MANY_TRIGGER_CHANNELS_IN_USE = 0x0000005F  # The number of trigger channels is greater than 4, except for a PS4824 where 8 channels are allowed for rising/falling/rising_or_falling trigger directions.
PICO_INVALID_TRIGGER_DIRECTION = 0x00000060  # When more than 4 trigger channels are set on a PS4824 and the direction is out of range. 
PICO_INVALID_TRIGGER_STATES = 0x00000061  #  When more than 4 trigger channels are set and their trigger condition states are not <API>_CONDITION_TRUE.
PICO_GET_DATA_ACTIVE = 0x00000103  
PICO_IP_NETWORKED = 0x00000104  # The device is currently connected via the IP Network socket and thus the call made is not supported.
PICO_INVALID_IP_ADDRESS = 0x00000105  # An incorrect IP address has been passed to the driver.
PICO_IPSOCKET_FAILED = 0x00000106  # The IP socket has failed.
PICO_IPSOCKET_TIMEDOUT = 0x00000107  # The IP socket has timed out.
PICO_SETTINGS_FAILED = 0x00000108  # Failed to apply the requested settings.
PICO_NETWORK_FAILED = 0x00000109  # The network connection has failed.
PICO_WS2_32_DLL_NOT_LOADED = 0x0000010A  # Unable to load the WS2 DLL.
PICO_INVALID_IP_PORT = 0x0000010B  # The specified IP port is invalid.
PICO_COUPLING_NOT_SUPPORTED = 0x0000010C  # The type of coupling requested is not supported on the opened device. 
PICO_BANDWIDTH_NOT_SUPPORTED = 0x0000010D  # Bandwidth limiting is not supported on the opened device.
PICO_INVALID_BANDWIDTH = 0x0000010E  # The value requested for the bandwidth limit is out of range.
PICO_AWG_NOT_SUPPORTED = 0x0000010F  # The arbitrary waveform generator is not supported by the opened device.
PICO_ETS_NOT_RUNNING = 0x00000110  # Data has been requested with ETS mode set but run block has not been called, or stop has been called.
PICO_SIG_GEN_WHITENOISE_NOT_SUPPORTED = 0x00000111  # White noise output is not supported on the opened device.
PICO_SIG_GEN_WAVETYPE_NOT_SUPPORTED = 0x00000112  # The wave type requested is not supported by the opened device.
PICO_INVALID_DIGITAL_PORT = 0x00000113  # The requested digital port number is out of range (MSOs only).
PICO_INVALID_DIGITAL_CHANNEL = 0x00000114  # The digital channel is not in the range <API>_DIGITAL_CHANNEL0 to <API>_DIGITAL_CHANNEL15, the digital channels that are supported.
PICO_INVALID_DIGITAL_TRIGGER_DIRECTION = 0x00000115  # The digital trigger direction is not a valid trigger direction and should be equal in value to one of the <API>_DIGITAL_DIRECTION enumerations.
PICO_SIG_GEN_PRBS_NOT_SUPPORTED = 0x00000116  # Signal generator does not generate pseudo-random binary sequence.
PICO_ETS_NOT_AVAILABLE_WITH_LOGIC_CHANNELS = 0x00000117  # When a digital port is enabled, ETS sample mode is not available for use.
PICO_WARNING_REPEAT_VALUE = 0x00000118
PICO_POWER_SUPPLY_CONNECTED = 0x00000119  # 4-channel scopes only: The DC power supply is connected.
PICO_POWER_SUPPLY_NOT_CONNECTED = 0x0000011A  # 4-channel scopes only: The DC power supply is not connected.
PICO_POWER_SUPPLY_REQUEST_INVALID = 0x0000011B  # Incorrect power mode passed for current power source.
PICO_POWER_SUPPLY_UNDERVOLTAGE = 0x0000011C  # The supply voltage from the USB source is too low.
PICO_CAPTURING_DATA = 0x0000011D  # The oscilloscope is in the process of capturing data.
PICO_USB3_0_DEVICE_NON_USB3_0_PORT = 0x0000011E  # A USB 3.0 device is connected to a non-USB 3.0 port.
PICO_NOT_SUPPORTED_BY_THIS_DEVICE = 0x0000011F  # A function has been called that is not supported by the current device.
PICO_INVALID_DEVICE_RESOLUTION = 0x00000120  # The device resolution is invalid (out of range).
PICO_INVALID_NUMBER_CHANNELS_FOR_RESOLUTION = 0x00000121  # The number of channels that can be enabled is limited in 15 and 16-bit modes. (Flexible Resolution Oscilloscopes only)
PICO_CHANNEL_DISABLED_DUE_TO_USB_POWERED = 0x00000122  # USB power not sufficient for all requested channels.
PICO_SIGGEN_DC_VOLTAGE_NOT_CONFIGURABLE = 0x00000123  # The signal generator does not have a configurable DC offset.
PICO_NO_TRIGGER_ENABLED_FOR_TRIGGER_IN_PRE_TRIG = 0x00000124  # An attempt has been made to define pre-trigger delay without first enabling a trigger.
PICO_TRIGGER_WITHIN_PRE_TRIG_NOT_ARMED = 0x00000125  # An attempt has been made to define pre-trigger delay without first arming a trigger.
PICO_TRIGGER_WITHIN_PRE_NOT_ALLOWED_WITH_DELAY = 0x00000126  # Pre-trigger delay and post-trigger delay cannot be used at the same time.
PICO_TRIGGER_INDEX_UNAVAILABLE = 0x00000127  # The array index points to a nonexistent trigger.
PICO_AWG_CLOCK_FREQUENCY = 0x00000128
PICO_TOO_MANY_CHANNELS_IN_USE = 0x00000129  # There are more 4 analog channels with a trigger condition set.
PICO_NULL_CONDITIONS = 0x0000012A  # The condition parameter is a null pointer.
PICO_DUPLICATE_CONDITION_SOURCE = 0x0000012B  # There is more than one condition pertaining to the same channel.
PICO_INVALID_CONDITION_INFO = 0x0000012C  # The parameter relating to condition information is out of range.
PICO_SETTINGS_READ_FAILED = 0x0000012D  # Reading the metadata has failed.
PICO_SETTINGS_WRITE_FAILED = 0x0000012E  # Writing the metadata has failed.
PICO_ARGUMENT_OUT_OF_RANGE = 0x0000012F  # A parameter has a value out of the expected range.
PICO_HARDWARE_VERSION_NOT_SUPPORTED = 0x00000130  # The driver does not support the hardware variant connected.
PICO_DIGITAL_HARDWARE_VERSION_NOT_SUPPORTED = 0x00000131  # The driver does not support the digital hardware variant connected.
PICO_ANALOGUE_HARDWARE_VERSION_NOT_SUPPORTED = 0x00000132  # The driver does not support the analog hardware variant connected.
PICO_UNABLE_TO_CONVERT_TO_RESISTANCE = 0x00000133  # Converting a channel's ADC value to resistance has failed.
PICO_DUPLICATED_CHANNEL = 0x00000134  # The channel is listed more than once in the function call.
PICO_INVALID_RESISTANCE_CONVERSION = 0x00000135  # The range cannot have resistance conversion applied.
PICO_INVALID_VALUE_IN_MAX_BUFFER = 0x00000136  # An invalid value is in the max buffer.
PICO_INVALID_VALUE_IN_MIN_BUFFER = 0x00000137  # An invalid value is in the min buffer.
PICO_SIGGEN_FREQUENCY_OUT_OF_RANGE = 0x00000138  # When calculating the frequency for phase conversion, the frequency is greater than that supported by the current variant.
PICO_EEPROM2_CORRUPT = 0x00000139  # The device's EEPROM is corrupt. Contact Pico Technology support: https://www.picotech.com/tech-support.
PICO_EEPROM2_FAIL = 0x0000013A  # The EEPROM has failed.
PICO_SERIAL_BUFFER_TOO_SMALL = 0x0000013B  # The serial buffer is too small for the required information.
PICO_SIGGEN_TRIGGER_AND_EXTERNAL_CLOCK_CLASH = 0x0000013C  # The signal generator trigger and the external clock have both been set. This is not allowed.
PICO_WARNING_SIGGEN_AUXIO_TRIGGER_DISABLED = 0x0000013D  # The AUX trigger was enabled and the external clock has been enabled, so the AUX has been automatically disabled.
PICO_SIGGEN_GATING_AUXIO_NOT_AVAILABLE = 0x00000013E  # The AUX I/O was set as a scope trigger and is now being set as a signal generator gating trigger. This is not allowed.
PICO_SIGGEN_GATING_AUXIO_ENABLED = 0x00000013F  # The AUX I/O was set by the signal generator as a gating trigger and is now being set as a scope trigger. This is not allowed.
PICO_RESOURCE_ERROR = 0x00000140  # A resource has failed to initialise
PICO_TEMPERATURE_TYPE_INVALID = 0x000000141  # The temperature type is out of range
PICO_TEMPERATURE_TYPE_NOT_SUPPORTED = 0x000000142  # A requested temperature type is not supported on this device
PICO_TIMEOUT = 0x00000143  # A read/write to the device has timed out
PICO_DEVICE_NOT_FUNCTIONING = 0x00000144  # The device cannot be connected correctly
PICO_INTERNAL_ERROR = 0x00000145  # The driver has experienced an unknown error and is unable to recover from this error
PICO_MULTIPLE_DEVICES_FOUND = 0x00000146  # Used when opening units via IP and more than multiple units have the same ip address
PICO_WARNING_NUMBER_OF_SEGMENTS_REDUCED = 0x00000147
PICO_CAL_PINS_STATES = 0x00000148  # the calibration pin states argument is out of range
PICO_CAL_PINS_FREQUENCY = 0x00000149  # the calibration pin frequency argument is out of range
PICO_CAL_PINS_AMPLITUDE = 0x0000014A  # the calibration pin amplitude argument is out of range
PICO_CAL_PINS_WAVETYPE = 0x0000014B  # the calibration pin wavetype argument is out of range
PICO_CAL_PINS_OFFSET = 0x0000014C  # the calibration pin offset argument is out of range
PICO_PROBE_FAULT = 0x0000014D  # the probe's identity has a problem
PICO_PROBE_IDENTITY_UNKNOWN = 0x0000014E  # the probe has not been identified
PICO_PROBE_POWER_DC_POWER_SUPPLY_REQUIRED = 0x0000014F  # enabling the probe would cause the device to exceed the allowable current limit
PICO_PROBE_NOT_POWERED_WITH_DC_POWER_SUPPLY = 0x00000150  # the DC power supply is connected; enabling the probe would cause the device to exceed the allowable current limit
PICO_PROBE_CONFIG_FAILURE = 0x00000151  # failed to complete probe configuration
PICO_PROBE_INTERACTION_CALLBACK = 0x00000152  # failed to set the callback function, as currently in current callback function
PICO_UNKNOWN_INTELLIGENT_PROBE = 0x00000153  # the probe has been verified but not known on this driver
PICO_INTELLIGENT_PROBE_CORRUPT =	0x00000154  # the intelligent probe cannot be verified
PICO_PROBE_COLLECTION_NOT_STARTED = 0x00000155  # the callback is null, probe collection will only start when first callback is a not a null pointer
PICO_PROBE_POWER_CONSUMPTION_EXCEEDED = 0x00000156  # the current drawn by the probe(s) has exceeded the allowed limit
PICO_WARNING_PROBE_CHANNEL_OUT_OF_SYNC = 0x00000157  # the channel range limits have changed due to connecting or disconnecting a probe the channel has been enabled
PICO_DEVICE_TIME_STAMP_RESET = 0x01000000  # The time stamp per waveform segment has been reset.
PICO_WATCHDOGTIMER = 0x10000000  # An internal erorr has occurred and a watchdog timer has been called.
PICO_IPP_NOT_FOUND = 0x10000001  # The picoipp.dll has not been found.
PICO_IPP_NO_FUNCTION = 0x10000002  # A function in the picoipp.dll does not exist.
PICO_IPP_ERROR = 0x10000003  # The Pico IPP call has failed.
PICO_SHADOW_CAL_NOT_AVAILABLE = 0x10000004  # Shadow calibration is not available on this device.
PICO_SHADOW_CAL_DISABLED = 0x10000005  # Shadow calibration is currently disabled.
PICO_SHADOW_CAL_ERROR = 0x10000006  # Shadow calibration error has occurred.
PICO_SHADOW_CAL_CORRUPT = 0x10000007  # The shadow calibration is corrupt.
PICO_DEVICE_MEMORY_OVERFLOW = 0x10000008  # the memory onboard the device has overflowed
# PICO_RESERVED_1 = 0x11000000


##
#From ps2000con.c (C sample code)
BUFFER_SIZE=1024
BUFFER_SIZE_STREAMING=50000
NUM_STREAMING_SAMPLES=100000000
MAX_CHANNELS 4
SINGLE_CH_SCOPE=1
DUAL_SCOPE=2

AWG_MAX_BUFFER_SIZE = 4096
AWG_DAC_FREQUENCY = 2e6
AWG_DDS_FREQUENCY = 48e6
AWG_PHASE_ACCUMULATOR = 4294967296.0

##
#From ps2000.h (SDK's headers)
PS2000_FIRST_USB = 1
PS2000_LAST_USB = 127
PS2000_MAX_UNITS = (PS2000_LAST_USB - PS2000_FIRST_USB + 1)
PS2000_MAX_TIMEBASE = 19

PS2105_MAX_TIMEBASE = 20
PS2104_MAX_TIMEBASE = 19

PS2200_MAX_TIMEBASE = 23

PS2000_MAX_OVERSAMPLE = 256

PS2105_MAX_ETS_CYCLES = 250
PS2105_MAX_ETS_INTERLEAVE = 50

PS2104_MAX_ETS_CYCLES = 125
PS2104_MAX_ETS_INTERLEAVE = 25

PS2203_MAX_ETS_CYCLES = 250
PS2203_MAX_ETS_INTERLEAVE = 50

PS2204_MAX_ETS_CYCLES = 250
PS2204_MAX_ETS_INTERLEAVE = 40

PS2205_MAX_ETS_CYCLES = 250
PS2205_MAX_ETS_INTERLEAVE = 40

PS2000_MIN_ETS_CYCLES_INTERLEAVE_RATIO = 1
PS2000_MAX_ETS_CYCLES_INTERLEAVE_RATIO = 10

PS2000_MIN_SIGGEN_FREQ = 0.0
PS2000_MAX_SIGGEN_FREQ = 100000.0

PS2000_MAX_VALUE = 32767
PS2000_MIN_VALUE = -32767
PS2000_LOST_DATA = -32768



	

#Using symbol :string is not compatible with JRuby (Java Ruby), see ffi's docs for more details
#Use :pointer instead

module PS2000
	extend FFI::Library
	ffi_lib 'ps2000.dll'
	
	##
	#List of enum (ps2000.h)
	enum :PS2000_CHANNEL, [:PS2000_CHANNEL_A, :PS2000_CHANNEL_B, :PS2000_CHANNEL_C, :PS2000_CHANNEL_D, :PS2000_EXTERNAL, :PS2000_MAX_CHANNELS, 4, :PS2000_NONE]
	enum :PS2000_RANGE, [:PS2000_10MV, :PS2000_20MV, :PS2000_50MV, :PS2000_100MV, :PS2000_200MV, :PS2000_500MV, :PS2000_1V, :PS2000_2V, :PS2000_5V, :PS2000_10V, :PS2000_20V, :PS2000_50V, :PS2000_MAX_RANGES]
	enum :PS2000_TIME_UNITS, [:PS2000_FS, :PS2000_PS, :PS2000_NS, :PS2000_US, :PS2000_MS, :PS2000_S, :PS2000_MAX_TIME_UNITS]
	enum :PS2000_ERROR, [ :PS2000_OK, :PS2000_MAX_UNITS_OPENED, :PS2000_MEM_FAIL, :PS2000_NOT_FOUND, :PS2000_FW_FAIL, :PS2000_NOT_RESPONDING, :PS2000_CONFIG_FAIL, :PS2000_OS_NOT_SUPPORTED, :PS2000_PICOPP_TOO_OLD]
	enum :PS2000_INFO, [:PS2000_DRIVER_VERSION, :PS2000_USB_VERSION, :PS2000_HARDWARE_VERSION, :PS2000_VARIANT_INFO, :PS2000_BATCH_AND_SERIAL, :PS2000_CAL_DATE, :PS2000_ERROR_CODE, :PS2000_KERNEL_DRIVER_VERSION, :PS2000_DRIVER_PATH]
	enum :PS2000_TDIR, [ :PS2000_RISING, :PS2000_FALLINF, :PS2000_MAX_DIRS]
	enum :PS2000_OPEN_PROGRESS, [:PS2000_OPEN_PROGRESS_FAIL, -1, :PS200_OPEN_PROGRESS_PENDING, 0, :PS2000_OPEN_PROGRESS_COMPLETE, 1]
	enum :PS2000_ETS_MODE, [:PS2000_ETS_OFF, :PS2000_ETS_FAST, :PS2000_ETS_SLOW, :PS2000_ETS_MODES_MAX]
	enum :PS2000_BUTTON_STATE, [:PS2000_NO_PRESS, :PS2000_SHORT_PRESS, :PS2000_LONG_PRESS]
	enum :PS2000_SWEEP_TYPE, [:PS2000_UP, :PS2000_DOWN, :PS2000_UPDOWN, :PS2000_DOWNUP, :PS2000_MAX_SWEEP_TYPES]  #in 'ps2000.h', it's MAX_SWEEP_TYPES without PS2000 ahead
	enum :PS2000_WAVE_TYPE, [:PS2000_SINE, :PS2000_SQUARE, :PS2000_TRIANGLE, :PS2000_RAMPUP, :PS2000_RAMPDOWN, :PS2000_DC_VOLTAGE, :PS2000_GAUSSIAN, :PS2000_SINC, :PS2000_HALF_SINE, :PS2000_WAVE_TYPE]
	
	#TODO: translate this code defining a type which point to a function  (Use Pointers to Functions (Structures in ffi 's doc)? callback pointer)
	# typedef void (PREF4 *GetOverviewBuffersMaxMin)
	# (
	  # int16_t **overviewBuffers,
	  # int16_t   overflow,
	  # uint32_t  triggeredAt,
	  # int16_t   triggered,
	  # int16_t   auto_stop,
	  # uint32_t  nValues
	# );
	
	##
	#Functions from ps2000.h
	attach_function :ps2000_open_unit, [], :int16
	attach_function :ps2000_get_unit_info, [:int16, :string, :int16, :int16], :int16 #really using :string? (string of int8)?
	attach_function :ps2000_flash_led, [:int16], :int16
	attach_function :ps2000_close_unit, [:int16], :int16
	attach_function :ps2000_set_channel, [:int16, :int16, :int16, :int16, :int16], :int16
	attach_function :ps2000_get_timebase, [:int16, :int16, :int32, :pointer, :pointer, :int16, :pointer], :int16 #pointer -> int32 int16 int32
	attach_function :ps2000_set_trigger, [:int16, :int16, :int16, :int16, :int16, :int16], :int16
	attach_function :ps2000_set_trigger2, [:int16, :int16, :int16, :int16, :float, :int16], :int16
	attach_function :ps2000_run_block, [:int16, :int32, :int16, :int16, :pointer], :int16 #pointer -> int32
	attach_function :ps2000_run_streaming, [:int16, :int16, :int32, :int16], :int16
	attach_function :ps2000_run_streaming_ns, [:int16, :uint32, :PS2000_TIME_UNITS, :uint32, :int16, :uint32, :uint32], :int16
	#attach_function :ps2000_run_streaming_ns, [:int16, :uint32, :int32, :uint32, :int16, :uint32, :uint32], :int16
	attach_function :ps2000_ready, [:int16], :int16
	attach_function :ps2000_stop, [:int16], :int16
	attach_function :ps2000_get_values, [:int16, :pointer, :pointer, :pointer, :pointer, :pointer, :int32], :int32 #pointer -> int16 int16 int16 int16 int16
	attach_function :ps2000_get_times_and_values, [:int16, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer :int16, :int32], :int32 #pointer -> int16 int16 int16 int16 int16 int16
	attach_function :ps2000_last_button_press, [:int16], :int16
	attach_function :ps2000_set_ets, [:int16, :int16, :int16, :int16], :int32
	attach_function :ps2000_set_led, [:int16, :int16], :int16
	attach_function :ps2000_open_unit_async, [], :int16
	attach_function :ps2000_open_unit_progress, [:pointer, :pointer], :int16 #pointer -> :int16, :int16
	# attach_function :ps2000_get_streaming_last_values, [:int16, :GetOverviewBuffersMaxMin], :int16 #need to create type :GetOverviewBuffersMaxMin
	attach_function :ps2000_overview_buffer_status, [:int16, :pointer], :int16 #pointer -> int16
	attach_function :ps2000_get_streaming_values, [:int16, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :uint32, :uint32], :uint32 #pointer -> double, int16, int16 int16, int16 int16, int16 int16, int16  int16, uint32 int16
	attach_function :ps2000_get_streaming_values_no_aggregation, [:int16, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :uint32], :uint32 #pointer -> double int16 int16 int16 int16 int16 uint32 int16 
	attach_function :ps2000_set_light, [:int16, :int16], :int16
	attach_function :ps2000_set_sig_gen_arbitrary, [:int16, :int16, :uint32, :uint32, :uint32, :uint32, :uint32, :uint8, :int32, :PS2000_SWEEP_TYPE, ::uint32], :int16
	attach_function :ps2000_set_sig_gen_built_in, [:int16, :int32, :uint32, :PS2000_WAVE_TYPE, :float, :float, :float, :float, :PS2000_SWEEP_TYPE, :uint32], :int16
	
	enum :PS2000_THRESHOLD_DIRECTION, [:PS2000_ABOVE, :PS2000_BELOW, :PS2000_ADV_RISING, :PS2000_ADV_FALLING, :PS2000_RISING_OR_FALLING, :PS2000_INSIDE, 0, :PS2000_OUTSIDE, 1, :PS2000_ENTER, 2, :PS2000_EXIT, 3,:PS2000_ENTER_OR_EXIT, 4, :PS2000_ADV_NONE, 2]
	enum :PS2000_THRESHOLD_MODE, [:PS2000_LEVEL, :PS2000_WINDOW]
	enum :PS2000_TRIGGER_STATE, [:PS2000_CONDITION_DONT_CARE, :PS2000_CONDITION_TRUE, :PS2000_CONDITION_FALSE, :PS2000_CONDITION_MAX]
	enum :PS2000_PULSE_WIDTH_TYPE, [:PS2000_PW_TYPE_NONE, :PS2000_PW_TYPE_LESS_THAN, :PS2000_PW_TYPE_GREATER_THAN, :PS2000_PW_TYPE_IN_RANGE, :PS2000_PW_TYPE_OUT_OF_RANGE]
	
	class PS2000_TRIGGER_CHANNEL_PROPERTIES < FFI::Struct
		layout :thresholdMajor, :int16,
				:thresholdMinor, :int16,
				:hysteresis, :uint16,
				:channel, :int16,
				:thresholdMode, :PS2000_THRESHOLD_MODE
	end
	
	class PS2000_TRIGGER_CONDITIONS < FFI::Struct
		layout :channelA, :PS2000_TRIGGER_STATE,
			:channelB, :PS2000_TRIGGER_STATE,
			:channelC, :PS2000_TRIGGER_STATE,
			:channelD, :PS2000_TRIGGER_STATE,
			:external, :PS2000_TRIGGER_STATE,
			:pulseWidthQualifier, :PS2000_TRIGGER_STATE
	end
	
	class PS2000_PWQ_CONDITIONS < FFI::Struct
		layout :channelA, :PS2000_TRIGGER_STATE,
			:channelB, :PS2000_TRIGGER_STATE,
			:channelC, :PS2000_TRIGGER_STATE,
			:channelD, :PS2000_TRIGGER_STATE,
			:external, :PS2000_TRIGGER_STATE
	end
	
	attach_function :ps2000SetAdvTriggerChannelProperties, [:int16, :pointer, :int16, :int32], :int16 #pointer -> :PS2000_TRIGGER_CHANNEL_PROPERTIES
	attach_function :ps2000SetAdvTriggerChannelConditions, [:int16, :pointer, :int16], :int16 #pointer -> :PS2000_TRIGGER_CONDITIONS
	attach_function :ps2000SetAdvTriggerChannelDirections, [:int16, :PS2000_THRESHOLD_DIRECTION, :PS2000_THRESHOLD_DIRECTION, :PS2000_THRESHOLD_DIRECTION, :PS2000_THRESHOLD_DIRECTION, :PS2000_THRESHOLD_DIRECTION], :int16
	attach_function :ps2000SetPulseWidthQualifier, [:int16, :PS2000_PWQ_CONDITIONS, :int16, :PS2000_THRESHOLD_DIRECTION, :uint32, :uint32, :PS2000_PULSE_WIDTH_TYPE], :int16 #pointer ->PS2000_PWQ_CONDITION
	attach_function :ps2000SetAdvTriggerDelay, [:int16, :uint32, :float], :int16
	attach_function :ps2000PingUnit, [:int16], :int16
	
	##
	#Struct and enums from 'ps2000con.c' (C sample code)
	
	enum :MODEL_TYPE, [:MODEL_NONE, :MODEL_PS2104, 2104, :MODEL_PS2105, 2105, :MODEL_PS2202, 2202, :MODEL_PS2203, 2203, :MODEL_PS2204, 2204, :MODEL_PS2205, 2205, :MODEL_PS2204A, 0xA204, :MODEL_PS2205A, 0xA205]
	
	class DIRECTIONS < FFI::Struct
		layout :channelA, :PS2000_THRESHOLD_DIRECTION,
			:channelB, :PS2000_THRESHOLD_DIRECTION,
			:channelC, :PS2000_THRESHOLD_DIRECTION,
			:channelD, :PS2000_THRESHOLD_DIRECTION,
			:ext, :PS2000_THRESHOLD_DIRECTION
	end
	
	class PULSE_WIDTH_QUALIFIER < FFI::Struct
		layout :conditions, :pointer,
			:nConditions, :int16,
			:direction, :PS2000_THRESHOLD_DIRECTION,
			:lower, :uint32,
			:upper, :uint32,
			:type, :PS2000_PULSE_WIDTH_TYPE
	end
	
	class SIMPLE < FFI::Struct
		layout :channel, :PS2000_CHANNEL,
			:threshold, :float,
			:direction, :int16,
			:delay, :float
	end
	
	class ADVANCED < FFI::Struct
		layout :hysteresis, :int16,
			:directions, DIRECTIONS,
			:nProperties, :int16,
			:conditions, :pointer,
			:channelProperties, :pointer,
			:pwq, PULSE_WIDTH_QUALIFIER,
			:totalSamples, :uint32,
			:autoStop, :int16,
			:trigerred, :int16
	end
	
	class TRIGGER_CHANNEL < FFI::Struct
		layout :simple, SIMPLE,
			:advanced, ADVANCED
	end
	
	class CHANNEL_SETTINGS < FFI::Struct
		layout :DCoupled, :int16,
			:range, :int16,
			:enabled, :int16,
			:values, [:int16, BUFFER_SIZE]
	end
	
	class UNIT_MODEL < FFI::Struct
		layout :handle, :int16,
			:model, :MODEL_TYPE,
			:firstRange, :PS2000_RANGE,
			:lastRange, :PS2000_RANGE,
			:trigger, TRIGGER_CHANNEL,
			:maxTimebase, :int16,
			:timebases, :int16,
			:noOfChannels, :int16,
			:channelSettings, [CHANNEL_SETTINGS, 4], # PS2000_MAX_CHANNELS=4
			:hasAdvancedTriggering, :int16,
			:hasFastStreaming, :int16,
			:hasEts, :int16,
			:hasSignalGenerator, :int16,
			:awgBufferSize, :int16
	end
	
	class BUFFER_INFO < FFI::Struct
		layout :unit, UNIT_MODEL,
			:appBuffers, [:pointer, DUAL_SCOPE*2],
			:bufferSizes, [:uint32, 4] # PS2000_MAX_CHANNELS=4
	end
	
	def PS2000.const_missing(sym)
		
		value = enum_value(sym)
		
		return super unless value
		
		value
	
	end
	
end