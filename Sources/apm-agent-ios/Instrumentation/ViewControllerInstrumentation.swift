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

    internal class ViewControllerInstrumentation {
        //let loadView: LoadView
        //let loadViewIfNeeded: LoadViewIfNeeded
        let viewDidLoad: ViewDidLoad
        let viewWillAppear: ViewWillAppear
        let viewDidAppear: ViewDidAppear
        //let viewDidDisappear: ViewDidDisappear
        //let viewWillDisappear: ViewWillDisappear
        //let viewWillLayoutSubviews: ViewWillLayoutSubviews
        //let viewDidLayoutSubviews: ViewDidLayoutSubviews
        //let transition: Transition
        init() throws {
            //loadView = try LoadView.build()
            //loadViewIfNeeded = try LoadViewIfNeeded.build()
            viewDidLoad = try ViewDidLoad.build()
            viewWillAppear = try ViewWillAppear.build()
            viewDidAppear = try ViewDidAppear.build()
            //viewDidDisappear = try ViewDidDisappear.build()
            //viewWillDisappear = try ViewWillDisappear.build()
            //viewWillLayoutSubviews = try ViewWillLayoutSubviews.build()
            //viewDidLayoutSubviews = try ViewDidLayoutSubviews.build()
            //transition = try Transition.build()
            //NotificationCenter.default.addObserver(TraceLogger.self, selector: #selector(TraceLogger.didEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(TraceLogger.self)
        }

        func swizzle() {
            //loadView.swizzle()
            viewDidLoad.swizzle()
            viewWillAppear.swizzle()
            viewDidAppear.swizzle()
            //viewDidDisappear.swizzle()
            //viewWillDisappear.swizzle()
            //transition.swizzle()
            //viewWillLayoutSubviews.swizzle()
            //viewDidLayoutSubviews.swizzle()
        }

        static func getTracer() -> TracerSdk {
            OpenTelemetrySDK.instance.tracerProvider.get(instrumentationName: "UIViewController", instrumentationVersion: "0.0.1") as! TracerSdk
        }

//        class LoadView: MethodSwizzler<
//        @convention(c) (UIViewController, Selector) -> Void,
//            @convention(block) (UIViewController) -> Void
//            >
//            {
//                static func build() throws -> LoadView {
//                    try LoadView(selector: #selector(UIViewController.loadView), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImplementation -> BlockSignature in
//                        { viewController -> Void in
//                            let name = "\(type(of: viewController)).loadView()"
//                            _ = MyTraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name, isRoot: true)
//
//                            previousImplementation(viewController, self.selector)
//
//                            MyTraceLogger.stopTrace(associatedObject: viewController)
//                        }
//                    }
//                }
//            }
//
//        class LoadViewIfNeeded: MethodSwizzler<
//        @convention(c) (UIViewController, Selector) -> Void,
//            @convention(block) (UIViewController) -> Void
//            >
//            {
//                static func build() throws -> LoadViewIfNeeded {
//                    try LoadViewIfNeeded(selector: #selector(UIViewController.loadViewIfNeeded), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImplementation -> BlockSignature in
//                        { viewController -> Void in
//                            let name = "\(type(of: viewController)).loadViewIfNeeded()"
//                            _ = MyTraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name, isRoot: true)
//
//                            previousImplementation(viewController, self.selector)
//
//                            MyTraceLogger.stopTrace(associatedObject: viewController)
//                        }
//                    }
//                }
//            }

        class ViewDidLoad: MethodSwizzler<
        @convention(c) (UIViewController, Selector) -> Void, // IMPSignature
            @convention(block) (UIViewController) -> Void // BlockSignature
            >
            {
                static func build() throws -> ViewDidLoad {
                    try ViewDidLoad(selector: #selector(UIViewController.viewDidLoad), klass: UIViewController.self)
                }

                func swizzle() {
                    swap { previousImplementation -> BlockSignature in
                        { viewController -> Void in
                            let title = viewController.navigationItem.title
                            let name = "\(type(of: viewController)) - view appearing"
                            
                            
                            _ = TraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name, preferredName: title)
                            previousImplementation(viewController, self.selector)
                        }
                    }
                }
            }

//        class AddChild: MethodSwizzler<
//        @convention(c) (UIViewController, Selector, UIViewController) -> Void,
//            @convention(block) (UIViewController, UIViewController) -> Void
//        >{
//            static func build() throws -> AddChild {
//                try AddChild(selector: #selector(UIViewController.addChild), klass: UIViewController.self)
//            }
//
//            func swizzle() {
//                swap { previousImplementation -> BlockSignature in
//                    { viewController, child -> Void in
//                        let name = "\(type(of: child)) added to \(type(of: viewController))"
//                        _ = MyTraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name, isRoot: false)
//                        previousImplementation(viewController, self.selector, child)
//                        MyTraceLogger.stopTrace(associatedObject: viewController)
//                    }
//                }
//            }
//        }
//
//        class Transition: MethodSwizzler <
//        @convention(c) (UIViewController, Selector, UIViewController, UIViewController, TimeInterval, UIView.AnimationOptions, (() -> Void)?, ((Bool) -> Void)?) -> Void,
//            @convention(block) (UIViewController, UIViewController, UIViewController, TimeInterval, UIView.AnimationOptions, (() -> Void)?, ((Bool) -> Void)?) -> Void
//
//            >
//            {
//                static func build() throws -> Transition {
//                    try Transition(selector: #selector(UIViewController.transition), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImplementaion -> BlockSignature in
//                        { viewController, from, to, duration, options, animations, completion -> Void in
//                            let name = "\(type(of: viewController)) transitioning to \(type(of: to)) from \(type(of: from))"
//                            _ = MyTraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name, isRoot: true)
//                            previousImplementaion(viewController, self.selector, from, to, duration, options, animations, completion)
//                            MyTraceLogger.stopTrace(associatedObject: viewController)
//                        }
//                    }
//                }
//            }

        class ViewWillAppear: MethodSwizzler<
        @convention(c) (UIViewController, Selector, Bool) -> Void,
            @convention(block) (UIViewController, Bool) -> Void
            >
            {
                static func build() throws -> ViewWillAppear {
                    try ViewWillAppear(selector: #selector(UIViewController.viewWillAppear), klass: UIViewController.self)
                }

                func swizzle() {
                    swap { previousImplementation -> BlockSignature in
                        { viewController, animated -> Void in
                            let title = viewController.navigationItem.title
                            let name = "\(type(of: viewController)) - view appearing"

                            _ = TraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name, preferredName: title)

                            previousImplementation(viewController, self.selector, animated)
                        }
                    }
                }
            }

        class ViewDidAppear: MethodSwizzler<
        @convention(c) (UIViewController, Selector, Bool) -> Void, // IMPSignature
            @convention(block) (UIViewController, Bool) -> Void // BlockSignature
            >
            {
                static func build() throws -> ViewDidAppear {
                    try ViewDidAppear(selector: #selector(UIViewController.viewDidAppear), klass: UIViewController.self)
                }
                func swizzle() {
                    swap { previousImplementation -> BlockSignature in
                        { viewController, animated -> Void in
                            //let name = "\(type(of: viewController)).viewDidAppear()"
                            //_ = TraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: name)
                            //TraceLogger.setDate(on: viewController)
                            previousImplementation(viewController, self.selector, animated)
                            TraceLogger.stopTrace(associatedObject: viewController)
                        }
                    }
                }
            }

//        class ViewDidDisappear: MethodSwizzler<
//        @convention(c) (UIViewController, Selector, Bool) -> Void, // IMPSignature
//            @convention(block) (UIViewController, Bool) -> Void // BlockSignature
//            >
//            {
//                static func build() throws -> ViewDidDisappear {
//                    try ViewDidDisappear(selector: #selector(UIViewController.viewDidDisappear), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImplementation -> BlockSignature in
//                        { viewController, animated -> Void in
//                            previousImplementation(viewController, self.selector, animated)
//
//                            MyTraceLogger.stopTrace(associatedObject: viewController)
//                        }
//                    }
//                }
//            }
//
//        class ViewWillDisappear: MethodSwizzler<
//        @convention(c) (UIViewController, Selector, Bool) -> Void, // IMPSignature
//            @convention(block) (UIViewController, Bool) -> Void // BlockSignature
//            >
//            {
//                static func build() throws -> ViewWillDisappear {
//                    try ViewWillDisappear(selector: #selector(UIViewController.viewWillDisappear), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImplementation -> BlockSignature in
//                        { viewController, animated -> Void in
//                            _ = MyTraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: "\(type(of: viewController)).viewDisappear()", isRoot: true)
//                            previousImplementation(viewController, self.selector, animated)
//                        }
//                    }
//                }
//            }
//
//        class ViewWillLayoutSubviews: MethodSwizzler <
//        @convention(c) (UIViewController, Selector) -> Void,
//            @convention(block) (UIViewController) -> Void
//            >
//            {
//                static func build() throws -> ViewWillLayoutSubviews {
//                    try ViewWillLayoutSubviews(selector: #selector(UIViewController.viewWillLayoutSubviews), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImplementation -> BlockSignature in
//                        { viewController -> Void in
//                           _ = MyTraceLogger.startTrace(tracer: ViewControllerInstrumentation.getTracer(), associatedObject: viewController, name: "\(type(of: viewController)).viewLayoutSubviews()", isRoot: false)
//                            previousImplementation(viewController, self.selector)
//                        }
//                    }
//                }
//            }
//
//        class ViewDidLayoutSubviews: MethodSwizzler <
//        @convention(c) (UIViewController, Selector) -> Void,
//            @convention(block) (UIViewController) -> Void
//            >
//            {
//                static func build() throws -> ViewDidLayoutSubviews {
//                    try ViewDidLayoutSubviews(selector: #selector(UIViewController.viewDidLayoutSubviews), klass: UIViewController.self)
//                }
//
//                func swizzle() {
//                    swap { previousImpelmentation -> BlockSignature in
//                        { viewController -> Void in
//                            previousImpelmentation(viewController, self.selector)
//                            MyTraceLogger.stopTrace(associatedObject: viewController)
//                        }
//                    }
//                }
//            }
    }

#endif // #if os(iOS)
