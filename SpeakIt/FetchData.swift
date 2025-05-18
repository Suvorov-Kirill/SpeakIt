//
//  FetchData.swift
//  SpeakIt
//
//  Created by Kirill Suvorov on 18.05.2025.
//

import Foundation

struct Response: Codable {
    let choices: [[String]:[String]]
}

func fetchData(fileURL: URL) {
    
    guard let url = URL(string: "192.168.1.106:19096/transcribe") else {
        print("Неверный url")
        return
    }
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("Файл не найден: \(fileURL.path)")
        return
    }
    
    
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        
        if let error = error {
            print("response error: \(error)")
        }
        
        guard let data = data else {
            print("No data")
            return
        }
        
        
    }
}
