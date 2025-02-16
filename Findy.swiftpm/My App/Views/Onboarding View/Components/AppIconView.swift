import SwiftUI

struct AppIconView: View {
    var size: CGFloat = 65
    var body: some View {
        if let appIcon = Bundle.main.icon{
            let imageView = Image(uiImage: appIcon)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: size)
                .perfectCornerRadius()
            
            imageView
                .background{
                    imageView
                        .blur(radius: 20)
                }
        }
    }
}
