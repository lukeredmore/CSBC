//
//  Env.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct Env {
    
    private static let production : Bool = {
        #if DEBUG
        //print("DEBUG")
        return false
        #else
        //print("PRODUCTION")
        return true
        #endif
    }()
    
    static func isProduction () -> Bool {
        return self.production
    }
    
}
