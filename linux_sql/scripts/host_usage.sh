#!/bin/bash

# Collect resource usage data and insert into psql

psql_host="localhost"
psql_port="5432"
db_name="host_agent"
psql_user="postgres"
psql_password="password"

# Collect usage info
vmstat_out=$(vmstat --unit M)
vmstat_disk_out=$(vmstat -d)
hostname=$(hostname -f)
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')
memory_free=$(echo "$vmstat_out" | tail -1 | awk '{print $4}')
cpu_idle=$(echo "$vmstat_out" | tail -1 | awk '{print $15}')
cpu_kernel=$(echo "$vmstat_out" | tail -1 | awk '{print $14}')
disk_io=$(echo "$vmstat_disk_out" | tail -1 | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//')

# Get host_id from hosts table using hostname
host_id=$(psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -t -c \
  "SELECT id FROM host_info WHERE hostname='$hostname';" | xargs)

# Insert into host_usage table
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', '$host_id', '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
