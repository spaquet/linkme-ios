import Foundation

@Observable
class NavigationManager {
    var selectedPerson: PersonModel?
    var showCaptureSheet = false
    var showBriefingSheet: PersonModel?
    var navigationPath: [PersonModel] = []

    func openPersonDetail(_ person: PersonModel) {
        selectedPerson = person
    }

    func openCapture() {
        showCaptureSheet = true
    }

    func openBriefing(_ person: PersonModel) {
        showBriefingSheet = person
    }

    func closeAll() {
        selectedPerson = nil
        showCaptureSheet = false
        showBriefingSheet = nil
        navigationPath = []
    }
}
