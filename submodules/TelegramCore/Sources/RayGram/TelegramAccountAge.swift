import Foundation

public struct TelegramAccountAgeResult: Equatable {
    public let primaryText: String
    public let copyText: String
    public let label: String
    
    public init(primaryText: String, copyText: String, label: String) {
        self.primaryText = primaryText
        self.copyText = copyText
        self.label = label
    }
}

public final class TelegramAccountAge {
    private static let milestones: [(id: Int64, year: Int, month: Int)] = [
        (1, 2013, 8),
        (500_000, 2013, 10),
        (1_500_000, 2013, 12),
        (5_000_000, 2014, 1),
        (15_000_000, 2014, 2),
        (25_000_000, 2014, 3),
        (40_000_000, 2014, 6),
        (55_000_000, 2014, 9),
        (70_000_000, 2014, 12),
        (95_000_000, 2015, 3),
        (120_000_000, 2015, 6),
        (150_000_000, 2015, 9),
        (180_000_000, 2015, 12),
        (220_000_000, 2016, 3),
        (265_000_000, 2016, 6),
        (310_000_000, 2016, 9),
        (360_000_000, 2016, 12),
        (400_000_000, 2017, 4),
        (450_000_000, 2017, 8),
        (510_000_000, 2017, 12),
        (570_000_000, 2018, 3),
        (650_000_000, 2018, 7),
        (720_000_000, 2018, 10),
        (780_000_000, 2018, 12),
        (850_000_000, 2019, 4),
        (930_000_000, 2019, 7),
        (1_000_000_000, 2019, 10),
        (1_060_000_000, 2019, 12),
        (1_160_000_000, 2020, 3),
        (1_280_000_000, 2020, 6),
        (1_400_000_000, 2020, 9),
        (1_540_000_000, 2020, 12),
        (1_700_000_000, 2021, 2),
        (1_880_000_000, 2021, 5),
        (2_000_000_000, 2021, 8),
        (2_140_000_000, 2021, 11),
        // 64-bit ID era
        (5_000_000_000, 2022, 1),
        (5_350_000_000, 2022, 4),
        (5_650_000_000, 2022, 8),
        (6_000_000_000, 2022, 12),
        (6_300_000_000, 2023, 4),
        (6_600_000_000, 2023, 7),
        (6_900_000_000, 2023, 11),
        (7_200_000_000, 2024, 3),
        (7_500_000_000, 2024, 6),
        (7_800_000_000, 2024, 10),
        (8_100_000_000, 2025, 2),
        (8_450_000_000, 2025, 6),
        (8_800_000_000, 2025, 11),
        (9_200_000_000, 2026, 3),
        (9_700_000_000, 2026, 10),
    ]
    
