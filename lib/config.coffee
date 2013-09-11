fs = require 'fs'
path = require 'path'
initConfig = require './config_sample'


init = ()->
  console.log  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  console.info "第一次使用程序，没有找到当前项目的配置文件，请按照提示输入相应参数 ..."
  console.log  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


  stdin = process.stdin
  stdout = process.stdout
  stdin.resume()
  stdin.setEncoding('utf8')
  dir = process.cwd()

  params = []
  defaultValue = []
  resultValue = []

  tips = initConfig._tips
  delete initConfig._tips


  i = 0

  for key, value of initConfig
    params[i] = key
    defaultValue[i] = value
    i++

  j = 0
  ret = {}

  stdout.write "#{tips[j]} (默认值'#{process.argv[2] || './'}') \n#{params[j]} :"

  stdin.on('data', (chunk)->
    if chunk == '\n'
      resultValue[j] = defaultValue[j]
    else
      resultValue[j] = chunk.trim()

    j++

    if j < i
      stdout.write "请输入#{tips[j]} (默认值'#{defaultValue[j]}') \n#{params[j]} :"
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

  DEFAULT_CONFIG_FILE_PATH = '../sample.m3dsync_config'

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
    init()
    return undefined
    #config = JSON.parse fs.readFileSync(DEFAULT_CONFIG_FILE_PATH)
#
#    console.warn "Can't find configuration file is the current directory: "
#    console.log "\t#{target}"
#    console.warn "Use default conf(\"#{path.resolve DEFAULT_CONFIG_FILE_PATH}\"):"
#    console.log "\thost  : #{CONFIG.server.host}"
#    console.log "\tpathto: #{CONFIG.server.pathto}"
#    console.log ""



module.exports.load = loadConfig