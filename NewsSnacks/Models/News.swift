struct News: Codable {
    let title: String
    let link: String
    let image: String
    let provider: String
    let news: NewsContent
}

struct NewsContent: Codable {
    let paragraph: String
    let genz_version: String
    let key_points: [String]
    let detailed_points: [String]
} 