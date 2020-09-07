# arrive
home sweet home, actions for smart home upon arriving (using geofences).

Initially I'm supporting garage gate and garage lights toggle, could add more in the future


## Installation
please structure your .env file as:

```bash
GarageGateDeviceId=<some_id>
GarageLightsDeviceId=<other_id>
EwelinkEndpoint=<cloud_function_endpoint>
EwelinkVerifier=<cloud_function_verifier>

HomeLocationId=<home location id (random string)>
HomeLatitude=<home location latitude>
HomeLongitude=<home location longitude>
```
