import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var navigationManager = NavigationManager()

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodayView(navigationManager: navigationManager)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Today")
                    }
                    .tag(0)

                PeopleView(navigationManager: navigationManager)
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("People")
                    }
                    .tag(1)

                ThreadsView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Threads")
                    }
                    .tag(2)

                PrivacyView()
                    .tabItem {
                        Image(systemName: "lock.fill")
                        Text("Privacy")
                    }
                    .tag(3)
            }

            NavigationStack {
                EmptyView()
                    .navigationDestination(item: $navigationManager.selectedPerson) { person in
                        PersonDetailView(person: person)
                    }
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .sheet(isPresented: $navigationManager.showCaptureSheet) {
            CaptureView()
        }
        .sheet(item: $navigationManager.showBriefingSheet) { person in
            BriefingView(person: person)
        }
    }
}

#Preview {
    MainTabView()
}
