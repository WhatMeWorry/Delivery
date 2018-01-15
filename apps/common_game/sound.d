
module sound;

import common;
import common_game;

import derelict.opengl3.gl3;
import gl3n.linalg : mat4, vec2, vec3, vec4; 
import std.random;
import std.stdio;
import std.conv : to;


import std.stdio;
import std.string;
import std.conv;
import derelict.sdl2.sdl;
import derelict.sdl2.mixer;  // import audio functionality

import std.file;
import core.thread;
import core.runtime;
import core.stdc.stdlib;

enum FIRST_FREE_UNRESERVED_CHANNEL = -1;

enum PLAYING = 1;
enum NOT_PLAYING = 0;

enum FOREVER = -1;
enum ONCE = 0;  // 1 = LOOP_TWICE  2 = LOOP_THRICE...

enum MIX_ERROR = -1;
enum SdlError = -1;

enum channels { MONO = 1, STEREO  = 2};

enum PLAYBACK_DEVICES = 0;
enum RECORDING_DEVICES = 1;

enum Sound { MUSIC = 0, SFX };

struct Track
{
    string  file;    // file name of audio file
    Sound   purpose; // music or sound effect
    int     loops;   // number of times to loop
    void*   ptr;     // Mix_Chunk* for sfx;  Mix_Music* for music;  
}

Track[string] tracks;


    //initSound(soundSys, FMOD_LOOP_NORMAL, "../audio/breakout.mp3");  // offset 0
    //initSound(soundSys, FMOD_LOOP_OFF,    "../audio/bleep.mp3");     // offset 1
    //initSound(soundSys, FMOD_LOOP_OFF,    "../audio/solid.wav");     // offset 2
    //initSound(soundSys, FMOD_LOOP_OFF,    "../audio/powerup.wav");   // offset 3
    //initSound(soundSys, FMOD_LOOP_OFF,    "../audio/bleep.wav");     // offset 4

                     // https://audio.online-convert.com/convert-to-wav
void setTitles()     // having trouble with .mp3 and mixer_SDL2
{
    tracks["BREAKOUT"]  = Track("../audio/breakout.wav", Sound.MUSIC, FOREVER, null );
    tracks["SOLID"]     = Track("../audio/solid.wav",    Sound.SFX,   ONCE,    null );	
	tracks["POWERUP"]   = Track("../audio/powerup.wav",  Sound.SFX,   ONCE,    null );
    tracks["BLEEP_WAV"] = Track("../audio/bleep.wav",    Sound.SFX,   ONCE,    null );	
}

/+
    const Track[string] tracks  = 
    [
        "SCRATCH"          : Track("scratch.wav", Sound.SFX, ONCE,    null ),
        "BACKGROUND_SOUND" : Track("beat.wav",    Sound.MUSIC,        FOREVER, null ),
        "HIGH"             : Track("high.wav",    Sound.SFX, ONCE,    null ),	
		"MED"              : Track("medium.wav",  Sound.SFX, ONCE,    null ),
        "LOW"              : Track("low.wav",     Sound.SFX, ONCE,    null )	
    ];	
+/

/+
SDL_mixer supports playing both samples and music. The documentation puts it this way:

SDL_mixer is a sample multi-channel audio mixer library.

It supports any number of simultaneously playing channels of 16 bit stereo audio, plus a single channel of music

Since playing both types of audio are supported, there is a structure fo each type.

The Mix_Chunk structure represents a sample, or in other words a sound effect.
The Mix_Music structure represents a piece of music, something that can be played for an extended period of time, usually repeated.
When you want to play sound effects, you would use a Mix_Chunk and it's associated functions. When you want to play music, you would use a Mix_Music and it's associated functions.

It's important to remember that you can play multiple samples at once, but you can only play one music at a time.
+/

/+
Mix_Chunk is used for playing sound samples, while Mix_Music is meant to play music.

One key difference between the two is that multiple Mix_Chunk can be played at once on different sound channels, whereas only one Mix_Music may be played at the time.

For example, if you're programming a game, you'd want to use Mix_Music for the background music and Mix_Chunk for sound effects (lasers, powerups, etc.)
+/


