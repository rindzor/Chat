//
//  UserAnnotation.swift
//  Chat
//
//  Created by  mac on 2/18/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: MKPointAnnotation {
    var uid: String?
    var age: Int?
    var profileImage: UIImage?
    var isMale: Bool?
}
