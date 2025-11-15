//
//  NextTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct NextTeamView: View {
    let team: Team
    let teamIndex: Int
    let round: GameRound
    let wordsRemaining: Int
    let explainingPlayer: Player
    let guessingPlayer: Player
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignBook.Spacing.xl) {
                Spacer()
                
                VStack(spacing: DesignBook.Spacing.lg) {
                    Text("🎯")
                        .font(.system(size: 80))
                    
                    Text("Next Team")
                        .font(DesignBook.Font.largeTitle)
                        .foregroundColor(DesignBook.Color.Text.primary)
                    
                    GameCard {
                        VStack(spacing: DesignBook.Spacing.md) {
                            Text(team.name)
                                .font(DesignBook.Font.title2)
                                .foregroundColor(DesignBook.Color.Team.color(for: teamIndex))
                            
                            Text("Current Score: \(team.score)")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    
                    GameCard {
                        VStack(spacing: DesignBook.Spacing.md) {
                            Text("Round Status")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            Text("\(round.title)")
                                .font(DesignBook.Font.title3)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                            
                            Text("Words remaining: \(wordsRemaining)")
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    
                    GameCard {
                        VStack(spacing: DesignBook.Spacing.md) {
                            Text("Team Roles")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            VStack(spacing: DesignBook.Spacing.sm) {
                                HStack {
                                    Image(systemName: "person.wave.2.fill")
                                        .foregroundColor(DesignBook.Color.Text.accent)
                                    Text("Explaining:")
                                        .font(DesignBook.Font.body)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                    Spacer()
                                    Text(explainingPlayer.name)
                                        .font(DesignBook.Font.bodyBold)
                                        .foregroundColor(DesignBook.Color.Text.primary)
                                }
                                
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(DesignBook.Color.Text.accent)
                                    Text("Guessing:")
                                        .font(DesignBook.Font.body)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                    Spacer()
                                    Text(guessingPlayer.name)
                                        .font(DesignBook.Font.bodyBold)
                                        .foregroundColor(DesignBook.Color.Text.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                }
                
                Spacer()
                
                PrimaryButton(title: "Start Turn") {
                    onContinue()
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.bottom, DesignBook.Spacing.lg)
            }
        }
    }
}

#Preview {
    let team = Team(name: "Team Beta", players: [
        Player(name: "Alice", teamId: UUID()),
        Player(name: "Bob", teamId: UUID())
    ])
    return NextTeamView(
        team: team,
        teamIndex: 1,
        round: .one,
        wordsRemaining: 15,
        explainingPlayer: team.players[0],
        guessingPlayer: team.players[1],
        onContinue: {}
    )
}

