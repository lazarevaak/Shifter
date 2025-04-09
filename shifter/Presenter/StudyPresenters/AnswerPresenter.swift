import UIKit

// MARK: - Presenter
final class AnswerReviewPresenter: AnswerReviewPresentationLogic {

    // MARK: - Properties
    weak var viewController: AnswerReviewDisplayLogic?

    // MARK: - Presentation Logic
    func presentResults(response: AnswerReview.FetchResults.Response) {
        let correctText = "correct_label".localized
        let incorrectText = "incorrect_label".localized
        let totalText = "total_label".localized

        let resultsText = """
        \(correctText): \(response.correctAnswers)
        \(incorrectText): \(response.incorrectAnswers)
        \(totalText): \(response.totalCards)
        """

        let viewModel = AnswerReview.FetchResults.ViewModel(
            title: response.title,
            resultsText: resultsText
        )
        viewController?.displayResults(viewModel: viewModel)
    }
}

