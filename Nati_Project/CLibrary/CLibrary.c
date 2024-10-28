#include "CLibrary.h"

static const int NUM_CHANNELS = 3;

void filterC(int w, int h, unsigned char* from, unsigned char* to, int nT)
{
	for (int y = 0; y < h; y++)
		for (int x = 0; x < w; x++)
			for (int channel = 0; channel < NUM_CHANNELS; channel++)
			{
				int sum = 0;
				int count = 0;

				for (int dy = -1; dy <= 1; dy++)
					for (int dx = -1; dx <= 1; dx++)
					{
						const int rx = x + dx;
						const int ry = y + dy;

						if (rx < 0 || rx >= w || ry < 0 || ry >= h)
							continue;

						count++;

						const int fromIndex = (ry * w + rx) * NUM_CHANNELS + channel;
						sum += from[fromIndex];
					}

				const int toIndex = (y * w + x) * NUM_CHANNELS + channel;
				to[toIndex] = sum / count;
			}
}