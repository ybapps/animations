//
//  ContentView.swift
//  Animations
//
//  Created by manfred on 2/23/21.
//
import ComposableArchitecture
import SwiftUI

// for refactoring:
// TCA domain has State that drives UI, Actions that user can perform in UI, Environment of dependencies that the feature needs to do its job

struct AppState: Equatable {
	var circleCenter = CGPoint.zero
	var circleCenter2 = CGPoint.init(x: 100, y: 100)
	var circleColor = Color.black
	var isCircleScaled = false
}

enum AppAction {
	case cycleColorsButtonTapped
	case dragGesture(CGPoint)
	case dragGesture2(CGPoint)
	case resetButtonTapped
	case setCircleColor(Color)
	case toggleScale(isOn: Bool)
}

struct AppEnvironment {}

import Combine

extension Scheduler {
  func animation(_ animation: Animation? = .default) -> AnySchedulerOf<Self> {
	.init(
	  minimumTolerance: { self.minimumTolerance },
	  now: { self.now },
	  scheduleImmediately: { options, action in
		self.schedule(options: options) {
		  withAnimation(animation, action)
		}
	  },
	  delayed: { after, tolerance, options, action in
		self.schedule(after: after, tolerance: tolerance, options: options) {
		  withAnimation(animation, action)
		}
	  },
	  interval: { after, interval, tolerance, options, action in
		self.schedule(after: after, interval: interval, tolerance: tolerance, options: options) {
		  withAnimation(animation, action)
		}
	  }
	)
  }
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> {
	state, action, environment in
	switch action {
		case .cycleColorsButtonTapped:
			state.circleColor = .red
			return Effect.concatenate(
				[Color.blue, .green, .purple, .black].map { color in
					Effect(value: .setCircleColor(color))
						.delay(for: .seconds(1), scheduler: DispatchQueue.main)
						.eraseToEffect()
				}
			)
			
		case let .dragGesture(location):
			state.circleCenter = location
			return .none
			
		case let .dragGesture2(location2):
			state.circleCenter2 = location2
			return .none
		
		case .resetButtonTapped:
			state = AppState()
			return .none
			
		case let .setCircleColor(color):
			state.circleColor = color
			return .none
			
		case .toggleScale(isOn: let isOn):
			state.isCircleScaled = isOn
			return .none
	}
}

struct TCAContentView: View {
	
	let store: Store<AppState, AppAction>

	var body: some View {
		WithViewStore(self.store) { viewStore in
			VStack {
				Circle()
					.fill(viewStore.circleColor)
					.frame(width: 50, height: 50)
					.scaleEffect(viewStore.isCircleScaled ? 2 : 1)
					.offset(x: viewStore.circleCenter.x - 25, y: viewStore.circleCenter.y - 25)
					.gesture(
						DragGesture(minimumDistance: 0).onChanged {
							value in
							withAnimation(.spring(response: 0.3, dampingFraction: 0.1)) { //viewStore.circleCenter = value.location
								viewStore.send(.dragGesture(value.location))
							}
						}
					)
				Circle()
					.fill(Color.red)
					.frame(width: 100, height: 100)
					.scaleEffect(viewStore.isCircleScaled ? 2 : 1)
					.offset(x: viewStore.circleCenter2.x - 25, y: viewStore.circleCenter2.y - 25)
					.gesture(
						DragGesture(minimumDistance: 0).onChanged {
							value in
							withAnimation(.spring(response: 0.3, dampingFraction: 0.1)) { //viewStore.circleCenter = value.location
								viewStore.send(.dragGesture2(value.location))
							}
						}
					)
				
				Toggle(
					"Scale",
					isOn: viewStore.binding(
						get: \.isCircleScaled,
						send: AppAction.toggleScale(isOn:)
					)
					.animation(.spring(response: 0.3, dampingFraction: 0.1))
				)
				
				Button("Cycle Circle Color") {
					withAnimation(.linear){
						viewStore.send(.cycleColorsButtonTapped)
						
					}
				}
				Button("Reset") {
					withAnimation(.linear) {
						viewStore.send(.resetButtonTapped)
					}
				}
			}
		}
	}
}

struct TCAContentView_Previews: PreviewProvider {
	static var previews: some View {
		TCAContentView(
			store: Store(
				initialState: AppState(),
				reducer: appReducer,
				environment: AppEnvironment()
			)
		)
	}
}
