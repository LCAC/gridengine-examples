/* C Example */
#include <stdio.h>
#include <mpi.h>

/* header files for getting hostname and process id */
#include <unistd.h>
#include <sys/types.h>


int main (argc, argv)
     int argc;
     char *argv[];
{
  int rank, size;
  char hostname[128];
  FILE *file;
  char namefile[256];

  MPI_Init (&argc, &argv);      /* starts MPI */
  MPI_Comm_rank (MPI_COMM_WORLD, &rank);        /* get current process id */
  MPI_Comm_size (MPI_COMM_WORLD, &size);        /* get number of processes */

  gethostname(hostname, 126);

  /* Substituir USERNAME por el username del usuario que va a ejecutar el ejemplo. */
  sprintf(namefile, "/scratch/nas/1/USERNAME/hello_%s", hostname);
  file = fopen(namefile, "w");
  fprintf( file, "Hello world from process %d of %d at hostname %s\n", rank, size, hostname );
  fclose(file);

  MPI_Finalize();
  return 0;
}
