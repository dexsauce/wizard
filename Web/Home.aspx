﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="WizardGame.Home" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        // global vars
        var isConnected = false; // connected to hub
        var hub = $.connection.homeHub; // get reference to hub
        var maxLobbies = 5;

        // Start the connection
        $.connection.hub.start().done(onConnectionInit);

        /*******************************
         * Functions executed by server *
         *******************************/
        hub.client.getListOfGameLobbies = function (gameLobbiesArray) {
            // validate
            if (gameLobbiesArray != null) {
                // draw game lobbies
                drawGameLobbies(gameLobbiesArray);
            }
        };

        /********************************
         * Functions executed by client *
         ********************************/

        // initialize connection
        function onConnectionInit() {
            // hide offline message
            $(".offline-message").fadeOut("fast");

            // update connection flag
            isConnected = true;

            // set interval
            setInterval(getListOfGameLobbies, 5000);
        };

        // list game lobbies
        function getListOfGameLobbies() {
            if (isConnected) {
                // request list of game lobbies
                hub.server.listAllGameLobbies(maxLobbies);
            }
        };

        // show facebook photo
        function selectUseFacebookPhoto() {
            // make sure we have the url
            if (facebookPhotoUrl != null && facebookPhotoUrl.length > 0) {
                $("#facebook-photo-preview").html("<img src='" + facebookPhotoUrl + "' alt='profile photo' />");
                $("#facebook-photo-preview").fadeIn("slow");
            }
        };

        // draw game lobby data
        function drawGameLobbies(_lobbies) {
            if (_lobbies == null)
                return;

            // clear lobbies
            $(".game-lobbies").html('');

            var lobby_html = "";

            // loop through lobbies
            for (var i = 0; i < _lobbies.length; i++) {
                var gameLobby = _lobbies[i];

                if(gameLobby == null)
                    break;

                // append new lobbies
                lobby_html += "<tr>";
                lobby_html += "<td>" + gameLobby.Name + "</td>";
                lobby_html += "<td class='text-center'>" + gameLobby.OwnerPlayerName + "</td>";
                lobby_html += "<td class='text-center'>" + gameLobby.NumPlayersInLobby + " / " + gameLobby.MaxPlayers + "</td>";
<%
    if (UserSession != null && UserSession.PlayerId > 0)
    {
%>
                lobby_html += "<td class='text-center'><a href=\"GameLobbyRoom.aspx?GameLobbyId=" + gameLobby.GameLobbyId + "\" class=\"btn btn-sm btn-success\">Join</a></td>";
<%
    }
    else
    {
%>
                lobby_html += "<td class='text-center'><a onclick=\"alert('You must create a Player before joining a game');\" class=\"btn btn-sm btn-danger\">Join</a></td>";
<%
    }
%>
                lobby_html += "</tr>";
            }

            // no game lobbies present
            if(_lobbies.length == 0) {
                lobby_html = "<tr><td colspan='4'>No game lobbies found</td></tr>";
            }

            // update game lobby table
            $(".game-lobbies").html(lobby_html);

            // update total number of lobbies
            $(".total-num-lobbies").html(_lobbies.length);
        };

        // gameId of game in progress (if any)
        var gameId = <%= (GameInProgress != null) ? GameInProgress.GameId : 0 %>;

        // active player id
        var playerId = <%= (UserSession != null) ? UserSession.PlayerId : 0 %>;

        function joinGame() {
            window.location = "Play.aspx?GameId=" + gameId;

            return false;
        }

        function quitGame() {
            // close game in progress
            $("#gameInProgressModal").modal('hide');

            if(isConnected) {
                // quit game
                hub.server.quitGame(playerId, gameId);
            }
        }

        function cancelGame() {
            // close game in progress
            $("#gameInProgressModal").modal('hide');

            if(isConnected) {
                // cancel game
                hub.server.cancelGame(playerId, gameId);
            }
        }
    </script>
    <!-- viewport settings for mobile -->
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1,maximum-scale=1" >
</asp:Content>
<asp:Content ID="ContentMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="page-header hidden-xs" style="margin-top: 14px;">
            <h1 id="WelcomeTitle" runat="server">Welcome, guest!</h1>
        </div>
        <div class="col-sm-6">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <strong>Getting started</strong>
                </div>
                <ul class="list-group">
                    <% if (UserPlayers != null && UserPlayers.Length == 0)
                       { %>
                    <li class="list-group-item">
                        <button class="btn btn-lg btn-primary btn-block" data-toggle="modal" data-target="#newPlayerModal" onclick="return false;">
                            Create your Player
                       
                        </button>
                    </li>
                    <% } // UserPlayers %>
                    <li class="list-group-item">
                        <a class="btn btn-lg btn-default btn-block" href="HostGame.aspx">Host Game
                        </a>
                    </li>
                    <!--
                    <li class="list-group-item">
                        <a class="btn btn-lg btn-default btn-block" href="AvailableGames.aspx">
                            Join Game
                        </a>
                    </li>
                    -->
                </ul>
            </div>
        </div>
        <div class="col-sm-6">
            <!-- available games -->
            <div class="panel panel-default">
                <div class="panel-heading">
                    <strong>Available games to join</strong>
                </div>
                <table class="table table-hover" style="width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 40%;">Lobby</th>
                            <th class="text-center" style="width: 40%;">Host</th>
                            <th class="text-center" style="width: 20%;">Players</th>
                            <th>&nbsp;</th>
                        </tr>
                    </thead>
                    <tbody class="game-lobbies">
                        <%= ListGameLobbiesHtml() %>
                    </tbody>
                </table>
                <style type="text/css">
                    .game-lobbies tr td {
                        vertical-align: middle !important;
                    }
                </style>
            </div>
            <!-- match history -->
            <div class="panel panel-default">
                <div class="panel-heading">
                    <strong>Match history</strong>
                </div>
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Game</th>
                            <th class="text-center">Date</th>
                            <th class="text-center">Score</th>
                            <th class="text-center">Result</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= ListMatchHistoryHtml() %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="modal fade" id="newPlayerModal" tabindex="-1" role="dialog" aria-labelledby="newPlayerModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                    <h4 class="modal-title" id="newPlayerModalLabel">New player</h4>
                </div>
                <div class="modal-body">
                    <p class="alert alert-info"><span class="glyphicon glyphicon-info-sign"></span>Please enter some information about your player.</p>
                    <div class="form-group">
                        <label for="recipient-name" class="control-label">Name</label>
                        <asp:TextBox ID="PlayerName" CssClass="form-control" runat="server" />
                    </div>
                    <!--
                    <div class="form-group">
                        <label for="message-text" class="control-label">Voice pack</label>
                        <asp:DropDownList ID="VoicePackList" runat="server" CssClass="form-control">
                            <asp:ListItem Text="Rob" Value="rob"></asp:ListItem>
                            <asp:ListItem Text="Dexter" Value="dexter"></asp:ListItem>
                            <asp:ListItem Text="Scott" Value="scott"></asp:ListItem>
                            <asp:ListItem Text="Kevin" Value="kevin"></asp:ListItem>
                            <asp:ListItem Text="Tony" Value="tony"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    -->
                    <div class="form-group">
                        <label for="message-text" class="control-label">Photo</label>
                        <asp:FileUpload ID="PlayerPhoto" CssClass="form-control" runat="server" />
                    </div>
                    <div class="checkbox" id="UseFacebookProfilePhoto" runat="server">
                        <label>
                            <asp:CheckBox ID="cbUseFacebookPhoto" runat="server" OnClick="selectUseFacebookPhoto();" />
                            Use profile photo from Facebook
                           
                            <input type="hidden" id="txtFacebookPhotoUrl" name="txtFacebookPhotoUrl" runat="server" value="" />
                        </label>
                    </div>
                    <div class="form-group facebook-photo-preview hidden">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal" onclick="return false;">Close</button>
                    <asp:Button ID="btnNewPlayer" runat="server" CssClass="btn btn-primary" Text="Create player" OnClick="btnNewPlayer_Click" />
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="gameInProgressModal" tabindex="-1" role="dialog" aria-labelledby="gameInProgressModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="gameInProgressModalLabel">You have a game in progress!</h4>
                </div>
                <div class="modal-body">
                    <div>
                        <input type="button" class="btn btn-lg btn-block btn-primary" value="Rejoin game" onclick="joinGame(); return false;" />
                        <% 
                        // player is the game host
                        if(GameInProgress != null && GameInProgress.OwnerPlayerId == UserSession.PlayerId) {
                        %>
                        <input type="button" class="btn btn-lg btn-block btn-danger" value="Cancel game" onclick="cancelGame(); return false;" />
                        <% } else { %>
                        <input type="button" class="btn btn-lg btn-block btn-danger" value="Quit game" onclick="quitGame(); return false;" />
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        $(document).ready(function() {
            // game in progress modal
            $("#gameInProgressModal").modal({
                backdrop: 'static',
                keyboard: false,
                show: false
            });

            $('#newPlayerModal').on('show.bs.modal', function (event) {
                // load profile picture url from facebook (if signed in)
                getFacebookPictureURL();

                var button = $(event.relatedTarget); // Button that triggered the modal
                var modal = $(this);
            });
 
            <%
            // show game in progress modal
            if (GameInProgress != null && GameInProgress.GameId > 0)
            {
                Response.Write("setTimeout(function() { $('#gameInProgressModal').modal('show'); }, 1000);");
            }
            %>
        });
    </script>
</asp:Content>
