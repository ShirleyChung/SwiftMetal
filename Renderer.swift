import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState

    init? (mtkView: MTKView) {
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
            mtkView.device = device
            mtkView.colorPixelFormat = .bgra8Unorm
            if let commandQueue = device.makeCommandQueue() {
                self.commandQueue = commandQueue
                //let library = device.makeDefaultLibrary()
                let shadername = "./Shaders.metallib"
                if let shaderfile = URL(string: shadername) {
                    if let library = try? device.makeLibrary(URL: shaderfile) {

                        let vertexFunction = library.makeFunction(name: "vertex_main")
                        let fragmentFunction = library.makeFunction(name: "fragment_main")
                
                        let pipelineDescriptor = MTLRenderPipelineDescriptor()
                        pipelineDescriptor.vertexFunction = vertexFunction
                        pipelineDescriptor.fragmentFunction = fragmentFunction
                        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
                        if let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) {
                            self.pipelineState = pipelineState
                            super.init()
                            mtkView.delegate = self
                        }
                    } else {
                        print("cannot load metal library from Shaders")
                    }
                } else {
                    print("shader url error. \(shadername) not exist")
                }
            }
        }
        return nil
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.endEncoding()
                commandBuffer.present(drawable)
                commandBuffer.commit()
            }
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size:CGSize) {}
}
