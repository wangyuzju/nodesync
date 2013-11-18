# nodesync

监测本地文件夹，自动将变化的文件上传到服务器的指定目录下

## **注意事项**
1. 同步工具需要运行才能监测到文件的改动并进行同步，因此需要**在修改文件之前，执行程序，开始监测文件改动**。
2. 同步工具只是将代码同步到开发机，**没有提交到SVN**，在开发机上预览效果无误之后，请记得**手动提交代码到SVN**。
3. 建议以强制同步模式运行程序，即`nodesync -f`，虽然会强制覆盖文件，但是由于代码最终是通过SVN提交，因此不会导致冲突



## Install

```
npm install -g nodesync
```

## Usage

```
nodesync         # 当前目录没有配置文件会自动运行配置引导，相当于执行 nodesync config
nodesync -f      # 强制同步方式(建议使用)
nodesync -p src/ # 监听当前目录下的src目录内的文件变动
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
  + path: 需要监控的本地文件夹的相对路径（如：src/site/，**"./"表示监测本目录下的全部文件**）
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
  "path": "src/test/",  // "./"
  "ignore": "*.swap, *.bak, test*",
  "host": "http://config.music.baidu.com/nodesync",
  "pathto": "/bae/home/user/branch/music/"

  /*以下为可选参数*/
  "force": true,      //默认执行nodesync -f

}
```

## 常见错误说明
### Error: watch EMFILE: Too many opened files.
OS X系统默认ulimit被设置成256（查看方式：ulimit -n）,调大该值即可：`ulimit -n 16384`

### file md5 not match, please check your version and try svn up.
由于多人同时修改，导致开发机器上的文件有别人的改动，会报此提示。建议**运行程序时将上-f参数**，如`nodesync -f`，这样就会强制同步当前保存的文件到开发机
（PS：开发机只是提供预览效果，覆盖了别人的改动也没有关系，最终的代码是通过SVN提交，冲突通过SVN解决）


## TODO
- 自动冲突解决、冲突提示强制覆盖
- 离线文件改动监测
- 修复win下监测大量文件时CPU占用较高的问题


# change log
1. 0.0.7 add stable mode (using "chokidar") for supporting old version of nodejs(0.8) and OSX(10.7)
2. 0.0.10 add file filter feature
3. 0.0.25 add `nodesync -l` option for local testing
