#!/bin/sh

sleep 30
java -cp ./app.jar com.tp2020.backend.migrator.MigratorKt ./application.conf &&
java -jar ./app.jar -config=./application.conf
