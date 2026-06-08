import SwiftUI

struct PeopleView: View {
    let navigationManager: NavigationManager
    @State private var people: [PersonModel] = []
    @State private var searchText = ""

    var filteredPeople: [PersonModel] {
        if searchText.isEmpty {
            return people
        }
        return people.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopBar
                HStack {
                    Text("People")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.ink)

                    Spacer()

                    Button(action: {
                        navigationManager.openCapture()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.t700)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.s500)

                    TextField("Search people", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(LinkMeColors.surface)
                .cornerRadius(LinkMeLayout.cornerRadius)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // List
                if filteredPeople.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(LinkMeColors.s300)

                        Text("No people yet")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.s500)

                        Text("Start capturing notes after meetings")
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(LinkMeColors.s400)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(filteredPeople, id: \.id) { person in
                                Button(action: {
                                    navigationManager.openPersonDetail(person)
                                }) {
                                    HStack(spacing: 12) {
                                        Avatar(name: person.name, size: 44)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(person.name)
                                                .font(.system(size: 15, weight: .semibold, design: .default))
                                                .foregroundColor(LinkMeColors.ink)

                                            Text("\(person.role) · \(person.company)")
                                                .font(.system(size: 13, design: .default))
                                                .foregroundColor(LinkMeColors.s500)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(LinkMeColors.s300)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(LinkMeColors.canvas)
                                }
                            }
                        }
                        .background(LinkMeColors.surface)
                        .cornerRadius(LinkMeLayout.cardRadius)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .padding(.bottom, LinkMeLayout.tabBarHeight + 18)
                    }
                }
            }
        }
        .onAppear {
            // Load mock data on first launch
            let dbPeople = DatabaseManager.shared.fetchPeople()
            people = dbPeople.isEmpty ? MockDataManager.mockPeople : dbPeople
        }
    }
}

#Preview {
    PeopleView(navigationManager: NavigationManager())
}
