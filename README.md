# arrive
home sweet home, actions for smart home upon arriving (using geofences)
initially I'm supporting garage gate and garage lights toggle, could add more in the future


## Installation
please structure your .env file as:

```bash
GarageGateDeviceId=<someid>
GarageLightsDeviceId=<otherid>
EwelinkEndpoint=<cloud function endpoint>
EwelinkVerifier=<cloud function verifier>

HomeLocationId=<home location id (random string)>
HomeLatitude=<home location latitude>
HomeLongitude=<home location longitude>
```