void initAndOpenSoundAndLoadTracks()
{	
    // Initialize all SDL subsystems
    if (SDL_Init(SDL_INIT_AUDIO) < 0 )
    {
	    writeln(to!string(SDL_GetError()), " SDL_Init failed at line ", __LINE__);
        return;
    }

    int    audioRate     = 22050;
	ushort audioFormat   = AUDIO_S16SYS;
	int    audioChannels = 2;
	int    audioBuffers  = 4096;	

	
    // Initialize SDL_mixer
    if (Mix_OpenAudio(audioRate, MIX_DEFAULT_FORMAT, audioChannels, audioBuffers) == SdlError)
    {
		writeln(to!string(SDL_GetError()), " failed at Mix_OpenAudio line ", __LINE__);
        return;
    }
	
	
    SDL_version compileVersion;
    SDL_MIXER_VERSION(&compileVersion);
	
    const SDL_version* linkVersion = Mix_Linked_Version();

    writeln("Compiled with SDL_mixer version: ", "\n", "major.minor.patch = ", 
            to!string(compileVersion.major), ".",
			to!string(compileVersion.minor), ".",
			to!string(compileVersion.patch));			
 
 

    writeln("Running with SDL_mixer version: ", "\n", "major.minor.patch = ", 
            to!string(linkVersion.major), ".",
			to!string(linkVersion.minor), ".",
			to!string(linkVersion.patch));			

    int devices = SDL_GetNumAudioDevices(PLAYBACK_DEVICES);

    for (int i = 0; i < devices; i++) 
    {
        
        writeln("Audio device ", i, " : ", to!string(SDL_GetAudioDeviceName(i, PLAYBACK_DEVICES)));
    }

    setTitles();

    writeln("after setTitles");
    foreach(string s, Track t; tracks)
    {
        loadSound(t);   // sets ptr to a file with audio data
        tracks[s] = t;  // update associative array
    }    
}






bool isMusicPlaying()
{	
    if (Mix_PlayingMusic() == PLAYING)
        return(true);
    else
        return(false);	    
}

bool isMusicNotPlaying()
{	
    if (Mix_PlayingMusic() == PLAYING)
        return(false);
    else
        return(true);	    
}



  
   
Mix_Music* LoadMusic(string musicFile)
{
    // This can load WAVE, MOD, MIDI, OGG, MP3, FLAC
    Mix_Music* temp = Mix_LoadMUS(cast (const(char)*) musicFile);
    if (temp == null)
    {
        writeln(to!string(SDL_GetError()), " Failed in file ", __FILE__, " at Mix_LoadMUS line ", __LINE__);
        exit(-1);
    }
    return temp;
}


Mix_Chunk* LoadSoundEffect(string soundEffectFile)
{
    // This can load WAVE, AIFF, RIFF, OGG, and VOC files.
    Mix_Chunk* temp = Mix_LoadWAV(cast (const(char)*) soundEffectFile);
    if (temp == null)
    {
        writeln(to!string(SDL_GetError()), " Failed in file ", __FILE__, " at Mix_LoadWAV line ", __LINE__);
        writeln("Attempting to load file: ", soundEffectFile);
        exit(-1);
    }
    return temp;
}


void PlayMusic(Mix_Music *music, int loops)
{
    if (Mix_PlayMusic(music, loops) == MIX_ERROR)
    {
        writeln(to!string(SDL_GetError()), " failed at Mix_PlayMusic line ", __LINE__); 
        exit(-1);
    }
}

void PlaySoundEffect(int channel, Mix_Chunk* chunk, int loops)
{
    if (Mix_PlayChannel(channel, chunk, loops) == MIX_ERROR)
    {
		writeln(to!string(SDL_GetError()), " failed at Mix_PlayChannel line " , __LINE__);
        return;
    }	
}

void loadSound(ref Track track)
{
    writeln("track = ", track);
    if (track.purpose == Sound.MUSIC)
    {
        writeln("loadMusic with = ", track.file);
        track.ptr =  cast(Mix_Music*) LoadMusic(track.file);            
    }
    if (track.purpose == Sound.SFX)
    {
        writeln("loadSFX with = ", track.file);        
        track.ptr = cast(Mix_Chunk*) LoadSoundEffect(track.file);            	
    }
	else
    {
    }
}
   
 
void playSound(string str)
{
    Track track = tracks[str];   
    writeln("inside playSound track.ptr = ", track.ptr);	
    if (track.purpose == Sound.MUSIC)
    {
        PlayMusic(cast(Mix_Music*) track.ptr, FOREVER);            
    }
    if (track.purpose == Sound.SFX)
    {
        PlaySoundEffect(FIRST_FREE_UNRESERVED_CHANNEL, cast(Mix_Chunk*) track.ptr, ONCE);           	
    }
	else
    {
    }


}











/+
************************************************************************************
************************************************************************************

FMOD code has been retired in favor of SDL2 and SDL2_Mixer audio functionality

************************************************************************************
************************************************************************************


