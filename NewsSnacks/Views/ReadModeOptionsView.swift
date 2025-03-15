import SwiftUI

struct ReadModeOptionsView: View {
    @Binding var selectedMode: ReadMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ReadMode.allCases, id: \.self) { mode in
                    Button {
                        selectedMode = mode
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(mode.rawValue)
                                .font(.headline)
                            Text(mode.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Select Read Mode")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 