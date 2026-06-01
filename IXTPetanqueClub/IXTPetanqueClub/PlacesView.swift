import MapKit
import SwiftUI

struct PlacesView: View {
    @State private var places = SampleData.places
    @State private var weather: WeatherSnapshot?
    @State private var isLoadingPlaces = false
    @State private var isLoadingWeather = false
    @State private var alertMessage: String?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    private let lyonCoordinate = CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderBar(title: "Places", subtitle: "Live courts and weather around Lyon", trailingIcon: "location.fill")

                mapPreview

                VStack(spacing: 12) {
                    SectionTitle(title: "Nearby Courts", action: isLoadingPlaces ? "Loading" : "Refresh") {
                        Task { await loadPlaces() }
                    }
                    ForEach(places) { place in
                        Button {
                            openRoute(to: place)
                        } label: {
                            placeRow(place)
                        }
                        .buttonStyle(.plain)
                    }
                }

                weatherWidget
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .task {
            await loadPlaces()
            await loadWeather()
        }
        .alert("Places", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var mapPreview: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: Array(places.prefix(8))) { place in
            MapAnnotation(coordinate: coordinate(for: place)) {
                Image(systemName: "figure.petanque")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(ClubTheme.electricBlue)
                    .clipShape(Circle())
                    .shadow(color: ClubTheme.electricBlue.opacity(0.45), radius: 10, y: 4)
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .topLeading) {
            Text("Around Lyon")
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(ClubTheme.graphite.opacity(0.84))
                .clipShape(Capsule())
                .padding(16)
        }
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ClubTheme.stroke))
    }

    private func placeRow(_ place: ClubPlace) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "figure.petanque")
                .foregroundStyle(ClubTheme.electricBlue)
                .frame(width: 42, height: 42)
                .background(ClubTheme.electricBlue.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 15, weight: .bold))
                Text("\(place.courts) courts · \(place.openStatus)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
                Text("\(place.type) · \(place.surface) · next \(place.nextSlot)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ClubTheme.muted.opacity(0.9))
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(place.distance)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ClubTheme.electricBlue)
                Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    .foregroundStyle(ClubTheme.muted)
            }
        }
        .padding(14)
        .glassPanel(radius: 16)
    }

    private var weatherWidget: some View {
        let snapshot = weather ?? WeatherSnapshot(
            location: "Lyon, France",
            temperature: isLoadingWeather ? "--" : "Offline",
            description: isLoadingWeather ? "Loading live forecast" : "Using fallback data",
            humidity: "--",
            rain: "--",
            wind: "--",
            icon: "cloud.sun.fill",
            hours: SampleData.weatherHours
        )

        return VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Live Weather", action: isLoadingWeather ? "Loading" : "Refresh") {
                Task { await loadWeather() }
            }
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.location)
                        .font(.system(size: 15, weight: .bold))
                    Text(snapshot.temperature)
                        .font(.system(size: 52, weight: .black))
                    Text(snapshot.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ClubTheme.muted)
                }
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: snapshot.icon)
                        .font(.system(size: 42))
                        .foregroundStyle(snapshot.icon.contains("sun") ? .yellow : ClubTheme.electricBlue)
                    Text("Rain \(snapshot.rain)")
                        .font(.system(size: 12, weight: .bold))
                    Text("Wind \(snapshot.wind)")
                        .font(.system(size: 12, weight: .bold))
                    Text("Humidity \(snapshot.humidity)")
                        .font(.system(size: 12, weight: .bold))
                }
            }
            HStack(spacing: 8) {
                ForEach(snapshot.hours.prefix(6)) { hour in
                    VStack(spacing: 6) {
                        Text(hour.time)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ClubTheme.muted)
                        Image(systemName: hour.icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(hour.icon == "wind" ? ClubTheme.electricBlue : .yellow)
                        Text(hour.temp)
                            .font(.system(size: 11, weight: .black))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(ClubTheme.graphite.opacity(0.34))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(18)
        .clubCard()
    }

    @MainActor
    private func loadPlaces() async {
        isLoadingPlaces = true
        defer { isLoadingPlaces = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "terrain de pétanque"
        request.region = MKCoordinateRegion(
            center: lyonCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )

        do {
            let response = try await MKLocalSearch(request: request).start()
            let origin = CLLocation(latitude: lyonCoordinate.latitude, longitude: lyonCoordinate.longitude)
            let mapped = response.mapItems.prefix(8).enumerated().map { index, item in
                let location = CLLocation(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                let distance = origin.distance(from: location) / 1000
                return ClubPlace(
                    name: item.name ?? "Terrain de pétanque",
                    city: item.placemark.locality ?? "Lyon",
                    courts: max(2, min(8, index + 2)),
                    distance: String(format: "%.1f km", distance),
                    openStatus: "Check hours in Maps",
                    type: item.pointOfInterestCategory == .park ? "Open terrain" : "Club or court",
                    nextSlot: "route",
                    surface: "Local terrain",
                    coordinate: item.placemark.coordinate
                )
            }
            if !mapped.isEmpty {
                places = Array(mapped)
            }
        } catch {
            alertMessage = "Could not load MapKit courts right now. Showing saved club places."
        }
    }

    @MainActor
    private func loadWeather() async {
        isLoadingWeather = true
        defer { isLoadingWeather = false }

        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=45.764&longitude=4.8357&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code&hourly=temperature_2m,weather_code&forecast_days=1&timezone=auto") else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let forecast = try JSONDecoder().decode(OpenMeteoForecast.self, from: data)
            let current = forecast.current
            let hours = forecast.hourly.time.prefix(6).enumerated().map { index, time in
                WeatherHour(
                    time: String(time.suffix(5)),
                    temp: "\(Int(round(forecast.hourly.temperature2m[index])))°",
                    icon: icon(for: forecast.hourly.weatherCode[index])
                )
            }
            weather = WeatherSnapshot(
                location: "Lyon, France",
                temperature: "\(Int(round(current.temperature2m)))°",
                description: description(for: current.weatherCode),
                humidity: "\(current.relativeHumidity2m)%",
                rain: "\(Int(round(current.precipitation))) mm",
                wind: "\(Int(round(current.windSpeed10m))) km/h",
                icon: icon(for: current.weatherCode),
                hours: Array(hours)
            )
        } catch {
            alertMessage = "Could not load live weather. Check network permissions or try again."
        }
    }

    private func openRoute(to place: ClubPlace) {
        let coordinate = coordinate(for: place)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        item.name = place.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    private func coordinate(for place: ClubPlace) -> CLLocationCoordinate2D {
        if let coordinate = place.coordinate {
            return coordinate
        }
        let hash = abs(place.name.hashValue)
        let latOffset = Double(hash % 60) / 10000 - 0.003
        let lonOffset = Double((hash / 60) % 60) / 10000 - 0.003
        return CLLocationCoordinate2D(latitude: lyonCoordinate.latitude + latOffset, longitude: lyonCoordinate.longitude + lonOffset)
    }

    private func icon(for code: Int) -> String {
        switch code {
        case 0: "sun.max.fill"
        case 1...3: "cloud.sun.fill"
        case 45...48: "cloud.fog.fill"
        case 51...67, 80...82: "cloud.rain.fill"
        case 71...77, 85...86: "snowflake"
        case 95...99: "cloud.bolt.rain.fill"
        default: "cloud.fill"
        }
    }

    private func description(for code: Int) -> String {
        switch code {
        case 0: "Clear sky"
        case 1...3: "Partly cloudy"
        case 45...48: "Foggy"
        case 51...67, 80...82: "Rain possible"
        case 71...77, 85...86: "Snow"
        case 95...99: "Thunderstorm"
        default: "Weather updated live"
        }
    }
}

private struct OpenMeteoForecast: Decodable {
    let current: Current
    let hourly: Hourly

    struct Current: Decodable {
        let temperature2m: Double
        let relativeHumidity2m: Int
        let precipitation: Double
        let windSpeed10m: Double
        let weatherCode: Int

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case precipitation
            case windSpeed10m = "wind_speed_10m"
            case weatherCode = "weather_code"
        }
    }

    struct Hourly: Decodable {
        let time: [String]
        let temperature2m: [Double]
        let weatherCode: [Int]

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
        }
    }
}
