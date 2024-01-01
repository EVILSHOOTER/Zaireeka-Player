# Zaireeka-Player
A way to play The Flaming Lips' Zaireeka (an album that requires 4 CD players).

Obviously not a replacement for the intended method, but a nice-to-have "emulator" for those interested.

[A link to a version somebody did in Unity 5 years ago, with its more developed sound engine](https://github.com/schippas/Zaireeka3D)

## Downloads (v0.1)
Since the project requires copyrighted music, you have to edit and add the tracks in yourself. 

*insert links here for win, lin, mac*

### How to add in Zaireeka, or your own music
I apologise for this, as the way this works is a result of me working around the engine's current limitations/unimplemented features.

- Make 8 folders, naming from 1-8 - one for each track. 
- For each disc, get the selected track off of each (e.g. get Track #1 from all 4 CDs) and import it into Audacity. 
- Split the stereo track into its mono channels.
- Now export them (as either .WAV or .MP3), naming them (like this: 1L, 1R,  2L, 2R,  3L, 3R,  4L, 4R)
- In each folder you've made, put the files you have made for that track inside

If you were to do an album yourself, you can use as many discs as you want. Change the metadata.json to reflect the changes in the tracks.

## How to use (edit) the project
Get Godot Engine v4.2 onwards. 
Download the files on this page and extract them into a folder. 
Open Godot Engine, click "Import", navigate to the folder containing the downloaded project and click on "project.godot". 
This should open the project.

## Features to add
### Bugs/changes I'd like to make
- fix issue where you can drag speakers even when mouse is over the UI
- actually get the metadata off of the WAV files themselves, not a separate JSON
- write an algo to separate the L/R channels from a single audio file.
- allow optional use of MP3 or OGG files instead (may interfere wtih point 2)
- maybe don't load all of the audio at the beginning of the program but between songs?

### Potential future features if I'm bothered
- save/load speaker configs
  - preset speaker configs
- multiplayer (ideally P2P cuz this is simple, but server-based makes sense)
- EQ option for all and individual speakers
- reverb option for all and individual speakers
  - ideally: actual spatial reverb. the shape of the room (maybe using CSG) changes reverb.
- mobile support
- time offset for each CD
  - even cooler: for EACH speaker (L and R)
    - zak: "give a milliseconds range. gives a cool soundstage effect"
- visualiser for the background
- time offset for each speaker set

## My Description
I made this as a quick proof-of-concept for myself since I had this idea for a while and could not find someone else to have done it. 
so yeah, working on-off from 23rd December to 1st January, I squeezed this out. a few irritating limitations with Godot, which I could have written workaround code for, but instead chose quicker methods for myself.
eventually, right before releasing, I did find that someone had done it 5 years prior, rendering my solution virtually useless unless I continued to update it with more features. 
that being said, user friendliness is a must, and I want to achieve a good amount of that through feedback.

I understand that this will not be the complete experience for a lot of people. Part of the fun of the album is to listen together with others, and have the music reverberate throughout the room. What I wanted to do was make a sort-of recreation of this for those who may not be able to perform this themselves. Hopefully, I (or anyone else who wants to contribute) could help write a multiplayer feature for this, or even their own spatial reverb plugin that works on Godot.

## credits
- KenneyNL - Kenney's Game Assets (used for button icons)
- The Flaming Lips - Zaireeka (full album, not included in this repository)
- Godot Foundation - Godot Engine (game engine used)
