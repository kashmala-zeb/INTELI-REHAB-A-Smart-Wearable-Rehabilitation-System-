#include <Wire.h>

const int MPU_ADDR = 0x68; // Your verified physical address
bool mpuOnline = false;

void setup() {
  Serial.begin(115200);
  while (!Serial) { delay(10); }
  
  Serial.println("\n--- RAW REGISTER HARDWARE INITIALIZATION ---");

  // Start I2C on your working physical pins 15 and 16
  Wire.begin(15, 16);

  // Wake up the MPU-6050 (write 0 to the Power Management 1 register 0x6B)
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B); 
  Wire.write(0);     
  byte error = Wire.endTransmission();

  if (error == 0) {
    mpuOnline = true;
    Serial.println("✅ MPU-6050 woke up and is responding!");
  } else {
    Serial.println("❌ Failed to wake up MPU-6050. Check physical contact.");
  }
  Serial.println("---------------------------------------------");
}

void loop() {
  // 1. Read Raw Analog Muscle Pin (GPIO 4)
  int rawMuscle = analogRead(4);
  Serial.print("Raw_Muscle: ");
  Serial.print(rawMuscle);

  // 2. Read Raw Accelerometer Registers directly
  if (mpuOnline) {
    Wire.beginTransmission(MPU_ADDR);
    Wire.write(0x3B); // Starting register for Accelerometer data (Accel_X_High)
    byte error = Wire.endTransmission(false);

    if (error == 0) {
      // Request 6 bytes (2 bytes for X, 2 bytes for Y, 2 bytes for Z)
      Wire.requestFrom(MPU_ADDR, 6, true);
      
      int16_t rawX = (Wire.read() << 8) | Wire.read();
      int16_t rawY = (Wire.read() << 8) | Wire.read();
      int16_t rawZ = (Wire.read() << 8) | Wire.read();

      // Convert raw register values to standard Gs (raw / 16384.0)
      float accelX = rawX / 16384.0;
      float accelY = rawY / 16384.0;

      Serial.print(" | Accel_X: ");
      Serial.print(accelX);
      Serial.print(" | Accel_Y: ");
      Serial.print(accelY);
    } else {
      Serial.print(" | Accel: READ_ERROR");
      mpuOnline = false; // Flag to attempt wake-up again
    }
  } else {
    // Attempt to wake the chip up again live if it lost contact
    Wire.beginTransmission(MPU_ADDR);
    Wire.write(0x6B);
    Wire.write(0);
    if (Wire.endTransmission() == 0) {
      mpuOnline = true;
    }
    Serial.print(" | Accel: PHYSICAL_OFFLINE");
  }

  Serial.println();
  delay(150); 
}