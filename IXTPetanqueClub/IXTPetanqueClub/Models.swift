import Foundation
import CoreLocation
import SwiftUI

struct Player: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let club: String
    let rating: Int
    let winRate: Int
    let avatar: String
    let color: Color
}

struct Tournament: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let capacity: String
    let startsIn: String
}

struct ClubPlace: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let courts: Int
    let distance: String
    let openStatus: String
    let type: String
    let nextSlot: String
    let surface: String
    var coordinate: CLLocationCoordinate2D? = nil
}

struct Club: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let members: Int
    let matchesToday: Int
    let cityRank: Int
    let nextEvent: String
}

struct MatchRecord: Identifiable {
    let id = UUID()
    let title: String
    let score: String
    let place: String
    let duration: String
    let ratingChange: String
    let result: String
}

struct ClubEvent: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let place: String
    let players: String
}

struct ClubNotice: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let time: String
    let icon: String
}

struct AnalyticsMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let detail: String
}

struct WeatherHour: Identifiable {
    let id = UUID()
    let time: String
    let temp: String
    let icon: String
}

struct WeatherSnapshot {
    let location: String
    let temperature: String
    let description: String
    let humidity: String
    let rain: String
    let wind: String
    let icon: String
    let hours: [WeatherHour]
}

struct RuleItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let source: String
}

struct HistoryEvent: Identifiable {
    let id = UUID()
    let year: String
    let title: String
    let detail: String
}

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let sourceName: String
    let summary: String
    let url: URL
}

enum SampleData {
    static let players = [
        Player(name: "Pierre Martin", club: "Club de Lyon", rating: 1540, winRate: 68, avatar: "PM", color: .blue),
        Player(name: "Lucas Bernard", club: "Club de Lyon", rating: 1480, winRate: 62, avatar: "LB", color: .orange),
        Player(name: "Thomas Durand", club: "Club de Nice", rating: 1420, winRate: 57, avatar: "TD", color: .red),
        Player(name: "Julien Moreau", club: "Marseille Sud", rating: 1300, winRate: 51, avatar: "JM", color: .purple),
        Player(name: "Jean Dupont", club: "Club de Lyon", rating: 1620, winRate: 74, avatar: "JD", color: .green),
        Player(name: "Michel Blanc", club: "Marseille Sud", rating: 1580, winRate: 71, avatar: "MB", color: .teal),
        Player(name: "Antoine Lefevre", club: "Petanque Passion", rating: 1560, winRate: 69, avatar: "AL", color: .indigo),
        Player(name: "Camille Roux", club: "Paris Boules", rating: 1515, winRate: 64, avatar: "CR", color: .mint),
        Player(name: "Nicolas Faure", club: "Nice Riviera", rating: 1495, winRate: 61, avatar: "NF", color: .cyan),
        Player(name: "Sophie Garnier", club: "Club de Lyon", rating: 1470, winRate: 60, avatar: "SG", color: .pink),
        Player(name: "Marc Vidal", club: "Toulouse Ovalie", rating: 1445, winRate: 58, avatar: "MV", color: .brown),
        Player(name: "Hugo Caron", club: "Bordeaux Parc", rating: 1390, winRate: 54, avatar: "HC", color: .yellow)
    ]

    static let tournaments = [
        Tournament(name: "Weekend Cup", city: "Marseille", capacity: "8/16", startsIn: "Starts in 2h"),
        Tournament(name: "Open de Lyon", city: "Lyon", capacity: "12/32", startsIn: "Tomorrow"),
        Tournament(name: "Rhone Doubles", city: "Villeurbanne", capacity: "6/8", startsIn: "Friday"),
        Tournament(name: "Paris Precision Night", city: "Paris", capacity: "10/16", startsIn: "Saturday"),
        Tournament(name: "Sud Masters", city: "Nice", capacity: "14/16", startsIn: "Sunday")
    ]

    static let places = [
        ClubPlace(name: "Terrain de la Croix-Rousse", city: "Lyon", courts: 4, distance: "1.2 km", openStatus: "Open until 22:00", type: "Open terrain", nextSlot: "18:30", surface: "Fine gravel"),
        ClubPlace(name: "Club Marseille Sud", city: "Marseille", courts: 6, distance: "3.8 km", openStatus: "Open today", type: "Club", nextSlot: "19:00", surface: "Packed sand"),
        ClubPlace(name: "Parc Borely Courts", city: "Marseille", courts: 3, distance: "4.4 km", openStatus: "Private courts", type: "Private", nextSlot: "Members only", surface: "Natural gravel"),
        ClubPlace(name: "Place Bellecour", city: "Lyon", courts: 2, distance: "1.8 km", openStatus: "Busy", type: "Public", nextSlot: "20:15", surface: "Urban gravel"),
        ClubPlace(name: "Paris Canal Saint-Martin", city: "Paris", courts: 5, distance: "6.2 km", openStatus: "Open today", type: "Open terrain", nextSlot: "17:45", surface: "Mixed gravel")
    ]

    static let clubs = [
        Club(name: "Club de Lyon", city: "Lyon", members: 42, matchesToday: 5, cityRank: 2, nextEvent: "Friday doubles"),
        Club(name: "Club Marseille Sud", city: "Marseille", members: 24, matchesToday: 5, cityRank: 3, nextEvent: "Weekend Cup"),
        Club(name: "Paris Boules", city: "Paris", members: 67, matchesToday: 9, cityRank: 1, nextEvent: "Precision Night"),
        Club(name: "Nice Riviera", city: "Nice", members: 31, matchesToday: 4, cityRank: 4, nextEvent: "Sunday social")
    ]

