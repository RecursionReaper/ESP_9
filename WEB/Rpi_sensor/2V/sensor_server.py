import time
import json
import threading
import os
from datetime import datetime
import random  # For generating random values
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

# Fake sensor reading functions
def get_fake_water_level():
    # Generate random water level between 0 and 100
    return random.uniform(0, 100)

def get_fake_temp_humidity():
    # Generate random temperature and humidity values
    temperature = random.uniform(20, 30)  # Temperature between 20°C and 30°C
    humidity = random.uniform(40, 60)  # Humidity between 40% and 60%
    return round(temperature, 1), round(humidity, 1)

# Sensor reading loop with fake values
def sensor_loop():
    try:
        while True:
            # Read fake water level
            water_level = get_fake_water_level()
            
            # Read fake temperature and humidity
            temperature, humidity = get_fake_temp_humidity()
                
            # Add readings to data store
            sensor_data.add_reading(water_level, temperature, humidity)
            
            print(f"Water Level: {water_level}%, Temp: {temperature}°C, Humidity: {humidity}%")
            time.sleep(2)  # Take readings every 2 seconds
    except Exception as e:
        print(f"Error in sensor loop: {e}")

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
