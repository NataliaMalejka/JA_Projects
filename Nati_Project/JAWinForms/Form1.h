#pragma once

#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cstdint>
#include <cstdint>

namespace CppCLRWinFormsProject {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	using namespace std;

#pragma pack(push, 1)
	struct BMPHeader
	{
		uint16_t file_type;
		uint32_t file_size;
		uint16_t reserved1;
		uint16_t reserved2;
		uint32_t offset_data;
	};

	struct DIBHeader
	{
		uint32_t dib_header_size;
		int32_t width;
		int32_t height;
		uint16_t planes;
		uint16_t bit_count;
		uint32_t compression;
		uint32_t image_size;
		int32_t x_pixels_per_meter;
		int32_t y_pixels_per_meter;
		uint32_t colors_used;
		uint32_t colors_important;
	};
#pragma pack(pop)

	struct Pixel
	{
		uint8_t blue;
		uint8_t green;
		uint8_t red;
	};

	extern "C" uint32_t CheckSSE2Asm(uint8_t a, uint8_t b, uint8_t c);
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
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->pictureBox1))->BeginInit();
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
			this->pictureBox1->Location = System::Drawing::Point(133, 106);
			this->pictureBox1->Name = L"pictureBox1";
			this->pictureBox1->Size = System::Drawing::Size(516, 339);
			this->pictureBox1->TabIndex = 1;
			this->pictureBox1->TabStop = false;
			// 
			// textBox1
			// 
			this->textBox1->Location = System::Drawing::Point(133, 12);
			this->textBox1->Name = L"textBox1";
			this->textBox1->Size = System::Drawing::Size(516, 20);
			this->textBox1->TabIndex = 2;
			// 
			// textBox2
			// 
			this->textBox2->Location = System::Drawing::Point(296, 57);
			this->textBox2->Name = L"textBox2";
			this->textBox2->Size = System::Drawing::Size(353, 20);
			this->textBox2->TabIndex = 3;
			// 
			// Form1
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(812, 519);
			this->Controls->Add(this->textBox2);
			this->Controls->Add(this->textBox1);
			this->Controls->Add(this->pictureBox1);
			this->Controls->Add(this->button1);
			this->Name = L"Form1";
			this->Text = L"Form1";
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->pictureBox1))->EndInit();
			this->ResumeLayout(false);
			this->PerformLayout();

		}

		bool loadBMP(const std::string& file_path, BMPHeader& bmp_header, DIBHeader& dib_header, std::vector<Pixel>& pixels)
		{
			std::ifstream file(file_path, std::ios::binary);
			if (!file)
			{
				return false;
			}

			file.read(reinterpret_cast<char*>(&bmp_header), sizeof(BMPHeader));
			if (bmp_header.file_type != 0x4D42)
			{
				return false;
			}

			file.read(reinterpret_cast<char*>(&dib_header), sizeof(DIBHeader));
			if (dib_header.bit_count != 24)
			{
				return false;
			}

			file.seekg(bmp_header.offset_data, std::ios::beg);

			int row_stride = (dib_header.width * 3 + 3) & ~3;
			pixels.resize(dib_header.width * dib_header.height);

			for (int y = 0; y < dib_header.height; ++y)
			{
				for (int x = 0; x < dib_header.width; ++x)
				{
					Pixel pixel;
					file.read(reinterpret_cast<char*>(&pixel), sizeof(Pixel));
					int index = (dib_header.height - 1 - y) * dib_header.width + x;
					pixels[index] = pixel;
				}

				file.ignore(row_stride - dib_header.width * 3);
			}

			file.close();
			return true;
		}


#pragma endregion

	private: System::Void button1_Click(System::Object^ sender, System::EventArgs^ e)
	{
		using namespace System::Runtime::InteropServices;
		System::String^ managedString = textBox1->Text;
		const char* chars = (const char*)(Marshal::StringToHGlobalAnsi(managedString)).ToPointer();
		std::string file_path = chars;
		Marshal::FreeHGlobal(IntPtr((void*)chars));

		BMPHeader bmp_header;
		DIBHeader dib_header;
		std::vector<Pixel> pixels;

		if (loadBMP(file_path, bmp_header, dib_header, pixels))
		{
			textBox2->Text = "szerokosc w pikselach: " + dib_header.width.ToString();

			for (size_t i = 0; i < pixels.size(); ++i)
			{
				Pixel& pixel = pixels[i];

				uint8_t blue = pixel.blue;
				uint8_t green = pixel.green;
				uint8_t red = pixel.red;

				uint32_t BGR = CheckSSE2Asm(blue, green, red);

				int width = 50;
				int height = 50;

				uint8_t new_blue = (BGR) >> 16 & 0xFF;
				uint8_t new_green = (BGR) >> 8 & 0xFF;
				uint8_t new_red = (BGR) & 0xFF;

				System::Drawing::Bitmap^ bitmap = gcnew System::Drawing::Bitmap(width, height);

				for (int y = 0; y < height; ++y)
				{
					for (int x = 0; x < width; ++x)
					{

						System::Drawing::Color color = System::Drawing::Color::FromArgb(new_blue, new_green, new_red);
						bitmap->SetPixel(x, y, color);
					}
				}

				pictureBox1->Image = bitmap;

				if (i >= 0) break;
			}
		}
		else
		{
			textBox2->Text = "nie wczytano obrazu";
		}
	}

	};
}
