//
//  QMakeDecisionApp.swift
//  QMakeDecision
//
//  Created by qihongrui on 2025/1/6.
//

import SwiftUI
import WidgetKit

@main
struct QMakeDecisionApp: App {
    init() {
        #if !EXTENSION
        // 只在主应用中启用 WidgetCenter
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
