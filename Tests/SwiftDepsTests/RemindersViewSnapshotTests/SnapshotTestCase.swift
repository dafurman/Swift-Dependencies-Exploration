// Created 1/3/19

import Dependencies
import iOSSnapshotTestCase
import SwiftUI

class SnapshotTestCase: FBSnapshotTestCase {

    private var referenceImageDirectory: String?
    private var imageDiffDirectory: String?
    private let perPixelTolerancePercentage = CGFloat(0.4)
    private var window: UIWindow?
    private var oldWindow: UIWindow?

    // MARK: - Lifecycle

    override func tearDown() {
        resetWindow()

        super.tearDown()
    }

    // MARK: - Helper Methods

    private func resetWindow() {
        oldWindow?.makeKeyAndVisible()
        window?.removeFromSuperview()
        setWindowTags(oldWindow: window, mainWindow: oldWindow)
        window = nil
        oldWindow = nil
    }

    private func display(controller: UIViewController, delay: TimeInterval = 0.0) {
        oldWindow = UIApplication.sharedKeyWindow
        window = UIWindow(frame: UIScreen.main.bounds)
        setWindowTags(oldWindow: oldWindow, mainWindow: window)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        oldWindow?.removeFromSuperview()

        _ = controller.view

        waitForDelay(delay)
    }

    private func setWindowTags(oldWindow: UIWindow?, mainWindow: UIWindow?) {
        oldWindow?.tag = 0
        mainWindow?.tag = 13371 // The main window's tag should always be equal to UIWindow.mainAppWindowTag to let this window be used from UIApplication.mainAppWindow.
    }

    private func verify(
        controller: UIViewController,
        delay: TimeInterval = 0.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let directory = ("\(file)" as NSString).deletingLastPathComponent

        // Save for later use in getReferenceImageDirectory
        referenceImageDirectory = NSString.path(withComponents: [directory, "ReferenceImages"])

        // Save for later use in getImageDiffDirectory
        imageDiffDirectory = NSString.path(withComponents: [directory, "FailedSnapshotTests"])

        display(controller: controller, delay: delay)

        FBSnapshotVerifyView(window!, perPixelTolerance: perPixelTolerancePercentage, file: file, line: line)

        resetWindow()
    }

    func verify<ViewContent: View>(
        _ view: ViewContent,
        delay: TimeInterval = 0.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        verify(
            controller: UIHostingController(rootView: view),
            delay: delay,
            file: file,
            line: line
        )
    }

    override func getReferenceImageDirectory(withDefault dir: String?) -> String {
        guard let referenceImageDirectory = referenceImageDirectory else {
            fatalError("Do not call FBSnapshotVerifyView directly.")
        }
        return referenceImageDirectory
    }

    override func getImageDiffDirectory(withDefault dir: Swift.String?) -> Swift.String {
        guard let imageDiffDirectory = imageDiffDirectory else {
            fatalError("Do not call FBSnapshotVerifyView directly.")
        }

        return imageDiffDirectory
    }

}

private extension SnapshotTestCase {
    func waitForDelay(_ delay: TimeInterval) {
        let expectation = expectation(description: "Snapshot test expectation")
        let waitResult = XCTWaiter().wait(for: [expectation], timeout: delay)
        XCTAssertNotEqual(waitResult, .interrupted, "\(expectation.description) interrupted")
    }
}

private extension UIApplication {
    static var sharedKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