    private static func dateFor(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        components.hour = 12
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
    
    public static func estimateDate(userId: Int64) -> Date? {
        guard userId > 0 else { return nil }
        
        let count = milestones.count
        guard count >= 2 else { return nil }
        
        if userId <= milestones[0].id {
            return dateFor(year: milestones[0].year, month: milestones[0].month)
        }
        
        // Handle transition bridge between 32-bit and 64-bit ID space
        if userId >= 2_140_000_000 && userId < 5_000_000_000 {
            let d1 = dateFor(year: 2021, month: 11).timeIntervalSince1970
            let d2 = dateFor(year: 2022, month: 1).timeIntervalSince1970
            let fraction = Double(userId - 2_140_000_000) / Double(5_000_000_000 - 2_140_000_000)
            let ts = d1 + fraction * (d2 - d1)
            return Date(timeIntervalSince1970: ts)
        }
        
        for i in 0 ..< (count - 1) {
            let m1 = milestones[i]
            let m2 = milestones[i + 1]
            if userId >= m1.id && userId <= m2.id {
                let d1 = dateFor(year: m1.year, month: m1.month).timeIntervalSince1970
                let d2 = dateFor(year: m2.year, month: m2.month).timeIntervalSince1970
                let fraction = Double(userId - m1.id) / Double(m2.id - m1.id)
                let ts = d1 + fraction * (d2 - d1)
                return Date(timeIntervalSince1970: ts)
            }
        }
        
        // If beyond last milestone, extrapolate with recent rate (~80M IDs per month)
        let last = milestones[count - 1]
        let lastDate = dateFor(year: last.year, month: last.month)
        let extraIds = Double(userId - last.id)
        let extraSeconds = (extraIds / 80_000_000.0) * (30.44 * 86400.0)
        return lastDate.addingTimeInterval(extraSeconds)
    }
    
    public static func calculate(userId: Int64, isRussian: Bool) -> TelegramAccountAgeResult? {
        guard let estimatedDate = estimateDate(userId: userId) else { return nil }
        
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let dateComponents = calendar.dateComponents([.year, .month], from: estimatedDate)
        guard let estYear = dateComponents.year, let estMonth = dateComponents.month else { return nil }
        
        let ageComponents = calendar.dateComponents([.year, .month], from: estimatedDate, to: now)
        let years = max(0, ageComponents.year ?? 0)
        let months = max(0, ageComponents.month ?? 0)
        
        let monthName = isRussian ? russianMonthName(estMonth) : englishMonthName(estMonth)
        let label = isRussian ? "отлёга" : "account age"
        
        let ageCompact: String
        let ageFull: String
        
        if isRussian {
            if years > 0 && months > 0 {
                ageCompact = "\(years) \(russianYearsShort(years)) \(months) мес."
                ageFull = "\(years) \(russianYearsWord(years)) \(months) \(russianMonthsWord(months))"
            } else if years > 0 {
                ageCompact = "\(years) \(russianYearsWord(years))"
                ageFull = "\(years) \(russianYearsWord(years))"
            } else if months > 0 {
                ageCompact = "\(months) \(russianMonthsWord(months))"
                ageFull = "\(months) \(russianMonthsWord(months))"
            } else {
                ageCompact = "< 1 мес."
                ageFull = "менее месяца"
            }
            
            let primaryText = "~\(monthName) \(estYear) (\(ageCompact))"
            let copyText = "Дата регистрации: ~\(monthName) \(estYear) (отлёга: \(ageFull))"
            return TelegramAccountAgeResult(primaryText: primaryText, copyText: copyText, label: label)
        } else {
            if years > 0 && months > 0 {
                ageCompact = "\(years)y \(months)m"
                ageFull = "\(years) \(years == 1 ? "year" : "years") \(months) \(months == 1 ? "month" : "months")"
            } else if years > 0 {
                ageCompact = "\(years) \(years == 1 ? "year" : "years")"
                ageFull = "\(years) \(years == 1 ? "year" : "years")"
            } else if months > 0 {
                ageCompact = "\(months) \(months == 1 ? "month" : "months")"
                ageFull = "\(months) \(months == 1 ? "month" : "months")"
            } else {
                ageCompact = "< 1 month"
                ageFull = "less than a month"
            }
            
            let primaryText = "~\(monthName) \(estYear) (\(ageCompact))"
            let copyText = "Registration date: ~\(monthName) \(estYear) (account age: \(ageFull))"
            return TelegramAccountAgeResult(primaryText: primaryText, copyText: copyText, label: label)
        }
    }
    
    private static func russianMonthName(_ month: Int) -> String {
        switch month {
        case 1: return "Январь"
        case 2: return "Февраль"
        case 3: return "Март"
        case 4: return "Апрель"
        case 5: return "Май"
        case 6: return "Июнь"
        case 7: return "Июль"
        case 8: return "Август"
        case 9: return "Сентябрь"
        case 10: return "Октябрь"
        case 11: return "Ноябрь"
        case 12: return "Декабрь"
        default: return ""
        }
    }
    
    private static func englishMonthName(_ month: Int) -> String {
        switch month {
        case 1: return "January"
        case 2: return "February"
        case 3: return "March"
        case 4: return "April"
        case 5: return "May"
        case 6: return "June"
        case 7: return "July"
        case 8: return "August"
        case 9: return "September"
        case 10: return "October"
        case 11: return "November"
        case 12: return "December"
        default: return ""
        }
    }
    
    private static func russianYearsWord(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder100 >= 11 && remainder100 <= 19 {
            return "лет"
        }
        if remainder10 == 1 {
            return "год"
        }
        if remainder10 >= 2 && remainder10 <= 4 {
            return "года"
        }
        return "лет"
    }
    
    private static func russianYearsShort(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder100 >= 11 && remainder100 <= 19 {
            return "лет"
        }
        if remainder10 == 1 {
            return "год"
        }
        if remainder10 >= 2 && remainder10 <= 4 {
            return "года"
        }
        return "лет"
    }
    
    private static func russianMonthsWord(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder100 >= 11 && remainder100 <= 19 {
            return "месяцев"
        }
        if remainder10 == 1 {
            return "месяц"
        }
        if remainder10 >= 2 && remainder10 <= 4 {
            return "месяца"
        }
        return "месяцев"
    }
}
