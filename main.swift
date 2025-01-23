import SwiftUI


@main
struct MetalApp: App {
@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true // 关闭最后一个窗口时退出应用程序
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, Metal swift")
                .font(.headline)
                .padding()
            MetalView()
                .frame(width: 400, height: 300)
        }
    }
}
