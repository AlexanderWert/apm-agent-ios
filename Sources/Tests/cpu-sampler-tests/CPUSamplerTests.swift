// Copyright © 2022 Elasticsearch BV
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.


import Foundation
import Dispatch
import XCTest
@testable import CPUSampler


final class InstrumentorTests: XCTestCase {

    let busy : DispatchWorkItem = DispatchWorkItem(qos: .unspecified, flags: .detached){
        while (true) {
            arc4random()
        }
    }
    
    override func setUp() {
        DispatchQueue.global().async(execute: busy)
        
        
    }
    override func tearDown() {
        if (!busy.isCancelled) {
            busy.cancel()
        }
    }
    
    func testCPUSampler() {
        if #available(iOS 13.0, *) {
            self.measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTClockMetric()]) {
                let result = CPUSampler.cpuFootprint()
                print("cpu usage: \(result)")
            }
        } else {
            self.measure {
                let _ = CPUSampler.cpuFootprint()
            }
        }
    }
}
