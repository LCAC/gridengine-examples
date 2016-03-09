#!/bin/sh
# following option makes sure the job will run in the current directory
#$ -cwd
# Envia'm un mail quan comenci i acabi el job:
#$ -m bea
# ... a aquesta adreça
#$ -M USERNAME@DOMAIN.EXT
# following option makes sure the job has the same environmnent variables as the submission shell
#$ -V

# En fer servir "mpirun.mpich2" és imprescindible afegir el paràmetre ''-machinefile'',
# ja que l'entorn paral·lel "mpich" s'encarrega de preparar l'arxiu "machines" amb
# la llista de màquines on es pot executar l'aplicació.
mpirun.mpich2 -np 3 -machinefile $TMPDIR/machines /scratch/boada-1/USERNAME/hello_world_mpi
