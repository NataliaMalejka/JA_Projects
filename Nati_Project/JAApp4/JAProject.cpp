// cpuid.cpp 
// processor: x86, x64
// Use the __cpuid intrinsic to get information about a CPU

#include <stdio.h>
#include <string.h>
#include <intrin.h>
#include <emmintrin.h>	//  SSE2 instructions library header
#include <cmath>
#include <iostream>
#include <vector>

extern "C" int _fastcall CheckSSEAsm();
extern "C" int _fastcall CheckSSE2Asm();
extern "C" double RadToDegAsm(double dRad);

int CheckSSECpp();


int main(int argc, char* argv[])
{
    int wynikSSE = CheckSSEAsm();

    
}

