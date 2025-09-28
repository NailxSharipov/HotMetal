//
//  AchievmentView.swift
//  AhievmentPopup
//
//  Created by Nail Sharipov on 31.08.2022.
//

import SwiftUI

struct AchievmentView: View {

    @StateObject
    private var viewModel = ViewModel()
    let color: Color
    let controller: AchievmentController

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.items) { item in
                    Cell(item: item, color: color, duration: viewModel.controller?.lifeTime ?? 1)
                        .padding([.leading, .trailing], 16)
                        .transition(.asymmetric(insertion: .slide, removal: .opacity))
                        .onTapGesture() {
                            controller.onPress(achievmentId: item.id)
                        }
                }
            }
            .padding(.top, 16)
        }
        
        .onAppear() {
            viewModel.controller = controller
        }
    }
}

extension AchievmentItem: Identifiable {}
