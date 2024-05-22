//
//  ContentView.swift
//  Sound
//
//  Created by SABITOV Danil on 22.05.2024.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State var volume: CGFloat = 0.5
    
    var body: some View {
        Image("Background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .overlay {
                OwnSlider(currentVolume: $volume)
                    .frame(width: 100, height: 200)
            }
    }
}

struct OwnSlider: View {
    @Binding var currentVolume: CGFloat
    @State private var lastVolume: CGFloat = .zero
    @State private var widthScale: CGFloat = 1
    @State private var heightScale: CGFloat = 1
    @State private var anchorSide: UnitPoint = .zero
    
    var body: some View {
        GeometryReader { reader in
            let size = reader.size
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.white)
                        .scaleEffect(y: currentVolume, anchor: .bottom)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20 ,style: .continuous))
                .frame(width: size.width, height: size.height)
                .scaleEffect(x: widthScale, y: heightScale, anchor: anchorSide)
                .gesture(
                    LongPressGesture(minimumDuration: 0.0)
                        .onEnded { _ in
                            lastVolume = currentVolume
                        }.simultaneously(with: DragGesture()
                            .onChanged { dragGesture in
                                let startLocation =  dragGesture.startLocation.y
                                let currentLocation = dragGesture.location.y
                                let offset =  startLocation - currentLocation
                                var progress = (offset / size.height) + lastVolume
                                
                                let isDown = progress < 0 ? true : false
                                let power = isDown ? (1 - progress) : (progress)
                                
                                if progress < 0 || progress > 1 {
                                    widthScale = 1 / pow(power, 1 / 10)
                                    heightScale = pow(power, 1 / 8)
                                    anchorSide = isDown ? .top : .bottom
                                }
                                
                                progress = max(0, progress)
                                progress = min(1, progress)
                                
                                currentVolume =  progress
                                
                            }).onEnded { _ in
                                lastVolume = currentVolume
                                withAnimation {
                                    currentVolume = 0.5
                                    widthScale = 1.0
                                    heightScale = 1.0
                                }
                            }
                )
        }
    }
}

#Preview {
    ContentView()
}
