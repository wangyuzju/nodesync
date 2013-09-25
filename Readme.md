# nodesync

监测本地文件夹，自动将变化的文件上传到服务器的指定目录下

## Install

```
npm install -g nodesync
```

## Usage

```
nodesync [src/]
```
开始监控并自动同步改动文件

```
nodesync config
```
根据当前的配置文件，重新设置配置文件

## Init && Configuration

假如需要监控 ~/workspace/music-branch-119/src/site/ 目录（music/为项目根目录），并同步到/bae/home/user/branch/music/src/site，可以采用以下方法

### 方法一: 自动生成配置文件
1. 切换**项目根目录** ~/workspace/music-branch-119/（其实任意，只要下此还在该目录调用nodesync就行，不然会找不到配置文件）
2. 第一次执行，需要输入以下配置信息（根据提示的默认值酌情修改）
  + path: 需要监控的本地文件夹的相对路径（如：src/site/）
  + ignore: 忽略监控的文件类型（如: "*.swp, *.bak"）
  + host: 服务器接收脚本URL，回车即可
  + pathto: 项目文件存放到服务器上的绝对路径。（**/bae/home/user/branch/music/**）
3. 提示配置文件.m3dsync_config保存成功，后续可直接通过该文件修改配置
4. **nodesync**, 改动的文件会文件自动同步到开发机

### 方法二：手动填写配置文件
1. cp sample.m3dsync_config ~/workspace/music/.m3dsync_config
2. vim .m3dsync_config

``` javascript
{
  "path": "src/test/",
  "type": ["*"],
  "host": "http://config.music.baidu.com",
  "pathto": "/bae/home/user/branch/music/"
}
```

## 常见错误说明

### Error: watch EMFILE: Too many opened files.
OS X系统默认ulimit被设置成256（查看方式：ulimit -n）,调大该值即可：`ulimit -n 16384`

## TODO
- <del>添加监控文件类型过滤</del>
- 自动冲突解决、冲突提示强制覆盖
- 离线文件改动监测


# change log
2. 0.0.10 add file filter feature
1. 0.0.7 add stable mode (using "chokidar") for supporting old version of nodejs(0.8) and OSX(10.7)