// src/app/page.tsx

"use client";

import { useState, useEffect, useRef } from 'react';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

// Raspberry Pi IP address
const API_URL = 'http://192.168.1.13:8000/api/readings';

// AQI levels and colors with enhanced visibility
const AQI_LEVELS = [
  { range: [0, 50], label: 'Good', color: 'bg-green-600', textColor: 'text-green-700', borderColor: 'border-green-600', description: 'Air quality is satisfactory, and air pollution poses little or no risk.' },
  { range: [51, 100], label: 'Moderate', color: 'bg-yellow-500', textColor: 'text-yellow-700', borderColor: 'border-yellow-500', description: 'Air quality is acceptable. However, there may be a risk for some people.' },
  { range: [101, 150], label: 'Unhealthy for Sensitive Groups', color: 'bg-orange-500', textColor: 'text-orange-700', borderColor: 'border-orange-500', description: 'Members of sensitive groups may experience health effects.' },
  { range: [151, 200], label: 'Unhealthy', color: 'bg-red-600', textColor: 'text-red-700', borderColor: 'border-red-600', description: 'Some members of the general public may experience health effects.' },
  { range: [201, 300], label: 'Very Unhealthy', color: 'bg-purple-600', textColor: 'text-purple-700', borderColor: 'border-purple-600', description: 'Health alert: The risk of health effects is increased for everyone.' },
  { range: [301, 500], label: 'Hazardous', color: 'bg-pink-900', textColor: 'text-pink-900', borderColor: 'border-pink-900', description: 'Health warning of emergency conditions; everyone is more likely to be affected.' },
];

// Function to get AQI info based on value
const getAqiInfo = (aqi) => {
  return AQI_LEVELS.find(level => aqi >= level.range[0] && aqi <= level.range[1]) || AQI_LEVELS[5];
};

