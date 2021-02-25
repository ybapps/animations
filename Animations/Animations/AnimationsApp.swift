//
//  AnimationsApp.swift
//  Animations
//
//  Created by manfred on 2/23/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct AnimationsApp: App {
    var body: some Scene {
        WindowGroup {
            TCAContentView(
				store: Store(
				 initialState: AppState(),
				 reducer: appReducer,
				 environment: AppEnvironment()
				)
			)
        }
    }
}
