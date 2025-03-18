//
//  EqualizerView.swift
//  Nothing X MacOS
//
//  Created by Arunavo Ray on 14/02/23.
//

import SwiftUI

struct EqualizerView: View {
    
    @ObservedObject var viewModel = AppContainer.shared.container.resolve(EqualizerViewViewModel.self)!
    @Binding var eqMode: EQProfiles
    
    var body: some View {
        
        
        VStack {
            // Back - Heading - Settings | Quit
            HStack {
                // Back
                BackButtonComponent()
                
                Spacer()
      
            }
            
            
            HStack {
                
                VStack(alignment: .leading) {
                    // Heading
                    Text("EQUALISER")
                        .modifier(ViewTitleStyle())
                        .padding(.bottom, 4)
                    
                    // Desc
                    Text("Customise your sound by selecting your favourite preset.")
                        .modifier(DescriptionTextStyle())
                    
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                
                Spacer()
                
            }
                
            
            VStack(alignment: .center) {
                
                Spacer()
                
                //HStack - Balanced | MORE BASS
                HStack(spacing: 5) {
                    //BALANCED
                    Button("Balanced") {
                        viewModel.switchEQ(eq: .BALANCED)
                    }
                    
                    .buttonStyle(EQButton(selected: eqMode == .BALANCED))
                    
                    //MORE BASS
                    Button("More bass") {
                        viewModel.switchEQ(eq: .MORE_BASE)
                    }
                    .buttonStyle(EQButton(selected: eqMode == .MORE_BASE))                }
                
                //HStack - MORE TREBLE | Controls
                HStack(spacing: 5) {
                    //MORE TREBLE
                    Button("More treble") {
                        viewModel.switchEQ(eq: .MORE_TREBEL)
                    }
                    .buttonStyle(EQButton(selected: eqMode == .MORE_TREBEL))
                    
                    //VOICE
                    Button("Voice") {
                        viewModel.switchEQ(eq: .VOICE)
                    }
                    .buttonStyle(EQButton(selected: eqMode == .VOICE))                }
                
            
            Spacer()
            
        }
    
        }
        .navigationBarBackButtonHidden(true)
        .background(.black)
        .frame(width: 250, height: 230)
       
    }
}


struct EqualizerView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var eqMode: EQProfiles = .BALANCED // State variable for preview

        var body: some View {
            EqualizerView(eqMode: $eqMode) // Pass the binding
                .environmentObject(AppContainer.shared.container.resolve(MainViewViewModel.self)!)
                .previewDisplayName("Equalizer View Preview")
        }
    }

    static var previews: some View {
        PreviewWrapper() // Use the wrapper to create an instance
    }
}