void checkForErrors(FMOD_RESULT result, string s, bool wantSuccessDisplayed = false)
{
    if (result == FMOD_OK)
    {
        if (wantSuccessDisplayed)
            writeln("  ", s, " was successful");
    }
    else
    {
        writeln("FMOD error ", FMOD_ErrorString(result), " after call to ", s);
        writeAndPause("Error above");
    }
}


void printVersions()
{
    FMOD_SYSTEM*  system = null;
    FMOD_RESULT   result;
    uint          fmodVersion;

    result = FMOD_System_Create(&system);
    checkForErrors(result, "FMOD_System_Create");    

    result = FMOD_System_GetVersion(system, &fmodVersion);
    checkForErrors(result, "FMOD_System_GetVersion", true);
    
    writefln("fmod version: %s (bindings: %s)", fmodVersion, FMOD_VERSION);

    result = FMOD_System_Release(system);
    checkForErrors(result, "FMOD_System_Release");
}


void checkVersions()
{
    FMOD_SYSTEM*  system;
    FMOD_RESULT   result;
    uint          fmodVersion;

    result = FMOD_System_Create(&system);
    checkForErrors(result, "FMOD_System_Create");

    result = FMOD_System_GetVersion(system, &fmodVersion);
    checkForErrors(result, "FMOD_System_GetVersion", true);

    if (fmodVersion < FMOD_VERSION)
    {
        writeln("FMOD library version ", fmodVersion, " doesn't match header version ", FMOD_VERSION);
        writeAndPause(" ");
    }
    else
    {
        writeln("FMOD library version is good");
    }

    result = FMOD_System_Release(system);
    checkForErrors(result, "FMOD_System_Release");
}


void printDrivers()
{
    FMOD_SYSTEM*  system = null;
    FMOD_RESULT   result;
    uint          fmodVersion;
    int           drivers;

    result = FMOD_System_Create(&system);
    checkForErrors(result, "FMOD_System_Create");    

    FMOD_System_GetNumDrivers(system, &drivers);
    checkForErrors(result, "FMOD_System_GetNumDrivers");     
    
    writefln("fmod drivers: %s", drivers);

    foreach(i; 0..drivers)
    {
        char[64]  name;
        FMOD_GUID guid;
        int       sampleRate;
        FMOD_SPEAKERMODE speakerMode;
        int       speakerModeChannels;

        result = FMOD_System_GetDriverInfo(system, 
                                           i, 
                                           name.ptr, 
                                           name.length, 
                                           &guid,
                                           &sampleRate, 
                                           &speakerMode, 
                                           &speakerModeChannels);
  
        checkForErrors(result, "FMOD_System_GetDriverInfo");

        writefln("fmod driver [%s]: (%s,%s,%s,'%s')", i, sampleRate, speakerMode, speakerModeChannels, to!string(name.ptr));
    }
    result = FMOD_System_Release(system);
    checkForErrors(result, "FMOD_System_Release");
}





void playSound(FMOD_MODE fmode, FMOD_SYSTEM* sys, string audioFile)
{
    FMOD_SOUND*            sound;
    FMOD_CHANNEL*          channel;
    FMOD_CREATESOUNDEXINFO info;
    FMOD_RESULT            result;
    info.cbsize = FMOD_CREATESOUNDEXINFO.sizeof;  // required!  When commented out FMOD_System_CreateSound fails 

    const char[] file = audioFile.dup;

    // Some files have embedded loop points which automatically makes looping turn on
    // So we explicitly turn off looping

    if (fmode == FMOD_LOOP_OFF)
    {
        result = FMOD_System_CreateSound(sys, file.ptr, fmode, &info, &sound);
        checkForErrors(result, "FMOD_System_CreateSound", false);
    } 
    else if (fmode == FMOD_LOOP_NORMAL)
    {
        result = FMOD_System_CreateStream(sys, file.ptr, fmode, &info, &sound);
        checkForErrors(result, "FMOD_System_CreateStream", false);
    }
    else
    {
        writeln("Invalid FMOD_MODE for this function");
    }

    result = FMOD_System_PlaySound(sys,       // system (from create system)
                                   sound,     // sound (from Create Sound/Stream) 
                                   null,      // channel group
                                   0,         // paused 
                                   &channel); // Address of a channel handle pointer that receives the new
                                              // playihgchannel. Optional. Use 0/NULL to ignore.

    checkForErrors(result, "FMOD_System_PlaySound");
}


// This example uses an FSB file, which is a preferred pack format for fmod containing multiple sounds.
// This could just as easily be exchanged with a wav/mp3/ogg file for example, but in this case you 
// wouldnt need to call getSubSound. Because getNumSubSounds is called here the example would work with 
// both types of sound file (packed vs single).

