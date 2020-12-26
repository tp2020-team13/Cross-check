#!/bin/sh

java -cp ./backend.jar com.tp2020.backend.migrator.MigratorKt ./application.production.conf &&
java -jar ./backend.jar -config=./application.production.conf
