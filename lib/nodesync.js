// Generated by CoffeeScript 1.6.3
(function() {
  var Filter, MatchContainer, config, fc, fs, initMain, parseArgv, path, program, remote, startWatch, watch;

  fs = require('fs');

  path = require('path');

  watch = require("watch-project");

  program = require('commander');

  remote = require('./upload');

  fc = require('./filechange');

  config = require('./config');

  /*
    start watching for the project directory
  */


  startWatch = function(opts) {
    var filter, handleFileChange, preCheck;
    if (!opts.host) {
      console.error("Please specific [ host ] in the configuration file!");
      process.exit();
    }
    if (!opts.pathto) {
      console.error("Please specific [ pathto ] in the configuration file!");
      process.exit();
    }
    if (!opts.path) {
      console.error("Please sepcific [ path ] in the confiuration file!");
      process.exit();
    }
    if (!fs.existsSync(opts.path)) {
      console.error("Error: ");
      console.log("\tDirectory '" + opts.path + "' to watch is not Exist!");
      return;
    }
    if (opts.beta) {
      console.warn("[Beta Mode Enable: works well on linux]");
    }
    console.log("Local : >>>");
    console.log("\tWatching : '" + opts.path + "'");
    console.log("\tConnect to: '" + opts.host + "'");
    console.log("\tSync File To: '\u001b[1;35m" + opts.pathto + "\u001b[0m'");
    console.log("");
    remote.connect(opts.host, opts.pathto, opts.force, opts.debug);
    if (opts.ignore) {
      filter = new Filter(opts.ignore && opts.ignore.replace(/,\s/g, ",").split(','));
      preCheck = function(s) {
        return filter.match(s);
      };
    } else {
      preCheck = function() {
        return false;
      };
    }
    handleFileChange = (function(enableJCH) {
      if (enableJCH) {
        if (opts.local) {
          return handleFileChange = function(e) {
            switch (e.type) {
              case 'change':
                if (path.basename(e.filename).slice(0, 8) === "coffess_") {
                  return jch.parse(e.filename);
                }
            }
          };
        } else {
          return handleFileChange = function(e) {
            switch (e.type) {
              case 'mkdir':
                return remote.mkdir(e.filename);
              case 'change':
                remote.save(e.filename, e.oid);
                if (path.basename(e.filename).slice(0, 8) === "coffess_") {
                  return jch.parse(e.filename);
                }
                break;
              case 'create':
                return remote.save(e.filename, e.oid);
              case 'delete':
              case 'rmdir':
                return remote["delete"](e.filename, e.oid);
              case 'mvfile':
              case 'mvdir':
                return remote.move(e.oname, e.oid, e.filename);
            }
          };
        }
      } else {
        if (opts.local) {
          return handleFileChange = function(e) {};
        } else {
          return handleFileChange = function(e) {
            switch (e.type) {
              case 'mkdir':
                return remote.mkdir(e.filename);
              case 'change':
              case 'create':
                return remote.save(e.filename, e.oid);
              case 'delete':
              case 'rmdir':
                return remote["delete"](e.filename, e.oid);
              case 'mvfile':
              case 'mvdir':
                return remote.move(e.oname, e.oid, e.filename);
            }
          };
        }
      }
    })(!!global.jch);
    /*
    
        watch file change
    */

    watch(opts.path, {
      stable: !opts.beta,
      withHidden: opts.all
    }, function(e) {
      if (preCheck(path.basename(e.filename))) {
        return;
      }
      console.log("[" + ((new Date()).toTimeString().slice(0, 8)) + "] Local: >>>\u001b[1;4m" + e.type + "\u001b[0m [" + e.filename + "]");
      if (opts.debug) {
        console.log("   old:\t" + e.oid);
        console.log("   new:\t" + (e.nid || e.oid));
      }
      return handleFileChange(e);
    });
    /*
    
        TODO save file status in local
        save watch status for trigger change events next time
    */

    return process.on('SIGINT', function() {
      return process.exit();
    });
  };

  /*
  
      prepare for watching the project directory
  */


  console.error = function(s) {
    return console.log("\u001b[1;31m" + s + "\u001b[0m");
  };

  console.info = function(s) {
    return console.log("\u001b[36m" + s + "\u001b[0m");
  };

  console.warn = function(s) {
    return console.log("\u001b[1;35m" + s + "\u001b[0m");
  };

  parseArgv = function() {
    program;
    var confFile;
    switch (process.argv[2]) {
      case 'resolve':
        return console.log("resolve conflict!");
      case 'config':
        confFile = path.resolve('.m3dsync_config');
        if (fs.existsSync(confFile)) {
          return config.create(path.resolve('.m3dsync_config'));
        } else {
          return config.create();
        }
        break;
      case 'jch':
        global.jch = require("coffess");
        console.info("# enable jch mode!");
        return initMain();
      default:
        return initMain();
    }
  };

  initMain = function() {
    var conf, key, params, value;
    program.option('', '').option('', '').option('-l, --local', 'disable auto sync feature for local testing').option('-p, --path <dir>', 'specifies dir path to be watched').option('-f, --force', 'force sync mode, without checking file\'s MD5').option('-a, --all', 'watch hidden files and dirs as well').option('-b, --beta', 'beta version, only stable on linux').option('-d, --debug', 'show more detailed debug info').version('0.0.25', '-v, --version');
    params = program.parse(process.argv);
    if (params.local) {
      console.info("# enable [ local ] mode!");
    }
    conf = config.load(path.resolve('.m3dsync_config'));
    if (conf) {
      for (key in conf) {
        value = conf[key];
        if (params[key] == null) {
          params[key] = value;
        }
      }
      return startWatch(params);
    }
  };

  module.exports.run = parseArgv;

  /* #   #*/


  /* #   #   #*/


  MatchContainer = (function() {
    function MatchContainer() {}

    MatchContainer.prototype.add = function(val) {
      var l;
      l = val.length;
      if (this[l]) {
        return this[l][val] = true;
      } else {
        this[l] = {};
        return this[l][val] = true;
      }
    };

    return MatchContainer;

  })();

  Filter = (function() {
    function Filter(config) {
      this.config = config;
      this._prepare();
    }

    Filter.prototype._prepare = function() {
      var val, _i, _len, _ref, _results;
      this.leftMatch = new MatchContainer();
      this.rightMatch = new MatchContainer();
      this.totalMatch = new MatchContainer();
      _ref = this.config;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        if (val[0] === "*") {
          _results.push(this.rightMatch.add(val.slice(1)));
        } else if (val.slice(-1) === "*") {
          _results.push(this.leftMatch.add(val.slice(0, -1)));
        } else {
          _results.push(this.totalMatch[val.length] = val);
        }
      }
      return _results;
    };

    Filter.prototype.match = function(s) {
      var l, len, lenMatchList, _ref, _ref1;
      l = s.length;
      _ref = this.rightMatch;
      for (len in _ref) {
        lenMatchList = _ref[len];
        if (len >= l) {
          break;
        }
        if (lenMatchList[s.slice(-len)]) {
          return true;
        }
      }
      _ref1 = this.leftMatch;
      for (len in _ref1) {
        lenMatchList = _ref1[len];
        if (len >= l) {
          break;
        }
        if (lenMatchList[s.slice(0, len)]) {
          return true;
        }
      }
      if (this.totalMatch[l]) {
        return true;
      }
      return false;
    };

    return Filter;

  })();

}).call(this);
