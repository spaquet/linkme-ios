import SwiftUI

struct MainTabView: View {
    let appState: AppState
    @State private var selectedTab = 0
    @State private var navigationManager = NavigationManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TodayView(navigationManager: navigationManager, appState: appState)
                    .tag(0)

                PeopleView(navigationManager: navigationManager)
                    .tag(1)

                ThreadsView(navigationManager: navigationManager)
                    .tag(3)

                PrivacyView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            CustomTabBar(selectedTab: $selectedTab, navigationManager: navigationManager)

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

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(LinkMeColors.s200)

            ZStack(alignment: .center) {
                LinkMeColors.white
                    .ignoresSafeArea(edges: .bottom)

                HStack(spacing: 0) {
                    TabBarItem(
                        icon: "house.fill",
                        label: "Today",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )

                    TabBarItem(
                        icon: "person.2",
                        label: "People",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )

                    VStack {
                        Button(action: {
                            navigationManager.showCaptureSheet = true
                        }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            LinkMeColors.t400,
                                            LinkMeColors.t600
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(22)
                                .shadow(
                                    color: LinkMeColors.t600.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .offset(y: -22)

                        Spacer()
                    }

                    TabBarItem(
                        icon: "chart.bar.yaxis",
                        label: "Threads",
                        isSelected: selectedTab == 3,
                        action: { selectedTab = 3 }
                    )

                    TabBarItem(
                        icon: "checkmark.shield",
                        label: "Privacy",
                        isSelected: selectedTab == 4,
                        action: { selectedTab = 4 }
                    )
                }
                .frame(height: 48)
                .padding(.top, 2)
            }
            .frame(height: 48 + LinkMeLayout.homeInset)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .light))

                Text(label)
                    .font(.system(size: 8.5, weight: isSelected ? .semibold : .light, design: .default))
                    .tracking(0.01)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? LinkMeColors.t700 : LinkMeColors.s400)
        }
    }
}

#Preview {
    let appState = AppState()
    let defaultCard = CardModel(
        firstName: "Marcus",
        lastName: "Chen",
        email: "marcus@meridian.com",
        role: "General Partner",
        company: "Meridian Ventures",
        isDefault: true
    )
    appState.currentUser = UserModel(
        firstName: "Marcus",
        lastName: "Chen",
        email: "marcus@meridian.com",
        role: "General Partner",
        company: "Meridian Ventures",
        cards: [defaultCard]
    )
    return MainTabView(appState: appState)
}
