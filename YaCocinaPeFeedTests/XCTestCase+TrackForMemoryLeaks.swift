//
//  XCTestCase+TrackForMemoryLeaks.swift
//  YaCocinaPeFeedTests
//
//  Created by Pablo Butron on 12/2/25.
//

import XCTest


extension XCTestCase {
    func trackForMemoryLeaks (from instance: AnyObject) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated, potential memory leak")
        }
    }
    
}
