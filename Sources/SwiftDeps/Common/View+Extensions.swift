import Foundation
import SwiftUI

public extension View {
    /// Automatically sets the SwiftUI Preview Name based on the name of the function.
    func previewDisplayName(function: StaticString = #function, requiresLivePreview: Bool = false) -> some View {
        let functionName = "\(function)".formattedPreviewName
        let requiresLivePreviewText = requiresLivePreview ? " - Run in Live Preview" : ""
        return previewDisplayName("\(functionName)\(requiresLivePreviewText)")
    }
}

private extension String {
    var camelCaseToWords: String {
        unicodeScalars.dropFirst().reduce(String(prefix(1))) {
            CharacterSet.uppercaseLetters.contains($1)
            ? $0 + " " + String($1)
            : $0 + String($1)
        }
    }

    var formattedPreviewName: String {
        var string = self.replacingOccurrences(of: "__preview__", with: "")
        string = string.prefix(1).uppercased() + string.dropFirst()

        return string.camelCaseToWords
    }
}
