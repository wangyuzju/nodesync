http = require 'http'
fs = require 'fs'
path = require 'path'
FormData = require 'form-data'

DEBUG = false

remote =
  connect: (host, pathTo, debug) ->
    DEBUG = debug
    @host = host
    # 确保上传路径最后的 "/" ，不然如果用户没有指定 "/" 就会出错。
    @pathTo = path.resolve( pathTo ) + "/"
    @post {op: "init"}

  post: (opts) ->
    self = @
    form = new FormData()
    for key, value of opts
      #if the value is empty will cause form_data.js error
      form.append key, value if value

    form.submit(@host, (err, res)->
      if err
        # connect failed
        console.error "\t#{err}"
        return

      if not self.connected
        self.connected = true
        console.info "Server: >>> "
      else
        if DEBUG
          logPrefix = "[#{(new Date()).toTimeString().slice(0, 8)}] Server: >>> \n\t"
        else
          logPrefix = "[#{(new Date()).toTimeString().slice(0, 8)}] Server: >>>"

      res.on 'data', (chunk)->
        data = JSON.parse chunk
        switch data.code
          when 22001 then console.error  "#{logPrefix} #{data.msg}"
          when 22000 then console.info "#{logPrefix} #{data.msg}"
          else console.log "\t#{data.msg}"
        #console.log ""
    )

  _debugInfo: (event, filepath)->
    # send module used for debug
    console.log "  send:\t >>>>>>>>"
    console.log "\t      op: \u001b[1;4m#{event}\u001b[0m"
    console.log "\t  pathto: #{@pathTo}"
    console.log "\tfilepath: #{filepath}"
    console.log ""

  save: (fp, oid) ->
    if DEBUG
      @_debugInfo 'change', fp

    @post
      op: 'change'
      to: @pathTo
      filepath: fp

      md5: oid
      file: fs.createReadStream(fp)

  mkdir: (dir) ->
    if DEBUG
      @_debugInfo 'mkdir', dir


    @post
      op: 'mkdir'
      to: @pathTo
      filepath: dir

  delete: (fp, oid)->
    if DEBUG
      @_debugInfo 'del', fp

    @post
      op: "del"
      to: @pathTo
      filepath: fp

  move: (fp, oid, nfp) ->
    if DEBUG
      @_debugInfo 'mv', "move #{fp} to #{nfp}"

    @post
      op: 'mv'
      to: @pathTo
      filepath: fp
      target: nfp
      oid: oid

module.exports = remote