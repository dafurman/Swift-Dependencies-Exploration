import Dependencies
import Foundation
import SwiftUI

struct RemindersView: View {

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel = .init()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if let reminders = viewModel.reminders {
                List {
                    ForEach(reminders) {
                        Text($0.title)
                    }
                }
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            } else {
                ProgressView()
                    .controlSize(.large)
                    .tint(viewModel.loadingIndicatorColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .onAppear(perform: viewModel.onAppear)
        .task {
            viewModel.task()
        }
    }

    class ViewModel: ObservableObject {
        @Published private(set) var error: Error?
        @Published private(set) var reminders: [Reminder]?

        @Dependency(\.analytics) private static var analytics_static
        @Dependency(\.analytics) private var analytics

        @Dependency(\.remindersRepository) private var remindersRepository
        var loadingIndicatorColor: Color {
            // We have to know about implementation details of Features.BlueLoading_Dependencies to know that we need to propagate dependencies. 😢
            let usesBlue = withDependencies(from: self) {
                Features.BlueLoading.isEnabled
            }
            return usesBlue ? .blue : .black
        }

        @MainActor
        func onAppear() {
            loadReminders()
        }

        func task() {
            // We must use withDependencies(from:) here if we want to use Dependencies.analytics. If we stored these as an instance property wrapper, this could be avoided.
            withDependencies(from: self) {
                Dependencies.analytics.trackEvent(named: "task()")
                // We need to use withDependencies here to propagate the analytics dependency.
                Self.staticTask()
            }
        }

        private static func staticTask() {
            Dependencies.analytics.trackEvent(named: "staticTask()")
        }

        @MainActor
        private func loadReminders() {
            Task {
                do {
                    reminders = try await remindersRepository.fetchReminders()
                } catch {
                    self.error = error
                }
            }
        }
    }

}

struct RemindersView_Previews: PreviewProvider {

    static var loadingView: some View {
        withDependencies {
            $0.remindersRepository = .infiniteLoadingMock
        } operation: {
            RemindersView()
                .previewDisplayName()
        }
    }

    static var loadingBlueView: some View {
        withDependencies {
            $0.remindersRepository = .infiniteLoadingMock
            $0.featureFlags = FeatureFlags(enabledFeatures: [.blueLoading])
        } operation: {
            RemindersView()
                .previewDisplayName()
        }
    }

    static var oneReminderView: some View {
        withDependencies {
            $0.remindersRepository = .oneReminderMock
        } operation: {
            RemindersView()
                .previewDisplayName()
        }
    }

    static var errorView: some View {
        withDependencies {
            $0.remindersRepository = .errorMock
        } operation: {
            RemindersView()
                .previewDisplayName()
        }
    }

    static var previews: some View {
        loadingView
        loadingBlueView
        oneReminderView
        errorView
    }
}
