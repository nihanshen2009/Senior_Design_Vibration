#include <Wire.h>
#include "SparkFun_Qwiic_KX13X.h"
#include <SD.h>
#include <SPI.h>

const int chipSelect = BUILTIN_SDCARD;
IntervalTimer myTimer;

QwiicKX134 kxAccel;
outputData myData;


volatile unsigned int buff_1[512];
volatile unsigned int ind = 0;
volatile unsigned int buff_2[512];
volatile bool activeBuff = 0;
volatile bool full = 0;
const int fileNum;


void setup()
{
  Serial.begin(9600);
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    while (1) {
      // No SD card, so don't do anything more - stay stuck here
    }
  }
  else
    Serial.println("card initialized.");
  Wire.begin();
  if( !kxAccel.begin() ){
    Serial.println("Could not communicate with the the KX13X. Freezing.");
    while(1);
  }
  else
    Serial.println("KX13X Ready.");
  if( !kxAccel.initialize(DEFAULT_SETTINGS)){ // Loading default settings.
    Serial.println("Could not initialize the KX13X chip.");
    while(1);
  }
  else
    Serial.println("All systems initialized...");
  Serial.println(kxAccel.setOutputDataRate(0b1011));
  myTimer.begin(measure_time, 625);
}

void loop()
{
  
  if (full){
    File dataFile = SD.open("datalog.txt", FILE_WRITE);
    if (dataFile) {
      if (activeBuff == 0) {
        dataFile.write(buff_1, sizeof(buff_1));
      } else {
        dataFile.write(buff_2, sizeof(buff_2));
      }
      dataFile.close();
      full = 0;
      Serial.println("written");
    } else {
      Serial.println("file error");
    }
  }
  
}
 
void measure_time () {
  rawOutputData rawData;
  kxAccel.getRawAccelData(&rawData);
  if(activeBuff == 0) {
    buff_1[ind] = rawData.xData;
  } else {
    buff_2[ind] = rawData.xData;
  }
  ind += 1;
  if (ind >= 512) {
    ind = 0;
    full = 1;
    activeBuff = !activeBuff;
  }
}
