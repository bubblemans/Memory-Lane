//
//  VoiceInterface.swift
//  Alz
//
//  Created by Alvin Lin on 2/15/20.
//  Copyright © 2020 Alvin Lin. All rights reserved.
//

import Foundation
import AVFoundation

var audioString: String?
var player : AVPlayer?

struct TextInput: Codable {
    var text: String
}

struct Response: Codable {
    var status: String
    var audio: String
}

class VoiceInterface {
    func textToSpeech() {
//        let utc = TimeZone(abbreviation: "UTC")!
//        let now = Calendar.current.dateComponents(in: utc, from: Date())
//        let year = String(describing: (now.year)!)
//        let month = String(describing: (now.month)!)
//        let day = String(describing: (now.day)!)
        
        let inputText = "Hello, Alvin! Welcome to Alz. Today is 2020 February 15th. You are at Standford University"
        let textInput = TextInput(text: inputText )
        let textJson = try! JSONEncoder().encode(textInput)
        guard let url = URL(string: "https://voice.almond.stanford.edu/rest/tts") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = textJson
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var done = false
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil { return }
            
            if let data = data {
                do {
                    let urlString = try JSONDecoder().decode(Response.self, from: data).audio
                    audioString = "https://voice.almond.stanford.edu" + urlString
                    done = true
                } catch {
                    print("Caught error")
                }
            }
            
        }.resume()
        
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !done
        
        speechURLToAudio()
    }
    
    open func speechURLToAudio() {
        guard  let url = URL(string: audioString!) else {
            print("error to get the mp3 file")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVPlayer(url: url as URL)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
