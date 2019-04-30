#!/bin/bash

cd ../
docker-compose down -v
pkill vault 
rm -Rf ~/.vault-toke*
