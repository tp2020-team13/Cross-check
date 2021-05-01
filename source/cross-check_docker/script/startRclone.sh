#!/bin/bash

while [[ true ]] ; do

	# performs synchronizations / copy
	rclone sync /data/crosscheck/crosscheck_data/minio_data/ crosscheck-backup:../../data/crosscheck/crosscheck-backup/minio_data

	# waiting for something to change or it will pass 300 seconds
	inotifywait --recursive --timeout 300 -e modify,delete,create,move   /data/crosscheck/crosscheck_data/minio_data

	# going back to the beginning
done
