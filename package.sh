#!/usr/bin/env sh

PROJECT_HOME=`dirname "$0"`

show_usage() {
	echo " Run \"mvn clean package spring-boot:repackage -P profiles\" for all services and shop-app application."
	echo " Usage:"
	echo " 1. Options to enable database sharding:"
	echo "    -mycat"
	echo "    -sharding-proxy"
	echo " 2. Options to enable global transaction management:"
	echo "   -seata"
	echo " 3. Options to enable APM tools:"
	echo "   -skywalking"
	echo "   -pinpoint"
	echo "   -zipkin"
}
package_project() {
	cd $1
	mvn $CLEAN package spring-boot:repackage "$PROFILES"
	cd ..
}

if [ $# -eq 0 ]; then
	show_usage
	sleep 1
fi;

PROFILES="-P dev"
DB_HOST="mysql"
CLEAN=""

while [ -n "$1" ] 
do
	case "$1" in 
		-mycat|--mycat) 
		    PROFILES="$PROFILES,mycat";
		    DB_HOST="mycat"
		    shift 1;;
		-sharding-proxy|--sharding-proxy) 
		    PROFILES="$PROFILES,sharding-proxy"; 
		    DB_HOST="shardingproxy"
		    shift 1;;
		-seata|--seata) PROFILES="$PROFILES,seata"; shift 1;;
		-zipkin|--zipkin) PROFILES="$PROFILES,zipkin"; shift 1;;
		-skywaling|--skywaling) PROFILES="$PROFILES,skywaling"; shift 1;;
		-pinpoint|--pinpoint) PROFILES="$PROFILES,pinpoint"; shift 1;;
		-clean|--clean) CLEAN="clean"; shift 1;;
		?|-?|-help|--help) show_usage; exit 0;;
		--) break;;
		*) echo " Invalid parameter: $1"; exit 1;;
	esac
done

cd $PROJECT_HOME
mvn install
cd service-client
mvn clean install
cd ..

package_project "item-service"
package_project "stock-service"
package_project "user-service"
package_project "order-service"
package_project "shop-web"

# order和user服务需要连接数据库：
# 1. 本地运行模式：通过maven的profile完成数据库HOST、PORT配置；
# 2. Docker容器运行：通过docker run传递环境变量值，将数据库HOST、PORT传递到容器；
sed -i "s/^MYSQL_HOST=.*$/MYSQL_HOST=$DB_HOST/g" order-service/run.sh
sed -i "s/^MYSQL_HOST=.*$/MYSQL_HOST=$DB_HOST/g" user-service/run.sh

echo " Finished"