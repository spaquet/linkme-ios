import Foundation

@Observable
class NavigationManager {
    var showCaptureSheet = false
    var showBriefingSheet: PersonModel?
    var showFollowupSheet: (person: PersonModel, nudge: NudgeModel?)?
    var navigationPath: [PersonModel] = []

    func openPersonDetail(_ person: PersonModel) {
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
    }
}
