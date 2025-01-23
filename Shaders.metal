#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[ attribute(0) ]]; // 頂點位置
    float2 offset;                     // 星星的位置偏移
    float scale;                       // 星星的大小
};

struct VertexOut {
    float4 position [[ position ]];    // 屏幕上的位置
    float4 color;                      // 星星顏色
};

// 頂點著色器
vertex VertexOut vertex_main(const device VertexIn* vertexArray [[ buffer(0) ]],
                              uint vertexID [[ vertex_id ]],
                              constant float2* screenSize [[ buffer(1) ]]) {
    VertexOut out;

    // 計算星星在螢幕上的位置，應用偏移與縮放
    float2 scaledPosition = vertexArray[vertexID].position * vertexArray[vertexID].scale;
    out.position = float4(scaledPosition + vertexArray[vertexID].offset, 0.0, 1.0);

    // 將位置從像素座標轉換為 NDC (-1 到 1)
    out.position.x /= screenSize->x / 2.0;
    out.position.y /= screenSize->y / 2.0;

    // 星星顏色設為黃色
    out.color = float4(1.0, 1.0, 0.0, 1.0);

    return out;
}

// 片段著色器
fragment float4 fragment_main(VertexOut in [[ stage_in ]]) {
    return in.color;
}

