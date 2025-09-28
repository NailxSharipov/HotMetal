//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 31.08.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    private var viewModel = ViewModel()
    
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                Button("0") {
                    viewModel.unlock(index: 0)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("1") {
                    viewModel.unlock(index: 1)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("2") {
                    viewModel.unlock(index: 2)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("3") {
                    viewModel.unlock(index: 3)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("4") {
                    viewModel.unlock(index: 4)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("5") {
                    viewModel.unlock(index: 5)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("6") {
                    viewModel.unlock(index: 6)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("7") {
                    viewModel.unlock(index: 7)
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
                Button("1-2-3-4") {
                    viewModel.unlock(array: [1, 2, 3, 4])
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(.green)
                .clipShape(Capsule())
            }
            .frame(
                maxHeight: .infinity
            )
            ZStack() {
                AchievmentView(color: .orange, controller: viewModel)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottom
        )
        .background(.yellow)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