void playFSBfile(FMOD_MODE fmode, FMOD_SYSTEM* sys, string audioFile)
{
    FMOD_SOUND*            sound;
    FMOD_SOUND*            subSound;
    FMOD_CHANNEL*          channel;
    FMOD_CREATESOUNDEXINFO info;
    FMOD_RESULT            result;
    info.cbsize = FMOD_CREATESOUNDEXINFO.sizeof;  // required!  When commented out FMOD_System_CreateSound fails 

    const char[] file = audioFile.dup;

    // Some files have embedded loop points which automatically makes looping turn on
    // So we explicitly turn off looping

    if (fmode == FMOD_LOOP_OFF)
    {
        result = FMOD_System_CreateSound(sys, file.ptr, fmode, &info, &sound);
        checkForErrors(result, "FMOD_System_CreateSound", false);
    } 
    if (fmode == FMOD_LOOP_NORMAL)
    {
        result = FMOD_System_CreateStream(sys, file.ptr, fmode, &info, &sound);
        checkForErrors(result, "FMOD_System_CreateStream");
    }

    int numSubSounds;
    result = FMOD_Sound_GetNumSubSounds(sound, &numSubSounds);
    checkForErrors(result, "FMOD_Sound_GetNumSubSounds");

    if (numSubSounds)
    {
        result = FMOD_Sound_GetSubSound(sound, 0, &subSound);
        checkForErrors(result, "FMOD_Sound_GetSubSound");

        sound = subSound;
    }

    result = FMOD_System_PlaySound(sys, sound, null, 0, &channel);
    checkForErrors(result, "FMOD_System_PlaySound");
}


struct SoundSystem
{
    FMOD_SYSTEM*            system;
    uint                    fmodVersion;
    FMOD_SOUND*[]           sounds;
    FMOD_CHANNEL*[]         channels;
    FMOD_CREATESOUNDEXINFO  infos;
    void*                   extraDriverData;
}



void initSoundSystem(ref SoundSystem sys)
{
    FMOD_RESULT   result;

    result = FMOD_System_Create(&sys.system);
    checkForErrors(result, "FMOD_System_Create", true);

    result = FMOD_System_GetVersion(sys.system, &sys.fmodVersion);
    checkForErrors(result, "FMOD_System_GetVersion", true);

    writeln("FMOD_VERSION = ", FMOD_VERSION);
    writeln("sys.fmodVersion = ", sys.fmodVersion);

    if (sys.fmodVersion < FMOD_VERSION)
    {
        writeln("FMOD lib version ", sys.fmodVersion, " does not match header version ", FMOD_VERSION);
    }

    result = FMOD_System_Init(sys.system, 32, FMOD_INIT_NORMAL, sys.extraDriverData);
    checkForErrors(result, "FMOD_System_Init", true);
}




void initSound(ref SoundSystem soundSys, FMOD_MODE fmode, string audioFile)
{
    FMOD_SOUND*            sound;
    FMOD_CHANNEL*          channel;
    FMOD_CREATESOUNDEXINFO info;
    FMOD_RESULT            result;
    info.cbsize = FMOD_CREATESOUNDEXINFO.sizeof;  // required!  When commented out FMOD_System_CreateSound fails 

    const char[] file = audioFile.dup;

    // Some files have embedded loop points which automatically makes looping turn on
    // So we explicitly turn off looping

    if (fmode == FMOD_LOOP_OFF)
    {
        result = FMOD_System_CreateSound(soundSys.system, file.ptr, fmode, &info, &sound);
        checkForErrors(result, "FMOD_System_CreateSound", true);
        soundSys.sounds ~= sound;
    } 
    else if (fmode == FMOD_LOOP_NORMAL)
    {
        result = FMOD_System_CreateStream(soundSys.system, file.ptr, fmode, &info, &sound);
        checkForErrors(result, "FMOD_System_CreateStream", true);
        soundSys.sounds ~= sound;
    }
    else
    {
        writeln("Invalid FMOD_MODE for this function");
    }

}


void playSound(SoundSystem soundSys, int soundIndex )
{
    FMOD_RESULT  result;
    result = FMOD_System_PlaySound(soundSys.system,       // system (from create system)
                                   soundSys.sounds[soundIndex],     // sound (from Create Sound/Stream) 
                                   null,      // channel group
                                   0,         // paused 
                                   null);     // Address of a channel handle pointer that receives the new
                                              // playihgchannel. Optional. Use 0/NULL to ignore.

    checkForErrors(result, "FMOD_System_PlaySound");
}


+/