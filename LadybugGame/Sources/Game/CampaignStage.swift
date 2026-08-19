import CoreGraphics

/// A finite Adventure level. Score is intentionally a mastery target, never an
/// unlock requirement; completing the travel objective unlocks the next stage.
struct CampaignStage: Identifiable, Sendable {
    let id: Int
    let biome: Biome
    let objective: String
    let targetDistance: CGFloat
    let masteryScore: Int
    let bossLevel: Int?

    var number: Int { id + 1 }
    var isBossStage: Bool { bossLevel != nil }
    var chapter: Int {
        if id <= 5 { return 1 }
        if id <= 10 { return 2 }
        return 3
    }

    var firstClearReward: Int {
        8 + number * 2 + (isBossStage ? 20 : 0)
    }

    static let all: [CampaignStage] = [
        CampaignStage(id: 0, biome: .meadowDay, objective: "Collect snacks and learn the warning signs.", targetDistance: 11_000, masteryScore: 500, bossLevel: nil),
        CampaignStage(id: 1, biome: .meadowNight, objective: "Follow the glow and survive the night hunters.", targetDistance: 11_500, masteryScore: 550, bossLevel: nil),
        CampaignStage(id: 2, biome: .desert, objective: "Cross the dunes without getting cornered.", targetDistance: 12_000, masteryScore: 600, bossLevel: nil),
        CampaignStage(id: 3, biome: .snow, objective: "Keep moving through the frozen wind.", targetDistance: 12_500, masteryScore: 650, bossLevel: nil),
        CampaignStage(id: 4, biome: .jungle, objective: "Read the canopy and dodge ambushes.", targetDistance: 13_000, masteryScore: 700, bossLevel: nil),
        CampaignStage(id: 5, biome: .cave, objective: "Reach the den and defeat Bramble Bear.", targetDistance: 13_500, masteryScore: 750, bossLevel: 1),
        CampaignStage(id: 6, biome: .underwater, objective: "Find friendly sea life among the predators.", targetDistance: 14_000, masteryScore: 800, bossLevel: nil),
        CampaignStage(id: 7, biome: .volcano, objective: "Outrun the fire ants and lava hunters.", targetDistance: 14_500, masteryScore: 850, bossLevel: nil),
        CampaignStage(id: 8, biome: .cloud, objective: "Ride the pink sky currents between storms.", targetDistance: 15_000, masteryScore: 900, bossLevel: nil),
        CampaignStage(id: 9, biome: .swamp, objective: "Navigate the fog before threats close in.", targetDistance: 15_500, masteryScore: 950, bossLevel: nil),
        CampaignStage(id: 10, biome: .city, objective: "Master the bug magnet and defeat Stormfeather.", targetDistance: 16_000, masteryScore: 1_000, bossLevel: 2),
        CampaignStage(id: 11, biome: .ruins, objective: "Escape the guardians of the old temple.", targetDistance: 16_500, masteryScore: 1_050, bossLevel: nil),
        CampaignStage(id: 12, biome: .mushroom, objective: "Separate glowing snacks from toxic spores.", targetDistance: 17_000, masteryScore: 1_100, bossLevel: nil),
        CampaignStage(id: 13, biome: .crystal, objective: "Cross the caverns without touching the shards.", targetDistance: 17_500, masteryScore: 1_150, bossLevel: nil),
        CampaignStage(id: 14, biome: .space, objective: "Board the final arena and stop the Void Harvester.", targetDistance: 18_000, masteryScore: 1_200, bossLevel: 3),
    ]

    static func stage(id: Int) -> CampaignStage? {
        all.first { $0.id == id }
    }
}
