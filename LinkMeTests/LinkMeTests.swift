//
//  LinkMeTests.swift
//  LinkMeTests
//
//  Created by Stéphane PAQUET on 6/8/26.
//

import Testing
@testable import LinkMe

struct LinkMeTests {

    @Test func extractionKeepsFullNameAfterMeetingVerb() async throws {
        let data = AIExtractionManager.fallbackExtract("Met Carl Johnson")

        #expect(data.name == "Carl Johnson")
        #expect(data.name != "Met Carl")
    }

    @Test func extractionRemovesSpeechPunctuationFromShortName() async throws {
        let data = AIExtractionManager.fallbackExtract("Hind Louis.")

        #expect(data.name == "Hind Louis")
        #expect(data.name?.hasSuffix(".") == false)
    }

    @Test func extractionFindsRelationshipFields() async throws {
        let data = AIExtractionManager.fallbackExtract(
            "Met Elena Park at Northstar Health. Founder raising seed. Send intro to Mara tomorrow."
        )

        #expect(data.name == "Elena Park")
        #expect(data.company == "Northstar Health")
        #expect(data.role == "Founder")
        #expect(data.tags.contains("Founder"))
        #expect(data.tags.contains("Seed"))
        #expect(data.tags.contains("Follow-up"))
        #expect(data.followUp != nil)
    }

    @Test func extractionSeparatesIntroFollowUpFromPersonalDetail() async throws {
        let data = AIExtractionManager.fallbackExtract(
            "met greg johnson vp at starbucks 3 kids looking forward to introduce me to their CMO"
        )

        #expect(data.name == "Greg Johnson")
        #expect(data.role == "VP")
        #expect(data.company == "Starbucks")
        #expect(data.liveContext == nil)
        #expect(data.followUp == "Intro to CMO")
        #expect(data.personalDetail == "3 kids")
        #expect(data.tags.contains("Follow-up"))
    }

}
