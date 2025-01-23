all: main.swift MetalView.swift Renderer.swift Shaders.metallib
	swiftc -o MetalSwiftApp main.swift -parse-as-library Renderer.swift MetalView.swift -framework Metal -framework MetalKit -framework SwiftUI

Shaders.metallib: Shaders.metal
	xcrun -sdk macosx metal -c Shaders.metal -o Shaders.air
	xcrun -sdk macosx metallib Shaders.air -o Shaders.metallib

clean:
	rm -f Shaders.air
	rm -f Shaders.metallib
	rm -f MetalSwiftApp
