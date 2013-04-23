part of irc_client;

/**
 * The [Irc] object is passed to methods on the [Handler]s, so that they
 * can send commands back to the IRC server.
 */
class Irc {
  Logger ioLog = new Logger("io");
  StringSink _socket;
  String _nick;
  String _server;
  String _realName;
  int _port;
  List<Handler> _handlers;
  
  Irc._(this._server, this._port, this._nick, this._realName, this._handlers);
  
  /**
   * Returns the current nickname
   */
  String get nick => _nick;

  /**
   * Writes the [message] to the irc server. (Currently also writes it to
   * the console, but will eventually replace with with a logger).
   */
  void write(String message) {
    ioLog.fine(">>${message}");
    _socket.writeln(message);
  }
  
  /**
   * Sends a private [message] to the [nickOrChannel]. 
   */
  void sendMessage(String nickOrChannel, String message) {
    write("${Commands.PRIVMSG} ${nickOrChannel} :${message}");
  }
  
  /**
   * Sends a [notice] to the [user].
   */
  void sendNotice(String user, String notice) {
    write("${Commands.NOTICE} ${user} :${notice}");
  }
  
  /**
   * Joins a [channel].
   */
  void join(String channel) {
    write("${Commands.JOIN} ${channel}");
  }
  
  /**
   * Sets the current [nick].
   */
  void setNick(String nick) {
    _nick = nick;
    write("${Commands.NICK} ${nick}");
  }
  
  /**
   * Call this to cause the [onConnection] methods of the [handlers] get
   * called. This is usually not necessary, as the IrcClient or
   * NickServHandler calls this when appropriate anyway.
   */
  connected(Irc irc) {
    for (var handler in _handlers) {
      if (handler.onConnection(this)) {
        break;
      }
    }
  }
  
  void connect() {
    Socket.connect(_server, _port).then((socket) {
      var stream = socket
          .transform(new StringDecoder())
          .transform(new LineTransformer())
          .transform(new IrcTransformer());
      _socket = socket;
      
      setNick(_nick);
      write("${Commands.USER} ${_nick} 0 * :${_realName}");
      
      stream.listen((cmd) {
        ioLog.fine("<<${cmd.line}");
        var handled = false;
        for (var handler in _handlers) {
          handled = handler.onCommand(cmd, this);
          if (handled) {
            break;
          }
        }
        if (!handled) {
          if (cmd.commandNumber == Replies.END_OF_MOTD) {
            connected(this);
          }
          if (cmd.command == Commands.PRIVMSG && isChannel(cmd.params[0])) {
            for (var handler in _handlers) {
              if (handler.onChannelMessage(cmd.params[0], cmd.trailing, this)) {
                break;
              }
            }
          }
          if (cmd.command == Commands.PRIVMSG && namesAreEqual(cmd.params[0], nick)) {
            var user = cmd.prefix.substring(0, cmd.prefix.indexOf("!"));
            for (var handler in _handlers) {
              if (handler.onPrivateMessage(user, cmd.trailing, this)) {
                break;
              }
            }
          }
          if (cmd.command == Commands.PING) {
            write("${Commands.PONG} thisserver ${cmd.params[0]}");
          }
        }
      },
      onError: _onError, 
      onDone: _onDone);
    });
  }
  
  _onError(error) {
    
  }
  
  _onDone() {
    
  }
}
