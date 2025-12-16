//
//  NMAuthLocalization.swift
//  NMAuth
//
//  Created by 小大 on 2025/12/10.
//

import Foundation
import NMKit

public extension String {
    
    var pref_localized: String {
        let bundle = Bundle(for: NMPreferenceBundleToken.self)
        
        if let path = bundle.path(forResource: "NMPreferenceModule", ofType: "bundle"),
           let resourceBundle = Bundle(path: path) {
            return self.localized(in: resourceBundle)
        }
        
        return self.localized(in: Bundle.main)
    }
}

private final class NMPreferenceBundleToken {}
