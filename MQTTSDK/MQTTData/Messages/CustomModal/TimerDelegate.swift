//
//  TimerDelegate.swift
//  MqttChatDemo
//
//  Created by Jayesh on 17/09/18.
//  Copyright © 2018 Hitesh. All rights reserved.
//

import UIKit
protocol TimerCountDelegate: class
{
    func tinerChangeInUserData(_ userInfo : TimerClass)
   
}
class TimerClass
{
    var username: NSString
    var id : NSInteger
    
     var countTimer: NSString!
    
    var secondsLeft :TimeInterval!
    var interval : TimeInterval!
    
    var hours : Int = 0
    var minutes : Int = 0
    var seconds : Int = 0
    
    var timer : Timer!

    init(fromString index : NSInteger ,Username : NSString ) {
        self.id = index
        self.username = Username
    }
    
    func currentTimerString() //this is similar to your method updateCounter:
    {
        self.secondsLeft =  self.secondsLeft - 1
        if self.secondsLeft > 0 {
            self.hours = Int(self.secondsLeft / 3600)
            self.minutes = Int((self.secondsLeft / 3600)/60)
            self.hours = Int(self.secondsLeft / 3600) % 60
            
            self.countTimer = NSString(format: "%02d:%02d:%02d",self.hours,self.minutes,self.seconds)
            
        }else{
            
            self.hours = 0
            self.minutes = 0
            self.seconds = 0
        }
        
        /*
         self.countTimer = [NSString stringWithFormat:@"%02d:%02d:%02d", self.hours, self.minutes, self.seconds];
         if([self.delegate respondsToSelector:@selector(timerChangedInRecipe:)])
         [self.delegate timerChangedInRecipe:self];
         */
    }
}
