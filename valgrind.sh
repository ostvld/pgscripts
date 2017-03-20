#!/usr/bin/env bash

set -e

M=$HOME/work/postgrespro/postgresql-install
U=`whoami`

pkill -9 postgres || true

rm -rf $M || true
mkdir $M

make install

$M/bin/initdb -D $M/data-master

echo "listen_addresses = '127.0.0.1'" >> $M/data-master/postgresql.conf
echo "max_prepared_transactions = 100" >> $M/data-master/postgresql.conf
echo "wal_level = hot_standby" >> $M/data-master/postgresql.conf
echo "wal_keep_segments = 128" >> $M/data-master/postgresql.conf
echo "max_connections = 10" >> $M/data-master/postgresql.conf
echo "wal_log_hints = on" >> $M/data-master/postgresql.conf
echo "max_wal_senders = 8" >> $M/data-master/postgresql.conf
echo "wal_keep_segments = 64" >> $M/data-master/postgresql.conf
echo "listen_addresses = '*'" >> $M/data-master/postgresql.conf
echo "hot_standby = on" >> $M/data-master/postgresql.conf
echo "log_statement = all" >> $M/data-master/postgresql.conf
echo "max_locks_per_transaction = 256" >> $M/data-master/postgresql.conf
#echo "shared_buffers = 1GB" >> $M/data-master/postgresql.conf
#echo "fsync = off" >> $M/data-master/postgresql.conf
#echo "autovacuum = off" >> $M/data-master/postgresql.conf
echo "host replication $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf
echo "host all $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf
echo '' > $M/data-master/logfile

rm $HOME/work/postgrespro/postgresql-valgrind/*.log || true

echo '!!!'
echo '!!! Hint: after PostgreSQL will start run `make installcheck` in the second terminal'
echo '!!!'

echo 'PostgreSQL will start in:'
echo -n '5...'
sleep 1
echo -n '4...'
sleep 1
echo -n '3...'
sleep 1
echo -n '2...'
sleep 1
echo -n '1...'
sleep 1
echo 'NOW'

valgrind --leak-check=full --track-origins=yes --gen-suppressions=all \
  --suppressions=src/tools/valgrind.supp --time-stamp=yes \
  --log-file=$HOME/work/postgrespro/postgresql-valgrind/%p.log \
  --trace-children=yes postgres -D \
  $HOME/work/postgrespro/postgresql-install/data-master \
  2>&1 | tee $HOME/work/postgrespro/postgresql-valgrind/postmaster.log

