# create db
psql -h localhost -U spencerboucher -c "drop database if exists pct;"
psql -h localhost -U spencerboucher -c "create database pct;"
psql -h localhost -U spencerboucher -d pct -c "create extension postgis;"

# import PCT
shp2pgsql -Icd data/pct/PacificCrestTrail.shp trail | psql -h localhost -U spencerboucher -d pct

# import roads
shp2pgsql -Icd data/washington/tl_2017_53_prisecroads.shp washington | psql -h localhost -U spencerboucher -d pct
shp2pgsql -Icd data/oregon/tl_2017_41_prisecroads.shp oregon | psql -h localhost -U spencerboucher -d pct
shp2pgsql -Icd data/california/tl_2017_06_prisecroads.shp california | psql -h localhost -U spencerboucher -d pct

# import earthquakes
ogr2ogr -f PostgreSQL PG:"dbname=pct user=spencerboucher" data/earthquakes.json -nln earthquakes

psql -h localhost -U spencerboucher -d pct -f setup.sql
