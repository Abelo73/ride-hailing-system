package com.ride.trip_service.service.impl;

import com.ride.trip_service.dto.ApiResponse;
import com.ride.trip_service.dto.DriverDto;
import com.ride.trip_service.entity.Trip;
import com.ride.trip_service.repository.TripRepository;
import com.ride.trip_service.service.TripService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TripServiceImpl implements TripService {

    private final TripRepository tripRepository;
    private final com.ride.trip_service.producer.TripProducer tripProducer;

    @Override
    public Trip createTrip(Trip trip) {
        if (trip.getCreatedAt() == null) {
            trip.setCreatedAt(LocalDateTime.now());
        }
        trip.setStatus("REQUESTED");
        Trip savedTrip = tripRepository.save(trip);

        // Asynchronous Driver Matching via Kafka
        try {
            com.ride.trip_service.event.TripRequestedEvent event = com.ride.trip_service.event.TripRequestedEvent.builder()
                    .tripId(savedTrip.getId())
                    .userId(savedTrip.getUserId())
                    .pickupLocation(savedTrip.getPickupLocation())
                    .dropoffLocation(savedTrip.getDropoffLocation())
                    .build();
            
            tripProducer.sendTripRequest(event);
        } catch (Exception e) {
            System.err.println("Failed to publish trip request: " + e.getMessage());
        }

        return savedTrip;
    }

    @Override
    public Trip getTripById(Long id) {
        return tripRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Trip not found with id: " + id));
    }

    @Override
    public List<Trip> getAllTrips() {
        return tripRepository.findAll();
    }
}
