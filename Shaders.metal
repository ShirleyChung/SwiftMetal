#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut vertex_main(const device float4* vertexArray [[ buffer(0) ]], uint vertexID [[ vertex_id ]]) {
    VertexOut out;
    out.position = vertexArray[vertexID];
    out.color = float4(0.0, 1.0, 0.0, 1.0);
    return out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]]) {
    return in.color;
}
