import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .tag(0)

            PeopleScreen()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("People")
                }
                .tag(1)

            ThreadsScreen()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Threads")
                }
                .tag(2)

            PrivacyScreen()
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
