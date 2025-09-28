//
//  AchievmentView+DataProvider.swift
//  AhievmentPopup
//
//  Created by Nail Sharipov on 01.09.2022.
//

import SwiftUI

struct AchievmentItem {
    let id: String
    let title: String
    let description: String
    let image: Image
}

protocol AchievmentObserver: AnyObject {
    
    @MainActor
    func onUpdate(items: [AchievmentItem])
    
}

protocol AchievmentDataProvider: AnyObject {
    
    func subscribe(observer: AchievmentObserver)

}

protocol AchievmentController {
    
    var lifeTime: TimeInterval { get }

    var dataProvider: AchievmentDataProvider { get }
    
    func onPress(achievmentId: String)

    func onPresent(ids: [String])
}
