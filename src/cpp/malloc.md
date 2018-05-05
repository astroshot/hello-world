https://stackoverflow.com/questions/1119134/how-do-malloc-and-free-work


OK some answers about malloc were already posted.

The more interesting part is how free works (and in this direction, malloc too can be understood better).

In many malloc/free implementations, free does normally not return the memory to the operating system (or at least only in rare cases). The reason is that you will get gaps in your heap and thus it can happen, that you just finish off your 2 or 4 GB of virtual memory with gaps. This should be avoided, since as soon as the virtual memory is finished, you will be in really big trouble. The other reason is, that the OS can only handle memory chunks that are of a specific size and alignment. To be specific: Normally the OS can only handle blocks that the virtual memory manager can handle (most often multiples of 512 bytes e.g. 4KB).

So returning 40 Bytes to the OS will just not work. So what does free do?

Free will put the memory block in its own free block list. Normally it also tries to meld together adjacent blocks in the address space. The free block list is just a circular list of memory chunks which have some administrative data in the beginning. This is also the reason why managing very small memory elements with the standard malloc/free is not efficient. Every memory chunk needs additional data and with smaller sizes more fragmentation happens.

The free-list is also the first place that malloc looks at when a new chunk of memory is needed. It is scanned before it calls for new memory from the OS. When a chunk is found that is bigger than the needed memory, it is divided into two parts. One is returned to caller, the other is put back into the free list.

There are many different optimizations to this standard behaviour (for example for small chunks of memory). But since malloc and free must be so universal, the standard behaviour is always the fallback when alternatives are not usable. There are also optimizations in handling the free-list — for example storing the chunks in lists sorted by sizes. But all optimizations also have their own limitations.

Why does your code crash:

The reason is that by writing 9 chars (don't forget the trailing null byte) into an area sized for 4 chars, you will probably overwrite the administrative-data stored for another chunk of memory that resides "behind" your chunk of data (since this data is most often stored "in front" of the memory chunks). When free then tries to put your chunk into the free list, it can touch this administrative-data and therefore stumble over an overwritten pointer. This will crash the system.

This is a rather graceful behaviour. I have also seen situations where a runaway pointer somewhere has overwritten data in the memory-free-list and the system did not immediately crash but some subroutines later. Even in a system of medium complexity such problems can be really, really hard to debug! In the one case I was involved, it took us (a larger group of developers) several days to find the reason of the crash -- since it was in a totally different location than the one indicated by the memory dump. It is like a time-bomb. You know, your next "free" or "malloc" will crash, but you don't know why!

Those are some of the worst C/C++ problems, and one reason why pointers can be so problematic.
