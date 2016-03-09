# following option makes sure the job will run in the current directory
#$ -cwd
# Reicibir un mail cuando comience y acabe el job:
#$ -m bea
# ... a este mail:
#$ -M nobody@ac.upc.edu
# following option makes sure the job has the same environmnent variables as the submission shell
#$ -V

mpirun.mpich2 -np 3 -machinefile $TMPDIR/machines /scratch/boada-1/USERNAME/hello_world_mpi
