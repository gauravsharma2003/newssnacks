//
//  ContentView.swift
//  NewsSnacks
//
//  Created by Gaurav Sharma on 15/03/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedReadMode: ReadMode = .paragraph
    @State private var showReadModeOptions = false
    @State private var showLanguageOptions = false
    @State private var isDarkMode = false
    @State private var currentIndex = 0
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top bar with app name and dark mode toggle
                HStack {
                    Text("NewsSnacks")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .yellow : .gray)
                            .padding()
                    }
                }
                
                // Vertical scrolling news cards with snap effect
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.news.enumerated()), id: \.1.title) { index, news in
                                NewsCardView(news: news, readMode: selectedReadMode)
                                    .frame(height: geometry.size.height - 140)
                                    .containerRelativeFrame(.vertical)
                                    .id(index)
                                    .onAppear {
                                        currentIndex = index
                                        if index == viewModel.news.count - 3 {
                                            viewModel.loadMoreNews()
                                        }
                                    }
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .refreshable {
                        viewModel.refreshNews()
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // Next card button
                Button {
                    withAnimation {
                        if currentIndex < viewModel.news.count - 1 {
                            scrollProxy?.scrollTo(currentIndex + 1, anchor: .top)
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 35))
                        .foregroundStyle(.blue)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding()
                .padding(.bottom, 80) // Adjust for bottom navigation
            }
            .overlay(alignment: .bottom) {
                // Bottom navigation
                BottomNavigationView(
                    selectedReadMode: $selectedReadMode,
                    showReadModeOptions: $showReadModeOptions,
                    showLanguageOptions: $showLanguageOptions,
                    newsLink: viewModel.news[currentIndex].link,
                    currentLanguage: viewModel.currentLanguage,
                    onShare: {
                        NewsCardView(news: viewModel.news[currentIndex], readMode: selectedReadMode)
                            .snapshot()
                    }
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showReadModeOptions) {
            ReadModeOptionsView(selectedMode: $selectedReadMode)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showLanguageOptions) {
            LanguageOptionsView(
                selectedLanguage: $viewModel.currentLanguage,
                languages: viewModel.availableLanguages
            )
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 140)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
