# following option makes sure the job will run in the current directory
#$ -cwd
# Reicibir un mail cuando comience y acabe el job:
#$ -m bea
# ... a este mail:
#$ -M nobody@ac.upc.edu
# following option makes sure the job has the same environmnent variables as the submission shell
#$ -V

# Cuando llamamos a mpirun.mpich2, es importante añadir el parámetro
# "-machinefile $TMPDIR/machines" dado que el entorno paralelo "mpich"
# se encarga de preparar el archivo "machines" con la lista de máquinas
# donde se ejecutará la aplicación.
mpirun.mpich2 -np 3 -machinefile $TMPDIR/machines /scratch/boada-1/USERNAME/hello_world_mpi
