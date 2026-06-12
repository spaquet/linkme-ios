import Foundation

@Observable
class NavigationManager {
    var showCaptureSheet = false
    var showBriefingSheet: PersonModel?
    var showFollowupSheet: (person: PersonModel, nudge: NudgeModel?)?
    var navigationPath: [PersonModel] = []
    // Preserves the Brief -> Profile -> Back to Brief flow. Keep this separate from
    // navigationPath so normal People/Threads profile opens do not show return UI.
    var briefReturnPersonId: String?
    // Set by PersonDetailView before popping. MainTabView consumes it after the
    // navigation path reaches root, because presenting during the pop can be dropped.
    var pendingBriefAfterProfilePop: PersonModel?

    func openPersonDetail(_ person: PersonModel, returnToBrief: Bool = false) {
        briefReturnPersonId = returnToBrief ? person.id : nil
        navigationPath.append(person)
    }

    func openCapture() {
        showCaptureSheet = true
    }

    func openBriefing(_ person: PersonModel) {
        showBriefingSheet = person
    }

    func openFollowup(_ person: PersonModel, nudge: NudgeModel? = nil) {
        showFollowupSheet = (person, nudge)
    }

    func closeAll() {
        showCaptureSheet = false
        showBriefingSheet = nil
        showFollowupSheet = nil
        navigationPath = []
        briefReturnPersonId = nil
        pendingBriefAfterProfilePop = nil
    }
}
