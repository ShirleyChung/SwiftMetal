import SwiftUI


@main
struct MetalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
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
