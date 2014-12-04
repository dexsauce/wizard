﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json;

namespace WizardGame.Helpers
{
    public class GameState
    {
        public int GameId = 0;
        public int Round = 0;
        public int Turn = 0;
        public int DealerPositionIndex = 0;
        public int PlayerTurnIndex = 0;
        public int LastToActIndex = 0;
        public Player[] Players = null;
        public Card[] CardsPlayed = null;
        public GameStateStatus Status = GameStateStatus.Setup;
        public Deck Deck = null;
        public ScoreCard scoreCard = null;
        public Card TrumpCard = null;
        public Suit SuitToFollow = Suit.None;
        public PlayerScore[] PlayerScores;

        public GameState()
        {
            // new score card
            scoreCard = new ScoreCard();

            // generate new deck
            Deck = new Deck();
        }

        public PlayerScore[] GetPlayerScoreByRound(int round)
        {
            if (scoreCard.PlayerScores == null)
                return null;

            return scoreCard.PlayerScores.
                Where(ps => ps.Round == round).
                ToArray();
        }

        public void ClearTurnFlags()
        {
            if (Players != null && Players.Length > 0)
            {
                for (int i = 0; i < Players.Length; i++)
                {
                    Players[i].IsTurn = false;
                    Players[i].IsLastToAct = false;
                }
            }
        }

        public void ClearAllFlags()
        {
            if (Players != null && Players.Length > 0)
            {
                for (int i = 0; i < Players.Length; i++)
                {
                    Players[i].IsTurn = false;
                    Players[i].IsDealer = false;
                    Players[i].IsLastToAct = false;
                }
            }
        }

        public void ClearBidsAndTricks()
        {
            if (Players != null && Players.Length > 0)
            {
                for (int i = 0; i < Players.Length; i++)
                {
                    Players[i].Bid = 0;
                    Players[i].TricksTaken = 0;
                }
            }
        }

        public void AddScoreEntries()
        {
            if (Players != null && Players.Length > 0)
            {
                for (int i = 0; i < Players.Length; i++)
                {
                    Player player = Players[i];

                    // add score card entry
                    scoreCard.AddPlayerScore(player.PlayerId, Round, player.Bid, player.TricksTaken);

                    int total_score = 0;

                    // add scores from each round to calculate total
                    for (int x = 0; x < scoreCard.PlayerScores.Length; x++)
                    {
                        var playerScore = scoreCard.PlayerScores[x];

                        if (playerScore.PlayerId == player.PlayerId)
                        {
                            total_score += playerScore.Score;
                        }
                    }

                    // clear entries
                    player.Bid = 0;
                    player.TricksTaken = 0;
                    player.Score = total_score;
                }

                // update player scores
                PlayerScores = scoreCard.PlayerScores;
            }
        }

        public bool HasRoundEnded()
        {
            if (Players != null)
            {
                // loop through players
                for (int i = 0; i < Players.Length; i++)
                {
                    // round has not ended if player still has cards
                    if (Players[i].HasCards())
                        return false;
                }
            }

            return true;
        }

        public bool PlayCard(int playerId, Card card)
        {
            // get player object
            Player player = Players.Where(p => p.PlayerId == playerId).FirstOrDefault();

            // validate
            if (player != null && player.PlayerId > 0)
            {
                // play card
                Card playedCard = player.PlayCard(card);

                if(playedCard == null)
                    return false;

                // update turn flag
                player.IsTurn = false;

                // get cards played list
                List<Card> cardsPlayedList = (CardsPlayed == null) ? 
                    new List<Card>() : CardsPlayed.ToList();

                // if no suit to follow has been set, next card can potentially be the leading suit
                if (SuitToFollow == Suit.None)
                {
                    if (card.Suit == Suit.Fluff)
                        SuitToFollow = Suit.None;
                    else if (card.Suit == Suit.Wizard)
                        SuitToFollow = Suit.Wizard; 
                }
                                    
                // add card to played pile
                cardsPlayedList.Add(card);

                // replace array
                CardsPlayed = cardsPlayedList.ToArray();

                // check if last player
                if (PlayerTurnIndex == LastToActIndex)
                {
                    // update status
                    Status = GameStateStatus.TurnEnded;

                    // increment turn #
                    Turn++;

                    // validate turn #
                    if (Turn > Round)
                        Turn = Round;
                }
                else
                {
                    // next player turn
                    PlayerTurnIndex++;

                    if (PlayerTurnIndex > Players.Length - 1)
                        PlayerTurnIndex = 0;

                    // update turn flag
                    Players[PlayerTurnIndex].IsTurn = true;
                }

                // clear list
                cardsPlayedList = null;
            }

            return true;
        }

