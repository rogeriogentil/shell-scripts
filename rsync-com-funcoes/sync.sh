#!/bin/bash
#
# Conecta a um rsync daemon remoto que requer autenticação para sincronizar
# arquivos entre hosts.
#
# Criado por: Rogerio J. Gentil

# Diretório(s) ou arquivo(s) a ser(em) sincronizado(s) do host de origem.
dir_src1=/home/
dir_sr21=/opt/

# Host de destino (deixe em branco se o host de destino for uma máquina local).
dst=127.0.0.1

# Por padrão, um rsync daemon usa porta TCP 873.
port=873

# Diretório(s) virtual(is) de destino a ser(em) sincronizado(s) executando sob um
# daemon no host remoto.
dir_dst1=destino1
dir_dst2=destino2

# Usuário para autenticação no host de destino.
usr=usersync

# Arquivo que armazena a senha de usuário para autenticação.
# IMPORTANTE: Este arquivo não deve ter permissão de leitura para outros usuários.
# Ou seja, as permissões máximas devem ser -rw-r----- (640).
pass=./sync.pass

# Arquivo temporário que conterá a lista de arquivo(s) que devem ser sincronizados.
includes=/tmp/sync.tmp

# Data completa (o memso que %Y-%m-%d).
date=$(date +%F)

# Hora completa (o mesmo que %H:%M:%S).
hour=$(date +%T)

# Arquivo de log.
tty_file='sync-'$date-$hour'.log'

# Diretório de log.
dir_log=/var/log/rsync

# Cria arquivo temporário para armazenar lista de arquivos que serão incluídos na
# sincronização se ele não existir.
#--------------------------------
criarArquivoTemporario() {
   if [ ! -e $includes ]; then
      touch $includes
   fi
}

# Sincroniza arquivos da origem 1.
#---------------------------------
sincronizar1() {
  if [ -d $dir_src1 ]; then
    criarArquivoTemporario
    cd $dir_src1

    # Busca os arquivos JPG que tenham apenas dígitos em seu nome (de 2 a 6),
    # remove os dois primeiros caracteres (./) da saída do comando find
    # e imprime saída no arquivo de itens a serem sincronizados.
    find . -regextype posix-egrep -type f -regex '^./[0-9]{2,6}.jpg$' | cut -c 3-12 > $includes
  
    rsync -azv --files-from=$includes --password-file=$pass --log-file=$dir_log'/rsync.log' $dir_src1 rsync://$usr'@'$dst':'$port'/'$dir_dst1  >> $dir_log'/'$tty_file
  else
    echo 'dir_src='$dir_src1 'não é um diretório de origem válido.'
  fi
}

# Sincroniza arquivos da origem 2.
#---------------------------------
sincronizar2() {
  if [ -d $dir_src2 ]; then
    criarArquivoTemporario
    cd $dir_src2

    # Busca os arquivos JPG que tenham apenas dígitos em seu nome (7), 
    # remove os dois primeiros caracteres (./) da saída do comando find
    # e imprime saída no arquivo de itens a serem sincronizados.

    find . -regextype posix-egrep -type f -regex '^./[0-9]{7}.jpg$' | cut -c 3-13 > $includes

    rsync -azv --files-from=$includes --password-file=$pass --log-file=$dir_log'/rsync.log' $dir_src2 rsync://$usr'@'$dst':'$port'/'$dir_dst2  >> $dir_log'/'$tty_file
  else
    echo 'dir_src='$dir_src2 'não é um diretório de origem válido.'
  fi
}

case "$1" in
sync1)
   sincronizar1
   ;;

sync2)
   sincronizar2
   ;;

syncAll)
   sincronizar1
   sincronizar2
   ;;

*) 
   echo "Argumento inválido. Use (sync1|sync2|syncAll)"
   exit 1
esac

exit $?