    static let matchHistory = [
        MatchRecord(title: "Pierre & Lucas vs Thomas & Julien", score: "13 : 9", place: "Club de Lyon", duration: "42 min", ratingChange: "+18", result: "Win"),
        MatchRecord(title: "Pierre vs Jean", score: "10 : 13", place: "Croix-Rousse", duration: "36 min", ratingChange: "-9", result: "Loss"),
        MatchRecord(title: "Pierre, Sophie & Lucas vs Marseille Sud", score: "13 : 7", place: "Terrain de Lyon", duration: "51 min", ratingChange: "+22", result: "Win"),
        MatchRecord(title: "Pierre & Marc vs Michel & Antoine", score: "12 : 13", place: "Parc Borely", duration: "47 min", ratingChange: "-4", result: "Loss")
    ]

    static let events = [
        ClubEvent(title: "Friday Doubles", date: "31 May · 19:00", place: "Club de Lyon", players: "12 going"),
        ClubEvent(title: "Precision Training", date: "02 Jun · 18:30", place: "Croix-Rousse", players: "8 going"),
        ClubEvent(title: "Weekend Cup", date: "08 Jun · 10:00", place: "Marseille Sud", players: "8/16 players"),
        ClubEvent(title: "Club Board Night", date: "12 Jun · 20:00", place: "Clubhouse", players: "Members")
    ]

    static let notices = [
        ClubNotice(title: "Court availability", detail: "Two courts are free after 18:30 at Club de Lyon.", time: "Today", icon: "figure.petanque"),
        ClubNotice(title: "Equipment note", detail: "Score rings and jack markers are available in the clubhouse.", time: "Today", icon: "circle.grid.2x2.fill"),
        ClubNotice(title: "Tournament deadline", detail: "Weekend Cup bracket closes today at 20:00.", time: "Today", icon: "trophy.fill")
    ]

    static let analytics = [
        AnalyticsMetric(title: "Favorite partner", value: "Lucas", detail: "72% win rate together"),
        AnalyticsMetric(title: "Most frequent rival", value: "Thomas", detail: "14 matches this month"),
        AnalyticsMetric(title: "Average score", value: "9.4", detail: "last 30 games"),
        AnalyticsMetric(title: "Best format", value: "2v2", detail: "50% of all matches")
    ]

    static let weatherHours = [
        WeatherHour(time: "12h", temp: "23°", icon: "sun.max.fill"),
        WeatherHour(time: "13h", temp: "24°", icon: "sun.max.fill"),
        WeatherHour(time: "14h", temp: "24°", icon: "cloud.sun.fill"),
        WeatherHour(time: "15h", temp: "25°", icon: "sun.max.fill"),
        WeatherHour(time: "16h", temp: "25°", icon: "wind"),
        WeatherHour(time: "17h", temp: "24°", icon: "cloud.fill")
    ]

    static let rules = [
        RuleItem(title: "Teams", detail: "Pétanque is played as singles, doubles or triples. In singles and doubles each player uses three boules; in triples each player uses two.", source: "FIPJP official rules"),
        RuleItem(title: "Target distance", detail: "For senior play, the jack is valid when thrown between 6 and 10 metres from the throwing circle.", source: "FIPJP official rules"),
        RuleItem(title: "Scoring", detail: "Only one team scores in each mène: one point for each boule closer to the jack than the opponent’s nearest boule.", source: "FIPJP official rules"),
        RuleItem(title: "Winning score", detail: "A standard game is played to 13 points.", source: "FIPJP official rules"),
        RuleItem(title: "Throwing circle", detail: "Players throw with both feet inside the circle and keep them on the ground until the thrown boule has landed.", source: "FIPJP official rules")
    ]

    static let history = [
        HistoryEvent(year: "1907", title: "Modern pétanque is born", detail: "The modern form is generally traced to La Ciotat in Provence, linked to Jules Lenoir and the adaptation of boules with feet fixed."),
        HistoryEvent(year: "1910", title: "Name and first official competition", detail: "The word pétanque became associated with the new game around the first official competition at La Ciotat."),
        HistoryEvent(year: "1945", title: "FFPJP founded", detail: "The Fédération Française de Pétanque et de Jeu Provençal was founded on 31 July 1945 to organise and develop pétanque and jeu provençal in France."),
        HistoryEvent(year: "Today", title: "Club sport across France", detail: "Pétanque remains a major French club sport, played socially and competitively from local terrains to national championships.")
    ]

    static let news = [
        NewsItem(
            title: "FIPJP says no 2026 rule change has been decided",
            date: "2026",
            sourceName: "FIPJP",
            summary: "The international federation states that it is the only body authorised to modify pétanque and jeu provençal rules, and that no 2026 modification has been decided.",
            url: URL(string: "https://www.fipjp.org/")!
        ),
        NewsItem(
            title: "FFPJP competition platform lists official French events",
            date: "2026",
            sourceName: "FFPJP Compétitions",
            summary: "The official competitions platform presents federal national competitions, highlights and upcoming pétanque and jeu provençal events in France.",
            url: URL(string: "https://compet.ffpjp.org/")!
        ),
        NewsItem(
            title: "Official rules reference",
            date: "Updated reference",
            sourceName: "FIPJP",
            summary: "The app’s rule cards are based on the FIPJP official rules for the sport of pétanque.",
            url: URL(string: "https://fipjp.org/images/2021/reglements/Official_Rules_Petanque-En.pdf")!
        )
    ]
}
