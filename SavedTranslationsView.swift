import SwiftUI

struct SavedTranslationsView: View {
    @Binding var savedTranslations: [(String, String)] // Use Binding to modify the original array

    var body: some View {
        VStack {
            Text("Saved Translations")
                .font(.largeTitle)
                .padding()

            List(savedTranslations, id: \.0) { translation, language in
                Text("\(translation) (\(language))") // Display translation with language
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                clearAllTranslations()
            }) {
                Text("Clear All Translations")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
    
    func clearAllTranslations() {
        savedTranslations.removeAll() // Clear the array
        UserDefaults.standard.removeObject(forKey: "savedTranslations") // Remove from UserDefaults
    }
} 