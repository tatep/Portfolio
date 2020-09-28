
int sendToGB(int value, int octave, int oldValue) { // sends notes to garageband

  if (value != oldValue) {
    
    playChord(oldValue, octave, 0);// puts old note on low

  }
    
    if (value != -1) { // -1 means all notes are off
      
      playChord(value, octave, 127); // new note on high
      
    } else {

      playChord(oldValue, octave, 0);
    }

return value;


}



void playChord(int value, int octave, int vol) {

  for (int i = 0; i < 3; i++) {

    usbMIDI.sendNoteOn(chords[value][i] + (octave + 2) * 12, vol, 1);
  }

}
