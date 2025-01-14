#pragma once

#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cstdint>
#include <cstdint>

#include <thread>
#include <chrono>
#include <future>

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <Windows.h>

// void f(int)
//void (*mojwskaznik)(int)

typedef double(__fastcall* FilterCFunc)(int, int, unsigned char*, unsigned char*, int);


namespace CppCLRWinFormsProject {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	using namespace std;


	extern "C" {
		// #include "CLibrary.h"
#include "AsmLibrary.h"
	}
	/// <summary>
	/// Summary for Form1
	/// </summary>
	public ref class Form1 : public System::Windows::Forms::Form
	{
	public:
		Form1(void)
		{
			InitializeComponent();
			//
			//TODO: Add the constructor code here
			//
		}

	protected:
		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		~Form1()
		{
			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::Button^ button1;
	protected:
	private: System::Windows::Forms::PictureBox^ pictureBox1;
	private: System::Windows::Forms::TextBox^ textBox1;
	private: System::Windows::Forms::TextBox^ textBox2;
	private: System::Windows::Forms::RadioButton^ radioButton1;
	private: System::Windows::Forms::RadioButton^ radioButton2;

	private: System::Windows::Forms::ProgressBar^ progressBar1;
	private: System::ComponentModel::BackgroundWorker^ backgroundWorker1;
	private: System::Windows::Forms::RadioButton^ radioButton3;
	private: System::Windows::Forms::RadioButton^ radioButton4;
	private: System::Windows::Forms::RadioButton^ radioButton5;
	private: System::Windows::Forms::RadioButton^ radioButton6;
	private: System::Windows::Forms::RadioButton^ radioButton7;
	private: System::Windows::Forms::RadioButton^ radioButton8;
	private: System::Windows::Forms::RadioButton^ radioButton9;
	private: System::Windows::Forms::FlowLayoutPanel^ flowLayoutPanel1;


	private:
		/// <summary>
		/// Required designer variable.
		/// </summary>
		System::ComponentModel::Container^ components;

#pragma region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		void InitializeComponent(void)
		{
			this->button1 = (gcnew System::Windows::Forms::Button());
			this->pictureBox1 = (gcnew System::Windows::Forms::PictureBox());
			this->textBox1 = (gcnew System::Windows::Forms::TextBox());
			this->textBox2 = (gcnew System::Windows::Forms::TextBox());
			this->radioButton1 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton2 = (gcnew System::Windows::Forms::RadioButton());
			this->progressBar1 = (gcnew System::Windows::Forms::ProgressBar());
			this->backgroundWorker1 = (gcnew System::ComponentModel::BackgroundWorker());
			this->radioButton3 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton4 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton5 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton6 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton7 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton8 = (gcnew System::Windows::Forms::RadioButton());
			this->radioButton9 = (gcnew System::Windows::Forms::RadioButton());
			this->flowLayoutPanel1 = (gcnew System::Windows::Forms::FlowLayoutPanel());
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->pictureBox1))->BeginInit();
			this->flowLayoutPanel1->SuspendLayout();
			this->SuspendLayout();
			// 
			// button1
			// 
			this->button1->Location = System::Drawing::Point(133, 57);
			this->button1->Name = L"button1";
			this->button1->Size = System::Drawing::Size(75, 23);
			this->button1->TabIndex = 0;
			this->button1->Text = L"Zastosuj";
			this->button1->UseVisualStyleBackColor = true;
			this->button1->Click += gcnew System::EventHandler(this, &Form1::button1_Click);
			// 
			// pictureBox1
			// 
			this->pictureBox1->Location = System::Drawing::Point(133, 122);
			this->pictureBox1->Name = L"pictureBox1";
			this->pictureBox1->Size = System::Drawing::Size(853, 484);
			this->pictureBox1->TabIndex = 1;
			this->pictureBox1->TabStop = false;
			this->pictureBox1->Click += gcnew System::EventHandler(this, &Form1::pictureBox1_Click);
			// 
			// textBox1
			// 
			this->textBox1->Location = System::Drawing::Point(133, 12);
			this->textBox1->Name = L"textBox1";
			this->textBox1->Size = System::Drawing::Size(853, 20);
			this->textBox1->TabIndex = 2;
			// 
			// textBox2
			// 
			this->textBox2->Location = System::Drawing::Point(223, 57);
			this->textBox2->Name = L"textBox2";
			this->textBox2->Size = System::Drawing::Size(752, 20);
			this->textBox2->TabIndex = 3;
			this->textBox2->TextChanged += gcnew System::EventHandler(this, &Form1::textBox2_TextChanged);
			// 
			// radioButton1
			// 
			this->radioButton1->AutoSize = true;
			this->radioButton1->Checked = true;
			this->radioButton1->Location = System::Drawing::Point(133, 99);
			this->radioButton1->Name = L"radioButton1";
			this->radioButton1->Size = System::Drawing::Size(32, 17);
			this->radioButton1->TabIndex = 4;
			this->radioButton1->TabStop = true;
			this->radioButton1->Text = L"C";
			this->radioButton1->UseVisualStyleBackColor = true;
			// 
			// radioButton2
			// 
			this->radioButton2->AutoSize = true;
			this->radioButton2->Location = System::Drawing::Point(234, 99);
			this->radioButton2->Name = L"radioButton2";
			this->radioButton2->Size = System::Drawing::Size(45, 17);
			this->radioButton2->TabIndex = 5;
			this->radioButton2->Text = L"Asm";
			this->radioButton2->UseVisualStyleBackColor = true;
			// 
			// progressBar1
			// 
			this->progressBar1->Location = System::Drawing::Point(296, 93);
			this->progressBar1->Name = L"progressBar1";
			this->progressBar1->Size = System::Drawing::Size(235, 23);
			this->progressBar1->TabIndex = 7;
			this->progressBar1->Click += gcnew System::EventHandler(this, &Form1::progressBar1_Click);
			// 
			// radioButton3
			// 
			this->radioButton3->AutoSize = true;
			this->radioButton3->Location = System::Drawing::Point(243, 3);
			this->radioButton3->Name = L"radioButton3";
			this->radioButton3->Size = System::Drawing::Size(31, 17);
			this->radioButton3->TabIndex = 8;
			this->radioButton3->TabStop = true;
			this->radioButton3->Text = L"1\r\n";
			this->radioButton3->UseVisualStyleBackColor = true;
			this->radioButton3->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton3_CheckedChanged);
			// 
			// radioButton4
			// 
			this->radioButton4->AutoSize = true;
			this->radioButton4->Location = System::Drawing::Point(206, 3);
			this->radioButton4->Name = L"radioButton4";
			this->radioButton4->Size = System::Drawing::Size(31, 17);
			this->radioButton4->TabIndex = 9;
			this->radioButton4->TabStop = true;
			this->radioButton4->Text = L"2";
			this->radioButton4->UseVisualStyleBackColor = true;
			this->radioButton4->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton4_CheckedChanged);
			// 
			// radioButton5
			// 
			this->radioButton5->AutoSize = true;
			this->radioButton5->Location = System::Drawing::Point(169, 3);
			this->radioButton5->Name = L"radioButton5";
			this->radioButton5->Size = System::Drawing::Size(31, 17);
			this->radioButton5->TabIndex = 10;
			this->radioButton5->TabStop = true;
			this->radioButton5->Text = L"4";
			this->radioButton5->UseVisualStyleBackColor = true;
			this->radioButton5->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton5_CheckedChanged);
			// 
			// radioButton6
			// 
			this->radioButton6->AutoSize = true;
			this->radioButton6->Location = System::Drawing::Point(132, 3);
			this->radioButton6->Name = L"radioButton6";
			this->radioButton6->Size = System::Drawing::Size(31, 17);
			this->radioButton6->TabIndex = 11;
			this->radioButton6->TabStop = true;
			this->radioButton6->Text = L"8";
			this->radioButton6->UseVisualStyleBackColor = true;
			this->radioButton6->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton6_CheckedChanged);
			// 
			// radioButton7
			// 
			this->radioButton7->AutoSize = true;
			this->radioButton7->Location = System::Drawing::Point(89, 3);
			this->radioButton7->Name = L"radioButton7";
			this->radioButton7->Size = System::Drawing::Size(37, 17);
			this->radioButton7->TabIndex = 12;
			this->radioButton7->TabStop = true;
			this->radioButton7->Text = L"16";
			this->radioButton7->UseVisualStyleBackColor = true;
			this->radioButton7->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton7_CheckedChanged);
			// 
			// radioButton8
			// 
			this->radioButton8->AutoSize = true;
			this->radioButton8->Location = System::Drawing::Point(46, 3);
			this->radioButton8->Name = L"radioButton8";
			this->radioButton8->Size = System::Drawing::Size(37, 17);
			this->radioButton8->TabIndex = 13;
			this->radioButton8->TabStop = true;
			this->radioButton8->Text = L"32";
			this->radioButton8->UseVisualStyleBackColor = true;
			this->radioButton8->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton8_CheckedChanged);
			// 
			// radioButton9
			// 
			this->radioButton9->AutoSize = true;
			this->radioButton9->Location = System::Drawing::Point(3, 3);
			this->radioButton9->Name = L"radioButton9";
			this->radioButton9->Size = System::Drawing::Size(37, 17);
			this->radioButton9->TabIndex = 14;
			this->radioButton9->TabStop = true;
			this->radioButton9->Text = L"64";
			this->radioButton9->UseVisualStyleBackColor = true;
			this->radioButton9->CheckedChanged += gcnew System::EventHandler(this, &Form1::radioButton9_CheckedChanged);
			// 
			// flowLayoutPanel1
			// 
			this->flowLayoutPanel1->Controls->Add(this->radioButton9);
			this->flowLayoutPanel1->Controls->Add(this->radioButton8);
			this->flowLayoutPanel1->Controls->Add(this->radioButton7);
			this->flowLayoutPanel1->Controls->Add(this->radioButton6);
			this->flowLayoutPanel1->Controls->Add(this->radioButton5);
			this->flowLayoutPanel1->Controls->Add(this->radioButton4);
			this->flowLayoutPanel1->Controls->Add(this->radioButton3);
			this->flowLayoutPanel1->Location = System::Drawing::Point(552, 93);
			this->flowLayoutPanel1->Name = L"flowLayoutPanel1";
			this->flowLayoutPanel1->Size = System::Drawing::Size(381, 23);
			this->flowLayoutPanel1->TabIndex = 15;
			this->flowLayoutPanel1->Paint += gcnew System::Windows::Forms::PaintEventHandler(this, &Form1::flowLayoutPanel1_Paint);
			// 
			// Form1
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(1064, 618);
			this->Controls->Add(this->flowLayoutPanel1);
			this->Controls->Add(this->progressBar1);
			this->Controls->Add(this->radioButton2);
			this->Controls->Add(this->radioButton1);
			this->Controls->Add(this->textBox2);
			this->Controls->Add(this->textBox1);
			this->Controls->Add(this->pictureBox1);
			this->Controls->Add(this->button1);
			this->Name = L"Form1";
			this->Text = L"Form1";
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->pictureBox1))->EndInit();
			this->flowLayoutPanel1->ResumeLayout(false);
			this->flowLayoutPanel1->PerformLayout();
			this->ResumeLayout(false);
			this->PerformLayout();

		}

		

