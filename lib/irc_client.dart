/**
 * This library lets you connect to an IRC server.
 * 
 * A very basic IRC bot:
 * 
 *     import 'packages:irc_client/irc_client.dart';
 *     
 *     class BotHandler extends Handler {
 *       bool onChannelMessage(String channel, String message, Irc irc) {
 *         if (message.toLowerCase().contains("hello")) {
 *           irc.sendMessage(channel, "Hey!");
 *         }
 *       }
 *     }
 *     
 *     main() {
 *       var bot = new IrcClient("bottymcbot");
 *       bot.handlers.add(new BotHandler());
 *       bot.run("irc.freenode.net");
 *     }
 * 
 * There is a more complex example in example/example.dart
 */
library irc_client;

//import 'dart:io';
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'dart:typed_data';

part 'src/constants.dart';
part 'src/connection.dart';
part 'src/command.dart';
part 'src/handler.dart';
part 'src/nickserv.dart';
part 'src/client.dart';