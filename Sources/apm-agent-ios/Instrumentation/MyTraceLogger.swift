// Copyright © 2021 Elasticsearch BV
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
#if os(iOS)
import Foundation
import OpenTelemetryApi
import OpenTelemetrySdk
import SwiftUI
import UIKit


class MyTraceLogger {
    private static var objectKey: UInt8 = 0
    private static var timerKey: UInt8 = 0
    @objc static func didEnterBackground() {
        OpenTelemetrySDK.instance.contextProvider.activeSpan?.addEvent(name: "application entered background")
    }

    static func setDate(on object: AnyObject) {
        objc_setAssociatedObject(object, UnsafeRawPointer(&Self.timerKey), Date(), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

    static func fetchDate(from object: AnyObject) -> Date? {
        let date = objc_getAssociatedObject(object, UnsafeRawPointer(&Self.timerKey)) as? Date
        objc_setAssociatedObject(object, UnsafeRawPointer(&Self.timerKey), nil, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        return date
    }

    static func startTrace(tracer: TracerSdk, associatedObject: AnyObject, name: String, isRoot: Bool) -> Span? {
        print("####### 4 Starting span ...")
        /*
        var isRoot = true
        if let activeSpan = OpenTelemetrySDK.instance.contextProvider.activeSpan {
            print("####### ACTIVE SPAN: \(activeSpan.context.spanId)")
            isRoot = false
        }
         */
        if isRoot {
            guard let previousSpan = objc_getAssociatedObject(associatedObject, UnsafeRawPointer(&Self.objectKey)) as? Span else {
                
                let builder = tracer.spanBuilder(spanName: "\(name)")
                    .setSpanKind(spanKind: .client).setActive(true)
                
                if isRoot {
                    builder.setNoParent()
                }
                    
                let span = builder.startSpan()
                print("####### 4 Starting span: \(span.context.spanId)")
                print("####### NAME: \(span.name)")
                span.setAttribute(key: "session.id", value: SessionManager.instance.session())
                objc_setAssociatedObject(associatedObject, UnsafeRawPointer(&Self.objectKey), span, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return span
            }
            return previousSpan
        }
        return nil
    }
     
    static func stopTrace(associatedObject: AnyObject) {
        if let span = objc_getAssociatedObject(associatedObject, UnsafeRawPointer(&Self.objectKey)) as? Span {
            print("####### 4 Stopping span: \(span.context.spanId)")
            print("####### NAME: \(span.name)")
            span.status = .ok
            
            if let activeSpanBefore = OpenTelemetrySDK.instance.contextProvider.activeSpan {
                print("####### ACTIVE SPAN BEFORE: \(activeSpanBefore.context.spanId)")
            }
            span.end()
            if let activeSpanAfter = OpenTelemetrySDK.instance.contextProvider.activeSpan {
                print("####### ACTIVE SPAN AFTER: \(activeSpanAfter.context.spanId)")
            }
            objc_setAssociatedObject(associatedObject, UnsafeRawPointer(&Self.objectKey), nil, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
#endif // #if os(iOS)
