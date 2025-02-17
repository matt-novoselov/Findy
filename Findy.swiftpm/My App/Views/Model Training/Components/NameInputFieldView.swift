//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 17/02/25.
//

import SwiftUI

struct NameInputFieldView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        @Bindable var appViewModel = appViewModel
        VStack (alignment: .leading){
            HStack{
                Group{
                    Image(systemName: "tag.fill")
                    Text("Name your object")
                }
                .font(.body)
                .foregroundStyle(Color.primary)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            }
            
            //
            TextField("My Object", text: $appViewModel.savedObject.userGivenObjectName)
                .padding()
                .background(RecessedRectangleView(cornerRadius: .infinity))
        }
    }
}

#Preview {
    ZStack{
        Color.green
        NameInputFieldView()
    }
    .environment(AppViewModel())
}
