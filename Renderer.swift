import Metal
import MetalKit
import Foundation

let currentDirectoryPath = FileManager.default.currentDirectoryPath

struct VertexIn {
    var position: SIMD2<Float>
    var offset: SIMD2<Float>
    var scale: Float
}

class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private var vertexBuffer: MTLBuffer
    private var screenSize: SIMD2<Float>

    // 定義星星形狀（五角星）
    let starVertices: [SIMD2<Float>] = [
        SIMD2(0, 0),   // 中心點
        SIMD2(0, 1), SIMD2(-0.2, 0.3),
        SIMD2(-0.2, 0.3), SIMD2(-1, 0.3),
        SIMD2(-1, 0.3), SIMD2(-0.4, -0.1),
        SIMD2(-0.4, -0.1), SIMD2(-0.6, -1),
        SIMD2(-0.6, -1), SIMD2(0, -0.4),
        SIMD2(0, -0.4), SIMD2(0.6, -1),
        SIMD2(0.6, -1), SIMD2(0.4, -0.1),
        SIMD2(0.4, -0.1), SIMD2(1, 0.3),
        SIMD2(1, 0.3), SIMD2(0.2, 0.3),
        SIMD2(0.2, 0.3), SIMD2(0, 1)
    ]


    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return nil
        }
        self.device = device
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm

        guard let commandQueue = device.makeCommandQueue() else {
            print("Failed to create command queue")
            return nil
        }
        self.commandQueue = commandQueue

        // 加載着色器
        let shaderfile = "\(currentDirectoryPath)/Shaders.metallib"
        if let url = URL(string: shaderfile) {
            if let library = try? device.makeLibrary(URL: url) {
                let vertexFunction = library.makeFunction(name: "vertex_main")
                let fragmentFunction = library.makeFunction(name: "fragment_main")

                // 創建渲染管線
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
                self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

                // 定義幾顆星星的位置與大小
                let stars: [VertexIn] = starVertices.flatMap { position in
                    [
                        VertexIn(position: position, offset: SIMD2(100, 100), scale: 50),
                        VertexIn(position: position, offset: SIMD2(300, 200), scale: 70),
                        VertexIn(position: position, offset: SIMD2(500, 300), scale: 90)
                    ]
                }

                // 創建頂點緩衝區
                self.vertexBuffer = device.makeBuffer(bytes: stars, length: stars.count * MemoryLayout<VertexIn>.stride, options: [])!

                // 設置螢幕大小
                self.screenSize = SIMD2(Float(mtkView.drawableSize.width), Float(mtkView.drawableSize.height))

                super.init()
                mtkView.delegate = self
                return
            } else {
                print("make library with url fail")
            }
        }
        else {
            print("\(shaderfile) is invalid")
        }
        return nil
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                renderEncoder.setVertexBytes(&screenSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 1)

                // 繪製星星（使用 .triangle）
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: starVertices.count)
                renderEncoder.endEncoding()

                commandBuffer.present(drawable)
                commandBuffer.commit()
            } else {
                print("render encoder fail")
            }
        } else {
            print("command Buffer fail")
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.screenSize = SIMD2(Float(size.width), Float(size.height))
    }
}

