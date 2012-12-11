const long sleepTime = 10*1000;
const int sampleInterval = 500;
const int samples = 10;
const byte debug = 0;

const byte ledPin = 12;
const byte lightSensorPin = A0;
const byte tempSensorPin = A1;
const byte moistureSensorPin = A2;

const char instance[] = {
  "BigSensorUnit1"};

void setup() {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
}

void loop() {

  sampleSensors();


  if (debug){
    Serial.print("Sampling done, now sleeping  ");
    Serial.print(sleepTime/1000, DEC);
    Serial.println(" seconds until next round");
  }
  delay(sleepTime);
}


void sampleSensors() {
  long lightSum = 0;
  long tempSum = 0;
  long moistSum = 0;
  digitalWrite(ledPin, HIGH);
  for (int i=0; i<samples; i++) {
    int lightValue = analogRead(lightSensorPin);
    lightSum += lightValue;
    if (debug) {
      Serial.print("Just read Light: ");
      Serial.print(lightValue, DEC);
      Serial.print(" (");
      Serial.print(lightSum, DEC);
      Serial.println(")");
    }
    int tempValue = analogRead(tempSensorPin);
    tempSum += tempValue;
    if (debug) {
      Serial.print("Just read Temperature:  ");
      Serial.print(tempValue, DEC);
      Serial.print(" (");
      Serial.print(tempSum, DEC);
      Serial.println(")");
    }
    int moistValue = analogRead(moistureSensorPin);
    moistSum += moistValue;
    if (debug) {
      Serial.print("Just read Moisture:  ");
      Serial.print(moistValue, DEC);
      Serial.print(" (");
      Serial.print(moistSum, DEC);
      Serial.println(")");
    }
    delay(sampleInterval);
  }
  digitalWrite(ledPin, HIGH);

  float temperature = float(tempSum) / float(samples) * 0.2222 - 61.11;
  float light = float(lightSum) / float(samples);
  float moisture = float(moistSum) / float(samples);

  reportValues(temperature, light, moisture);
}


void reportValues ( float temp, float light, float moisture ) {
  digitalWrite(ledPin, HIGH);
  Serial.print("id:");
  Serial.print(instance);
  Serial.print("::");
  
  Serial.print("t:");
  Serial.print(temp, 2);
  Serial.print("::l:");
  Serial.print(light, 2);
  Serial.print("::m:");
  Serial.println(moisture, 2);
  digitalWrite(ledPin, LOW);
}

