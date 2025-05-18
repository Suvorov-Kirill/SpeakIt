//
//  ContentView.swift
//  SpeakIt
//
//  Created by Kirill Suvorov on 18.04.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var audioRecorder = AudioRecorder()
    
    @State private var selectedOption = "Тип разговора"
    @State private var userOption = ""
    @State private var hideTF = true
    @State private var isRecording = false
    var body: some View {
        VStack {
            Text("Название разговора")
            
            Menu {
                Button("Публичное выступление") {
                    selectedOption = "Публичное выступление"
                    hideTF = true
                }
                Button("Защита проекта/реферата") {
                    selectedOption = "Защита проекта/реферата"
                    hideTF = true
                }
                Button("Свой вариант") {
                    selectedOption = "Свой вариант"
                    hideTF = false
                    
                }
                
            } label: {
                Label(selectedOption, systemImage: "chevron.down")
                    .padding()
                    .cornerRadius(8)
            }
            if !hideTF {
                TextField(text: $userOption) {
                    Text("Свой вариант")
                }
                    .padding([.leading, .trailing])
            }
            Spacer()
            Text("Ответ:")
                .multilineTextAlignment(.leading)
                .frame(width: 300, height: 300, alignment: .topLeading)
            Spacer()
            Button {
                audioRecorder.playRecord()
            } label: {
                Text("Воспроизвести")
            }
            Button {
                isRecording.toggle()
                if isRecording {
                    audioRecorder.startRecording()
                } else {
                    audioRecorder.stopRecording()
                }
            } label: {
                HStack{
                    Image(systemName: "play.fill")
                    Text("Старт")
                }
            }
        }
        .padding()
        .onChange(of: audioRecorder.isRecording) { oldValue, newValue in
            
        }
    }
}

#Preview {
    ContentView()
}
