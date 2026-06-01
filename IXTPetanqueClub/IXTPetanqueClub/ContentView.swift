import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: MainTab = .home
    @State private var moreDestination: MoreDestination = .menu

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ClubScreen {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab, moreDestination: $moreDestination)
                        case .match:
                            MatchView()
                        case .rankings:
                            RankingsView(selectedTab: $selectedTab)
                        case .places:
                            PlacesView()
                        case .clubs:
                            ClubsView()
                        case .more:
                            MoreView(destination: $moreDestination)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        BottomNav(selectedTab: $selectedTab)
                    }
                    .ignoresSafeArea(.keyboard)
                }
            } else {
                OnboardingView()
            }
        }
    }
}