        public void EnterBid(int playerId, int bid)
        {
            // get player object
            Player player = Players.Where(p => p.PlayerId == playerId).FirstOrDefault();

            // validate
            if (player != null && player.PlayerId > 0)
            {
                // set bid
                player.Bid = bid;

                // set flag
                player.IsTurn = false;

                // check if last player to bid
                if (PlayerTurnIndex == DealerPositionIndex)
                {
                    // done bidding, start round
                    Status = GameStateStatus.RoundInProgress;
                }

                // update player turn index
                PlayerTurnIndex++;

                if (PlayerTurnIndex > Players.Length - 1)
                    PlayerTurnIndex = 0;

                // update next player turn flag
                Players[PlayerTurnIndex].IsTurn = true;
            }  
        }

        public bool StartNextRound()
        {
            // validation
            if (Players == null)
                return false;

            // reset cards played
            CardsPlayed = null;

            // max rounds
            int maxRounds = (60 / Players.Length);

            if (Round > maxRounds)
                return false;

            // increment rounds
            Round++;

            // set turn #
            Turn = 1;

            // new deck
            Deck = new Deck();

            // clear turn flags
            ClearAllFlags();

            // clear existing bids
            ClearBidsAndTricks();

            // next dealer
            DealerPositionIndex++;

            if (DealerPositionIndex > Players.Length - 1)
                DealerPositionIndex = 0;

            // set flag
            Players[DealerPositionIndex].IsDealer = true;

            // next player turn
            PlayerTurnIndex = DealerPositionIndex + 1;

            if (PlayerTurnIndex > Players.Length - 1)
                PlayerTurnIndex = 0;

            // set flag
            Players[PlayerTurnIndex].IsTurn = true;

            // last to act flag
            LastToActIndex = DealerPositionIndex;

            Players[LastToActIndex].IsLastToAct = true;

            // set game status
            Status = GameStateStatus.DealInProgress;

            // get number of cards to deal
            int numCardsToDeal = (Round * Players.Length);

            // current index
            int currentIndex = PlayerTurnIndex;

            // deal cards
            for (int i = 0; i < numCardsToDeal; i++)
            {
                // take top card from deck
                Card topCard = Deck.TakeTopCard();

                // give to player
                Players[currentIndex].ReceiveCard(topCard);

                // increment index
                currentIndex++;

                // back to 0 when we reach last player
                if (currentIndex > Players.Length - 1)
                    currentIndex = 0;
            }

            // set game status
            Status = GameStateStatus.BiddingInProgress;

            // update trump card if cards remain
            if (Deck.Cards != null && Deck.Cards.Length > 0)
            {
                // determine trump
                TrumpCard = Deck.TakeTopCard();

                // check if trump must be determined
                if (TrumpCard.Suit == Suit.Wizard)
                {
                    Status = GameStateStatus.SelectTrump;
                }
            }

            return true;
        }

        public void StartGame(Player[] _players)
        {
            // validate players
            if(_players == null || _players.Length < 3)
                throw new Exception("3 players minimum required to play");

            // reset cards played
            CardsPlayed = null;

            // update players
            Players = _players;

            // determine random dealer position
            Random random = new Random();

            // assign dealer index
            DealerPositionIndex = random.Next(0, Players.Length - 1);
            
            // set flag
            Players[DealerPositionIndex].IsDealer = true;

            // get player turn index
            PlayerTurnIndex = DealerPositionIndex + 1;

            if (PlayerTurnIndex > Players.Length - 1)
                PlayerTurnIndex = 0;

            // set flag
            Players[PlayerTurnIndex].IsTurn = true;

            // set last to act flag
            LastToActIndex = DealerPositionIndex;

            Players[LastToActIndex].IsLastToAct = true;

            // set round #
            Round = 1;

            // set turn #
            Turn = 1;

            // set game status
            Status = GameStateStatus.DealInProgress;

            // get number of cards to deal
            int numCardsToDeal = (Round * Players.Length);

            // current index
            int currentIndex = PlayerTurnIndex;

            // deal cards
            for (int i = 0; i < numCardsToDeal; i++)
            {
                // take top card from deck
                Card topCard = Deck.TakeTopCard();

                // give to player
                Players[currentIndex].ReceiveCard(topCard);

                // increment index
                currentIndex++;

                // back to 0 when we reach last player
                if (currentIndex > Players.Length - 1)
                    currentIndex = 0;
            }

            // update trump card
            TrumpCard = Deck.TakeTopCard();
                
            // set game status
            Status = GameStateStatus.BiddingInProgress;

            // check if trump must be determined
            if (TrumpCard.Suit == Suit.Wizard)
            {
                Status = GameStateStatus.SelectTrump;
            }
        }

        public Player GetPointLeader()
        {
            Player pointLeader = Players.OrderByDescending(p => p.Score).FirstOrDefault();

            return pointLeader;
        }
    }

    public enum GameStateStatus
    {
        DealInProgress = 0,
        BiddingInProgress = 1,
        RoundInProgress = 2,
        Setup = 3,
        Finished = 4,
        TurnEnded = 5,
        SelectTrump = 6,
        RoundEnded = 7
    }
}