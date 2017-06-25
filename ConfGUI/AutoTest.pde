//open PID auto-test definition file to send to GroundSegment
public void Auto_Test () {
 if (CONNECTED) {
   selectInput("Select CSV for auto test", "fileSelected");
 } 
}

//Enable/disable AutoTest mode
void Autotest_mode(boolean theFlag) {
  if(theFlag==false) {
    autotestMode = 0; //autotestMode OFF
  } else {
    autotestMode = 1; //autotestMode ON
  } 
  
  //Here shall be the message creation and delivery to GS
  if (CONNECTED) {
    arduino.write(PT_PID_AUTOTEST_MODE);
    arduino.write(autotestMode);
  }
  println(PT_PID_AUTOTEST_MODE);
  println(autotestMode); 
}



void fileSelected(File selection) {
  int time;  // millis
  int pot;  //x,y,z,t (simulate joystick potentiometers)
  int value;
  Table csvTable;
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    csvTable = loadTable(selection.getAbsolutePath(), "header");
    arduino.write(PT_PID_AUTOTEST_SET);
    println(PT_PID_AUTOTEST_SET); 
    arduino.write(csvTable.getRowCount());
    println(csvTable.getRowCount()); 
    println("millis\tpot\tvalue"); 
    for (TableRow row : csvTable.rows()) {
      time = row.getInt("time");
      pot = row.getInt("pot");
      value = row.getInt("value");
      arduino.write(time);
      arduino.write(pot);
      arduino.write(value);
      print(time);print("\t"); 
      print(pot);print("\t"); 
      println(value);
    }
    AutoTestMode_Toggle.setValue(true);
    autotestMode = 1;
  }
}
  
