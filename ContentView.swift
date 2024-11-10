import SwiftUI

struct ContentView: View {
    @State private var originalText: String = ""
    @State private var translatedText: String = ""
    @State private var selectedLanguage: String = "fr" // Default language
    @State private var savedTranslations: [(String, String)] = [] // Array to hold saved translations with language
    let languages = ["fr", "es", "de", "it", "zh-CN"] // List of languages

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter text to translate", text: $originalText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity) // Make input box full width
                
                Picker("Select Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Button(action: {
                    translateText()
                }) {
                    Text("Translate")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                // Display the translated text with fixed height
                Text(translatedText)
                    .font(.headline)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, minHeight: 100) // Fixed height for consistency
                    .multilineTextAlignment(.leading) // Align text to the leading edge
                
                NavigationLink(destination: SavedTranslationsView(savedTranslations: $savedTranslations)) {
                    Text("View Saved Translations")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Translate Me")
            .onAppear(perform: loadTranslations) // Load translations when the view appears
        }
    }
    
    func translateText() {
        let urlString = "https://api.mymemory.translated.net/get?q=\(originalText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&langpair=en|\(selectedLanguage)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONDecoder().decode(TranslationResponse.self, from: data) {
                    DispatchQueue.main.async {
                        translatedText = jsonResponse.responseData.translatedText
                        saveTranslation() // Automatically save translation after successful translation
                    }
                }
            }
        }.resume()
    }
    
    func saveTranslation() {
        if !originalText.isEmpty && !translatedText.isEmpty {
            savedTranslations.append((translatedText, selectedLanguage)) // Save translation with language
            originalText = "" // Clear original text after saving
            saveToUserDefaults() // Save to UserDefaults
        }
    }
    
    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        let translations = savedTranslations.map { "\($0.0)|\($0.1)" } // Convert to string format
        defaults.set(translations, forKey: "savedTranslations") // Save to UserDefaults
    }
    
    func loadTranslations() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.array(forKey: "savedTranslations") as? [String] {
            savedTranslations = savedData.compactMap { item in
                let components = item.split(separator: "|").map(String.init)
                return components.count == 2 ? (components[0], components[1]) : nil
            }
        }
    }
}

struct TranslationResponse: Codable {
    let responseData: ResponseData
}

struct ResponseData: Codable {
    let translatedText: String
} 