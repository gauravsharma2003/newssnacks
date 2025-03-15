import SwiftUI

struct NewsCardView: View {
    let news: News
    let readMode: ReadMode
    @State private var imageData: Data?
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollButton = false
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                // News image
                Group {
                    if let loadedImage = image {
                        Image(uiImage: loadedImage)
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fill)
                            .overlay {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Image Unavailable")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                    }
                }
                .frame(maxHeight: 200)
                .clipped()
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Provider name
                            Text(news.provider)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.gray)
                            
                            // Title
                            Text(news.title)
                                .font(.system(.title2, design: .serif))
                                .fontWeight(.bold)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Content based on read mode
                            if readMode == .snack || readMode == .dinner {
                                let points = readMode == .snack ? news.news.key_points : news.news.detailed_points
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(points, id: \.self) { point in
                                        HStack(alignment: .top, spacing: 8) {
                                            Circle()
                                                .fill(Color.gray.opacity(0.5))
                                                .frame(width: 4, height: 4)
                                                .padding(.top, 8)
                                            Text(point)
                                                .font(.system(.body, design: .rounded))
                                        }
                                    }
                                }
                            } else {
                                Text(readMode.getContent(from: news.news))
                                    .font(.system(.body, design: .rounded))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                        .id("content")
                        .background(GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        showScrollButton = value < -100
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if showScrollButton {
                            Button {
                                withAnimation {
                                    proxy.scrollTo("content", anchor: .top)
                                }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.blue)
                                    .background(Color(UIColor.systemBackground))
                                    .clipShape(Circle())
                            }
                            .padding()
                            .padding(.bottom, 60)
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .task {
            image = await NetworkManager.shared.fetchImage(from: news.image)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 