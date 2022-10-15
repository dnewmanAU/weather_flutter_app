import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../routes/settings.dart';
import '../models/coordinates_model.dart';
import '../models/forecast_model.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Coordinates>? ords;
  Forecast? forecast;
  var lat = 0.0;
  var lon = 0.0;
  var locationName = '';
  var weatherType = '';
  var temp = 0.0;
  var feelsLike = 0.0;
  var tempMin = 0.0;
  var tempMax = 0.0;
  var humidity = 0;
  var windSpeed = 0.0;
  var windDeg = 0;
  var windGust = 0.0;
  var sunrise = 0;
  var sunset = 0;
  var timezone = 0;
  var locationSuccess = false;
  var forecastSuccess = false;

  @override
  void initState() {
    super.initState();

    // fetch latitude and longitude from API
    getLocationOrds('Gold%20Coast');
  }

  getLocationOrds(location) async {
    // also accepts postcode parsed as string
    ords = await LocationService().getCoordinates(location);
    if (ords != null) {
      lat = ords?[0].lat ?? 0.0;
      lon = ords?[0].lon ?? 0.0;
      locationName = ords?[0].name ?? 'Unknown';
      setState(() {
        locationSuccess = true;
        getForecast(lat, lon);
      });
    } else {
      setState(() {
        locationSuccess = false;
      });
    }
  }

  getForecast(lat, lon) async {
    forecast = await WeatherService().getForecast(lat, lon);
    if (forecast != null) {
      weatherType = forecast?.weather[0].main ?? '';
      temp = forecast?.main.temp ?? 0.0;
      feelsLike = forecast?.main.feelsLike ?? 0.0;
      tempMin = forecast?.main.tempMin ?? 0.0;
      tempMax = forecast?.main.tempMax ?? 0.0;
      humidity = forecast?.main.humidity ?? 0;
      windSpeed = forecast?.wind.speed ?? 0.0;
      windDeg = forecast?.wind.deg ?? 0;
      windGust = forecast?.wind.gust ?? 0.0;
      sunrise = forecast?.sys.sunrise ?? 0;
      sunset = forecast?.sys.sunset ?? 0;
      timezone = forecast?.timezone ?? 0;
      setState(() {
        forecastSuccess = true;
      });
    } else {
      setState(() {
        forecastSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              ),
            ),
          ],
        ),
        body: Center(
          child: Visibility(
            visible: locationSuccess && forecastSuccess,
            replacement: const Text('Failed to load location'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter a town or city',
                        ),
                        onFieldSubmitted: (val) => getLocationOrds(val),
                      ),
                    ],
                  ),
                ),
                Text(locationName),
                Text('$lat'),
                Text('$lon'),
                Text('Current: $weatherType'),
                Text('Temperature: $temp'),
                Text('Feels like: $feelsLike'),
                Text('Min: $tempMin'),
                Text('Max: $tempMax'),
                Text('Humidity: $humidity'),
                Text('Wind speed: $windSpeed'),
                Text('Wind direction: $windDeg'),
                Text('Wind gust: $windGust'),
                Text(
                    'SunriseEpoch: ${DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch((sunrise + timezone) * 1000, isUtc: true))}'),
                Text(
                    'SunsetEpoch: ${DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch((sunset + timezone) * 1000, isUtc: true))}'),
                Text('Timezone: $timezone'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