#pragma endregion

	private: System::Void button1_Click(System::Object^ sender, System::EventArgs^ e)
	{
		constexpr int NUM_CHANNELS = 3;

		using namespace System::Runtime::InteropServices;
		using namespace System::Drawing;
		System::String^ managedString = textBox1->Text;

		Bitmap^ image = gcnew Bitmap(managedString);

		const int width = image->Width;
		const int height = image->Height;

		unsigned char* image_data = new unsigned char[width * height * NUM_CHANNELS];

		for (int y = 0; y < height; ++y)
		{
			for (int x = 0; x < width; ++x)
			{
				Color color = image->GetPixel(x, y);
				image_data[(y * width + x) * NUM_CHANNELS + 0] = color.R;
				image_data[(y * width + x) * NUM_CHANNELS + 1] = color.G;
				image_data[(y * width + x) * NUM_CHANNELS + 2] = color.B;
			}
		}

		unsigned char* new_image_data = new unsigned char[width * height * NUM_CHANNELS];

		bool bibliotekaC = true;

		if (radioButton1->Checked)
		{
			HINSTANCE hDLL = LoadLibrary(L"CLibrary.dll");
			if (!hDLL)
			{
				textBox2->Text = "Nie udalo sie wczytac CLibrary.dll";
				return;
			}

			FilterCFunc filterC = (FilterCFunc)GetProcAddress(hDLL, "filterC");
			if (!filterC)
			{
				textBox2->Text = "Nie udalo sie wczytac funkcji filterC";
				return;
			}

			String^ str;
			for (int numThreads = 1; numThreads <= 64; numThreads *= 2)
			{
				//int numThreads = 16;

				double duration = filterC(width, height, image_data, new_image_data, numThreads);

				duration = std::round(duration * 10.0) / 10.0;
				str += numThreads.ToString() + ": " + duration + "ms  ";
			}
			textBox2->Text = str;

			FreeLibrary(hDLL);
		}
		else // biblioteka ASM
		{
			String^ str;
			//for (int numThreads = 1; numThreads <= 64; numThreads *= 2)
			{
				int numThreads = 1;

				int STRIP_HEIGHT = (height -2) / numThreads;
				int modulo = (height -2) % numThreads;
				int counter = 0;

				std::vector<std::thread> threads;

				int currentRow = 1;
				
				auto start = std::chrono::high_resolution_clock::now();

				for (int i = 0; i < numThreads; i++)
				{
					int currentHeight = (height -2) / numThreads + (modulo > 0 ? 1 : 0);
					if (modulo > 0) modulo--;

					threads.push_back(std::thread(filterAsm, image_data, new_image_data, 12, 27, 9));
					currentRow += currentHeight;
				}
				
				for (std::thread& t : threads)
				{
					t.join();
				}

				auto end = std::chrono::high_resolution_clock::now();
				auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
				str += numThreads.ToString() + ": " + duration.count().ToString() + "ms  ";
			}
			textBox2->Text = str;
		}

		Bitmap^ new_image = gcnew Bitmap(width, height);

		for (int y = 0; y < height; ++y)
		{
			for (int x = 0; x < width; ++x)
			{
				Color color = Color::FromArgb(
					new_image_data[(y * width + x) * NUM_CHANNELS + 0],
					new_image_data[(y * width + x) * NUM_CHANNELS + 1],
					new_image_data[(y * width + x) * NUM_CHANNELS + 2]);
				new_image->SetPixel(x, y, color);
			}
		}

		pictureBox1->SizeMode = PictureBoxSizeMode::Zoom;
		pictureBox1->Image = new_image;
	}

	private: System::Void pictureBox1_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void textBox2_TextChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void checkedListBox1_SelectedIndexChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void progressBar1_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton3_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton4_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton5_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton6_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton7_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton8_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void radioButton9_CheckedChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void flowLayoutPanel1_Paint(System::Object^ sender, System::Windows::Forms::PaintEventArgs^ e) {
	}
};
}