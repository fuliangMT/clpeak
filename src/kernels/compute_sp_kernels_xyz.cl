MSTRINGIFY(

// Avoiding auto-vectorize by using vector-width locked dependent code

\n#undef MAD_4
\n#undef MAD_16
\n#undef MAD_64

\n#define MAD_4(x, y, z)     z = fma(y, x, z);   y = fma(z, y, x);   x = fma(y, z, x);   z = fma(x, y, z);
\n#define MAD_16(x, y, z)    MAD_4(x, y, z);        MAD_4(x, y, z);        MAD_4(x, y, z);        MAD_4(x, y, z);
\n#define MAD_64(x, y, z)    MAD_16(x, y, z);       MAD_16(x, y, z);       MAD_16(x, y, z);       MAD_16(x, y, z);
\n

__kernel void compute_sp_v1(__global float *ptr, float _A)
{
    float x = _A;
    float y = (float)get_local_id(0);
    float z = (float)get_group_id(0);

    for(int i=0; i<128; i++)
    {
        MAD_16(x, y, z);
    }

    ptr[get_global_id(0)] = z;
}


__kernel void compute_sp_v2(__global float *ptr, float _A)
{
    float2 x = (float2)(_A, (_A+1));
    float2 y = (float2)get_local_id(0);
    float2 z = (float2)get_group_id(0); 

    for(int i=0; i<64; i++)
    {
        MAD_16(x, y, z);
    }

    ptr[get_global_id(0)] = (z.S0) + (z.S1);
}

__kernel void compute_sp_v4(__global float *ptr, float _A)
{
    float4 x = (float4)(_A, (_A+1), (_A+2), (_A+3));
    float4 y = (float4)get_local_id(0);
    float4 z = (float4)get_group_id(0);

    for(int i=0; i<32; i++)
    {
        MAD_16(x, y, z);
    }

    ptr[get_global_id(0)] = (z.S0) + (z.S1) + (z.S2) + (z.S3);
}


__kernel void compute_sp_v8(__global float *ptr, float _A)
{
    float8 x = (float8)(_A, (_A+1), (_A+2), (_A+3), (_A+4), (_A+5), (_A+6), (_A+7));
    float8 y = (float8)get_local_id(0);

    for(int i=0; i<16; i++)
    {
        MAD_16(x, y, y);
    }

    ptr[get_global_id(0)] = (y.S0) + (y.S1) + (y.S2) + (y.S3) + (y.S4) + (y.S5) + (y.S6) + (y.S7);
}

__kernel void compute_sp_v16(__global float *ptr, float _A)
{
    float16 x = (float16)(_A, (_A+1), (_A+2), (_A+3), (_A+4), (_A+5), (_A+6), (_A+7),
                    (_A+8), (_A+9), (_A+10), (_A+11), (_A+12), (_A+13), (_A+14), (_A+15));
    float16 y = (float16)get_local_id(0);

    for(int i=0; i<8; i++)
    {
        MAD_16(x, y, y);
    }

    float2 t = (y.S01) + (y.S23) + (y.S45) + (y.S67) + (y.S89) + (y.SAB) + (y.SCD) + (y.SEF);
    ptr[get_global_id(0)] = t.S0 + t.S1;
}

)
