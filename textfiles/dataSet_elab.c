#include <stdio.h>
#include <math.h>

#define MAXLEN 32

int main ()
{

  FILE *fp, *fpout;
  char c= '0';
  int i= 0, j= 0, decimal_size, size, tmp[MAXLEN], exp, sign= 0, k= 0;
  
  fp= fopen("dataset.txt", "r");
  fpout= fopen("dataset_out.txt", "w");

  while(c!= EOF)
    {
      i= 0;
      while(c!= '_')
	{
	  //printf("test");
	  c= getc(fp);
	  if(c== '.')
	      decimal_size= i;
	  else if(c== 'e')
	    {
	      c= getc(fp);
	      c= getc(fp);
	      c= getc(fp);
	      exp= (int) (c- '0');
	    }
	  else if(c== '\n')
	    {
	      size= i; 
	      i= 0;
	      c= '_';
	    }
	  else if(c== EOF)
	    {
	      size= i;
	      i= 0;
	      break;
	    }
	  else if(c== ' ') ;
	  else if(c== '-')
	    {
	      sign= 1;
	      printf("test %d\n", k);
	    }
	  else
	    {
	      tmp[i]= (int) (c-'0');
	      i= i+1;
	    }
	}

      if(sign== 1) fprintf(fpout, "-");
      
      for(j= 0; j< size; j++)
	if(j!= decimal_size+exp)
	  fprintf(fpout, "%d", tmp[j]);
	else
	  fprintf(fpout, ".%d", tmp[j]);

      fprintf(fpout, "\n");

      sign= 0;
      if(c!= EOF) c= '0';
      k= k+1;
    }
}
	   

      
      
