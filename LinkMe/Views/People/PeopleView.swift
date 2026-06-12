import SwiftUI

struct PeopleView: View {
    @Bindable var navigationManager: NavigationManager
    @Binding var selectedTab: Int
    @StateObject private var contactSync = ContactSyncManager.shared
    @State private var people: [PersonModel] = []
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedSort = PersonSortOption.capturedRecent

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

        // Filter by name search
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // Sort
        return PersonSortManager.sort(result, by: selectedSort)
    }

    private func contactDetail(for person: PersonModel) -> String {
        let work = [person.role, person.company]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: " · ")

        if !work.isEmpty {
            return work
        }

        if let snapshotValue = firstSnapshotValue(person.appleContactSnapshotJson, collection: "phoneNumbers") {
            return snapshotValue
        }

        if let snapshotValue = firstSnapshotValue(person.appleContactSnapshotJson, collection: "emailAddresses") {
            return snapshotValue
        }

        return person.appleContactIdentifier == nil ? "App contact" : "iPhone contact"
    }

    private func firstSnapshotValue(_ json: String?, collection: String) -> String? {
        guard let json,
              let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let values = object[collection] as? [[String: Any]] else {
            return nil
        }

        return values.compactMap { $0["value"] as? String }
            .first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopBar
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("People")
                            .font(.system(size: 28, weight: .semibold, design: .default))
                            .tracking(-0.02)
                            .foregroundColor(LinkMeColors.ink)

                        Text("\(people.count) contacts · all on this device")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(LinkMeColors.s500)
                    }

                    Spacer()

                    Menu {
                        ForEach(PersonSortOption.allCases, id: \.id) { option in
                            Button(action: { selectedSort = option }) {
                                HStack(spacing: 6) {
                                    Text(option.rawValue)
                                        .font(.system(size: 14, weight: .semibold, design: .default))

                                    if selectedSort == option {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 36, height: 36)
                            .background(LinkMeColors.surface)
                            .cornerRadius(10)
                            .border(LinkMeColors.s200, width: 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                // Search
                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(LinkMeColors.s500)

                    TextField("Search people", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14.5, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 9)
                .background(LinkMeColors.surface)
                .cornerRadius(LinkMeLayout.cornerRadius)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                // Filter chips
                HStack(spacing: 6) {
                    ForEach(filters, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            Text(filter)
                                .font(.system(size: 13, weight: .semibold, design: .default))
                                .foregroundColor(selectedFilter == filter ? .white : LinkMeColors.s600)
                                .frame(height: 30)
                                .padding(.horizontal, 12)
                                .background(selectedFilter == filter ? LinkMeColors.ink : LinkMeColors.surface)
                                .border(selectedFilter == filter ? LinkMeColors.ink : LinkMeColors.s200, width: 1)
                                .cornerRadius(999)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 9)

                // List
                if people.isEmpty {
                    emptyState
                } else if filteredPeople.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(LinkMeColors.s300)

                        Text("No matches")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.s500)

                        Text("Try a different search or filter")
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(LinkMeColors.s400)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, LinkMeLayout.tabBarHeight)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredPeople.indices, id: \.self) { index in
                                Button(action: {
                                    navigationManager.openPersonDetail(filteredPeople[index])
                                }) {
                                    HStack(spacing: 11) {
                                        Avatar(name: filteredPeople[index].name, size: 42)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(filteredPeople[index].name)
                                                .font(.system(size: 14.5, weight: .semibold, design: .default))
                                                .foregroundColor(LinkMeColors.ink)

                                            Text(contactDetail(for: filteredPeople[index]))
                                                .font(.system(size: 12.5, design: .default))
                                                .foregroundColor(LinkMeColors.s500)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(formatLastContact(filteredPeople[index].lastContact))
                                                .font(.system(size: 11, weight: .regular, design: .default))
                                                .foregroundColor(LinkMeColors.s400)

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(LinkMeColors.s300)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(LinkMeColors.canvas)
                                }

                                if index < filteredPeople.count - 1 {
                                    Divider()
                                        .padding(.horizontal, 14)
                                }
                            }
                        }
                        .background(LinkMeColors.surface)
                        .cornerRadius(LinkMeLayout.cardRadius)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .padding(.bottom, LinkMeLayout.tabBarHeight + 18)
                    }
                }
            }
        }
        .onAppear {
            loadPeople()
            Task {
                if contactSync.isEnabled {
                    await contactSync.sync()
                    loadPeople()
                }
            }
        }
        .onChange(of: contactSync.state) { _, state in
            if state == .synced {
                loadPeople()
            }
        }
        .onChange(of: navigationManager.navigationPath.count) { _, _ in
            loadPeople()
        }
        .onChange(of: selectedFilter) { _, _ in
            loadPeople()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: contactSync.isEnabled ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.plus")
                .font(.system(size: 42, weight: .light))
                .foregroundColor(LinkMeColors.s300)

            VStack(spacing: 5) {
                Text(contactSync.isEnabled ? emptyTitleForEnabledSync : "Sync your contacts")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)

                Text(contactSync.isEnabled ? emptyDetailForEnabledSync : "Turn on Contacts in Privacy to populate People from your iPhone contacts.")
                    .font(.system(size: 13, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 34)
            }

            if !contactSync.isEnabled {
                Button(action: { selectedTab = 4 }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 13, weight: .semibold))

                        Text("Open Privacy")
                            .font(.system(size: 13.5, weight: .semibold, design: .default))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 38)
                    .background(LinkMeColors.ink)
                    .cornerRadius(12)
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, LinkMeLayout.tabBarHeight)
    }

    private var emptyTitleForEnabledSync: String {
        switch contactSync.state {
        case .syncing:
            return "Syncing contacts"
        case .denied:
            return "Contacts access denied"
        case .failed:
            return "Contacts sync failed"
        default:
            return "No contacts found"
        }
    }

    private var emptyDetailForEnabledSync: String {
        switch contactSync.state {
        case .syncing:
            return "Your iPhone contacts are being added to People."
        case .denied:
            return "Allow Contacts access in Settings, then return to Privacy and sync again."
        case .failed(let message):
            return message
        default:
            return "People will appear here after Contacts sync imports them."
        }
    }

    private func loadPeople() {
        switch selectedFilter {
        case "Investors":
            people = DatabaseManager.shared.fetchPeople(matchingTags: ["Investor", "Angel"], partialMatch: true)
        case "Founders":
            people = DatabaseManager.shared.fetchPeople(tagged: "Founder")
        case "Execs":
            people = DatabaseManager.shared.fetchPeople(matchingTags: ["Exec", "Buyer"], partialMatch: true)
        default:
            people = DatabaseManager.shared.fetchPeople()
        }
    }
}

#Preview {
    PeopleView(navigationManager: NavigationManager(), selectedTab: .constant(1))
}
