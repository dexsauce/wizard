﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="GameLobbyRoom.aspx.cs" Inherits="WizardGame.GameLobbyRoom" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        // player object
        var currentPlayer = new function () {
            this.PlayerId = 0,
            this.Name = "",
            this.PictureURL = "",
            this.UserId = 0,
            this.connectionId = ""
        };

        // server group id
        var groupNameId = '<%=GameLobby.GroupNameId%>';

        // is connected to server
        var isConnected = false;

        currentPlayer.PlayerId = '<%= PlayerData.PlayerId %>';
        currentPlayer.Name = '<%= PlayerData.Name %>';
        currentPlayer.PictureURL = '<%= PlayerData.PictureURL %>';
        currentPlayer.UserId = '<%= PlayerData.UserId %>';

        // initialize connection
        function onConnectionInit() {

            // update connection flag
            isConnected = true;

            // tell server we are joining the lobby
            joinGameLobby(currentPlayer.PlayerId, groupNameId);
        };

        // Start the connection
        $.connection.hub.start().done(onConnectionInit);

        // get reference to hub
        var hub = $.connection.gameSessionHub;

        /*******************************************
         * functions that are called by the server *
         *******************************************/

        // playerJoinedLobby
        hub.client.playerJoinedLobby = function (playerId, playerName, playerConnectionId) {
            logMessage("-- " + playerName + " has joined the game lobby --");
        };

        // playerLeftLobby
        hub.client.playerLeftLobby = function playerLeftLobby(playerName, connectionId) {
            logMessage("-- " + playerName + " has left the game lobby --");
        };

        // receiveChatMessage
        hub.client.receiveChatMessage = function receiveChatMessage(playerName, message) {
            logMessage("-- message received from: " + playerName + " --");
            appendChatMessage(playerName, message);
        }

        // logMessage
        hub.client.logMessage = function logMessage(message) {
            logMessage(message);
        };

        /*******************************************
         * functions that are called by the client *
         *******************************************/
        function joinGameLobby(playerId, groupNameId) {
            logMessage("-- calling joinGameLobby(" + playerId + "," + groupNameId + ") on server --");

            // call joinGameLobby on server
            hub.server.joinGameLobby(playerId, groupNameId)
                .done(function () {
                    logMessage("-- joinGameLobby executed on server --");
                })
                .fail(function (msg) {
                    logMessage("-- " + msg + " --");
                });
        };

        function leaveGameLobby() {
            logMessage("-- calling leaveGameLobby(" + player.Name + "," + groupNameId + ") on server --");

            // call leaveGameLobby on server
            hub.server.leaveGameLobby(player.Name, groupNameId)
                .done(function () {
                    logMessage("-- leaveGameLobby executed on server --");
                })
                .fail(function (msg) {
                    logMessage("-- " + msg + " --");
                });
        };

        function sendChatMessage() {
            logMessage("-- calling sendChatMessage on server --");

            // get chat message box
            var $chatbox = $("#txtChatMessage");

            // get msg
            var message = $chatbox.val();

            // clear chat box
            $chatbox.val('');

            // send to server
            hub.server.sendChatMessage(currentPlayer.Name, message, groupNameId)
                .done(function () {
                    logMessage("-- sendChatMessage executed on server --");
                })
                .fail(function (error) {
                    logMessage("-- " + msg + " --");
                });
        };

        function clearChatWindow() {
            var $chatwindow = $("#txtChatWindow");

            // clear chat window
            $chatwindow.val('');

            logMessage("-- cleared chat window --");
        };

        function appendChatMessage(playerName, message) {
            var oldMessages = $("#txtChatWindow").val();
            var time = new Date();
            var timeStr = time.getHours() + ":" + time.getMinutes() + ":" + time.getSeconds();
            var chatStr = "[" + timeStr + "] " + playerName + ": " + message + "\n";

            // append new message
            $("#txtChatWindow").val(oldMessages + chatStr);
        };
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="page-header" style="margin-top: 14px;">
            <h1 runat="server" id="GameLobbyTitle">Title</h1>
        </div>
        <div class="col-sm-8">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <strong>Chat window</strong>
                </div>
                <div class="panel-body">
                    <div class="form-group">
                        <textarea id="txtChatWindow" name="txtChatWindow" class="form-control" rows="6" readonly></textarea>
                        <style type="text/css">
                            #txtChatWindow {
                                width: 100%;
                                border: none;
                                resize: none;
                                background-color: transparent;
                            }
                        </style>
                    </div>
                    <div class="form-group" style="margin-bottom: 0px;">
                        <div class="input-group">
                            <input type="text" id="txtChatMessage" name="txtChatMessage" class="form-control" placeholder="Send a message to other players" />
                            <span class="input-group-btn">
                                <input type="button" id="btnClearChat" name="btnClearChat" class="btn btn-default" value="Clear" onclick="clearChatWindow(); return false;" />
                                <input type="button" id="btnSendChat" name="btnSendChat" class="btn btn-primary" value="Send" onclick="sendChatMessage(); return false;" />
                                <script>
                                    // bind enter event to chat text box
                                    $("#txtChatMessage").bind("keypress", function (event) {
                                        // enter key pressed
                                        if (event.keyCode == 13) {
                                            sendChatMessage();
                                        }
                                    });
                                </script>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <strong>Players</strong>
                </div>
                <ul class="list-group player-list">
                    <li class="list-group-item">
                        <% if (PlayerData != null && !string.IsNullOrEmpty(PlayerData.Name)) { Response.Write(PlayerData.Name); }%>
                    </li>
                </ul>
                <div class="panel-footer">
                    Connected: <span class="total-players">1</span>
                </div>
            </div>
            <div class="form-group">
                <% 
                    // check if player is game host
                    if (IsGameHost)
                    {
                        // player is the game host
                %>
                <asp:Button runat="server" ID="btnStartGame" CssClass="btn btn-lg btn-primary btn-block" Text="Start game" disabled OnClick="btnStartGame_Click" />
                <asp:Button runat="server" ID="btnCancelGame" CssClass="btn btn-lg btn-default btn-block" Text="Cancel game" OnClick="btnCancelGame_Click" />
                <% 
                    }
                    else
                    {
                        // player is not the host 
                %>
                <asp:Button runat="server" ID="btnQuitGame" CssClass="btn btn-lg btn-primary btn-block" Text="Quit game" OnClick="btnQuitGame_Click" />
                <% 
                    }
                %>
            </div>
        </div>
    </div>
</asp:Content>