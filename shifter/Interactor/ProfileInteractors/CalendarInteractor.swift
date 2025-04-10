import UIKit

// MARK: - CalendarDayViewModel
struct CalendarDayViewModel {
    let dayNumber: Int
    let isToday: Bool
    let isCurrentMonth: Bool
    let isWeekend: Bool
}

protocol CalendarDisplayLogic: AnyObject {
    func displayCalendar(viewModel: CalendarModule.FetchDays.ViewModel)
}

protocol CalendarBusinessLogic {
    func fetchCalendar(request: CalendarModule.FetchDays.Request)
}

protocol CalendarPresentationLogic {
    func presentCalendar(response: CalendarModule.FetchDays.Response)
}

protocol CalendarRoutingLogic {
    func routeToDayDetail(at date: Date)
}

protocol CalendarDataStore {
    var selectedDate: Date? { get set }
}

import Foundation
import CoreData

// MARK: - VIP Module Definitions
enum CalendarModule {
    enum FetchDays {
        struct Request { let date: Date }
        struct Response { let entities: [CalendarDay] }
        struct ViewModel {
            let monthText: String
            let days: [CalendarDayViewModel]
        }
    }
}

// MARK: - Interactor
final class CalendarInteractor: CalendarBusinessLogic {
    var presenter: CalendarPresentationLogic?
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchCalendar(request: CalendarModule.FetchDays.Request) {
        let calendar = Calendar.current
        guard let firstOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: request.date)
            ),
            let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return }

        let dayCount = range.count
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let weekdayOffset = (firstWeekday - calendar.firstWeekday + 7) % 7

        // Clean up old entities
        let fetchReq: NSFetchRequest<CalendarDay> = CalendarDay.fetchRequest()
        do {
            let oldDays = try context.fetch(fetchReq)
            oldDays.forEach(context.delete)
            try context.save()
        } catch {
            print("Cleanup error: \(error)")
        }

        var days: [CalendarDay] = []

        // Leading blanks
        for _ in 0..<weekdayOffset {
            let blank = CalendarDay(context: context)
            blank.dayNumber = 0
            blank.isCurrentMonth = false
            blank.isToday = false
            blank.isWeekend = false
            days.append(blank)
        }

        let today = calendar.startOfDay(for: Date())
        for day in 1...dayCount {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
            else { continue }
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let weekday = calendar.component(.weekday, from: date)
            let isWeekend = (weekday == 1 || weekday == 7)

            let entity = CalendarDay(context: context)
            entity.date = date
            entity.dayNumber = Int32(day)
            entity.isToday = isToday
            entity.isCurrentMonth = true
            entity.isWeekend = isWeekend
            days.append(entity)
        }

        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }

        let response = CalendarModule.FetchDays.Response(entities: days)
        presenter?.presentCalendar(response: response)
    }
}
