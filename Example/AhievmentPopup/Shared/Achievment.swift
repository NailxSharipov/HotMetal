//
//  Achievment.swift
//  AhievmentPopup
//
//  Created by Nail Sharipov on 31.08.2022.
//

enum Achievment: Int {
    case firstSuccess = 0       // complete any lesson
    case welcomeAboard = 1      // play 10 games
    case firstLove = 2          // collect 5 hearts
    case expert = 3             // complete lesson without any mistake
    case cinephile = 4          // unlock lesson by watching ad
    case bestFriend = 5         // invite friend
    case subscribtion = 6       // get a subscribtion
    case myTreasure = 7         // buy full version
    case stepByStep = 8         // win 3 times
    case onceAgain = 9          // win completed lesson
    case oneSecondBefore = 10   // one second before ...
    case progressOne = 11       // complete 3 lessons
    case progressTwo = 12       // complete 5 lessons
    case progressThree = 13     // complete 10 lessons
    
    
    var id: String {
        "achiev_\(self.rawValue)"
    }
}