export default function Home() {
  const [data, setData] = useState({
    waterLevel: 0,
    temperature: 0,
    humidity: 0,
    aqi: 35, // Default AQI value
    lastUpdated: '-',
    history: {
      timestamps: [],
      waterLevels: [],
      temperatures: [],
      humidities: [],
      aqiLevels: [], // Added AQI history
    },
  });

  const chartRef = useRef(null);
  const aqiInfo = getAqiInfo(data.aqi);

  // Fetch data from API
  const fetchData = async () => {
    try {
      const response = await fetch(API_URL);
      const responseData = await response.json();

      setData({
        waterLevel: responseData.latest.water_level,
        temperature: responseData.latest.temperature,
        humidity: responseData.latest.humidity,
        aqi: responseData.latest.aqi || data.aqi, // Use existing value if not provided by API
        lastUpdated: responseData.latest.timestamp,
        history: {
          timestamps: responseData.timestamps,
          waterLevels: responseData.water_levels,
          temperatures: responseData.temperatures,
          humidities: responseData.humidities,
          aqiLevels: responseData.aqi_levels || [], // Add AQI history if available
        },
      });
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  // Initial data load and periodic updates
  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 3000);
    return () => clearInterval(interval);
  }, []);

  // Chart configuration with improved visibility
  const chartData = {
    labels: data.history.timestamps,
    datasets: [
      {
        label: 'Water Level (%)',
        data: data.history.waterLevels,
        borderColor: 'rgba(30, 64, 175, 1)', // Darker blue
        backgroundColor: 'rgba(30, 64, 175, 0.2)',
        borderWidth: 3,
        tension: 0.2,
        yAxisID: 'percentage',
      },
      {
        label: 'Temperature (°C)',
        data: data.history.temperatures,
        borderColor: 'rgba(185, 28, 28, 1)', // Darker red
        backgroundColor: 'rgba(185, 28, 28, 0.2)',
        borderWidth: 3,
        tension: 0.2,
        yAxisID: 'temperature',
      },
      {
        label: 'Humidity (%)',
        data: data.history.humidities,
        borderColor: 'rgba(22, 101, 52, 1)', // Darker green
        backgroundColor: 'rgba(22, 101, 52, 0.2)',
        borderWidth: 3,
        tension: 0.2,
        yAxisID: 'percentage',
      },
      // Add AQI dataset if we have history data
      ...(data.history.aqiLevels.length ? [{
        label: 'AQI',
        data: data.history.aqiLevels,
        borderColor: 'rgba(109, 40, 217, 1)', // Darker purple
        backgroundColor: 'rgba(109, 40, 217, 0.2)',
        borderWidth: 3,
        tension: 0.2,
        yAxisID: 'aqi',
      }] : []),
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        display: true,
        title: {
          display: true,
          text: 'Time',
          color: '#374151', // Dark gray text
          font: {
            weight: 'bold',
          }
        },
        grid: {
          color: 'rgba(0, 0, 0, 0.1)', // Slightly darker grid lines
        },
        ticks: {
          color: '#4B5563', // Medium gray text for ticks
        }
      },
      percentage: {
        type: 'linear',
        display: true,
        position: 'left',
        min: 0,
        max: 100,
        title: {
          display: true,
          text: 'Percentage (%)',
          color: '#374151',
          font: {
            weight: 'bold',
          }
        },
        grid: {
          color: 'rgba(0, 0, 0, 0.1)',
        },
        ticks: {
          color: '#4B5563',
        }
      },
      temperature: {
        type: 'linear',
        display: true,
        position: 'right',
        min: 0,
        max: 50,
        grid: {
          drawOnChartArea: false,
          color: 'rgba(0, 0, 0, 0.1)',
        },
        title: {
          display: true,
          text: 'Temperature (°C)',
          color: '#374151',
          font: {
            weight: 'bold',
          }
        },
        ticks: {
          color: '#4B5563',
        }
      },
      aqi: {
        type: 'linear',
        display: data.history.aqiLevels.length > 0,
        position: 'right',
        min: 0,
        max: 500,
        grid: {
          drawOnChartArea: false,
          color: 'rgba(0, 0, 0, 0.1)',
        },
        title: {
          display: true,
          text: 'AQI',
          color: '#374151',
          font: {
            weight: 'bold',
          }
        },
        ticks: {
          color: '#4B5563',
        }
      },
    },
    interaction: {
      mode: 'index',
      intersect: false,
    },
    plugins: {
      legend: {
        position: 'top',
        labels: {
          color: '#1F2937',
          font: {
            weight: 'bold',
          },
          boxWidth: 16,
          padding: 16
        }
      },
      tooltip: {
        backgroundColor: 'rgba(17, 24, 39, 0.8)',
        titleColor: '#F9FAFB',
        bodyColor: '#F3F4F6',
        borderColor: 'rgba(255, 255, 255, 0.2)',
        borderWidth: 1,
        padding: 12,
      }
    },
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <title>Environmental Monitoring System</title>
      <meta name="description" content="Water level, air quality, temperature, and humidity monitoring system" />

      <main className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-center text-gray-900 mb-8 border-b-2 border-gray-200 pb-4">
          Environmental Monitoring Dashboard
        </h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {/* Water Level Card - Enhanced visibility */}
          <div className="bg-white rounded-lg shadow-lg border border-blue-100 p-6 hover:shadow-xl transition-shadow">
            <h2 className="text-xl font-semibold text-blue-800 mb-4 border-b border-blue-100 pb-2">Water Level</h2>
            <div className="flex items-center justify-center space-x-4">
              <div className="relative w-20 h-52 border-4 border-blue-300 rounded-md overflow-hidden bg-blue-50">
                <div
                  className="absolute bottom-0 left-0 w-full bg-blue-600 transition-all duration-500"
                  style={{ height: `${data.waterLevel}%` }}
                ></div>
                {/* Water level markers */}
                <div className="absolute top-0 right-0 h-full flex flex-col justify-between pr-1 text-xs font-bold text-gray-700">
                  <span>100%</span>
                  <span>75%</span>
                  <span>50%</span>
                  <span>25%</span>
                  <span>0%</span>
                </div>
              </div>
              <div className="text-4xl font-bold text-gray-900">{data.waterLevel.toFixed(1)}%</div>
            </div>
          </div>

          {/* AQI Card - Enhanced visibility */}
          <div className="bg-white rounded-lg shadow-lg border border-purple-100 p-6 hover:shadow-xl transition-shadow">
            <h2 className="text-xl font-semibold text-purple-800 mb-4 border-b border-purple-100 pb-2">Air Quality Index</h2>
            <div className="flex flex-col items-center justify-center">
              <div className="w-full mb-3">
                <div className="flex justify-between text-xs font-bold mb-1 text-gray-700">
                  <span>0</span>
                  <span>100</span>
                  <span>200</span>
                  <span>300</span>
                  <span>500</span>
                </div>
                <div className="h-4 w-full flex rounded-full overflow-hidden border border-gray-300">
                  <div className="w-1/6 bg-green-600"></div>
                  <div className="w-1/6 bg-yellow-500"></div>
                  <div className="w-1/6 bg-orange-500"></div>
                  <div className="w-1/6 bg-red-600"></div>
                  <div className="w-1/6 bg-purple-600"></div>
                  <div className="w-1/6 bg-pink-900"></div>
                </div>
                <div className="relative h-6 mt-1">
                  <div
                    className="absolute w-6 h-6 transform -translate-x-1/2 -translate-y-1/2 bg-gray-900 rounded-full shadow-md border-2 border-white"
                    style={{ left: `${Math.min(data.aqi / 5, 100)}%` }}
                  ></div>
                </div>
              </div>
              <div className={`text-5xl font-bold mb-2 ${aqiInfo.textColor}`}>{data.aqi}</div>
              <div className={`text-lg font-semibold ${aqiInfo.textColor} px-4 py-1 rounded-full border ${aqiInfo.borderColor} bg-opacity-10 ${aqiInfo.color.replace('bg-', 'bg-opacity-10 bg-')}`}>
                {aqiInfo.label}
              </div>
              <div className="text-sm text-gray-700 text-center mt-3 font-medium">{aqiInfo.description}</div>
            </div>
          </div>

          {/* Temperature Card - Enhanced visibility */}
          <div className="bg-white rounded-lg shadow-lg border border-red-100 p-6 hover:shadow-xl transition-shadow">
            <h2 className="text-xl font-semibold text-red-800 mb-4 border-b border-red-100 pb-2">Temperature</h2>
            <div className="flex flex-col items-center justify-center">
              <div className="text-6xl font-bold text-red-600 mb-2">
                {data.temperature.toFixed(1)}°C
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3 mt-4">
                <div
                  className="bg-gradient-to-r from-blue-500 via-yellow-500 to-red-600 h-3 rounded-full"
                  style={{ width: `${Math.min(100, (data.temperature / 50) * 100)}%` }}
                ></div>
              </div>
              <div className="flex justify-between w-full text-xs mt-1 text-gray-700 font-medium">
                <span>0°C</span>
                <span>25°C</span>
                <span>50°C</span>
              </div>
            </div>
          </div>

          {/* Humidity Card - Enhanced visibility */}
          <div className="bg-white rounded-lg shadow-lg border border-green-100 p-6 hover:shadow-xl transition-shadow">
            <h2 className="text-xl font-semibold text-green-800 mb-4 border-b border-green-100 pb-2">Humidity</h2>
            <div className="flex flex-col items-center justify-center">
              <div className="relative w-32 h-32 mb-2">
                <svg className="w-full h-full" viewBox="0 0 100 100">
                  <circle
                    cx="50"
                    cy="50"
                    r="45"
                    fill="none"
                    stroke="#E5E7EB"
                    strokeWidth="10"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="45"
                    fill="none"
                    stroke="#047857"
                    strokeWidth="10"
                    strokeDasharray={`${data.humidity.toFixed(1) * 2.83} 283`}
                    strokeDashoffset="0"
                    transform="rotate(-90 50 50)"
                  />
                  <text x="50" y="50" textAnchor="middle" dy="0.3em" className="text-3xl font-bold fill-green-700">
                    {data.humidity.toFixed(0)}%
                  </text>
                </svg>
              </div>
              <div className="text-gray-700 text-sm font-medium mt-2">
                {data.humidity < 30 ? 'Low Humidity' :
                  data.humidity > 70 ? 'High Humidity' : 'Optimal Humidity'}
              </div>
            </div>
          </div>
        </div>

        {/* Chart with enhanced visibility */}
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6 mb-4 hover:shadow-xl transition-shadow">
          <h2 className="text-xl font-semibold text-gray-800 mb-4 border-b border-gray-200 pb-2">Historical Data</h2>
          <div className="h-96">
            <Line ref={chartRef} data={chartData} options={chartOptions} />
          </div>
        </div>

        <div className="text-center text-gray-600 italic bg-gray-100 py-2 px-4 rounded-lg shadow-sm">
          Last updated: <span className="font-semibold">{data.lastUpdated}</span>
        </div>
      </main>
    </div>
  );
}
