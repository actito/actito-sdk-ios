//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoLoyaltyKit
import Testing

internal struct ActitoPassTest {
    @Test
    internal func testActitoPassSerialization() {
        let pass = ActitoPass(
            id: "testId",
            type: ActitoPass.PassType.boarding,
            version: 1,
            passbook: "testPassbook",
            template: "testTemplate",
            serial: "testSerial",
            barcode: "testBarcode",
            redeem: ActitoPass.Redeem.once,
            redeemHistory: [
                ActitoPass.Redemption(
                    comments: "testComents",
                    date: Date(timeIntervalSince1970: 1)
                ),
            ],
            limit: 1,
            token: "testToken",
            data: ["testDataKey": "testDataValue"],
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedPass = try ActitoPass.fromJson(json: pass.toJson())

            #expect(pass == convertedPass)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoPassSerializationWithNilProps() {
        let pass = ActitoPass(
            id: "testId",
            type: nil,
            version: 1,
            passbook: nil,
            template: nil,
            serial: "testSerial",
            barcode: "testBarcode",
            redeem: ActitoPass.Redeem.once,
            redeemHistory: [],
            limit: 1,
            token: "testToken",
            data: [:],
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedPass = try ActitoPass.fromJson(json: pass.toJson())

            #expect(pass == convertedPass)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testRedemptionSerialization() {
        let redemption = ActitoPass.Redemption(
            comments: "testString",
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedRedemption = try ActitoPass.Redemption.fromJson(json: redemption.toJson())

            #expect(redemption == convertedRedemption)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testRedemptionSerializationWithNilProps() {
        let redemption = ActitoPass.Redemption(
            comments: nil,
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedRedemption = try ActitoPass.Redemption.fromJson(json: redemption.toJson())

            #expect(redemption == convertedRedemption)
        } catch {
            Issue.record()
        }
    }
}
