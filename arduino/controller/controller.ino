#define NUM_BUTTONS 6

#include <MIDIcontroller.h>
#include <MIDIbutton.h>

byte MIDIchannel = 1;
int numButtons = NUM_BUTTONS;
int firstPin = 0;

MIDIbutton *buttons[NUM_BUTTONS];

void setup() { 
  for (int i=0; i < numButtons; i++) {
    int pin = firstPin + i;
    int cc = pin;
    pinMode(pin, INPUT_PULLUP);
    buttons[i] = new MIDIbutton(pin, (byte) cc, (byte) TRIGGER);
  }

}

void loop() {
  // put your main code here, to run repeatedly:
  for (int i = 0; i < numButtons; i++) {
    buttons[i]->send();  
  }

}
