#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Bit-twiddle hack.
static inline uint32_t next_pow2(uint32_t v)
{
   v--;
   v |= v >> 1;
   v |= v >> 2;
   v |= v >> 4;
   v |= v >> 8;
   v |= v >> 16;
   v++;
   return v;
}

// Bit-twiddle hack.
static inline unsigned log2_pow2(uint32_t v)
{
   if (v == 0)
      return 0;

   static const unsigned b[] = {0xAAAAAAAA, 0xCCCCCCCC, 0xF0F0F0F0, 
      0xFF00FF00, 0xFFFF0000};
   unsigned r = (v & b[0]) != 0;
   for (int i = 4; i > 0; i--)
   {
      r |= ((v & b[i]) != 0) << i;
   }

   return r;
}


// Encode a 16-sample block into 9-byte BRR block.
static void encode_block(uint8_t *brr_out, const int16_t *input)
{
   uint16_t max_abs = 0;
   for (unsigned i = 0; i < 16; i++)
   {
      uint16_t tmp_abs = abs(input[i]);
      if (tmp_abs > max_abs)
         max_abs = tmp_abs;
   }

   max_abs = next_pow2(max_abs);
   unsigned shift_factor = log2_pow2(max_abs) - 3;

   brr_out[0] = shift_factor << 4;

   for (unsigned i = 0; i < 8; i++)
   {
      unsigned s[2];

      s[0] = (input[2 * i] >> shift_factor) & 0xF;
      s[1] = (input[2 * i + 1] >> shift_factor) & 0xF;
      brr_out[i + 1] = (s[0] << 4) | s[1];
   }
}

int main(int argc, char **argv)
{
   if (argc != 3)
   {
      fprintf(stderr, "Usage: %s <infile> <outfile>\n", argv[0]);
      return 1;
   }

   FILE *infile = fopen(argv[1], "rb");
   FILE *outfile = fopen(argv[2], "wb");

   if (!infile)
   {
      fprintf(stderr, "Couldn't find input file.\n");
      goto error;
   }

   if (!outfile)
   {
      fprintf(stderr, "Couldn't find output file.\n");
      goto error;
   }

   int16_t input_block[16];
   uint8_t output_block[9];

   if (fread(input_block, sizeof(int16_t), 16, infile) == 0)
      goto error;

   for (;;)
   {
      encode_block(output_block, input_block);
      memset(input_block, 0, sizeof(input_block));

      if (fread(input_block, sizeof(int16_t), 16, infile) == 0)
      {
         output_block[0] |= 1; // Last sample
         fwrite(output_block, 1, sizeof(output_block), outfile);
         break;
      }

      fwrite(output_block, 1, sizeof(output_block), outfile);
   }

   fclose(infile);
   fclose(outfile);
   return 0;

error:
   if (infile)
      fclose(infile);
   if (outfile)
      fclose(outfile);
   return 1;
}
