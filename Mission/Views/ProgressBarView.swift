//
//  PrgressBarView.swift
//  Throttle
//
//  Created by Stephen Grigg on 13/2/2025.
//
import SwiftUI

public struct ProgressBarView: View {
    @State var torrent : Torrent
    @ObservedObject var store: Store
    
    public var body: some View {
        if torrent.recheckProgress > 0{
            ProgressView(value: torrent.recheckProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: store.color[torrent.status]))
        }else{
            ProgressView(value: torrent.percentComplete)
                .progressViewStyle(LinearProgressViewStyle(tint: store.color[torrent.status]))
        }
    }
}
