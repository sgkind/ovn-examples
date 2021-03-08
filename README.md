# ovn-examples

关于ovs和ovn的更多例子请参考[ovn_lab](https://github.com/cao19881125/ovn_lab).

***因部分新的ovn特性需要使用最新版本的ovn，ovn_lab中的ovn和ovs版本较低，因此在此仓库中保存相关测试，等后续ovn_lab中ovn和ovs的版本升级后合并入ovn_lab中***

## 编译docker镜像
在编译docker镜像前请先安装`make`和`docker`软件，将本仓库克隆到本地

### debian/linux
```
$ cd ovn-examples/docker
$ git submodule update --init
$ make build
```