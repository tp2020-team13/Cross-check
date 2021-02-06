#!/bin/sh

java -cp ./app.jar com.tp2020.backend.migrator.MigratorKt ./config/application.conf &&
java -jar ./app.jar -config=./application.conf
