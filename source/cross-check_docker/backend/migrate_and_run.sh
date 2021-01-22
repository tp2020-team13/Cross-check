#!/bin/sh

java -cp ./app.jar com.tp2020.backend.migrator.MigratorKt ./application.production.conf &&
java -jar ./app.jar -config=./application.production.conf
