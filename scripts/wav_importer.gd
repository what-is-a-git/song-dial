## Credit: https://github.com/Gianclgar/GDScriptAudioImport
class_name WAVImporter extends Node

static func parse_wave(bytes: PackedByteArray) -> Option:
	# if File is wav
	var newstream := AudioStreamWAV.new()
	
	#---------------------------
	#parrrrseeeeee!!! :D
	
	var bits_per_sample = 0
	var i = 0
	while true:
		if i >= len(bytes) - 4: # Failsafe, if there is no data bytes
			print("Data byte not found")
			break
			
		var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
		
		if those4bytes == "RIFF": 
			print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
			#RIP bytes 4-7 integer for now
		if those4bytes == "WAVE": 
			print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))

		if those4bytes == "fmt ":
			print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
			
			#get format subchunk size, 4 bytes next to "fmt " are an int32
			var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
			print ("Format subchunk size: " + str(formatsubchunksize))
			
			#using formatsubchunk index so it's easier to understand what's going on
			var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

			#get format code [Bytes 0-1]
			var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
			var format_name
			if format_code == 0: format_name = "8_BITS"
			elif format_code == 1: format_name = "16_BITS"
			elif format_code == 2: format_name = "IMA_ADPCM"
			else: 
				format_name = "UNKNOWN (trying to interpret as 16_BITS)"
				format_code = 1
			print ("Format: " + str(format_code) + " " + format_name)
			#assign format to our AudioStreamSample
			newstream.format = format_code
			
			#get channel num [Bytes 2-3]
			var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
			print ("Number of channels: " + str(channel_num))
			#set our AudioStreamSample to stereo if needed
			if channel_num == 2: newstream.stereo = true
			
			#get sample rate [Bytes 4-7]
			var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
			print ("Sample rate: " + str(sample_rate))
			#set our AudioStreamSample mixrate
			newstream.mix_rate = sample_rate
			
			#get byte_rate [Bytes 8-11] because we can
			var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
			print ("Byte rate: " + str(byte_rate))
			
			#same with bits*sample*channel [Bytes 12-13]
			var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
			print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
			
			#aaaand bits per sample/bitrate [Bytes 14-15]
			bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
			print ("Bits per sample: " + str(bits_per_sample))
			
		if those4bytes == "data":
			assert(bits_per_sample != 0)
			
			var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
			print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

			var data_entry_point = (i+8)
			print ("Audio data starts at byte " + str(data_entry_point))
			
			assert(data_entry_point < data_entry_point+audio_data_size-1)
			var data := bytes.slice(data_entry_point, data_entry_point+audio_data_size-1)
			
			if bits_per_sample in [24, 32]:
				newstream.data = convert_to_16bit(data, bits_per_sample)
			else:
				newstream.data = data
			
			break # the data will be at the end, end searching here
		
		i += 1
		# end of parsing
		#---------------------------
	
	assert(bits_per_sample != 0)
	
	#get samples and set loop end
	var samplenum = newstream.data.size() / (bits_per_sample / 8)
	newstream.loop_end = samplenum
	var opt := Option.new()
	opt.value = newstream
	opt.is_some = true
	return opt  #:D

# Converts .wav data from 24 or 32 bits to 16
#
# These conversions are SLOW in GDScript
# on my one test song, 32 -> 16 was around 3x slower than 24 -> 16
#
# I couldn't get threads to help very much
# They made the 24bit case about 2x faster in my test file
# And the 32bit case abour 50% slower
# I don't wanna risk it always being slower on other files
# And really, the solution would be to handle it in a low-level language
static func convert_to_16bit(data: PackedByteArray, from: int) -> PackedByteArray:
	print("converting to 16-bit from %d" % from)
	var time = Time.get_ticks_msec()
	# 24 bit .wav's are typically stored as integers
	# so we just grab the 2 most significant bytes and ignore the other
	if from == 24:
		var j = 0
		for i in range(0, data.size(), 3):
			data[j] = data[i+1]
			data[j+1] = data[i+2]
			j += 2
		data.resize(data.size() * 2 / 3)
	# 32 bit .wav's are typically stored as floating point numbers
	# so we need to grab all 4 bytes and interpret them as a float first
	if from == 32:
		var spb := StreamPeerBuffer.new()
		var single_float: float
		var value: int
		for i in range(0, data.size(), 4):
			spb.data_array = data.slice(i, i+3)
			single_float = spb.get_float()
			value = single_float * 32768
			data[i/2] = value
			data[i/2+1] = value >> 8
		data.resize(data.size() / 2)
	print("Took %f seconds for slow conversion" % ((Time.get_ticks_msec() - time) / 1000.0))
	return data


# ---------- REFERENCE ---------------
# note: typical values doesn't always match

#Positions  Typical Value Description
#
#1 - 4      "RIFF"        Marks the file as a RIFF multimedia file.
#                         Characters are each 1 byte long.
#
#5 - 8      (integer)     The overall file size in bytes (32-bit integer)
#                         minus 8 bytes. Typically, you'd fill this in after
#                         file creation is complete.
#
#9 - 12     "WAVE"        RIFF file format header. For our purposes, it
#                         always equals "WAVE".
#
#13-16      "fmt "        Format sub-chunk marker. Includes trailing null.
#
#17-20      16            Length of the rest of the format sub-chunk below.
#
#21-22      1             Audio format code, a 2 byte (16 bit) integer. 
#                         1 = PCM (pulse code modulation).
#
#23-24      2             Number of channels as a 2 byte (16 bit) integer.
#                         1 = mono, 2 = stereo, etc.
#
#25-28      44100         Sample rate as a 4 byte (32 bit) integer. Common
#                         values are 44100 (CD), 48000 (DAT). Sample rate =
#                         number of samples per second, or Hertz.
#
#29-32      176400        (SampleRate * BitsPerSample * Channels) / 8
#                         This is the Byte rate.
#
#33-34      4             (BitsPerSample * Channels) / 8
#                         1 = 8 bit mono, 2 = 8 bit stereo or 16 bit mono, 4
#                         = 16 bit stereo.
#
#35-36      16            Bits per sample. 
#
#37-40      "data"        Data sub-chunk header. Marks the beginning of the
#                         raw data section.
#
#41-44      (integer)     The number of bytes of the data section below this
#                         point. Also equal to (#ofSamples * #ofChannels *
#                         BitsPerSample) / 8
#
#45+                      The raw audio data.
