import SwiftUI

struct LanguageOptionsView: View {
    @Binding var selectedLanguage: String
    let languages: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languages, id: \.self) { language in
                    Button {
                        selectedLanguage = language
                        dismiss()
                    } label: {
                        Text(language)
                            .foregroundColor(language == selectedLanguage ? .blue : .primary)
                    }
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 