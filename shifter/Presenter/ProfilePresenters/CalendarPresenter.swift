import UIKit

// MARK: - Presenter

final class CalendarPresenter: CalendarPresentationLogic {
    weak var viewController: CalendarDisplayLogic?

    func presentCalendar(response: CalendarModule.FetchDays.Response) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"

        let monthText: String
        if let firstEntity = response.entities.first(where: { $0.dayNumber > 0 && $0.isCurrentMonth }) {
            monthText = formatter.string(from: firstEntity.date!)
        } else {
            monthText = formatter.string(from: Date())
        }

        let viewModels = response.entities.map { entity in
            CalendarDayViewModel(
                dayNumber: Int(entity.dayNumber),
                isToday: entity.isToday,
                isCurrentMonth: entity.isCurrentMonth,
                isWeekend: entity.isWeekend
            )
        }

        let viewModel = CalendarModule.FetchDays.ViewModel(
            monthText: monthText,
            days: viewModels
        )
        viewController?.displayCalendar(viewModel: viewModel)
    }
}
