import Foundation

class NewsViewModel: ObservableObject {
    @Published var news: [News] = []
    @Published var currentLanguage = "English"
    private var allNews: [News] = []
    private var currentPage = 0
    private let itemsPerPage = 5
    
    let availableLanguages = ["English", "हिंदी", "ગુજરાતી", "தமிழ்", "मराठी"]
    
    init() {
        loadInitialNews()
    }
    
    private func loadInitialNews() {
        guard let url = Bundle.main.url(forResource: "news", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        do {
            // Load and shuffle all news
            allNews = try JSONDecoder().decode([News].self, from: data).shuffled()
            loadMoreNews()
        } catch {
            print("Error decoding news: \(error)")
        }
    }
    
    func loadMoreNews() {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allNews.count)
        
        guard startIndex < allNews.count else { return }
        
        let newItems = Array(allNews[startIndex..<endIndex])
        news.append(contentsOf: newItems)
        currentPage += 1
    }
    
    func refreshNews() {
        news = []
        currentPage = 0
        allNews.shuffle()
        loadMoreNews()
    }
} 