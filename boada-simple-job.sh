### Directivas para el gestor de colas (modificar los valores NAMEOFJOB y la dirección de correo de la opción "-M", y mantener la opción "-S")
# Cambiar el nombre del trabajo
#$ -N NAMEOFJOB
# Especificar un shell
#$ -S /bin/sh
# Enviame un correo cuando empiece el trabajo y cuando acabe...
#$ -m be
# ... a esta dirección de correo
#$ -M nobody@ac.upc.edu

CSCRATCH=/scratch/boada-1/`whoami`

### Ejecutar el fichero ejecutable pertinente
$CSCRATCH/dir/binari -from $1 -to $2
