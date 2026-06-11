import Foundation

@Observable
class NavigationManager {
    var showCaptureSheet = false
    var showBriefingSheet: PersonModel?
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

    func closeAll() {
        showCaptureSheet = false
        showBriefingSheet = nil
        navigationPath = []
    }
}
