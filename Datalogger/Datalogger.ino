#include <Wire.h>
#include "SparkFun_Qwiic_KX13X.h"
#include <SD.h>
#include <SPI.h>

const int chipSelect = BUILTIN_SDCARD;
const int ledPin = 13;
IntervalTimer myTimer;

QwiicKX134 kxAccel;
outputData myData;
rawOutputData rawData;

bool ledStat = 0;

volatile unsigned int buff_1[512];
volatile unsigned int ind = 0;
volatile unsigned int buff_2[512];
volatile bool activeBuff = 0;
volatile bool full = 0;
const int fileNum;


void setup()
{
  delay(500);
  pinMode(17, OUTPUT);
  pinMode(ledPin, OUTPUT);
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
  Wire.setClock(1000000);
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
  else {
    Serial.println("All systems initialized...");
    Serial.println("Convertion factor: ");
    Serial.print(.0002441407513657033);
  }
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
      //debug led that will blink to show activity
      ledStat = !ledStat;
      digitalWrite(ledPin, ledStat);
    } else {
      Serial.println("file error");
    }
  }
  
}
 
void measure_time () {
  digitalWrite(17, 1);
  
  if(activeBuff == 0) {
    buff_1[ind] = micros();
    buff_1[ind+1] = rawData.xData;
    buff_1[ind+2] = rawData.yData;
    buff_1[ind+3] = rawData.zData;
  } else {
    buff_2[ind] = micros();
    buff_2[ind+1] = rawData.xData;
    buff_2[ind+2] = rawData.yData;
    buff_2[ind+3] = rawData.zData;
  }
  ind += 4;
  if (ind >= 512) {
    ind = 0;
    full = 1;
    activeBuff = !activeBuff;
    
  }
  
  kxAccel.getRawAccelData(&rawData);
  digitalWrite(17, 0);
}
