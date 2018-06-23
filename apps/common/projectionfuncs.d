module projectionfuncs;

import gl3n.linalg;  // mat4
import gl3n.math: tan;


mat4 perspectiveFunc(float fovInRadians, float aspect, float zNear, float zFar)
{
    float f = 1 / tan(fovInRadians / 2);
    float d = 1 / (zNear - zFar);
    float sum = (zFar + zNear);
    float mul = (zFar * zNear);

    /+ row major order does not work
    mat4 rm;  // row major
    rm[0][0] = f/aspect; rm[0][1] = 0;   rm[0][2] = 0;        rm[0][3] = 0;
    rm[1][0] = 0;        rm[1][1] = f;   rm[1][2] = 0;        rm[1][3] = 0;
    rm[2][0] = 0;        rm[2][1] = 0;   rm[2][2] = sum * d;  rm[2][3] = 2 * d * mul;
    rm[3][0] = 0;        rm[3][1] = 0;   rm[3][2] = -1;       rm[3][3] = 0;
    +/

    mat4 cm;  // column major

    cm[0][0] = f/aspect; cm[1][0] = 0;   cm[2][0] = 0;        cm[3][0] = 0;
    cm[0][1] = 0;        cm[1][1] = f;   cm[2][1] = 0;        cm[3][1] = 0;
    cm[0][2] = 0;        cm[1][2] = 0;   cm[2][2] = sum * d;  cm[3][2] = 2 * d * mul;
    cm[0][3] = 0;        cm[1][3] = 0;   cm[2][3] = -1;       cm[3][3] = 0;

    // from  dub package gfm:   math/gfm/math/matrix.d
    // Returns: perspective projection.
    /+
    mat4 prepare( f/aspect, 0,  0,                    0,
                  0,        f,  0,                    0,
                  0,        0,  (zFar + zNear) * d,   2 * d * zFar * zNear,
                  0,        0,  -1,                   0);
    +/
    return cm;
}


mat4 orthographicFunc(float left, float right, float bottom, float top, float near, float far)
{
    float dx = right - left;
    float dy = top - bottom;
    float dz = far - near;

    float tx = -(right + left) / dx;
    float ty = -(top + bottom) / dy;
    float tz = -(far + near)   / dz;

    // from  dub package gfm:   math/gfm/math/matrix.d
    /+
    return Matrix( 2/dx,  0,      0,      tx,
                   0,     2/dy,   0,      ty,
                   0,     0,      -2/dz,  tz,
                   0,     0,      0,      1);
    +/

    mat4 cm;  // column major

    cm[0][0] = 2/dx;   cm[1][0] = 0;     cm[2][0] = 0;        cm[3][0] = tx;
    cm[0][1] = 0;      cm[1][1] = 2/dy;  cm[2][1] = 0;        cm[3][1] = ty;
    cm[0][2] = 0;      cm[1][2] = 0;     cm[2][2] = -2/dz;    cm[3][2] = tz;
    cm[0][3] = 0;      cm[1][3] = 0;     cm[2][3] = 0;        cm[3][3] = 1;

    return cm;
}