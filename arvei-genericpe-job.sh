### Directivas para el gestor de colas (opcionales)
# Cambiar el nombre del trabajo
#$ -N testgenericpe
# Especificar un shell
#$ -S /bin/bash

# Para observar el formato de la variable $PE_HOSTFILE:
cat $PE_HOSTFILE >  /scratch/nas/1/$USER/genericpe.test

# Miramos el host donde se executa el job de forma inicial:
EXEC_HOST=`/bin/hostname`
echo "Master en: $EXEC_HOST" >> /scratch/nas/1/$USER/genericpe.test

# En cada uno de los nodos (incluyendo el job de ejecución) verificamos el hostname.
# Para obtener los nodos a los que nos podemos conectar, seleccionamos el primer campo
# del contenido del fichero mediante el comando cut
for h in `cat $PE_HOSTFILE | cut -f1 -d' ' `; do
        qrsh -inherit -nostdin -V $h "/bin/hostname | xargs echo 'Ejecutandose en el nodo: ' >> /scratch/nas/1/$USER/genericpe.test_$h" &
done

# Esperamos a que acaben todos los procesos
wait

exit 0
