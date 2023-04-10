#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
import SwiftUI
#endif

#if os(macOS)
import Foundation
import AppKit
#endif

#if os(Linux) || SERVER
import Foundation
#endif

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class AptosKit {
    public private(set) var text = "Hello, World!"

    public init() {
        
    }
}
