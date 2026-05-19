#!/bin/bash

GATEWAY_URL="http://localhost:8080/api/v1"

echo "🧪 Starting Step-by-Step Flow Test..."
echo "------------------------------------"

# 1. Create a User
echo "Step 1: Creating a User..."
USER_RESPONSE=$(curl -s -X POST "$GATEWAY_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Step Test User", "email": "step@test.com"}')
echo "Response: $USER_RESPONSE"
echo ""

# 2. Register a Driver
echo "Step 2: Registering an AVAILABLE Driver..."
DRIVER_RESPONSE=$(curl -s -X POST "$GATEWAY_URL/drivers" \
  -H "Content-Type: application/json" \
  -d '{"name": "Fast Driver", "licensePlate": "TEST-888", "status": "AVAILABLE"}')
echo "Response: $DRIVER_RESPONSE"
echo ""

# 3. Request a Trip
echo "Step 3: Requesting a Trip (Linear Matching)..."
TRIP_RESPONSE=$(curl -s -X POST "$GATEWAY_URL/trips" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "pickupLocation": "Point A", "dropoffLocation": "Point B"}')
echo "Response: $TRIP_RESPONSE"
echo ""

# 4. Update Location
echo "Step 4: Updating Driver Location (Redis GEO)..."
LOCATION_RESPONSE=$(curl -s -X POST "$GATEWAY_URL/locations" \
  -H "Content-Type: application/json" \
  -d '{"driverId": 4, "latitude": 37.7749, "longitude": -122.4194}')
echo "Response: $LOCATION_RESPONSE"
echo ""

# 5. Query Nearby
echo "Step 5: Querying Nearby Drivers..."
NEARBY_RESPONSE=$(curl -s -X GET "$GATEWAY_URL/locations/nearby?lat=37.7749&lon=-122.4194&radius=10")
echo "Response: $NEARBY_RESPONSE"
echo ""


echo "------------------------------------"
echo "✅ Test Flow Complete! Check if 'driverId' is assigned in the Trip response."
