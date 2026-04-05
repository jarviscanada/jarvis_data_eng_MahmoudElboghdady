#!/bin/bash

# Collect hardware specification data and insert into psql

psql_host="localhost"
psql_port="5432"
db_name="host_agent"
psql_user="postgres"
psql_password="password"

# Collect hardware info
lscpu_out=$(lscpu)
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "^BogoMIPS:" | awk '{print $2}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | xargs)
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}' | xargs)
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# Insert into hosts table
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, L2_cache, total_mem, timestamp)
VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$total_mem', '$timestamp');"

export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
