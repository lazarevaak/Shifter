import UIKit

// MARK: - SelectionPresentationLogic
class SelectionPresenter: SelectionPresentationLogic {
    
    // MARK: - Properties
    weak var viewController: SelectionDisplayLogic?
    
    // MARK: - Presentation Logic
    func presentLoad(response: Selection.Load.Response) {
        let questionTexts = response.questions.map { $0.question ?? "–" }
        let answerTexts   = response.answers.map  { $0.answer   ?? "–" }
        let vm = Selection.Load.ViewModel(
            questionTexts: questionTexts,
            answerTexts:   answerTexts
        )
        viewController?.displayLoad(viewModel: vm)
    }
    
    func presentEvaluation(response: Selection.Evaluate.Response) {
        let questionTexts = response.questions.map { $0.question ?? "–" }
        let answerTexts   = response.answers.map   { $0.answer   ?? "–" }
        let vm = Selection.Evaluate.ViewModel(
            questionIndex: response.questionIndex,
            answerIndex:   response.answerIndex,
            isCorrect:     response.isCorrect,
            questionTexts: questionTexts,
            answerTexts:   answerTexts,
            correctCount:  response.correctCount,
            total:         response.total
        )
        viewController?.displayEvaluation(viewModel: vm)
    }
}
