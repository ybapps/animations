//
//  ContentView.swift
//  Animations
//
//  Created by manfred on 2/23/21.
//

import SwiftUI


struct ContentView: View {
	@State var circleCenter = CGPoint.zero
	@State var circleColor = Color.black
	@State var isCircleScaled = false
	@State var isResetting = false
	
    var body: some View {
		VStack {
			Circle()
				.fill(self.circleColor)
				.frame(width: 50, height: 50)
				.scaleEffect(self.isCircleScaled ? 2 : 1)
				.offset(x: self.circleCenter.x - 25, y: self.circleCenter.y - 25)
//				.animation(self.isResetting ? nil : .spring(response: 0.3, dampingFraction: 0.1))
				.gesture(
					DragGesture(minimumDistance: 0).onChanged {
						value in
						withAnimation(.spring(response: 0.3, dampingFraction: 0.1)) { self.circleCenter = value.location
						}
					}
				)
			
			Toggle(
				"Scale",
				isOn: self.$isCircleScaled.animation(.spring(response: 0.3, dampingFraction: 0.1)) // explicit animation targeted to scale event.
			) //this binding is provided by the @State variable and these do not allow us to mutate state directly
			
			Button("Cycle Circle Color") {
				[Color.red, .blue, .green, .purple, .black]
					.enumerated()
					.forEach { offset, color in
						DispatchQueue.main.asyncAfter(deadline: .now() + 		.seconds(offset)) {
							withAnimation(.linear){
								self.circleColor = color
							}
						}
				}
			}
			Button("Reset") {
//				self.isResetting = true
				self.circleCenter = .zero
				self.circleColor = .black
				self.isCircleScaled = false
//				self.isResetting = false // SwiftUI sees all this as one transaction and therefore, isResetting is presumed to always be false.
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
