#include <DHT.h>

#define DHTPIN 2
#define SOIL_MOISTURE_PIN A0

#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  dht.begin();
}

void loop() {
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  int soilMoistureValue = analogRead(SOIL_MOISTURE_PIN);

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.print(" °C");
  
  Serial.print(" | Humidity: ");
  Serial.print(humidity);
  Serial.print(" %");
  
  Serial.print(" | Soil Moisture: ");
  Serial.println(soilMoistureValue);

  delay(2000);
}
