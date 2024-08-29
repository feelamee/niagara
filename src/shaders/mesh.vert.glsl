#version 450

#extension GL_EXT_shader_16bit_storage: require
#extension GL_EXT_shader_8bit_storage: require

#extension GL_GOOGLE_include_directive: require

#extension GL_ARB_shader_draw_parameters: require

#include "mesh.h"
#include "math.h"

layout(push_constant) uniform block
{
	Globals globals;
};

layout(binding = 0) readonly buffer DrawCommands
{
	MeshDrawCommand drawCommands[];
};

layout(binding = 1) readonly buffer Draws
{
	MeshDraw draws[];
};

layout(binding = 2) readonly buffer Vertices
{
	Vertex vertices[];
};

layout(binding = 3) readonly buffer Reorder
{
	uint reorder[];
};

layout(location = 0) out vec4 color;
layout(location = 1) out int vertid;

void main()
{
	uint drawId = drawCommands[gl_DrawIDARB].drawId;
	MeshDraw meshDraw = draws[drawId];

#if 1
	uint vid = reorder[gl_VertexIndex + drawCommands[gl_DrawIDARB].provokeOffset];
	uint pid = gl_VertexIndex;
#else
	uint vid = (gl_VertexIndex >> 16) + meshDraw.vertexOffset;
	uint pid = gl_VertexIndex & 0xffff;
#endif

	vec3 position = vec3(vertices[vid].vx, vertices[vid].vy, vertices[vid].vz);
	vec3 normal = vec3(int(vertices[vid].nx), int(vertices[vid].ny), int(vertices[vid].nz)) / 127.0 - 1.0;
	vec2 texcoord = vec2(vertices[vid].tu, vertices[vid].tv);

	gl_Position = globals.projection * vec4(rotateQuat(position, meshDraw.orientation) * meshDraw.scale + meshDraw.position, 1);

	color = vec4(normal * 0.5 + vec3(0.5), 1.0);
	vertid = int(pid);
}
