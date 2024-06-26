//
//  NavigationSheet.swift
//  OnsaTube
//
//  Created by Adem Özsayın on 9.06.2024.
//

import DesignSystem
import Env
import SwiftUI

@MainActor
struct NavigationSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    CloseToolbarItem()
                }
        }
    }
}
