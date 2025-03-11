//
//  FindMyBudsView.swift
//  Nothing X MacOS
//
//  Created by Arunavo Ray on 15/02/23.
//

import SwiftUI
import TipKit
struct FindMyBudsView: View {
    
    private let title: LocalizedStringKey? = "Volume warning"
    private let text: LocalizedStringKey? = "Your earbuds may be in use. Be sure to remove them from your ears before you continue. A loud sound will be played which could be uncomfortable for anyone wears them."
    private let topButtonText: LocalizedStringKey? = "Play"
    private let bottomButtonText: LocalizedStringKey? = "Cancel"
    
    @ObservedObject private var animation = PulsingCirclesAnimation.shared
    
    @StateObject private var viewModel = FindMyBudsViewViewModel(nothingService: NothingServiceImpl.shared)
    @State private var isRunning = false
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
      
        ZStack(alignment: .center) {
            
            VStack(spacing: 0) {
                HStack {
                    
                    BackButtonComponent()
                    Spacer()
                    // Quit
                    QuitButtonComponent()
                    
                }
                
                // Heading
                HStack() {
                    VStack(alignment: .leading) {
                        
                        if !isRunning {
                            
                            Text("Find my buds")
                                .modifier(ViewTitleStyle())
                                
                                
                            Spacer()
                            
                            // Description
                            HStack {
                                Text("Click above to play sound.")
                                    .modifier(DescriptionTextStyle())
                                    
                                
                                Spacer()
                                
                            }
                            
                        } else {
                            Spacer()
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                    .padding(.top, 1)
                    Spacer()
                }
                
            }
            .frame(width: 250, height: 230)
            .zIndex(1)
            
            
            
            
            HStack(alignment: .center) {
                VStack(alignment: .center) {
                    if viewModel.isRinging {
                        
                        ZStack {
                            
                            Circle()
                                .stroke(Color.red.opacity(1.0), lineWidth: 0.8)
                                .scaleEffect(animation.scale) // Scale effect based on the scale state
                                .opacity(animation.opacity) // Opacity effect based on the opacity state
                            
                            
                            
                            
                            Circle()
                                .stroke(Color.red.opacity(1.0), lineWidth: 0.8)
                                .scaleEffect(animation.secondCircleScale) // Scale effect for the second circle
                                .opacity(animation.secondCircleOpacity) // Opacity effect for the second circle
                                .onAppear {
                                    // Start the animation for the second circle
                                }
                            
                            HStack {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 18, weight: .light))
                                    .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                                    .foregroundColor(.white)
                            }
                            .frame(width: 60, height: 60)
                            .background(Color(#colorLiteral(red: 0.843137264251709, green: 0.09019608050584793, blue: 0.12941177189350128, alpha: 1)))
                            .clipShape(Circle()
                            )
                            .onTapGesture {
                                viewModel.stopRingingBuds()
                                animation.stopAnimation()
                                withAnimation {
                                    isRunning = false
                                }
                                
                            }
                            
                        }
                        .frame(width: 60, height: 60)
                        
                        
                    } else {
                        
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 18, weight: .light))
                                .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color(#colorLiteral(red: 0.843137264251709, green: 0.09019608050584793, blue: 0.12941177189350128, alpha: 1)))
                        .clipShape(Circle())
                        .onTapGesture {
                            withAnimation {
                                viewModel.shouldShowWarning = true
                            }
                        }
                    }
                }
            }
            
            }
            if viewModel.shouldShowWarning {
                Color.black.opacity(0.4) // Background dimming
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            viewModel.shouldShowWarning = false
                        }
                    }
                    .zIndex(3)
                
                ModalSheetComponent(isPresented: $viewModel.shouldShowWarning, title: title, text: text, topButtonText: topButtonText, bottomButtonText: bottomButtonText, action: {
                    
                    withAnimation {
                        isRunning = true
                    }
                    animation.startAnimation()
                    
                    viewModel.ringBuds()

                }, onCancelAction: {})
                .animation(.easeInOut, value: viewModel.shouldShowWarning) // Animate the appearance
                .offset(y: viewModel.shouldShowWarning ? 0 : 180) // Slide in from the bottom
                .zIndex(4)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(.black)
        .frame(width: 250, height: 230)
        .onDisappear {
            viewModel.stopRingingBuds()
            animation.stopAnimation()
        }
    }
    
    
}



struct FindMyBudsView_Previews: PreviewProvider {
    static var previews: some View {
        FindMyBudsView()
    }
}



