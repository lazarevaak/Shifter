import UIKit

// MARK: - Presenter
final class ResultsPresenter: ResultsPresentationLogic {

    // MARK: - Properties
    weak var viewController: ResultsDisplayLogic?

    // MARK: - Presentation Logic
    func presentResults(response: Results.Fetch.Response) {
        let title = "allcardslearned_label".localized
        let leftLine = "unstudied_label".localized + " \(response.leftScore)"
        let studiedLine = "studied_label".localized + " \(response.rightScore)"
        let progressLine = "progress_label".localized + " \(response.progress)%"

        let resultsText = [leftLine, "", studiedLine, "", progressLine].joined(separator: "\n")

        let viewModel = Results.Fetch.ViewModel(
            titleText: title,
            resultsText: resultsText
        )
        viewController?.displayResults(viewModel: viewModel)
    }
}

