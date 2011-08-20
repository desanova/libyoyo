

#include <libyoyo.hc>

int main(int argc, char **argv)
  {
    enum { STATS_RANGE = 7000 };
    enum { STATS_LINES = 15 };
    enum { STAT_COLUMNS = 70 };
    int range, count, i, j;
    uquad_t result_max = 0;
    static uquad_t stats[STATS_RANGE] = {0};
    static uquad_t result[STAT_COLUMNS] = {0};
    
    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);

    if ( !Prog_Arguments_Count() )
      {
        puts("usage: ./random <range>");
        exit(-1);
      }

    range = Prog_Argument_Int(0);
    
    
    count = range * 100;
    for ( i = 0; i < count; ++i )
      {
        uquad_t rnd = Get_Random(0,range);
        ++stats[ (rnd * STATS_RANGE) / range ];
      }
    
    for ( i = 0; i < STATS_RANGE; ++i )
      {
        result[i*STAT_COLUMNS/STATS_RANGE] += stats[i];
      }
      
    for ( i = 0; i < STAT_COLUMNS; ++i )
      {
        result_max = Yo_MAX(result_max,result[i]);
      }
      
    for ( i = 0; i < STAT_COLUMNS; ++i )
      {
        result[i] = ( result[i] * STATS_LINES *2 ) / result_max;
      }

    printf("range: %d, max: %lld, stats count: %d\n",range,result_max,STATS_RANGE);

    for ( j = STATS_LINES ; j > 0; --j )
      {
        for ( i = 0; i < STAT_COLUMNS; ++i )
          {
            if ( result[i]/2 < j ) putchar(' ');
            else if ( result[i]/2 > j ) putchar('+');
            else
              {
                if ( result[i] % 2 ) putchar('#');
                else putchar('=');
              }
          }
        putchar('\n');
      }

    return 0;
  }

