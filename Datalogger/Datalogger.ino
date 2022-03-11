#include <Wire.h>
#include "SparkFun_Qwiic_KX13X.h"
#include <SD.h>
#include <SPI.h>

const int chipSelect = BUILTIN_SDCARD;
IntervalTimer myTimer;

QwiicKX134 kxAccel;
outputData myData;
rawOutputData rawData;

volatile unsigned int buff_1[512];
volatile unsigned int ind = 0;
volatile unsigned int buff_2[512];
volatile bool activeBuff = 0;
volatile bool full = 0;
const int fileNum;

void setup()
{
  delay(500); //initial delay to make sure everything powers up
  pinMode(17, OUTPUT); //debug pin for interrupt
  Serial.begin(9600); //serial for debugging
  
  //SD card initilization
  if (!SD.begin(chipSelect)) { 
    Serial.println("Card failed, or not present"); 
    while (1) {
      // No SD card, so don't do anything more - stay stuck here
    }
  }
  else
    Serial.println("card initialized.");

  //I2C line initilization and setting clock speed
  Wire.begin();
  Wire.setClock(1000000);

  //Accel initilization
  if( !kxAccel.begin() ){
    Serial.println("Could not communicate with the the KX14X. Freezing.");
    while(1);
  }
  else
    Serial.println("KX13X Ready.");
  //Accel Default setting loading
  if( !kxAccel.initialize(DEFAULT_SETTINGS)){ // Loading default settings.
    Serial.println("Could not initialize the KX13X chip.");
    while(1);
  }
  else {
    Serial.println("All systems initialized...");
    Serial.println("Convertion factor: ");
    Serial.print(.0002441407513657033); //Convertion multiplier for raw data (in g)
  }
  //Accel output data rate
  Serial.println(kxAccel.setOutputDataRate(0b1011)); //test the change to 0b1100

  //Timer interrupt initilization
  myTimer.begin(measure_time, 625);
}

void loop()
{
  //if one of the buffers are full
  if (full){
    File dataFile = SD.open("datalog.txt", FILE_WRITE); //Begin writting to the data file
    if (dataFile) { //if data file is intilized
      if (activeBuff == 0) { //Choose the active buffer and write the data to SD card
        dataFile.write(buff_1, sizeof(buff_1));
      } else {
        dataFile.write(buff_2, sizeof(buff_2));
      }
      dataFile.close(); //close the data file
      full = 0; //set the full flag to 0
      Serial.println("written"); //Serial print for debugging
    } else {
      Serial.println("file error"); //if file is unavailable error
    }
  }
  
}
 
void measure_time () {
  digitalWrite(17, 1); //set the debugging pin high
  
  if(activeBuff == 0) { //write the data to appropriate buffer
    buff_1[ind] = micros(); //time
    buff_1[ind+1] = rawData.xData; //x accel
    buff_1[ind+2] = rawData.yData; //y accel
    buff_1[ind+3] = rawData.zData; //z accel
  } else {
    buff_2[ind] = micros(); //time
    buff_2[ind+1] = rawData.xData; //x accel
    buff_2[ind+2] = rawData.yData; //y accel
    buff_2[ind+3] = rawData.zData; //z accel
  }
  ind += 4; //increment the index
  if (ind >= 512) { //if index excedes the buffer size
    ind = 0; //reset index
    full = 1; //set the full flag high
    activeBuff = !activeBuff; //switch the active buffer
  }
  
  kxAccel.getRawAccelData(&rawData); //pole the sensor
  digitalWrite(17, 0); //set the debugging pin low
}
