package audio

import "core:fmt"
// https://miniaud.io/docs/
import ma "vendor:miniaudio"

// 0 - Use native channel count of the device
AUDIO_CHANNELS :: 0
AUDIO_SAMPLE_RATE :: 0
// miniaudio supports decoding WAV, MP3 and FLAC out of the box
AUDIO_FILE :: #load("./tree_falling.mp3")
BACKGROUND_MUSIC_FILE :: #load("./beaver_theme_song.mp3")

// Engine - high level API
engine: ma.engine

// Sound effect objects
decoder: ma.decoder
sound: ma.sound

// Background music objects
bg_decoder: ma.decoder
bg_music: ma.sound

init_audio :: proc() {
	// Initialize the audio engine
	engine_config := ma.engine_config_init()
	engine_config.channels = AUDIO_CHANNELS
	engine_config.sampleRate = AUDIO_SAMPLE_RATE
	engine_config.listenerCount = 1

	engine_init_result := ma.engine_init(&engine_config, &engine)
	if engine_init_result != .SUCCESS {
		fmt.panicf("failed to init miniaudio engine: %v", engine_init_result)
	}
	engine_start_result := ma.engine_start(&engine)
	if engine_start_result != .SUCCESS {
		fmt.panicf("failed to start miniaudio engine: %v", engine_start_result)
	}

	// Initialize sound effect decoder
	init_decoder(AUDIO_FILE, &decoder)
	init_sound(&decoder, &sound)

	// Initialize background music decoder
	init_decoder(BACKGROUND_MUSIC_FILE, &bg_decoder)
	init_sound(&bg_decoder, &bg_music)


	ma.sound_set_volume(&bg_music, 1)
	ma.sound_set_volume(&sound, 0.2)
	ma.sound_set_looping(&bg_music, true)
	// ma.sound_start(&bg_music)
}

init_decoder :: proc(file: []u8, decoder: ^ma.decoder) {
	decoder_config := ma.decoder_config_init(
		outputFormat = .f32,
		outputChannels = AUDIO_CHANNELS,
		outputSampleRate = AUDIO_SAMPLE_RATE,
	)
	decoder_config.encodingFormat = .mp3

	decoder_result := ma.decoder_init_memory(
		pData = raw_data(file),
		dataSize = len(file),
		pConfig = &decoder_config,
		pDecoder = decoder,
	)
	if decoder_result != .SUCCESS {
		fmt.panicf("failed to init decoder: %v", decoder_result)
	}
}

init_sound :: proc(decoder: ^ma.decoder, sound: ^ma.sound) {
	sound_result := ma.sound_init_from_data_source(
		pEngine = &engine,
		pDataSource = decoder.ds.pCurrent,
		flags = 0,
		pGroup = nil,
		pSound = sound,
	)
	if sound_result != .SUCCESS {
		fmt.panicf("failed to init sound file from memory: %v", sound_result)
	}
}

play_audio :: proc() {
	ma.sound_start(&sound)
}
