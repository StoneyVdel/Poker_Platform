using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public partial class Program : Node
{
	/*
		 * Suits: clubs (♣), diamonds (♦), hearts (♥) and spades (♠).
		 * Cards are represented like this: [Value as String, Suit as String],
		 * For example: ["3", "Diamond"], ["12", "Heart"]
		 * 
		 * NOTE: special values: 11 - Joker, 12 - Queen, 13 - King, 14 - Ace
		 */
		public double U1rank { get; set; }
		public double U2rank { get; set; }
		public string U1rankName { get; set; }
		public string U2rankName { get; set; }
		//public Room room = new Room()
		static List<string[]> CardsFromGodot = new List<string[]>();
		static List<string[]> CardsForUser1 = new List<string[]>();
		static List<string[]> CardsForUser2 = new List<string[]>();

		public void AddCardsToUser1(string[] arr)
		{
			CardsForUser1.Add(arr);
			
		}
		public void AddCardsToUser2(string[] arr)
		{
			CardsForUser2.Add(arr);
			
		}
		public void AssignStringArray(string[] arr)
		{
			CardsFromGodot.Add(arr);
		}
		
		public void TestProgram()
		{
			foreach (string[] o in CardsFromGodot)
			{
				GD.Print(o);
			}
			Room room = new Room
			{
				RoomName = "Test Room",
				CardsOnTable = new List<string[]>(CardsFromGodot)
			};
			ApplicationUser user1 = new ApplicationUser
			{
				Name = "A",
				PlayerCards = new List<string[]> (CardsForUser1),
				Chips = 0
			};
			ApplicationUser user2 = new ApplicationUser
			{
				Name = "B",
				PlayerCards = new List<string[]> (CardsForUser2),
				Chips = 0
			};
			ApplicationUser user3 = new ApplicationUser
			{
				Name = "C",
				PlayerCards = new List<string[]>
				{
					new string[]{"14", "Diamond"},
					new string[]{"4", "Spade"},
				},
				Chips = 0
			};

			ApplicationUser user4 = new ApplicationUser
			{
				Name = "D",
				PlayerCards = new List<string[]>
				{
					new string[]{"14", "Spade"},
					new string[]{"3", "Heart"},
				},
				Chips = 0
			};

			room.Chair0 = user1;
			room.Chair2 = user2;
			room.Chair3 = user3;
			room.Chair4 = user4;

			room.PotOfChair0 = 25;
			room.PotOfChair2 = 50;
			room.PotOfChair3 = 100;
			room.PotOfChair4 = 100;


			var result = room.SpreadMoneyToWinners();

			U1rank = (room.GetPlayerHandRank(user1)).Rank;
			U2rank = (room.GetPlayerHandRank(user2)).Rank;
			GD.Print(U1rank +" "+ U2rank );
			
			U1rankName = (room.GetPlayerHandRank(user1)).RankName;
			U2rankName = (room.GetPlayerHandRank(user2)).RankName;
			GD.Print(U1rankName +" "+ U2rankName );

		}
}
