import time
import json
import threading
import os
from datetime import datetime, timedelta
import random
import math
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Create app
app = FastAPI(title="Environmental Monitoring System")

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
        self.aqi_levels = []
        self.timestamps = []
        
        # Initial baseline values
        self.current_water_level = 70.0  # Start at 70%
        self.target_water_level = 70.0
        self.last_water_change = datetime.now()
        
        self.base_temperature = 23.0  # Baseline temperature
        self.temp_variation = 0.0    # Current temperature variation
        
        self.base_humidity = 50.0    # Baseline humidity
        self.humidity_variation = 0.0
        
        self.base_aqi = 35.0         # Initial AQI (good range)
        self.aqi_variation = 0.0
        self.aqi_trend = 0           # -1: improving, 0: stable, 1: worsening
        self.last_aqi_trend_change = datetime.now()
    
    def add_reading(self, water_level, temperature, humidity, aqi):
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        self.water_levels.append(water_level)
        self.temperatures.append(temperature)
        self.humidities.append(humidity)
        self.aqi_levels.append(aqi)
        self.timestamps.append(timestamp)
        
        # Keep only the most recent points
        if len(self.water_levels) > self.max_points:
            self.water_levels.pop(0)
            self.temperatures.pop(0)
            self.humidities.pop(0)
            self.aqi_levels.pop(0)
            self.timestamps.pop(0)
    
    def get_json(self):
        return {
            "water_levels": self.water_levels,
            "temperatures": self.temperatures,
            "humidities": self.humidities,
            "aqi_levels": self.aqi_levels,
            "timestamps": self.timestamps,
            "latest": {
                "water_level": self.water_levels[-1] if self.water_levels else 0,
                "temperature": self.temperatures[-1] if self.temperatures else 0,
                "humidity": self.humidities[-1] if self.humidities else 0,
                "aqi": self.aqi_levels[-1] if self.aqi_levels else 0,
                "timestamp": self.timestamps[-1] if self.timestamps else ""
            }
        }

# Initialize sensor data
sensor_data = SensorData()

# Realistic sensor reading functions
def get_realistic_water_level():
    """Simulates realistic water level changes"""
    now = datetime.now()
    
    # Check if it's time for a water level target change (every 5 minutes)
    if (now - sensor_data.last_water_change).total_seconds() >= 300:  # 5 minutes
        # Set a new target water level
        # In real life, water levels typically change slowly
        # We'll simulate some scenarios: normal consumption, refilling, rapid loss
        scenario = random.choices([
            "normal_consumption",
            "refill",
            "rapid_loss",
            "stable"
        ], weights=[0.4, 0.3, 0.2, 0.1])[0]
        
        current = sensor_data.current_water_level
        
        if scenario == "normal_consumption":
            # Slow decrease (1-10%)
            decrease = random.uniform(1, 10)
            sensor_data.target_water_level = max(0, current - decrease)
        elif scenario == "refill":
            # Increase (10-30%)
            increase = random.uniform(10, 30)
            sensor_data.target_water_level = min(100, current + increase)
        elif scenario == "rapid_loss":
            # Larger decrease (15-25%)
            decrease = random.uniform(15, 25)
            sensor_data.target_water_level = max(0, current - decrease)
        else:  # stable
            # Stay roughly the same
            sensor_data.target_water_level = current + random.uniform(-1, 1)
            
        sensor_data.last_water_change = now
    
    # Move current level toward target gradually
    difference = sensor_data.target_water_level - sensor_data.current_water_level
    # Move 2-5% of the remaining distance each reading
    adjustment_rate = random.uniform(0.02, 0.05)
    sensor_data.current_water_level += difference * adjustment_rate
    
    # Add tiny random fluctuations for sensor noise
    noise = random.uniform(-0.2, 0.2)
    result = max(0, min(100, sensor_data.current_water_level + noise))
    
    return round(result, 1)

