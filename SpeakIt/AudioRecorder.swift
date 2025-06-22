//
//  AudioRecorder.swift
//  SpeakIt
//
//  Created by Kirill Suvorov on 18.04.2025.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    @Published var fileURL: URL? = nil
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.record()
                    } else {
                        print("Нет доступа к микрофону")
                    }
                }
            }
        } catch {
            print("Ошибка настройки AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func record() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let fileName = "recording.m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(fileName)
        fileURL = audioURL
        
        do{
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()
            print("Запись началась: \(audioURL.path)")
        } catch {
            print("Ошибка записи: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        print("Запись остановлена")
    }
    
    func playRecord() {
        guard let fileURL = fileURL else {
            print("Невозможно воспроизвести, файла нет")
            return
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                player = try AVAudioPlayer(contentsOf: fileURL)
                player?.delegate = self
                player?.play()
                
            } catch {
                print("ошибка воспроизведения: \(error.localizedDescription)")
            }
        } else {
            print("Файл не найден")
        }
    }
    
    func stopPlay() {
        player?.stop()
    }
}
