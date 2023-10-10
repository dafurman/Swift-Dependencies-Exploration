import Foundation
import SwiftUI
@testable import SwiftDeps
import XCTest

class RemindersViewSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
//        recordMode = true
    }

    func testOneReminderViewLayout() {
        verify(RemindersView_Previews.oneReminderView, delay: 0.1)
    }

    func testLoadingViewLayout() {
        verify(RemindersView_Previews.loadingView, delay: 0.1)
    }

    func testLoadingBlueViewLayout() {
        verify(RemindersView_Previews.loadingBlueView, delay: 0.1)
    }

    func testErrorViewLayout() {
        verify(RemindersView_Previews.errorView, delay: 0.1)
    }

}
