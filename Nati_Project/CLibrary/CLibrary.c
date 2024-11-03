#include <windows.h>
#include "CLibrary.h"

static const int NUM_CHANNELS = 3;

typedef struct
{
	int w;
	int h;
	unsigned char* from;
	unsigned char* to;
	int stripSize;
	int startRow;
} ThreadData;

DWORD WINAPI threadFunc(LPVOID data)
{
	ThreadData* td = (ThreadData*)data;
	int w = td->w;
	int h = td->h;
	unsigned char* from = td->from;
	unsigned char* to = td->to;
	int stripSize = td->stripSize;
	int startRow = td->startRow;

	for (int y = startRow; y < startRow+stripSize; y++)
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
	return 0;
}

void __declspec(dllexport) __stdcall filterC(int w, int h, unsigned char* from, unsigned char* to, int nT)
{
	HANDLE* threads = (HANDLE*)malloc(nT * sizeof(HANDLE));
	ThreadData* threadData = (ThreadData*)malloc(nT * sizeof(ThreadData));

	if (threads == NULL || threadData == NULL)
	{
		free(threads);
		free(threadData);
		return;
	}

	const int stripSize = h / nT;
	for (int i = 0; i < nT; i++)
	{
		threadData[i].w = w;
		threadData[i].h = h;
		threadData[i].from = from;
		threadData[i].to = to;
		threadData[i].stripSize = stripSize;
		threadData[i].startRow = i * stripSize;

		threads[i] = CreateThread(NULL, 0, threadFunc, &threadData[i], 0, NULL);

		if (threads[i] == NULL)
		{
			for (int j = 0; j < i; j++)
				CloseHandle(threads[j]);

			free(threadData);
			free(threads);
			return;
		}
	}
	WaitForMultipleObjects(nT, threads, TRUE, INFINITE);

	for (int i = 0; i < nT; i++)
		CloseHandle(threads[i]);
	
	free(threadData);
	free(threads);
}