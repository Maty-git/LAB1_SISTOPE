Para la generación del reporte es necesario ejecutar el siguiente comando:

./generator.sh -i 1 -t 10 | ./preprocess.sh --iso8601 | ./filter.sh -c 0 -m 0 -r ".*" | ./transform.sh --anon-uid | ./aggregate.sh | ./report.sh -o reporte.csv

Si al ejecutar obtienes un error de "Permiso denegado", debes darle permisos de ejecución a los scripts con:

chmod +x generator.sh preprocess.sh filter.sh transform.sh aggregate.sh report.sh
