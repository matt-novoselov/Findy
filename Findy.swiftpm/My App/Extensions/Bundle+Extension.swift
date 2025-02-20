import UIKit

// Extension to extract app icon from assets
extension Bundle {
    var icon: UIImage? {
        // Safely access the app icon from the bundle's info dictionary
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last
        {
            // Return the UIImage if found
            return UIImage(named: icon)
        }
        
        // Return nil if the icon isn't found
        return nil
    }
}
