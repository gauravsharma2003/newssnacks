enum ReadMode: String, CaseIterable {
    case paragraph = "Paragraph"
    case snack = "Snack"
    case dinner = "Dinner"
    case genz = "GenZ"
    
    var description: String {
        switch self {
        case .paragraph:
            return "Complete article in a concise format"
        case .snack:
            return "Quick bullet points for busy readers"
        case .dinner:
            return "Detailed breakdown of the story"
        case .genz:
            return "News in GenZ language and style"
        }
    }
    
    func getContent(from news: NewsContent) -> String {
        switch self {
        case .paragraph:
            return news.paragraph
        case .snack:
            return news.key_points.joined(separator: "\n• ")
        case .dinner:
            return news.detailed_points.joined(separator: "\n• ")
        case .genz:
            return news.genz_version
        }
    }
} 