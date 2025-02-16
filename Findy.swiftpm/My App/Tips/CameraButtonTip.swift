import TipKit

struct CameraButtonTip: Tip {
    var title: Text {
        Text("Let's capture your item!")
    }
    
    var message: Text? {
        Text("Tap the shutter button to take a photo.")
    }
    
    var image: Image? {
        Image(systemName: "camera.fill")
    }
}
