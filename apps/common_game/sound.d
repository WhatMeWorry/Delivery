
module sound;

import common;
import common_game;

import derelict.opengl3.gl3;
import gl3n.linalg : mat4, vec2, vec3, vec4; 
import std.random;
import std.stdio;
import std.conv : to;



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

