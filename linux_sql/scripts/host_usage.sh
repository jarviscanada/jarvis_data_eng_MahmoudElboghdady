#!/bin/bash

# Setup and validate arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Parse resource usage
vmstat_out=$(vmstat --unit M)
vmstat_disk_out=$(vmstat -d)
hostname=$(hostname -f)
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')
memory_free=$(echo "$vmstat_out" | tail -1 | awk '{print $4}')
cpu_idle=$(echo "$vmstat_out" | tail -1 | awk '{print $15}')
cpu_kernel=$(echo "$vmstat_out" | tail -1 | awk '{print $14}')
disk_io=$(echo "$vmstat_disk_out" | tail -1 | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//')

# Subquery to find matching host_id from host_info
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Insert resource usage into host_usage table
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
