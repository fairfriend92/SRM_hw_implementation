#include <stdio.h>
#include <stdlib.h>
#include <math.h>

# define MAXLEN 32

long long to_int(int size, int * array);
int to_binaryInt(long long number, int * array);
void to_binaryFrac(long long number, int fractional_bits, int * array,
		   int frac_size);
long intPow(int a, int b);
int size_of_int(long long a);

int main ()
{
  FILE *fp, *fpout;
  int minus_sign= 0, index;
  char c= '0';
  int i=0, j, decimal_size, fractional_size,
    fractional_bits, integer_bits, size_of_int, tmp[MAXLEN],
    decimal[MAXLEN], fractional[MAXLEN];
  long long decimal_int, fractional_int;

  fp= fopen("input.txt", "r");
  fpout= fopen("out.txt", "w");
  printf("Insert number of fractional bits\n");
  scanf("%d", &fractional_bits);
  printf("Insert number of integer bits\n");
  scanf("%d", &integer_bits);

  while(c!=EOF)
    {
      i=0;
      while(c!= '_')
	{
	  c=getc(fp);
	  //printf("main: c is %c\n", c);
	  if(c== '.')
	    {
	      decimal_size=i;
	      decimal_int=to_int(decimal_size, tmp);
	      //printf("main: decimal_int is %lld\n", decimal_int);
	      size_of_int= to_binaryInt(decimal_int, decimal);
	      i=0;
	    }	  
	  else if(c== '\n')
	    {
	      //printf("main: inside else if(c== '\\n')\n");
	      fractional_size=i;
	      fractional_int=to_int(fractional_size, tmp);
	      to_binaryFrac(fractional_int, fractional_bits, fractional,
			    fractional_size);
	      i=0;
	      c= '_';
	      //printf("main: return from to_binaryFrac\n");
	    }
	  else if(c== EOF)
	    {
	      fractional_size=i;
	      fractional_int=to_int(fractional_size, tmp);
	      to_binaryFrac(fractional_int,fractional_bits, fractional,
			    fractional_size);
	      i=0;
	      break;
	    }
	  else if(c== '-') minus_sign= 1;
	  else 
	    {
	      tmp[i]= (int) (c-'0');
	      //printf("main: tmp[%d] is %d\n", i, tmp[i]);
	      i=i+1;
	    }
     	}
      if (minus_sign) fprintf(fpout, "1");

      else fprintf(fpout, "0");
      //printf("main: integer_bits, size_of_int are %d, %d\n", integer_bits,
      //size_of_int);
      for(j= 0; j< (integer_bits-size_of_int); j++)
	if(minus_sign== 0) 
	  fprintf(fpout, "0");
	else fprintf(fpout, "1");
      for(j= 1; j<= size_of_int; j++)	
	fprintf(fpout, "%d", abs(minus_sign-decimal[size_of_int-j]));
      for(j= 1; j<= fractional_bits; j++)
	fprintf(fpout, "%d", abs(minus_sign-fractional[j]));
      fprintf(fpout, "\n");
      //fprintf(fpout, "test\n");

      minus_sign= 0;
      if (c!= EOF) c= '0';
    }
}

int size_of_int(long long a)
{
  int i= 0, result= 0;

  while(a!= 0)
    {
      a= a/10;
      //printf("size_of_int: i, a are %d, %lld\n", i, a);
      i++;
    }
  return i;
}

long intPow(int a, int b)
{
  int i;
  long result=1;

  for(i= 0; i< b; i++)
    result *= a;

  //printf("intPow: result is %ld\n", result);
  return result;
}

long long to_int(int size, int * array)
{
  int i=0;
  long long decimal_int=0, increment;

  //printf("to_int: size is %d\n", size);
  
  while(i<size)
    {
      increment= array[i]*(intPow(10, size-1-i));
      decimal_int=decimal_int + increment;
      //printf("to_int: array[%d] is %d\n", i, array[i]);
      //printf("to_int: increment is %d\n", increment);
      //printf("to_int: decimal_int is %lld\n", decimal_int);
      i=i+1;
    }

  return decimal_int;
}

int to_binaryInt(long long number, int * array)
{
  int i=0;  

  if(number== 0)
    array[i]= 0;
  
  while(number>= 1)
    {
      //printf("to_binaryInt: number is %lld\n", number);
      if (number%2== 0)
	{
	  array[i]=0;
	  //printf("to_binaryInt: TEST, if\n");
	}
      else
	{
	  array[i]=1;
	  //printf("to_binaryInt: TEST, else\n");
	}
      number= number/2;
      i=i+1;
    }

  //printf("to_binaryInt: i is %d\n", i);

  return i;  
}

void to_binaryFrac(long long number, int fractional_bits, int * array,
		   int frac_size)
{
  int i=1, quotient, size= 0;
  long double tmp = 1.0;

  size= size_of_int(number);
  tmp= number;
  tmp= tmp/(intPow(10, frac_size)); 
  //printf("to_binaryFrac: number, size are %lld, %d\n", number, size);
    
  while(i<= fractional_bits)
    {
      tmp= tmp*2;
      //printf("to_binaryFrac: tmp is %.10Lf\n", tmp);
      quotient= tmp;
      //printf("to_binaryFrac: quotient is %d\n", quotient);
      array[i]= quotient;
      if (quotient== 1) tmp= tmp-1;
      i++;
    }

}
  

  
