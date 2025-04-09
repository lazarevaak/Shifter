import UIKit

// MARK: - Presenter
final class TestPresenter: TestPresentationLogic {

    // MARK: - Properties
    weak var viewController: TestDisplayLogic?

    // MARK: - Presentation Logic
    func presentTest(response: TestModels.TestResponse) {
        let viewModel = TestModels.TestViewModel(
            questionText: response.question,
            currentIndexText: "\(response.currentIndex + 1)",
            totalCards: response.totalCards,
            progress: response.progress,
            isTestCompleted: response.isTestCompleted,
            correctAnswers: response.correctAnswers,
            incorrectAnswers: response.incorrectAnswers
        )
        viewController?.displayTest(viewModel: viewModel)
    }

    func presentAnswer(response: TestModels.CheckAnswerResponse) {
        let viewModel = TestModels.CheckAnswerViewModel(
            alertTitle: response.resultMessage,
            correctAnswers: response.correctAnswers,
            incorrectAnswers: response.incorrectAnswers,
            totalCards: response.totalCards,
            isTestCompleted: response.isTestCompleted
        )
        viewController?.displayAnswer(viewModel: viewModel)
    }
}
