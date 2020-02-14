#!/bin/sh

docker run -d --net=mydemo --name stock -e NACOS_HOST=nacos -e ZIPKIN_HOST=zipkin -e SKYWALKING_HOST=skywalking mydemo/stock