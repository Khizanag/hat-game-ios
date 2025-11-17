//
//  SettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppConfiguration.self) private var appConfiguration

    @SceneStorage("SettingsView.isTestModeExpanded") private var isTestModeExpanded = false
    @SceneStorage("SettingsView.isDefaultsExpanded") private var isDefaultsExpanded = true
    @SceneStorage("SettingsView.isAboutExpanded") private var isAboutExpanded = true
    @SceneStorage("SettingsView.isDeveloperInfoExpanded") private var isDeveloperInfoExpanded = true
    
    var body: some View {
        content
            .setDefaultStyle(title: "Settings")
    }
}

private extension SettingsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                defaultsCard
                aboutCard
                developerInfoCard
                testModeCard
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
    }
    
    var testModeCard: some View {
        FoldableCard(
            isExpanded: $isTestModeExpanded,
            title: "Test Mode",
            icon: "flask",
            titleFont: DesignBook.Font.headline
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Toggle(
                    isOn: Binding(
                        get: { appConfiguration.isTestMode },
                        set: { handleTestModeChange($0) }
                    )
                ) {
                    Text("Prefill teams, players, and sample words so you can explore the flow instantly. You can still edit everything after enabling it.")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
                .toggleStyle(SwitchToggleStyle(tint: DesignBook.Color.Text.accent))
            }
        }
    }
    
    var defaultsCard: some View {
        FoldableCard(
            isExpanded: $isDefaultsExpanded,
            title: "Default Game Settings",
            icon: "slider.horizontal.3"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("These settings will be used as defaults when starting a new game. You can always change them during game setup.")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                
                defaultWordsPerPlayerSection
                
                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))
                
                defaultRoundDurationSection
            }
        }
    }
    
    var defaultWordsPerPlayerSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            HStack {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "text.bubble")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)
                    
                    Text("Default Words per Player")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
                
                Spacer()
                
                Text("\(appConfiguration.defaultWordsPerPlayer)")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
            
            Stepper(
                value: Binding(
                    get: { appConfiguration.defaultWordsPerPlayer },
                    set: { appConfiguration.defaultWordsPerPlayer = $0 }
                ),
                in: 3...20
            ) {
                Text("Adjust the default number of words each player should add")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }
    
    var defaultRoundDurationSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            HStack {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "timer")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)
                    
                    Text("Default Round Duration")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
                
                Spacer()
                
                Text("\(appConfiguration.defaultRoundDuration)s")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
            
            Stepper(
                value: Binding(
                    get: { appConfiguration.defaultRoundDuration },
                    set: { appConfiguration.defaultRoundDuration = $0 }
                ),
                in: 5...120,
                step: 5
            ) {
                Text("Adjust the default timer duration for each team's turn")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }
    
    var aboutCard: some View {
        FoldableCard(
            isExpanded: $isAboutExpanded,
            title: "About",
            icon: "info.circle"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                appInfoSection
                
                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))
                
                versionSection
            }
        }
    }
    
    var appInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("Hat Game")
                .font(DesignBook.Font.title3)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Text("A fun word guessing game where teams compete across multiple rounds with different rules. Perfect for parties and gatherings!")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    var versionSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            if let version = appVersion {
                HStack {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "number")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.tertiary)
                        
                        Text("Version")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                    
                    Spacer()
                    
                    Text(version)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
            }
            
            if let build = appBuild {
                HStack {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.tertiary)
                        
                        Text("Build")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                    
                    Spacer()
                    
                    Text(build)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
            }
        }
    }
    
    var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    var developerInfoCard: some View {
        FoldableCard(
            isExpanded: $isDeveloperInfoExpanded,
            title: "Developer Info",
            icon: "person.circle"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                developerHeader
                
                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))
                
                developerAboutSection
                
                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))
                
                technologiesSection
                
                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))
                
                contactSection
            }
        }
    }
    
    var developerHeader: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            Text("HatGame")
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Text("Created by Giga Khizanishvili")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    var developerAboutSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("About")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Text("HatGame is a modern take on the classic party game. It focuses on fast rounds, simple onboarding, and bright visuals powered by DesignBook.")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    var technologiesSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("Technologies")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                bullet("SwiftUI + Observation")
                bullet("Custom navigation system")
                bullet("DesignBook design tokens")
            }
        }
    }
    
    var contactSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            HStack(spacing: DesignBook.Spacing.sm) {
                Image(systemName: "envelope")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.accent)
                
                Text("Contact")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
            }
            
            Text("Feel free to reach out on GitHub: @gigakhizanishvili")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignBook.Spacing.sm) {
            Circle()
                .fill(DesignBook.Color.Text.accent)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    func handleTestModeChange(_ enabled: Bool) {
        appConfiguration.isTestMode = enabled
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.settings.view()
    }
    .environment(AppConfiguration())
}

