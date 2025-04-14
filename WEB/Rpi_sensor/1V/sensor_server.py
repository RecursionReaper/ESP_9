# sensor_server.py - Single file for Raspberry Pi
# Run with: python3 sensor_server.py

import time
import json
import threading
import os
from datetime import datetime
import RPi.GPIO as GPIO
import board
import adafruit_dht  # CircuitPython DHT library
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Create app
app = FastAPI(title="Water Level Monitoring System")

# Enable CORS for Next.js frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# GPIO Pin Configuration
TRIG_PIN = 23  # GPIO pin for ultrasonic sensor trigger
ECHO_PIN = 24  # GPIO pin for ultrasonic sensor echo

# Tank configuration (in cm)
TANK_HEIGHT = 100  # Height of the tank in cm

# Initialize DHT sensor using CircuitPython
# Use the appropriate board pin - D4 is GPIO4
dht_sensor = adafruit_dht.DHT22(board.D4)

# Sensor data storage
class SensorData:
    def __init__(self, max_points=100):
        self.max_points = max_points
        self.water_levels = []
        self.temperatures = []
        self.humidities = []
        self.timestamps = []
    
    def add_reading(self, water_level, temperature, humidity):
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        self.water_levels.append(water_level)
        self.temperatures.append(temperature)
        self.humidities.append(humidity)
        self.timestamps.append(timestamp)
        
        # Keep only the most recent points
        if len(self.water_levels) > self.max_points:
            self.water_levels.pop(0)
            self.temperatures.pop(0)
            self.humidities.pop(0)
            self.timestamps.pop(0)
    
    def get_json(self):
        return {
            "water_levels": self.water_levels,
            "temperatures": self.temperatures,
            "humidities": self.humidities,
            "timestamps": self.timestamps,
            "latest": {
                "water_level": self.water_levels[-1] if self.water_levels else 0,
                "temperature": self.temperatures[-1] if self.temperatures else 0,
                "humidity": self.humidities[-1] if self.humidities else 0,
                "timestamp": self.timestamps[-1] if self.timestamps else ""
            }
        }

# Initialize sensor data
sensor_data = SensorData()

# Setup GPIO
def setup_gpio():
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(TRIG_PIN, GPIO.OUT)
    GPIO.setup(ECHO_PIN, GPIO.IN)
    GPIO.output(TRIG_PIN, False)
    time.sleep(2)  # Let the sensors stabilize

# Cleanup GPIO on program exit
def cleanup_gpio():
    GPIO.cleanup()

# Read ultrasonic sensor to get water level
def get_water_level():
    # Send a 10us pulse to trigger
    GPIO.output(TRIG_PIN, True)
    time.sleep(0.00001)
    GPIO.output(TRIG_PIN, False)
    
    pulse_start = time.time()
    pulse_end = time.time()
    
    # Get pulse start time
    while GPIO.input(ECHO_PIN) == 0:
        pulse_start = time.time()
        if time.time() - pulse_start > 1:  # Timeout after 1 second
            return None
    
    # Get pulse end time
    while GPIO.input(ECHO_PIN) == 1:
        pulse_end = time.time()
        if time.time() - pulse_end > 1:  # Timeout after 1 second
            return None
    
    # Calculate pulse duration and distance
    pulse_duration = pulse_end - pulse_start
    distance = pulse_duration * 17150  # Speed of sound = 343 m/s = 34300 cm/s / 2
    distance = round(distance, 2)
    
    # Convert distance to water level
    water_level = max(0, min(100, 100 - (distance / TANK_HEIGHT * 100)))
    return water_level

# Read DHT sensor for temperature and humidity using CircuitPython
def get_temp_humidity():
    try:
        temperature = dht_sensor.temperature
        humidity = dht_sensor.humidity
        return round(temperature, 1), round(humidity, 1)
    except Exception as e:
        print(f"DHT sensor error: {e}")
        return None, None

# Sensor reading loop
def sensor_loop():
    setup_gpio()
    try:
        while True:
            # Read water level sensor
            water_level = get_water_level()
            
            # Read temperature and humidity with error handling
            try:
                temperature, humidity = get_temp_humidity()
            except RuntimeError as e:
                print(f"DHT reading error: {e}")
                temperature, humidity = None, None
                
            # Handle potential errors
            if water_level is None:
                water_level = 0
            if temperature is None:
                temperature = 0
            if humidity is None:
                humidity = 0
                
            # Add readings to data store
            sensor_data.add_reading(water_level, temperature, humidity)
            
            print(f"Water Level: {water_level}%, Temp: {temperature}°C, Humidity: {humidity}%")
            time.sleep(2)  # Take readings every 2 seconds
    except Exception as e:
        print(f"Error in sensor loop: {e}")
    finally:
        cleanup_gpio()

# FastAPI routes
@app.get("/api/readings")
async def get_readings():
    return sensor_data.get_json()

# Start sensor reading in background thread
@app.on_event("startup")
def startup_event():
    threading.Thread(target=sensor_loop, daemon=True).start()

# Run the server
if __name__ == "__main__":
    print("Starting Water Level Monitoring System")
    print("Access the API at: http://localhost:8000/api/readings")
    print("Connect your Next.js frontend to this API endpoint")
    uvicorn.run("sensor_server:app", host="0.0.0.0", port=8000, reload=False)