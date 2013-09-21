fs = require 'fs'
path = require 'path'


genConfFromSample = (confFile)->
  initConfig = require './config_sample'

  if !confFile
    console.log  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    console.info "第一次使用程序，没有找到当前项目的配置文件，请按照提示输入相应参数 ..."
    console.log  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  else
    # rewrite initConfig.conf with user defined configuratin file
    try
      initConfig.conf = JSON.parse(fs.readFileSync confFile)
    catch
      console.error "the configuration file '#{confFile}' is not a valid JSON file, please check the syntax"


  stdin = process.stdin
  stdout = process.stdout
  stdin.resume()
  stdin.setEncoding('utf8')
  dir = process.cwd()

  params = []
  defaultValue = []
  resultValue = []

  tips = initConfig.desc

  i = 0

  for key, value of initConfig.conf
    params[i] = key
    defaultValue[i] = value
    i++

  j = 0
  ret = {}

  stdout.write "#{tips[j]} 当前值 \"#{defaultValue[j]}\" \n#{params[j]} :"

  stdin.on('data', (chunk)->
    if chunk == '\n'
      resultValue[j] = defaultValue[j]
    else
      resultValue[j] = chunk.trim().replace(/^["']/, '').replace(/["']$/, '')

    j++

    if j < i
      stdout.write "请输入#{tips[j]} 当前值 \"#{defaultValue[j]}\" \n#{params[j]} :"
    else
      j = -1
      while ++j < i
        ret[params[j]] = resultValue[j]
        #j++
      #process.exit()

      console.info "成功保存以下配置保存到 '.m3dsync_config' 请重新执行程序开始监控"
      console.log  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      console.log ret
      console.log  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      console.info "如需修改配置，直接编辑 '.m3dsync_config' 文件即可"
      fs.writeFileSync '.m3dsync_config', JSON.stringify(ret, null, '  ')
      process.exit()
  )



loadConfig = (confFile)->
  #读取配置文件信息
  try
    config = fs.readFileSync(confFile)
    try
      config = JSON.parse config
      console.log "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      console.log "+ Using configuration file: #{confFile}"
      console.log "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      return config
    catch
      console.error "The configuration file \n\t#{confFile}\nis not a valid JSON file, please check the syntax"
      return
  catch e
    # no configuration file yet, ask user to input!
    genConfFromSample()
    return undefined


module.exports =
  load: loadConfig
  create: genConfFromSample