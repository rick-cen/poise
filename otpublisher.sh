#!/bin/bash

# Function to get the current date and time
current_datetime() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
}

# Function to simulate machine status readings
publish_machine_status() {
    local machine_id=$((RANDOM % 5 + 1)) # Random machine ID between 1 and 5
    local temp=$((RANDOM % 30 + 70)) # Random temperature between 70 and 100
    local vibration=$(awk -v min=0.1 -v max=0.5 'BEGIN{srand(); printf "%.1f", min + rand() * (max - min)}') # Random vibration level between 0.1 and 0.5
    local load=$((RANDOM % 51 + 50)) # Random load between 50 and 100
    local status="running"
    local datetime=$(current_datetime)
    
    mosquitto_pub -t "smart_factory/Section1/Assembly/Machine${machine_id}/status" -h localhost -m "[$datetime] Status: $status, Temp: $temp°C, Vibration: $vibration, Load: $load%" -r -u admin -P admin
}

# Function to simulate production line metrics
publish_production_metrics() {
    local units_produced=$((RANDOM % 100 + 50)) # Random units produced between 50 and 150
    local units_rejected=$((RANDOM % 10)) # Random units rejected between 0 and 9
    local production_rate=$((RANDOM % 31 + 20)) # Random production rate between 20 and 50
    local datetime=$(current_datetime)
    
    mosquitto_pub -t "smart_factory/Section2/Packing/ProductionLine001/metrics" -h localhost -m "[$datetime] Units Produced: $units_produced, Units Rejected: $units_rejected, Rate: $production_rate units/hr" -r -u admin -P admin
}

# Function to simulate environmental readings
publish_environment_data() {
    local temp=$((RANDOM % 11 + 65)) # Random temperature between 65 and 75
    local humidity=$((RANDOM % 21 + 40)) # Random humidity between 40 and 60
    local datetime=$(current_datetime)
    
    mosquitto_pub -t "smart_factory/Section1/environment/temperature" -h localhost -m "[$datetime] Temp: $temp°C" -r -u admin -P admin
    mosquitto_pub -t "smart_factory/Section1/environment/humidity" -h localhost -m "[$datetime] Humidity: $humidity%" -r -u admin -P admin
}

# Function to simulate maintenance alerts
publish_maintenance_alerts() {
    local machine_id=$((RANDOM % 5 + 1)) # Random machine ID between 1 and 5
    local alert="scheduled_maintenance_due"
    local days_due=$((RANDOM % 10 + 1)) # Random due days between 1 and 10
    local datetime=$(current_datetime)
    
    mosquitto_pub -t "smart_factory/maintenance/alerts" -h localhost -m "[$datetime] Machine ID: Machine${machine_id}, Alert: $alert, Due in: $days_due days" -r -u admin -P admin
}

# Function to simulate sensitive data leaks
publish_sensitive_data() {
    local sensitive_data="AccessToken: V2UgTG92ZSBDb2ZmZWU="
    local datetime=$(current_datetime)
    
    mosquitto_pub -t "smart_factory/login_data" -h localhost -m "[$datetime] Admin Data: $sensitive_data" -r -u admin -P admin
}

# Loop to continuously publish messages to the MQTT broker
sensitive_data_counter=0

while true; do
    publish_machine_status
    sleep 4
    publish_production_metrics
    sleep 5
    publish_environment_data
    sleep 3
    
    # Randomly publish maintenance alerts
    if [ $((RANDOM % 10)) -lt 3 ]; then
        publish_maintenance_alerts
    fi

    # Publish sensitive data every 60 seconds
    sensitive_data_counter=$((sensitive_data_counter + 1))
    if [ $sensitive_data_counter -ge 12 ]; then
        publish_sensitive_data
        sensitive_data_counter=0
    fi
done
