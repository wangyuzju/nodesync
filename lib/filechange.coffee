path = require 'path'
md5 = require 'MD5'


fc =
  dispatchEvent: (handler, oStatus)->
    nStatus = handler.status()

    if md5(oStatus) is md5(nStatus)
      return

    odata = JSON.parse oStatus
    ndata = JSON.parse nStatus


    ofile = {}
    odir = {}
    nfile = {}
    ndir = {}
    mvdir = {}
    deleteDirID = {}
    createDirID = {}
    deleteFileID = {}
    createFileID = {}


    #先处理文件夹
    for dir, data of odata.dir
      if !ndata.dir[dir]
        deleteDirID[data.id] = dir
      else if ndata.dir[dir].id is data.id
        delete odata.dir[dir]
        delete ndata.dir[dir]
      else
        #具有同名文件夹，但是内容不同
        #console.log 'content change ' + dir
        delete odata.dir[dir]
        delete ndata.dir[dir]

    for dir, data of ndata.dir
      createDirID[data.id] = dir


    #具有相同hash，说明是重命名事件，否则触发删除事件
    for id, dir of deleteDirID
      if createDirID[id]
        console.log 'mvdir ' + dir + ' -> ' + createDirID[id]
        mvdir[dir] = id;
        delete deleteDirID[id]
        delete createDirID[id]
      else
        console.log "rmdir" + dir
    #最后触发新建事件
    for id, dir of createDirID
      console.log "mkdir" + dir



    #再处理文件内容
    for file, data of odata.file
      if !ndata.file[file]
        deleteFileID[data.id] = file
      else if ndata.file[file].id is data.id
        delete odata.file[file]
        delete ndata.file[file]
      else
        #具有同名文件，但是内容不同
        console.log 'Modified ' + file
        delete odata.file[file]
        delete ndata.file[file]

    for file, data of ndata.file
      createFileID[data.id] = file

    #过滤重命名事件，触发删除事件
    for id, file of deleteFileID
      if createFileID[id]
        #过滤掉重命名文件夹导致的文件移动
        if !mvdir[path.dirname(file)]
          console.log "mvfile " + file + ' -> ' + createFileID[id]
        delete deleteFileID[id]
        delete createFileID[id]
      else
        console.log "delete " + file

    #触发新建事件
    for id, file of createFileID
      console.log "create " + file


module.exports = fc