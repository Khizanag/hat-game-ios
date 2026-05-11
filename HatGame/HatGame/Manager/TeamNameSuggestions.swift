//
//  TeamNameSuggestions.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.05.26.
//

import Foundation

/// Curated, party-friendly team-name suggestions used as inspiration in the team form.
/// Tone: playful, punny, and on-theme for a word-guessing game. Avoids offensive content.
enum TeamNameSuggestions {
    static func random(count: Int = 4) -> [String] {
        Array(all.shuffled().prefix(count))
    }

    static let all: [String] = [
        // Word / hat / game-themed
        "The Hat Trick",
        "Word Wizards",
        "Mind Readers",
        "Charade Chasers",
        "Word Nerds",
        "Hat Heads",
        "Brain Storm",
        "The Mime Crew",
        "Guess Who",
        "Wordsmiths",

        // Punny
        "Inglorious Speakers",
        "Quiztopher Walken",
        "Smarty Pants",
        "The Win Doors",
        "The Hat Pack",
        "Sherlock Homies",
        "Hocus Focus",
        "Quick Wits",
        "Vocab Vandals",
        "Pun-ic War",

        // Animal-themed
        "Howling Wolves",
        "Quokka Stars",
        "Wise Owls",
        "Fierce Foxes",
        "Penguin Posse",
        "Roaring Lions",
        "Bunny Brains",
        "Otter Geniuses",
        "Hippo Squad",
        "Koala-fied",

        // Food-themed
        "Spice Squad",
        "Pizza Slayers",
        "Taco 'bout Words",
        "Pretzel Logic",
        "Hot Sauce",
        "Hummus Heroes",
        "Donut Worry",
        "Soup Stars",
        "Mango Mob",
        "Sushi Roll Call",

        // Pop-culture nods
        "Stranger Strings",
        "Game of Phrases",
        "Friends with Words",
        "The Office Party",
        "Breaking Word",
        "The Hat-fields",
        "Lord of the Phrases",
        "Mission Impossi-word",
        "Avengers Assemble",
        "Star Words",

        // Tech / modern
        "Ctrl+Alt+Defeat",
        "The Algorithm",
        "Cache Money",
        "Beta Testers",
        "Pixel Perfect",
        "The Update",
        "Cookie Clickers",
        "Glitch Mob",
        "Wi-Fi Wonders",
        "Bit by Bit",

        // General funny
        "The Underdogs",
        "Bad Spellers Untie",
        "The Procrastinators",
        "Highly Unmotivated",
        "Couch Crusaders",
        "The Nappers",
        "Tactical Bananas",
        "Chaos Coordinators",
        "The Dream Team",
        "Plan B",

        // Sports parody
        "Slow Pokes",
        "Bench Warmers",
        "Yardstick Yetis",
        "Casual Friday",
        "Last Picks",
        "Marathon Sitters",
        "Athlete's Foot Note",
        "Time Outs",
        "Half-Time Heroes",
        "Game Over",

        // Tongue-in-cheek
        "We're With Smarty",
        "Last Place Champions",
        "Loose Cannons",
        "Backseat Drivers",
        "Comically Late",
        "Punday Funday",
        "Question Marks",
        "What Knots",
        "We Got This (Maybe)",
        "The Probably's",

        // Random brilliance
        "Loose Lips",
        "Word Vomit",
        "Hat in Hand",
        "Whisper Whisperers",
        "Charade Charioteers",
        "Guess-tastic",
        "Word Slingers",
        "Phrase Phantoms",
        "Mystery Mob",
        "Brain Trusts",
    ]
}
