//
//  ContentView.swift
//  SpeakIt
//
//  Created by Kirill Suvorov on 18.04.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var result: String = "Добро пожаловать в SpeakIt. Я здесь чтобы помочь вам улучшить речь и избавиться от слов-паразитов. Давайте вместе сделаем вашу коммуникацию более уверенной и четкой!"
    let deepPurple = Color(red: 66/255, green: 33/255, blue: 104/255)
    let deepBlue = Color(red: 25/255, green: 40/255, blue: 96/255)
    
    var body: some View {
        ZStack {
            LinearGradient(
                            gradient: Gradient(colors: [deepPurple, deepBlue, Color.indigo]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
            VStack {
                Text("Speakit")
                    .foregroundColor(.white)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                
                
                Spacer()
                ScrollView{
                    Text(result)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                    
                }
                Spacer()
                Button {
                    isPlaying.toggle()
                    if isPlaying {
                        audioRecorder.playRecord()
                    } else {
                        audioRecorder.stopPlay()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Воспроизвести")
                            .foregroundStyle(.cyan)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.bottom, 30)
                
                Button {
                    isRecording.toggle()
                    if isRecording {
                        audioRecorder.startRecording()
                    } else {
                        guard let fileURL = audioRecorder.fileURL else { return }
                        audioRecorder.stopRecording()
                        fetchData(fileURL: fileURL) {result in
                            self.result = result
                        }
                    }
                } label: {
                    VStack{
                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.red)
                            .clipShape(.circle)
                        
                        if !isRecording {
                            Text("Начать запись")
                                .foregroundStyle(.white)
                        } else {
                            Text("Остановить запись")
                                .foregroundStyle(.white)
                        }
                    }
                    
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
