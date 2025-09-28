//
//  AchievmentView+ViewModel.swift
//  AhievmentPopup
//
//  Created by Nail Sharipov on 01.09.2022.
//

import SwiftUI

extension AchievmentView {
    
    final class ViewModel: ObservableObject {
        
        var map: [String: Date] = [:]
        var items: [AchievmentItem] = []
        var controller: AchievmentController? {
            didSet {
                controller?.dataProvider.subscribe(observer: self)
            }
        }

        private var timer: Timer?

    }

}

extension AchievmentView.ViewModel: AchievmentObserver {

    func onUpdate(items: [AchievmentItem]) {
        guard let controller = controller else { return }
        
        assert(Thread.isMainThread)
        let now = Date()
        
        var newItems: [AchievmentItem] = []
        var newIds: [String] = []
        for item in items where map[item.id] == nil {
            map[item.id] = now.addingTimeInterval(controller.lifeTime)
            newItems.append(item)
            newIds.append(item.id)
        }
        
        if !newItems.isEmpty {
            self.controller?.onPresent(ids: newIds)
            
            withAnimation(.easeOut(duration: 0.5)) { [weak self] in
                guard let self = self else { return }
                self.items.append(contentsOf: newItems)
                self.objectWillChange.send()
            }
            
            self.startTimer()
        }
    }
    
    private func startTimer() {
        guard !(timer?.isValid ?? false) else {
            return
        }
        timer?.invalidate()
        
        let newTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.timerUpdate()
        }
        newTimer.fire()
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .default)
    }
    
    private func timerUpdate() {
        assert(Thread.isMainThread)
        guard !items.isEmpty else {
            self.stopTimer()
            return
        }

        let now = Date()
        var oldItems = [String]()
        for item in items {
            if let date = map[item.id], date < now {
                oldItems.append(item.id)
            }
        }
        
        guard !oldItems.isEmpty else {
            return
        }

        withAnimation(.easeOut(duration: 0.5)) { [weak self] in
            guard let self = self else { return }
            items.removeAll(where: { oldItems.contains($0.id) })
            self.objectWillChange.send()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
