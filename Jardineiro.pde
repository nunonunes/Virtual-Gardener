#include <OneWire.h>
#include <DallasTemperature.h>


byte debug = 0;

long sleepTime = 300000; // 5 minutes * 60 seconds * 1000 mili-seconds
const int sampleInterval = 500;
const int samples = 10;

const byte batteryMonitorPin = A0;
const byte lightSensorPin = A1;
const byte moistureSensorPin1 = A2;
const byte moistureSensorPin2 = A3;
const byte moistureSensorPin3 = A4;
const byte ledPin = 13;
const byte XBeeDTR = 2;
const byte temperaturePin = 3;

const float batVoltDivRatio = 1.496; // (Vin / Vout) obtained experimentaly

const char instance[] = "MiniGardener1";

OneWire oneWireSensor(temperaturePin);
DallasTemperature temperatureSensors(&oneWireSensor);

void setup() {
    Serial.begin(9600);
    pinMode(ledPin, OUTPUT);
    pinMode(XBeeDTR, OUTPUT);
    temperatureSensors.begin();
}

void loop() {

    sampleSensors();

    if (debug){
        Serial.println(String("DEBUG::Sampling done, sleeping 10s"));
        delay(10000);
    }
    else {
        delay(sleepTime);
    }
}


void sampleSensors() {
    long lightSum = 0;
    float tempSum = 0;
    long moistSum1 = 0;
    long moistSum2 = 0;
    long moistSum3 = 0;
    long batVoltageSum = 0;
    for (int i=0; i<samples; i++) {
        if (debug) {
            digitalWrite(ledPin, HIGH);
        }

        // Battery
        int batVoltageValue = analogRead(batteryMonitorPin);
        batVoltageSum += batVoltageValue;

        // Temperature
        temperatureSensors.requestTemperatures();
        float tempValue = temperatureSensors.getTempCByIndex(0);
        tempSum += tempValue;

        // Light
        int lightValue = analogRead(lightSensorPin);
        lightSum += lightValue;

        // Moisture 1
        int moistValue1 = analogRead(moistureSensorPin1);
        moistSum1 += moistValue1;

        // Moisture 2
        int moistValue2 = analogRead(moistureSensorPin2);
        moistSum2 += moistValue2;

        // Moisture 3
        int moistValue3 = analogRead(moistureSensorPin3);
        moistSum3 += moistValue3;

        if (debug) {
            String message = String("DEBUG::" + String(i+1));
            message += ("::id:" + String(instance));
            message += String("::b:" + floatToString(batVoltageValue));
            message += String("::t:" + floatToString(tempValue));
            message += String("::l:" + floatToString(lightValue));
            message += String("::m1:" + floatToString(moistValue1));
            message += String("::m2:" + floatToString(moistValue2));
            message += String("::m3:" + floatToString(moistValue3));
            Serial.println(message);
            digitalWrite(ledPin, LOW);
        }
        delay(sampleInterval);
    }

    float batVoltage = float(batVoltageSum) / float(samples) * 3.3 / float(1024) * float(batVoltDivRatio);
    float temperature = float(tempSum) / float(samples);
    float light = float(lightSum) / float(samples);
    float moisture1 = float(moistSum1) / float(samples);
    float moisture2 = float(moistSum2) / float(samples);
    float moisture3 = float(moistSum3) / float(samples);

    reportValues(batVoltage, temperature, light, moisture1, moisture2, moisture3);
}


void reportValues ( float batVoltage, float temperature, float light, float moisture1, float moisture2, float moisture3 ) {
    wakeXBee();
    String message = String("id:" + String(instance));
    message += String("::b:" + floatToString(batVoltage));
    message += String("::t:" + floatToString(temperature));
    message += String("::l:" + floatToString(light));
    message += String("::m1:" + floatToString(moisture1));
    message += String("::m2:" + floatToString(moisture2));
    message += String("::m3:" + floatToString(moisture3));
    Serial.println(message);
    if (Serial.available() > 0) {
        if (Serial.read() == 'd'){
            debug = !debug;
            if (debug) {
                Serial.println("DEBUG::Turning debug on");
            }
            else {
                Serial.println("DEBUG::Turning debug off");
            }
        }
        Serial.flush();
    }
    sleepXBee();
}


void wakeXBee() {
    if (debug) {
        Serial.println("DEBUG::Debug on, Not waking up the XBee module");
        return;
    }
    digitalWrite(XBeeDTR, LOW);
    delay(1000);
}


void sleepXBee() {
    if (debug) {
        Serial.println("DEBUG::Debug on, Not putting the XBee module to sleep");
        return;
    }
    digitalWrite(XBeeDTR, HIGH);
}

String floatToString(float val) {
    int intPart = int(val);
    int decPart = int((val-int(val))*100);
    String floatString = String(intPart);
    floatString += String('.');
    floatString += String(decPart);
    return floatString;
}





