import SwiftUI

struct BottomNavigationView: View {
    @Binding var selectedReadMode: ReadMode
    @Binding var showReadModeOptions: Bool
    @Binding var showLanguageOptions: Bool
    let newsLink: String
    let currentLanguage: String
    @State private var showShareSheet = false
    let onShare: () -> UIImage?
    
    var body: some View {
        HStack {
            Spacer()
            // Read mode button
            Button {
                showReadModeOptions = true
            } label: {
                VStack {
                    Image(systemName: "text.justify.left")
                        .font(.system(size: 24))
                    Text("Read Mode")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // Language button
            Button {
                showLanguageOptions = true
            } label: {
                VStack {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 24))
                    Text(currentLanguage)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // Share button
            Button {
                if let screenshot = onShare() {
                    showShareSheet = true
                }
            } label: {
                VStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 24))
                    Text("Share")
                        .font(.caption)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let screenshot = onShare() {
                    ShareSheet(items: [screenshot])
                }
            }
            
            Spacer()
            
            // Open in browser button
            Button {
                if let url = URL(string: newsLink) {
                    UIApplication.shared.open(url)
                }
            } label: {
                VStack {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 24))
                    Text("Browser")
                        .font(.caption)
                }
            }
            Spacer()
        }
        .foregroundColor(.primary)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

// ShareSheet UIViewControllerRepresentable
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 