//
//  FetchData.swift
//  SpeakIt
//
//  Created by Kirill Suvorov on 18.05.2025.
//

import Foundation
import Alamofire

struct Response: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
    let role: String
}

func fetchData(fileURL: URL, completion: @escaping (String) -> Void) {
    guard let url = URL(string: "http://172.20.10.6:19096/transcribe") else {
        print("Неверный url")
        return
    }
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("Файл не найден: \(fileURL.path)")
        return
    }
    
    AF.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(fileURL, withName: "audio", fileName: "recording.m4a", mimeType: "audio/m4a")}, to: url)
    .response { response in
        if let error = response.error {
            print("Ошибка загрузки: \(error.localizedDescription)")
        }
        
        if let data = response.data {
            do {
                let responseData = try JSONDecoder().decode(Response.self, from: data)
                let responseText = responseData.choices.first?.message.content
                print(responseText ?? "Ошибка расшифровки json")
                completion(responseText ?? "Ошибка расшифровки json")
            } catch {
                print(error.localizedDescription)
            }
            
            
        } else {
            print("Нет данных от сервера")
        }
    }
}
