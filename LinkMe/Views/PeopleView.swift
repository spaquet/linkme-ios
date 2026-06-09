import SwiftUI

struct PeopleView: View {
    let navigationManager: NavigationManager
    @State private var people: [PersonModel] = []
    @State private var searchText = ""
    @State private var selectedFilter = "All"

    private let filters = ["All", "Investors", "Founders", "Execs"]

    private func formatLastContact(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .month, .year], from: date, to: now)

        guard let days = components.day, let months = components.month, let years = components.year else {
            return "Never"
        }

        if years > 0 {
            return "\(years)y"
        } else if months > 0 {
            // Round up at 15 days: 11mo 23d displays as "12mo"
            let totalMonths = months + (days >= 15 ? 1 : 0)
            return "\(totalMonths)mo"
        } else if days > 0 {
            return "\(days)d"
        } else {
            return "Today"
        }
    }

    private var filteredPeople: [PersonModel] {
        var result = people

        // Filter by selected tag category
        if selectedFilter != "All" {
            result = result.filter { person in
                if selectedFilter == "Investors" {
                    // Match both "Investor" and "Angel" variations
                    return person.tags.contains { $0.contains("Investor") || $0.contains("Angel") }
                } else if selectedFilter == "Founders" {
                    return person.tags.contains("Founder")
                } else if selectedFilter == "Execs" {
                    // Match "Exec" and "Buyer" roles
                    return person.tags.contains { $0.contains("Exec") || $0.contains("Buyer") }
                }
                return true
            }
        }

        // Filter by name search
        if searchText.isEmpty {
            return result
        }
        return result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopBar
                VStack(alignment: .leading, spacing: 4) {
                    Text("People")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)

                    Text("\(people.count) relationships · all on this device")
                        .font(.system(size: 13.5, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

                // Filter chips
                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            Text(filter)
                                .font(.system(size: 13.5, weight: .semibold, design: .default))
                                .foregroundColor(selectedFilter == filter ? .white : LinkMeColors.s600)
                                .frame(height: 32)
                                .padding(.horizontal, 14)
                                .background(selectedFilter == filter ? LinkMeColors.ink : LinkMeColors.surface)
                                .border(selectedFilter == filter ? LinkMeColors.ink : LinkMeColors.s200, width: 1)
                                .cornerRadius(999)
                        }
                    }
                    Spacer()
                }
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

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(formatLastContact(person.lastContact))
                                                .font(.system(size: 11.5, weight: .regular, design: .default))
                                                .foregroundColor(LinkMeColors.s400)

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(LinkMeColors.s300)
                                        }
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
