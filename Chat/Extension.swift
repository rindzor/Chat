//
//  Extension.swift
//  Chat
//
//  Created by  mac on 2/4/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView{
    
    func addBlackGradientLayer (frame: CGRect, colors:[UIColor]) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.locations = [0.5, 1.0]
        
        gradient.colors = colors.map{$0.cgColor}
        self.layer.addSublayer(gradient)
        
    }
    
    // Функция загружает аватары юзеров в PeopleviewController
    func loadImage(_ urlString: String?, onSuccess: ((UIImage) -> Void)? = nil){
        self.image = UIImage()
        guard let string = urlString else {return}
        guard let url = URL(string: string) else {return}
        
        self.sd_setImage(with: url) { (image, error, type, url ) in
            if onSuccess != nil, error == nil{
                onSuccess!(image!)
            }
        }
    }
}

func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates: Bool)->String{
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if(components.year! >= 2){
        return "\(components.year!) year ago"
    }
    else if (components.year! >= 1) {
        return "1 year ago"
    }
    else if(components.month! >= 2){
        return "\(components.year!) months ago"
    }
    else if(components.month! >= 1){
        return "1 months ago"
    }
    else if(components.day! >= 2){
        return "\(components.day!) days ago"
    }
    else if(components.day! >= 1){
        return "1 day ago"
    }
    else if(components.hour! >= 2){
        return "\(components.hour!) hours ago"
    }
    else if(components.hour! >= 1){
        return "1 hour ago"
    }
    else if(components.minute! >= 2){
        return "\(components.minute!) minutes ago"
    }
    else if(components.minute! >= 1){
        return "1 minute ago"
    }
    else if(components.second! >= 3){
        return "\(components.second!) seconds ago"
    }
    else {
        return "Just now"
    }
    
    return "\(components.hour!) : \(components.minute!)"
}