def get_realistic_temp_humidity():
    """Simulates realistic temperature and humidity values with daily patterns"""
    now = datetime.now()
    hour = now.hour
    
    # Simulate daily temperature pattern
    # Temperature is typically lowest around 5-6 AM and highest around 3-4 PM
    daily_temp_cycle = math.sin((hour - 5) * math.pi / 12) if 5 <= hour <= 17 else -math.sin((hour - 17) * math.pi / 12)
    
    # Base temperature varies by time of day (±5°C)
    time_based_temp = sensor_data.base_temperature + (daily_temp_cycle * 5)
    
    # Slowly changing temperature variation (simulates weather patterns)
    # Gradually adjust the variation component
    sensor_data.temp_variation = sensor_data.temp_variation * 0.95 + random.uniform(-0.3, 0.3)
    # Limit the maximum variation
    sensor_data.temp_variation = max(-3, min(3, sensor_data.temp_variation))
    
    # Calculate final temperature with a small random component for sensor noise
    temperature = time_based_temp + sensor_data.temp_variation + random.uniform(-0.2, 0.2)
    
    # Humidity has inverse relationship with temperature during the day
    # But also has its own patterns
    base_humidity_for_time = sensor_data.base_humidity - (daily_temp_cycle * 15)
    
    # Humidity variation changes more slowly than temperature
    sensor_data.humidity_variation = sensor_data.humidity_variation * 0.98 + random.uniform(-0.2, 0.2)
    sensor_data.humidity_variation = max(-5, min(5, sensor_data.humidity_variation))
    
    # Calculate final humidity with small random component
    humidity = base_humidity_for_time + sensor_data.humidity_variation + random.uniform(-0.5, 0.5)
    humidity = max(20, min(95, humidity))  # Keep humidity in realistic range
    
    return round(temperature, 1), round(humidity, 1)

def get_realistic_aqi():
    """Simulates realistic AQI values which tend to follow patterns"""
    now = datetime.now()
    hour = now.hour
    
    # Check if it's time to change AQI trend (every 30-60 minutes)
    if (now - sensor_data.last_aqi_trend_change).total_seconds() >= random.uniform(1800, 3600):
        # AQI tends to be worse during rush hours (morning and evening) and better at night
        if 7 <= hour <= 9 or 16 <= hour <= 19:
            # Rush hours - more likely to worsen
            sensor_data.aqi_trend = random.choices([-1, 0, 1], weights=[0.2, 0.3, 0.5])[0]
        elif 22 <= hour or hour <= 5:
            # Night - more likely to improve
            sensor_data.aqi_trend = random.choices([-1, 0, 1], weights=[0.6, 0.3, 0.1])[0]
        else:
            # Other times - random
            sensor_data.aqi_trend = random.choices([-1, 0, 1], weights=[0.4, 0.2, 0.4])[0]
            
        sensor_data.last_aqi_trend_change = now
    
    # Apply the trend with some randomness
    if sensor_data.aqi_trend == 1:  # Worsening
        sensor_data.aqi_variation += random.uniform(0, 0.7)
    elif sensor_data.aqi_trend == -1:  # Improving
        sensor_data.aqi_variation -= random.uniform(0, 0.7)
    else:  # Stable
        sensor_data.aqi_variation += random.uniform(-0.3, 0.3)
    
    # Limit variation
    sensor_data.aqi_variation = max(-15, min(100, sensor_data.aqi_variation))
    
    # Calculate AQI with additional randomness for sensor readings
    aqi = sensor_data.base_aqi + sensor_data.aqi_variation + random.uniform(-0.5, 0.5)
    
    # Ensure AQI stays in valid range
    aqi = max(0, min(500, aqi))
    
    # AQI is reported as an integer
    return round(aqi)

# Sensor reading loop with realistic values
def sensor_loop():
    try:
        while True:
            # Read realistic water level
            water_level = get_realistic_water_level()
            
            # Read realistic temperature and humidity
            temperature, humidity = get_realistic_temp_humidity()
            
            # Read realistic AQI
            aqi = get_realistic_aqi()
                
            # Add readings to data store
            sensor_data.add_reading(water_level, temperature, humidity, aqi)
            
            print(f"Water Level: {water_level}%, Temp: {temperature}°C, Humidity: {humidity}%, AQI: {aqi}")
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
    print("Starting Environmental Monitoring System")
    print("Access the API at: http://localhost:8000/api/readings")
    print("Connect your Next.js frontend to this API endpoint")
    uvicorn.run("sensor_server:app", host="0.0.0.0", port=8000, reload=False)