#!/bin/sh
#用于在linux机器上自动部署时候做的初始化环境安装


function docker_install(){
	echo "检查Docker......"
	docker -v
	if [ $? -eq  0 ]; then
		echo "检查到Docker已安装!"
	else
		echo "docker 未安装，安装docker"
		yum install -y yum-utils device-mapper-persistent-data lvm2  #安装所需依赖包
		# 2.使用以下命令设置稳定存储库。
		sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
			# 3.安装Docker CE
		yum install -y docker-ce
		systemctl start docker #启动docker
		sudo mkdir -p /etc/docker
		sudo tee /etc/docker/daemon.json <<-'EOF'
		{
		  "registry-mirrors": ["https://mirror.ccs.tencentyun.com"]
		}
		EOF
		sudo systemctl daemon-reload
		sudo systemctl restart docker
		docker info #检查是否配置修改成功
		docker -v
	fi
}


function docker_compose_install(){
	echo "检查Docker......"
	docker-compose -v
	if [ $? -eq  0 ]; then
		echo "检查到docker-compose已安装!"
	else
		echo "dockercompose 未安装，安装docker"
		yum install -y docker-compose # 安装docker-compose
		docker-compose -v #查看版本

	fi
}

# 执行函数
docker_install
docker_compose_install