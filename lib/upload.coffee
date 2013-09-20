http = require 'http'
fs = require 'fs'
path = require 'path'
FormData = require 'form-data'

DEBUG = false

remote =
  connect: (host, pathTo, force, debug) ->
    DEBUG = debug

    if force
      @force = 'true'
    else
      @force = 'false'
    @host = host
    # 确保上传路径最后的 "/" ，不然如果用户没有指定 "/" 就会出错。
    @pathTo = path.resolve( pathTo ) + "/"
    @post {op: "init"}


  _debugInfo: (opts)->
    # dump the params post to the server
    console.log "  send:\t >>>>>>>>"

    for key, value of opts
      console.log "\t #{key}: \u001b[4m#{value}\u001b[0m"
    console.log ""


  post: (opts) ->
    @_debugInfo opts if DEBUG


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

      if DEBUG
        logPrefix = "[#{(new Date()).toTimeString().slice(0, 8)}] Server: >>> \n\t"
      else
        logPrefix = "[#{(new Date()).toTimeString().slice(0, 8)}] Server: >>>"

      res.on 'data', (chunk)->
        data = JSON.parse chunk
        switch data.code
          when 22001 then console.error  "#{logPrefix} #{data.msg}"
          when 22000 then console.info "#{logPrefix} #{data.msg}"
          else console.log "\t ddd #{data.msg}"

        #console.log ""
    )

  save: (fp, oid) ->
    @post
      op: 'change'
      force: @force
      to: @pathTo
      filepath: fp

      md5: oid
      file: fs.createReadStream(fp)

  mkdir: (dir) ->
    @post
      op: 'mkdir'
      force: @force
      to: @pathTo
      filepath: dir

  delete: (fp, oid)->
    @post
      op: "del"
      force: @force
      to: @pathTo
      filepath: fp

  move: (fp, oid, nfp) ->
    @post
      op: 'mv'
      force: @force
      to: @pathTo
      filepath: fp
      target: nfp
      oid: oid

module.exports = remote