#!/bin/bash
#
# Conecta a um rsync daemon remoto que requer autenticação para sincronizar
# arquivos entre hosts.
#
# Criado por: Rogerio J. Gentil

# Diretório ou arquivo a ser sincronizado do host de origem.
dir_src=/home/

# Host de destino.
dst=127.0.0.1

# Por padrão, um rsync daemon usa porta TCP 873.
port=873

# Diretório ou arquivo a ser sincronizado do host de destino.
dir_dst=/home/

# Usuário para autenticação no host de destino.
usr=usersync

# Arquivo que armazena a senha de usuário para autenticação.
# IMPORTANTE: Este arquivo não deve ter permissão de leitura para outros usuários.
# Ou seja, as permissões máximas devem ser -rw-r----- (640).
pass=sync.pass

# Padrão de arquivo a ser sincronizado.
include=*.txt

# Arquivo que contém lista de arquivo(s) e diretório(s) que não devem ser sincronizados.
exclude=sync.exclude

# Data completa (o memso que %Y-%m-%d).
date=$(date +%F)

# Hora completa (o mesmo que %H:%M:%S).
hour=$(date +%T)

# Arquivo que armazenará a saída da execução do script.
tty_file='sync-'$date-$hour'.log'

# Diretório de log (o diretório deve existir - ter sido criado).
dir_log=/var/log/rsync

# Para debug
echo 'rsync -azv --include='$include '--exclude-from='$exclude '--password-file='$pass '--log-file='$dir_log'/rsync.log' $dir_src 'rsync://'$usr'@'$dst':'$port'/'$dir_dst '>>' $dir_log'/'$tty_file

rsync -azv --include=$include --exclude-from=$exclude --password-file=$pass --log-file=$dir_log'/rsync.log' $dir_src rsync://$usr'@'$dst':'$port'/'$dir_dst >> $dir_log'/'$tty_file
