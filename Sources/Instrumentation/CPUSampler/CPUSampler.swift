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

import Foundation
import OpenTelemetryApi
import OpenTelemetrySdk

public class CPUSampler {
    let meter: Meter
    var gauge: DoubleObserverMetric
    var cpuTime: AnyCounterMetric<Double>
    public init() {
        meter = OpenTelemetrySDK.instance.meterProvider.get(instrumentationName: "CPU Sampler", instrumentationVersion: "0.0.1")
        
        cpuTime = meter.createDoubleCounter(name: "system.cpu.time")
        
        gauge = meter.createDoubleObservableGauge(name: "system.cpu.utilization") { [cpuTime]
            gauge in
            let (system_time, user_time, usage) = CPUSampler.cpuFootprint()
            gauge.observe(value: usage, labels: ["state": "user"])
            cpuTime.add(value: system_time, labels: ["state": "system"])
            cpuTime.add(value: user_time, labels: ["state":"user"])
            
        }
        
    }

    static func cpuFootprint() -> (Double,Double,Double) {
        var kr: kern_return_t
        var task_info_count: mach_msg_type_number_t

        task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))
        kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
        if kr != KERN_SUCCESS {
            return (-1, -1, -1)
        }
        var thread_list: thread_act_array_t?
        var thread_count: mach_msg_type_number_t = 0
        defer {
            if let thread_list = thread_list {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(thread_list).pointee), vm_size_t(thread_count))
            }
        }

        kr = task_threads(mach_task_self_, &thread_list, &thread_count)

        if kr != KERN_SUCCESS {
            return (-1,-1,-1)
        }

        var tot_cpu: Double = 0
        var tot_user: Double = 0
        var tot_system: Double = 0

        if let thread_list = thread_list {
            for j in 0 ..< Int(thread_count) {
                var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
                kr = thread_info(thread_list[j], thread_flavor_t(THREAD_BASIC_INFO),
                                 &thinfo, &thread_info_count)
                if kr != KERN_SUCCESS {
                    continue
                }

                let threadBasicInfo = CPUSampler.convertThreadInfoToThreadBasicInfo(thinfo)

                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    tot_user += (Double)(threadBasicInfo.user_time.seconds) + ((Double)(threadBasicInfo.user_time.microseconds) * 1e-6)
                    tot_system += (Double)(threadBasicInfo.system_time.seconds) + ((Double)(threadBasicInfo.user_time.microseconds) * 1e-6)
                    tot_cpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            } // for each thread
        }

        return (tot_system, tot_user, tot_cpu)
    }

    fileprivate static func convertThreadInfoToThreadBasicInfo(_ ti: [integer_t]) -> thread_basic_info {
            return thread_basic_info(user_time: time_value_t(seconds: ti[0],
                                                               microseconds: ti[1]),
                                       system_time: time_value_t(seconds: ti[2],
                                                                 microseconds: ti[3]),
                                       cpu_usage: ti[4],
                                       policy: ti[5],
                                       run_state: ti[6],
                                       flags: ti[7],
                                       suspend_count: ti[8],
                                       sleep_time: ti[9])

    }
}
