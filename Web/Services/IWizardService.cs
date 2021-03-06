﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using WizardGame.Helpers;

namespace WizardGame.Services
{
    [ServiceContract]
    public interface IWizardService
    {
        // Business Logic
        [OperationContract]
        bool EmailExists(string emailAddress);

        [OperationContract]
        bool UsernameExists(string username);

        [OperationContract]
        Session Login(string username, string password, string ipAddress);

        [OperationContract]
        Session FacebookLogin(string fb_email, string fb_userId);

        [OperationContract]
        NewUserResult NewUser(string username, string password, string emailAddress, bool active = true);

        void LogError(Exception ex);

        [OperationContract]
        Session ValidateSession(string secret);

        // Deletes
        [OperationContract]
        void DeleteSession(string secret);

        [OperationContract]
        void DeleteOldSessions(int maxDays = 3);

        [OperationContract]
        void DeleteGameLobbyById(int gameLobbyId);

        [OperationContract]
        void DeletePlayerFromGame(int playerId, int gameId, string connectionId);

        [OperationContract]
        void DeletePlayerFromGameLobby(int playerId, int gameLobbyId, string connectionId);

        // Gets
        [OperationContract]
        Game GetGameByConnectionId(string connectionId);

        [OperationContract]
        Game GetGameByGameLobbyId(int gameLobbyId);

        [OperationContract]
        Game GetGameById(int gameId);

        [OperationContract]
        GameLobby GetGameLobbyByConnectionId(string connectionId);

        [OperationContract]
        GameLobby GetGameLobbyById(int gameLobbyId);

        [OperationContract]
        GameLobbyPlayers GetGameLobbyPlayersByConnectionId(string connectionId);

        [OperationContract]
        GameLobbyPlayers GetGameLobbyPlayersByGameLobbyIdAndPlayerId(int gameLobbyId, int playerId);

        [OperationContract]
        GamePlayers GetGamePlayersByConnectionId(string connectionId);

        [OperationContract]
        GamePlayers GetGamePlayersByGameIdAndPlayerId(int gameId, int playerId);

        [OperationContract]
        GameHistory GetGameHistoryByGameId(int gameId);

        [OperationContract]
        GameHistory GetGameHistoryById(int gameHistoryId);

        [OperationContract]
        HandHistory[] GetHandHistoryByGameId(int gameId);

        [OperationContract]
        HandHistory GetHandHistoryById(int handHistoryId);

        [OperationContract]
        HandHistory GetLastHandHistoryByGameId(int gameId);

        [OperationContract]
        Game GetLatestGameByPlayerId(int playerId);

        [OperationContract]
        Player GetPlayerByConnectionId(string connectionId);

        [OperationContract]
        Player GetPlayerById(int playerId);

        [OperationContract]
        Player GetPlayerByName(string name);

        [OperationContract]
        Session GetSessionBySecret(string secret);

        [OperationContract]
        User GetUserById(int userId);

        [OperationContract]
        User GetUserByUsername(string username);

        // Lists
        [OperationContract]
        Player[] ListPlayersByUserId(int userId);

        [OperationContract]
        Player[] ListPlayersByGameLobbyId(int gameLobbyId);

        [OperationContract]
        Player[] ListPlayersByGameId(int gameId);

        [OperationContract]
        GameLobby[] ListAllGameLobbies(bool showInProgress);
        
        [OperationContract]
        GameHistoryStats[] ListGameHistoryStatsByPlayerId(int playerId);

        [OperationContract]
        Player[] ListLeaderboardPlayers();

        // Updates
        [OperationContract]
        Game UpdateGame(int gameId, int gameLobbyId, int ownerPlayerId, DateTime? dateCompleted, GameState gameState, string groupNameId);

        [OperationContract]
        GameLobby UpdateGameLobby(int gameLobbyId, int ownerPlayerId, string name, int maxPlayers, string groupNameId, string password, bool inProgress);

        [OperationContract]
        GameLobbyPlayers UpdateGameLobbyPlayers(int gameLobbyId, int playerId, string connectionId, ConnectionState state);

        [OperationContract]
        GamePlayers UpdateGamePlayers(int gameId, int playerId, string connectionId, ConnectionState state);

        [OperationContract]
        GameHistory UpdateGameHistory(int gameHistoryId, int gameId, int playerId, int score, int won);

        [OperationContract]
        HandHistory UpdateHandHistory(int handHistoryId, int gameId, Card trumpCard, Suit suitToFollow, Card[] cardsPlayed, int winnerPlayerId, int round);

        [OperationContract]
        Player UpdatePlayer(int playerId, string name, string pictureUrl, int userId);

        [OperationContract]
        Session UpdateSession(string secret, int userId, int playerId, string connectionId);

        [OperationContract]
        User UpdateUser(int userId, string username, string password, string emailAddress, bool active, string fb_userId);
    }
}
