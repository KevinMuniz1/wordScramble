//
//  ContentView.swift
//  wordScramble
//
//  Created by Kevin Muniz on 1/13/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = []
    @State private var rootWord = "example"
    @State private var newWord = ""
    
    @State private var alertTitle = ""
    @State private var messageTitle = ""
    @State private var showAlert = false
    var body: some View {
        NavigationStack {
            List {
                Section{
                    TextField("word", text: $newWord)
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("Enter your word")
                }
                Section(usedWords.count > 0 ? "Used Words" : "") {
                    ForEach(usedWords, id: \.self){ word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.onSubmit(addWord)
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(alertTitle, isPresented: $showAlert) {} message: {
                Text(messageTitle)
            }
            .toolbar {
                Button("Restart", action: restartGame)
            }
        }
    }
    func addWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            alertTitle = "Unoriginal"
            messageTitle = "This has been used before"
            showAlert = true
            return
        }
        
        guard isPossible(word: answer) else {
            alertTitle = "Invalid entry"
            messageTitle = "You can not use these letters to make this word"
            showAlert = true
            return
        }
        
        guard isReal(word: answer) else {
            alertTitle = "Just guessing?"
            messageTitle = "This is not a real word!"
            showAlert = true
            return
        }
            withAnimation {
                usedWords.insert(answer, at: 0)
            }
            newWord = ""
    }
    
    func restartGame() {
        startGame()
        usedWords.removeAll()
    }
    
    func startGame() {
        
        if let fileUrlLoaded = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let loadedContent = try? String(contentsOf: fileUrlLoaded){
                let string = loadedContent.components(separatedBy: "\n")
                rootWord = string.randomElement() ?? "wordless"
                return
            }
        }
        
        fatalError("There was a problem loading the words from the file in the bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var possibleWord = rootWord
        
        for letter in word {
            if let pos = possibleWord.firstIndex(of: letter) {
                possibleWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        
        let wordCheckerRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return wordCheckerRange.location == NSNotFound
    }
}

#Preview {
    ContentView()
}
