import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .tag(0)

            PeopleView()
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
    }
}

#Preview {
    MainTabView()
}
