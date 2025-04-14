# Environmental Monitoring System

A real-time environmental monitoring dashboard that displays water level, air quality, temperature, and humidity data from sensors connected to a Raspberry Pi 5.

## Project Overview

This project implements a full-stack IoT monitoring solution with a modern web interface. It consists of two main components:

1. A Python API server running on a Raspberry Pi 5 that collects sensor data
2. A Next.js web application running on a separate machine that provides a real-time dashboard

The system displays four key environmental parameters:
* Water level (percentage)
* Air Quality Index (AQI)
* Temperature (°C)
* Humidity (%)

Data is visualized through both individual monitoring cards with beautiful icons and a historical chart that shows trends over time.

## Features

* **Real-time Data Updates**: Dashboard refreshes automatically every 3 seconds
* **Responsive Design**: Works on desktop and mobile devices
* **Interactive Charts**: Historical data visualization using Chart.js
* **Visual Indicators**: Color-coded status displays for each parameter
* **AQI Classification**: Air quality shown with standard EPA color coding and health recommendations
* **Cross-device Architecture**: API and frontend can run on separate devices
* **Beautiful Icons**: Modern, intuitive icons for each environmental parameter

## Technical Stack

### Backend (Raspberry Pi 5)
* **Framework**: FastAPI
* **Language**: Python
* **Features**:
   * RESTful API
   * CORS support for cross-origin requests
   * Background thread for continuous sensor reading
   * Direct integration with physical sensors

### Frontend (MacBook or any computer)
* **Framework**: Next.js with React
* **Language**: TypeScript
* **Styling**: Tailwind CSS
* **Data Visualization**: Chart.js with react-chartjs-2
* **Icons**: High-quality environmental and dashboard icons

## Setup Instructions

### Prerequisites
* Raspberry Pi 5 with Python 3.8+ installed
* Node.js and npm/yarn installed on your development machine
* Both devices on the same local network
* Required sensors:
  * DHT22 or BME280 for temperature and humidity
  * MQ135 or equivalent for air quality
  * Ultrasonic water level sensor

### Backend Setup (Raspberry Pi 5)
1. Clone the repository to your Raspberry Pi
2. Install required Python packages:

```
pip install fastapi uvicorn pydantic adafruit-circuitpython-dht RPi.GPIO
```

3. Run the server:

```
python sensor_server.py
```

4. Note your Raspberry Pi's IP address (use `hostname -I`)

### Frontend Setup (Development Machine)
1. Clone the repository to your development machine
2. Navigate to the project directory
3. Install dependencies:

```
npm install
```

or

```
yarn
```

4. Update the API URL in `src/app/page.tsx` to point to your Raspberry Pi's IP address
5. Start the development server:

```
npm run dev
```

or

```
yarn dev
```

6. Open your browser to `http://localhost:3000`

## Production Deployment

### Backend
* Set up the Python server to run as a service using systemd on the Raspberry Pi
* Configure the service to start on boot

### Frontend
* Build the Next.js application:

```
npm run build
```

* Deploy the built application using your preferred hosting method

## Sensor Connection Guide

### Water Level Sensor
Connect an ultrasonic sensor (HC-SR04) to GPIO pins:
- VCC to 5V
- GND to GND
- TRIG to GPIO23
- ECHO to GPIO24

### Temperature/Humidity Sensor
Connect a DHT22 sensor:
- VCC to 3.3V
- GND to GND
- DATA to GPIO4

### Air Quality Sensor
Connect an MQ135 sensor:
- VCC to 5V
- GND to GND
- AOUT to an ADC connected to the Pi (or a direct analog input if available)

## License

MIT License

## Acknowledgments

* Chart.js for the visualization library
* Tailwind CSS for the styling framework
* FastAPI for the efficient Python API framework
* Font Awesome and Material Design for the beautiful environmental icons
