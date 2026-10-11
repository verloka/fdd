# Create Booking

Status: Draft

## Trigger / Outcome
- Initiator: customer submits the booking form (example only).
- Outcome: new confirmed booking or explicit rejection.

## Inputs
- Required: tenantId, serviceId, startTime, customer details.
- Optional: employeeId.

## Outputs
- Success: booking ID, status, time.
- Failure: error code and message.

## Flow
1. Validate tenant and service.
2. Resolve employee and check availability.
3. Create booking and initiate notification.

## Validations
- Service and employee belong to tenant.
- Selected employee provides the service.

## Invariants
- An employee cannot have overlapping confirmed bookings.

## Failures / Side Effects
- Unavailable slot: reject without creating a booking.
- Notification failure behavior remains unverified.
- Writes booking record and initiates notification.

## Dependencies
- Flow: availability
- Flow: notifications

## Scenarios
- S1: Given an available slot, when the customer submits valid data, then a booking is created. [untested]
- S2: Given an occupied slot, when booking is requested, then the request is rejected. [untested]

## Implementation References
- Source paths must be traced in the target repository.

## Unknowns
- Actual transaction boundaries, retries, statuses and notification failure handling.
