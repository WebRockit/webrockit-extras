#!/bin/sh

### This has been tested with CentOS 6.x x86_64 
###  
### Automate this by running:  
###    curl -L http://x.co/wrssc6  | bash -s stable

# Install some base requirements
reqpackages="erlang git openssl rabbitmq-server redis vim-enhanced wget"
tmpbdir="/var/tmp/`date +%s`.install"

if [ -e /etc/redhat-release ] || [ -L /etc/redhat-release ] ; then
	pkgmethod=rpm
else
	pkgmethod=dpkg
fi

checkpackages () {
	echo "#### Checking for required packages"
	missingpkg=""
	for pkg in ${reqpackages}; do
		echo "## Checking for package ${pkg}"
		if [ "${pkgmethod}" == "rpm" ]; then
			rpm --quiet -q ${pkg} 
			if [ $? -ne 0 ]; then
				missingpkg="${missingpkg} ${pkg}"
				echo "### Package ${pkg} missing"
			fi
		fi
	done
	sleep 2
	eval "$1='${missingpkg}'"
}	

installpackages () {
	echo "#### Installing packages: ${reqpackages}"
	if [ "${pkgmethod}" == "rpm" ]; then 
		yum -q -y install ${reqpackages}
	fi
}

if [ ! -z "${reqpackages}" ]; then
	checkpackages reqpackages
fi

if [ ! -z "${reqpackages}" ]; then
	installpackages
fi


echo "#### Configure RabbitMQ"
echo '[rabbitmq_management].' > /etc/rabbitmq/enabled_plugins
echo '[
    {rabbit, [
    {tcp_listeners, [5672]},
    {ssl_listeners, [5671]},
    {ssl_options, [{cacertfile,"/etc/rabbitmq/ssl/cacert.pem"},
                   {certfile,"/etc/rabbitmq/ssl/server_cert.pem"},
                   {keyfile,"/etc/rabbitmq/ssl/server_key.pem"},
                   {verify,verify_peer},
                   {fail_if_no_peer_cert,true}]}
  ]}
].' > /etc/rabbitmq/rabbitmq.conf
chkconfig rabbitmq-server on
echo "### Generate SSL cert for RabbitMQ"
rabbitsslpath="/etc/rabbitmq/ssl"
mkdir -p ${rabbitsslpath}


mkdir -p ${tmpbdir}/testca/private
mkdir -p ${tmpbdir}/testca/certs
touch ${tmpbdir}/testca/index.txt
echo 01 > ${tmpbdir}/testca/serial
cd ${tmpbdir}/testca
wget -O "${tmpbdir}/openssl.cnf" 'https://raw.github.com/WebRockit/webrockit-extras/master/rabbitmq/openssl.cnf'
openssl req -x509 -config ../openssl.cnf -newkey rsa:2048 -days 40000 -out cacert.pem -outform PEM -subj /CN=TestCA/ -nodes
openssl x509 -in cacert.pem -out cacert.cer -outform DER
cd ..
openssl genrsa -out server_key.pem 2048
openssl req -new -key server_key.pem -out server_req.pem -outform PEM -subj /CN=$(hostname)/O=server/ -nodes
cd testca
openssl ca -config ../openssl.cnf -in ../server_req.pem -out ../server_cert.pem -notext -batch -extensions server_ca_extensions
cd ..
openssl pkcs12 -export -out server_keycert.p12 -in server_cert.pem -inkey server_key.pem -passout pass:DemoPass
openssl genrsa -out client_key.pem 2048
openssl req -new -key client_key.pem -out client_req.pem -outform PEM -subj /CN=$(hostname)/O=client/ -nodes
cd testca
openssl ca -config ../openssl.cnf -in ../client_req.pem -out ../client_cert.pem -notext -batch -extensions client_ca_extensions
cd ..
openssl pkcs12 -export -out client_keycert.p12 -in client_cert.pem -inkey client_key.pem -passout pass:DemoPass
cp ${tmpbdir}/sensu_ca/cacert.pem /etc/rabbitmq/ssl/cacert.pem
cp ${tmpbdir}server/cert.pem /etc/rabbitmq/ssl/server_cert.pem
cp server/key.pem /etc/rabbitmq/ssl/server_key.pem


#####
###### Install ruby 2.0 with rvm
#####curl -L get.rvm.io | bash -s stable
#####source /etc/profile.d/rvm.sh
#####rvm requirements
#####rvm install 2.0
#####rvm use 2.0 --default
########rvm rubygems current
