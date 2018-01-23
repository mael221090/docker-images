echo $PWD

ls $PWD/notebooks
mkdir -p $PWD/notebooks
mkdir -p $PWD/data

#docker build -t pyspark-jupyther .
#docker run -it --rm -p 8888:8888 -v $PWD/notebooks:/opt/notebooks pyspark-jupyther

docker-compose up
