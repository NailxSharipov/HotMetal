//
//  ViewModel.swift
//  AhievmentPopup
//
//  Created by Nail Sharipov on 31.08.2022.
//

import SwiftUI

final class ViewModel: ObservableObject {
    
    let provider = TestDataProvider()
    
    func unlock(index: Int) {
        guard let achievment = Achievment(rawValue: index) else { return }
        Task { [weak self] in
            await self?.provider.add(achievment: achievment)
        }
    }
    
    func unlock(array: [Int]) {
        Task { [weak self] in
            var list = [Achievment]()
            for i in array {
                guard let achievment = Achievment(rawValue: i) else { continue }
                list.append(achievment)
            }
            guard !list.isEmpty else { return }
            await self?.provider.add(achievments: list)
        }
    }
    
}

extension ViewModel: AchievmentController {
    
    var lifeTime: TimeInterval { 5 }
    
    var dataProvider: AchievmentDataProvider { provider }
    
    func onPress(achievmentId: String) {
        debugPrint(achievmentId)
    }
    
    func onPresent(ids: [String]) {
        debugPrint("show \(ids)")
    }
}

final class TestDataProvider: AchievmentDataProvider {
    
    private struct Subscription {
        weak var observer: AchievmentObserver?
        
        init(observer: AchievmentObserver) {
            self.observer = observer
        }
    }
    
    private var items: [AchievmentItem] = []
    private var subscriptions: [Subscription] = []
    
    func subscribe(observer: AchievmentObserver) {
        subscriptions = subscriptions.filter({ $0.observer != nil })
        subscriptions.append(.init(observer: observer))
    }

    func add(achievment: Achievment) async {
        let item = AchievmentItem(achievment: achievment)
        await self.add(item: item)
    }
    
    func add(achievments: [Achievment]) async {
        let items = achievments.map({ AchievmentItem(achievment: $0) })
        await self.add(items: items)
    }
    
    @MainActor
    private func add(item: AchievmentItem) {
        guard !items.contains(where: { $0.id == item.id }) else { return }
        items.append(item)
        self.notify()
    }
    
    @MainActor
    private func add(items: [AchievmentItem]) {
        for item in items {
            guard !self.items.contains(where: { $0.id == item.id }) else { continue }
            self.items.append(item)
        }
        self.notify()
    }
    
    @MainActor
    private func notify() {
        subscriptions = subscriptions.filter({ $0.observer != nil })
        for subscription in subscriptions {
            subscription.observer?.onUpdate(items: items)
        }
    }
}

private extension AchievmentItem {
    
    init(achievment: Achievment) {
        let imgName = "image_\(achievment.rawValue % 4)"
        let title: String
        let description = "Description for achievment \(achievment) and some more"
        switch achievment {
        case .firstSuccess:
            title = "firstSuccess"
        case .welcomeAboard:
            title = "welcomeAboard"
        case .firstLove:
            title = "firstLove"
        case .expert:
            title = "expert"
        case .cinephile:
            title = "cinephile"
        case .bestFriend:
            title = "bestFriend"
        case .subscribtion:
            title = "subscribtion"
        case .myTreasure:
            title = "myTreasure"
        case .stepByStep:
            title = "stepByStep"
        case .onceAgain:
            title = "onceAgain"
        case .oneSecondBefore:
            title = "oneSecondBefore"
        case .progressOne:
            title = "progressOne"
        case .progressTwo:
            title = "progressTwo"
        case .progressThree:
            title = "progressThree"
        }
        
        self.init(id: achievment.id, title: title, description: description, image: Image(imgName))
    }
    
}
