#include "pch.h"

using namespace System;

#include "Form1.h"
#include <stdio.h>
#include <intrin.h>
#include <emmintrin.h>
#include <cmath>
#include <iostream>
#include <vector>

using namespace System::Windows::Forms;

[STAThread]
int main()
{


  Application::EnableVisualStyles();
  Application::SetCompatibleTextRenderingDefault(false);
  Application::Run(gcnew CppCLRWinFormsProject::Form1());

  

  return 0;
}