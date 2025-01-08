//
//  TooltipText.swift
//  Mission
//
//  Created by Stephen Grigg on 4/1/2025.
//

import Foundation
import SwiftUI

struct TooltipText: View {
    @State private var isActive = false
    
    let text: String
    let helpText: String
    var body: some View {
        Text(isActive ? helpText : text)
            .padding( isActive ? 6 : 0)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.blue, lineWidth: isActive  ? 1 : 0)
            )
            .animation(.easeOut(duration: 0.2) )
            .gesture(DragGesture(minimumDistance: 0)
                        .onChanged( { _ in isActive = true } )
                        .onEnded( { _ in isActive = false } )
            )
    }
}
