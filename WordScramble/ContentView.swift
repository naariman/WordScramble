//
//  ContentView.swift
//  WordScramble
//
//  Created by Nariman Nogaibayev on 07.08.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var userWords = [String]()
    @State private var rootWord = "some"
    @State private var newWord = ""
    @State private var usedWords = [String]()
    
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter new word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                }
                
                Section("Score") {
                    Text("Your score = \(score)")
                }
            }.navigationTitle(rootWord)
                .onSubmit { addNewWord() }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Change word") {
                            startGame()
                        }
                    }
                }
        }.onAppear { startGame() }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            }
    }
    
    private func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += answer.count
        
        newWord = ""
    }
    
    private func startGame() {
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startWordsUrl) {
                
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "some"
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    private func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isPossible(word: String) -> Bool {
        guard word.count >= 3 && word != rootWord else { return false }
        
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    private func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
