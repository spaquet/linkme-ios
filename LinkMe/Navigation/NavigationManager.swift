import Foundation

/// Manages app-wide navigation state (sheets and stack).
///
/// Handles both modal presentations (capture, briefing, followup) and stack-based
/// navigation (person detail profiles). Maintains separate state for return-to-brief flow.
@Observable
class NavigationManager {
    /// Whether the capture sheet is currently open.
    var showCaptureSheet = false

    /// The person to brief, if briefing sheet is open.
    var showBriefingSheet: PersonModel?

    /// The followup sheet state (person and optional nudge context).
    var showFollowupSheet: (person: PersonModel, nudge: NudgeModel?)?

    /// Stack of persons for profile navigation.
    var navigationPath: [PersonModel] = []

    /// Preserves the Brief → Profile → Back to Brief flow (separate from navigationPath).
    var briefReturnPersonId: String?

    /// Pending person to brief after profile closes (set by PersonDetailView on pop).
    var pendingBriefAfterProfilePop: PersonModel?

    /// Open a person's detail profile.
    ///
    /// - Parameters:
    ///   - person: The person to show.
    ///   - returnToBrief: If true, adds a "back to brief" button to the profile.
    func openPersonDetail(_ person: PersonModel, returnToBrief: Bool = false) {
        briefReturnPersonId = returnToBrief ? person.id : nil
        navigationPath.append(person)
    }

    /// Open the capture (voice note) sheet.
    func openCapture() {
        showCaptureSheet = true
    }

    /// Open the briefing sheet for a person.
    ///
    /// - Parameters:
    ///   - person: The person to brief.
    func openBriefing(_ person: PersonModel) {
        showBriefingSheet = person
    }

    /// Open the followup draft sheet.
    ///
    /// - Parameters:
    ///   - person: The person to follow up with.
    ///   - nudge: Optional nudge context that prompted this followup.
    func openFollowup(_ person: PersonModel, nudge: NudgeModel? = nil) {
        showFollowupSheet = (person, nudge)
    }

    /// Close all open sheets and clear navigation stack.
    func closeAll() {
        showCaptureSheet = false
        showBriefingSheet = nil
        showFollowupSheet = nil
        navigationPath = []
        briefReturnPersonId = nil
        pendingBriefAfterProfilePop = nil
    }
}
