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

## Init && Configuration

假如需要监控 ~/workspace/music-branch-119/src/site/ 目录（music/为项目根目录），并同步到/bae/home/user/branch/music/src/site，可以采用以下方法

### 方法一: 自动生成配置文件
1. 切换**项目根目录** ~/workspace/music-branch-119/（其实任意，只要下此还在该目录调用nodesync就行，不然会找不到配置文件）
2. 第一次执行，需要输入以下配置信息（根据提示的默认值酌情修改）
  + path: 需要监控的本地文件夹的相对路径（如：src/site/）
  + type: <del>暂时不支持</del>，回车即可
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

## TODO

- 添加监控文件类型过滤
