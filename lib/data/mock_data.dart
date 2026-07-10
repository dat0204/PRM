// lib/data/mock_data.dart
// SceneFlow - All mock data (converted from mockData.ts)

import '../models/project.dart';
import '../models/character.dart';
import '../models/location_item.dart';
import '../models/scene.dart';
import '../models/shooting_session.dart';

final List<Project> initialProjects = [
  const Project(
    id: 'long-goodbye',
    title: 'The Long Goodbye',
    description:
        'A modern hard-boiled detective noir story set in the rainy streets of Los Angeles. Detective Marlowe tries to solve a high-profile missing persons case that plunges him into the criminal underworld.',
    startDate: '2026-07-10',
    director: 'R. Chandler',
    type: ProjectType.feature,
    genre: ProjectGenre.noir,
    status: ProjectStatus.inProduction,
    progress: 45,
    thumbnailUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBVdodGU6285PDgY-9OmqnjdYcskXAWQ4PyDjtyOpneUMvNzUKs2RyPGbzwC9xbKIAfU7_ENyRQAakzLie1xoEXeRMz0m6fe1DyqQWV8VTGE0Qm-1GwER7wcVqdWZ0Lza10ud5X1vpS39LAT2Ifr0goRbg1ql4NHYbzRtp11rj-SXoAM4WwDKXiYveegZEdpt5d4Fc89azQEL5cCnvolvU51vKbnTVORcYYSPHEIv3EztrC5Gklo-WDgo-MrtvY1J3HY2rllak88Wo',
    codeName: 'SCN-104',
    acts: ['Act 1: The Setup', 'Act 2: The Confrontation', 'Act 3: The Resolution'],
  ),
  const Project(
    id: 'nebula-echoes',
    title: 'Nebula Echoes',
    description:
        'A cinematic sci-fi movie featuring a massive, glowing nebula in deep space. Silhouettes of a futuristic spacecraft are visible against the cosmic dust.',
    startDate: '2024-10-12',
    director: 'A. Tarkovsky',
    type: ProjectType.feature,
    genre: ProjectGenre.sciFi,
    status: ProjectStatus.inProduction,
    progress: 68,
    thumbnailUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB8V2aOzE7wJetPdWy6FNulsnSNdaXbjdR68VRS_TNf7A6O8xqkOeHMwAi6ckpYWKlSytlZfp_VNaj9uYECgjdQ9VhygyJBYOSZiE9b08sNooJDJFlPi33EFkt-XAX6m7ZpWflQYpwqnLFLH1SjkPMs9iCET9t4Z8Ey6Aft533EbWNgAYPsyvR7w_QRIJDjjLYFgvXh2nuYZRdDZVDFIpIKx8VRl2ZQikpka6_N2JVYJ8d-QfJIu5xzEnuhhsg3xLw6iw1qVK3oR6A',
    codeName: 'SCN-042',
    acts: ['Act 1: Space Departure', 'Act 2: The Nebula Signal', 'Act 3: Infinite Echoes'],
  ),
  const Project(
    id: 'silent-valley',
    title: 'The Silent Valley',
    description:
        'A dense, fog-covered forest valley at twilight. A moody, atmospheric cinematic drama exploring deep-seated family mysteries.',
    startDate: '2024-11-05',
    director: 'J. Campion',
    type: ProjectType.short,
    genre: ProjectGenre.drama,
    status: ProjectStatus.preProduction,
    progress: 12,
    thumbnailUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD3Dxb10bhvYsb-BM-8ShlP5HbItav7duwPSSxWGuEq84cqIANKTbnC7HEriCNuDEIA18N0WREwq2rB_G4rZnNf20BDWbXF-UOkHsQq70uLAly61CWTJFZ7GvkJy_5RL-fvo4rCAYCifUmqrQE1p9_N14U4qKyWw28USgAnCKNvLqE86VtfHgKCQ9FSS-Bf-v8q20pE_1o6feHQubMWMCnpXwfhx-Qp29wpllzMGwIcMLSE6ZbAk-M4LL4VjXRytIppi01e9HdNuQw',
    codeName: 'SCN-112',
    acts: ['Act 1: The Gathering', 'Act 2: Whispers in the Fog', 'Act 3: Silence Broken'],
  ),
  const Project(
    id: 'neon-rhapsody',
    title: 'Neon Rhapsody',
    description:
        'A gritty, urban movie depicting a rainy city street at night illuminated by scattered neon signs. High contrast, atmospheric thriller.',
    startDate: '2024-01-15',
    director: 'M. Mann',
    type: ProjectType.feature,
    genre: ProjectGenre.thriller,
    status: ProjectStatus.completed,
    progress: 100,
    thumbnailUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCLZp8eIRwTsj2lN1zrUa897SWXqQ0yjgFZHFDD2iPACX_eyoDvitJVBf2J-_HBMkOaANcg66Rpm_A7sg3wp2gcHsknDkDTwvGOEqTLxHJdZTadbmtnoiBRJ-ma0Zv4uSSUdKkuGSQWSMJUmtlEEbJw3bB8JVGGkTtiqIebFdXjhkS9zUzMtgFO6AYs3wn9aRNCs0FFZJJ0iAaMC6KXQWPAUVM6hzS-HkieHBXeI2ZhIgEteFrjBKhE2MDhCYX-C8pu80wTeKShi2A',
    codeName: 'SCN-001',
    acts: ['Act 1: Midnight Rain', 'Act 2: Neon Chase', 'Act 3: Final Symphony'],
  ),
];

final List<Character> initialCharacters = [
  const Character(
    id: 'marlowe',
    name: 'Julian Marlowe',
    role: CharacterRole.main,
    roleTitle: 'LEAD DETECTIVE',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuALijUqBTEDHuvXI0Tk_ZeyGqUh1oJjmbG3nyoPV5K9U3mseNB2Y6y9xD9LvDOVpI6zweOzxL3juffiFqCLgOm8I27lqc87-0VL7Og_ZWOSUdOsaW4KGWm509xzpy2Wb-VzsSoJ44b3ziqzEGWLuzIC9Zqzzf3_Yauuve22QSwizgYGHgRuRrkMJhmeRwFsT0PvTUX3g2XO51R4Fh6ULoExBkfKJpDSr3K86JPpYqntUOJTySyivfY-uq5IGTrCwYBmuo1lrFiZHFQ',
    psychologicalProfile:
        'Cynical, weathered, but guided by an unbreakable moral compass. Speaks in sharp, dry metaphors. A chain-smoker who watches the world collapse through glass blinds.',
  ),
  const Character(
    id: 'evelyn',
    name: 'Evelyn Thorne',
    role: CharacterRole.main,
    roleTitle: 'THE CLIENT / SUSPECT',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCsJoXD13WNPvnOKpWe84uAu5YPKSVc_GOsG5VQsNWMtcbszx-Pwv49f6Iw7dQ5jTckjBPkNZ-NH5_DZC0fSJxRD-hKftWdUCv5QV64ewSrkWqSBe2LFgBJVWNBRerkdWtJOEL4hA2rgyel45qPrpdyKuVTrSCXCUXUtvpO9fIGlxWjEy3LvWCI1JEL5sA_bdiP6__7xxQ9xxJ-BYXG7-SHdFAl0BmTSZoUJuL1Sg-VFfP3O6rW__PqrkYaQjBGucECPaMHkb2nBBc',
    psychologicalProfile:
        'Sophisticated, calculated, and anxious. She clutches her secrets tighter than her purse. Master of emotional manipulation, but genuinely fearful of the forces she unleashed.',
  ),
  const Character(
    id: 'elias',
    name: 'Elias Vance',
    role: CharacterRole.supporting,
    roleTitle: 'INFORMANT',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD4tma_hGH4Ka-1MlgtR6rxe2L9dnjBJDrmUHZ8mpUWq2Q_wYPkUgmUf0U_I2yIRTHIJTUuDZsGkTXrC0c3nBGxKtZUKsa7F37EaSaFH4YAvmrr0ZlbxM7g8o0xZJgmj08V3CtYLW7-Q0eM2ee6Nj3a-fcrqV_gf7YABNHPRYbknLNDAmsrlBNwGpYTlgl1KGqgaCkpPY8mwd-FUMw-l4VbyFGGj8jo5GZLagWWj-C7FH6XIu-1rbM9fnBtMA6oIdRuTE1IYGWmyiM',
    psychologicalProfile:
        'Spends his nights in the dark corners of Pier 39. Terrified of Silas but motivated by financial desperation. Always looks over his shoulder, speaks in rapid whispers.',
  ),
  const Character(
    id: 'silas',
    name: 'Silas Blackwood',
    role: CharacterRole.main,
    roleTitle: 'CRIME BOSS',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDWep88r3hF2k8T5-agsjN53HN-yiPBjG75ynU4FWbjeMtudLqqKLEkOPXErR3wYi_i7w6Ee8M4Xafd9Hrg-LvvFHnaObJKWR8rwfzXmTr6_KHHr6TW129TFBrukcCKlTomrcdoxoHrEMA24c_Z9N1Y3GJMehbY7nmsmHk3RWuDas7_93Ujm9oQL1DYpfwQo6eMs0xRztlGbE_wR_6cnbpHaJTB2LCPo6w8YrqDVr0cGvVrTPgAsc6XQiqItPXUjlhgL_DBK0pLw98',
    psychologicalProfile:
        'Authority in charcoal. Cold, soft-spoken, and infinitely dangerous. Runs the LA shipping ports. Views human relationships as commodities and lives as simple transactions.',
  ),
  const Character(
    id: 'cora',
    name: 'Cora Sterling',
    role: CharacterRole.supporting,
    roleTitle: "MAYOR'S DAUGHTER",
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDyTYlFUoOpzwqcacKH7RXhwyuMrbdPkARLucjWnWQ5M-vt2R7480kUBOl00l9XVtzNnAD20w0QYtgjzdSnuf5uLy633g5mJitfQIikLesgWhDvaOWhbFn4cWDtAD7n9iPzco-h2r4q9GXdtNeX6LwmFf8x8AGXLvPaCfBybDrvI_eM4Es3m4RtddKBOujw1ulFql2TsLuMef27t5KB_6SdOd1ORZTOhLui8tgkYdU9NW-aRYVlcGP_oercxAnT87rxHJ0rhQV5gjw',
    psychologicalProfile:
        "Intellectual, defiant, and deeply connected to the underground art scene. Refuses her father's protection and knows more about Silas than she lets on.",
  ),
  const Character(
    id: 'goon1',
    name: 'Mickey "The Goon"',
    role: CharacterRole.extra,
    roleTitle: 'HENCHMAN',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida/AP1WRLvad7aJ-Mi8W7YAXKPagY3B_AKfWB1SGLAzRW6BNNjADvuZkn6mJ9YlARV9m5TvEv5zFB8KJp09d18_OS77mMpgcC8ZlRpk5mw7vXEijP99ppDmgINNwO9WkPlUBueYmt0QjfYR8oXSbavtUd3ozrkxuMxJUykL05gdkdzooRN3PSsqLFpKBO_ifyEhq2rqMK4GKDotGU7ouEMNrCaGlRpgDVvqydpSuzSB9beG75lVk91I6K5gUvu8tw',
    psychologicalProfile:
        "Silas's silent shadow. Efficient, brutal, and completely loyal. Moves in the dark alleys without making a sound.",
  ),
  const Character(
    id: 'bartender',
    name: 'Sam',
    role: CharacterRole.extra,
    roleTitle: 'BARTENDER',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida/AP1WRLuJ6rOSI7Q1i1SaGUVwhOWaqBWMFu-8hnGMmeBorIMno_H2SnsfMF49anTJh3tM1F7oiUI14rVQZbNs3X0Dtnwl1RubmYGjrEML4IQbXYp4dvnDV0Cc-QknX9WJjfe2SGNnXDU8NLA05yxXHMnkeDMq0myO-t3n6A7Uqo_2JVkKumihpDAZfc1UbVoMPxV3y6x9Udm4c-LHix9YxQ2OUg9Co1E4TlyszbNNqvnQk3BzbkV3h1tFV1rrtBc',
    psychologicalProfile:
        "Serves rye whiskey and keeps his ears open. Has seen Marlowe wash blood off his hands more than once. Knows everyone's secrets but shares none.",
  ),
];

final List<LocationItem> initialLocations = [
  const LocationItem(
    id: 'loc-office',
    name: "Detective's Office",
    scenesCovered: 'SCENE 02, 04, 05',
    area: 'Downtown LA',
    setting: LocationSetting.interior,
    timeOfDay: LocationTimeOfDay.night,
    notes:
        'Requires heavy atmospheric smoke. Desk lamp practical needs a 40W tungsten bulb. Blinds cast sharp shadows.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBXTz-kV08Fgtv9_9IndKQnMY2ad37lT_mAWOkUaQ_kf1ysgb74AqYo4p_81LAlIncc5rbU3T9EbLVeTqYta6_bqAKd5sCGCFT1mAwOWFOLNGyfApphUPdGwNMQ74eigaehLnNTBOcU6I52fPz0mqkQRuTJ3tc7zNu_rBMAQOVikKZti7FsqiDmhuEdgltswNjpQsi9s1p8AmVcKqjiAF65MXvlBjHROzk2GnNXzTJtSQXTZ3VV5huE0nP0AEw3FgYe2zPI5302xvY',
  ),
  const LocationItem(
    id: 'loc-alley',
    name: 'Rainy Alleyway',
    scenesCovered: 'SCENE 01, 12',
    area: 'Backlot B',
    setting: LocationSetting.exterior,
    timeOfDay: LocationTimeOfDay.night,
    notes:
        'Puddles for reflections, wet down before shooting. Background neon flickering. Heavy rain effects active.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBVdodGU6285PDgY-9OmqnjdYcskXAWQ4PyDjtyOpneUMvNzUKs2RyPGbzwC9xbKIAfU7_ENyRQAakzLie1xoEXeRMz0m6fe1DyqQWV8VTGE0Qm-1GwER7wcVqdWZ0Lza10ud5X1vpS39LAT2Ifr0goRbg1ql4NHYbzRtp11rj-SXoAM4WwDKXiYveegZEdpt5d4Fc89azQEL5cCnvolvU51vKbnTVORcYYSPHEIv3EztrC5Gklo-WDgo-MrtvY1J3HY2rllak88Wo',
  ),
  const LocationItem(
    id: 'loc-kitchen',
    name: 'Safehouse Kitchen',
    scenesCovered: 'SCENE 22',
    area: 'Studio 4',
    setting: LocationSetting.interior,
    timeOfDay: LocationTimeOfDay.day,
    notes: 'Check practical fridge light. Warm morning light cutting through dusty glass windows.',
  ),
  const LocationItem(
    id: 'loc-warehouse',
    name: 'Abandoned Warehouse',
    scenesCovered: 'SCENE 31',
    area: 'Loading Dock',
    setting: LocationSetting.interior,
    timeOfDay: LocationTimeOfDay.day,
    notes: 'Ensure large overhead metal doors are operational. Shadows must feel heavy and empty.',
  ),
  const LocationItem(
    id: 'loc-diner',
    name: 'Diner Booth',
    scenesCovered: 'SCENE 18',
    area: 'Corner Booth',
    setting: LocationSetting.interior,
    timeOfDay: LocationTimeOfDay.day,
    notes: 'Check practical neon sign blinking in the window. High contrast lighting.',
  ),
];

final List<Scene> initialScenes = [
  const Scene(
    id: 'sc-01',
    projectId: 'long-goodbye',
    code: 'SC 01',
    title: 'The Rain',
    act: 'Act 1: The Setup',
    status: SceneStatus.done,
    description:
        'A heavy downpour floods the neon-lit alleyway. Detective MARLOWE stands under a flickering streetlight, collar up against the cold. He watches the entrance to the speakeasy.',
    setting: SceneSetting.exterior,
    timeOfDay: SceneTimeOfDay.night,
    locationId: 'loc-alley',
    characterIds: ['marlowe'],
    pages: 'Pages 1-3 (2 4/8)',
    estimatedHours: 3.5,
    actionDialogueText:
        "The rain beats heavily against the pavement, washing out the grime of Backlot B.\n\nMARLOWE stands inside a deep doorway, pull-up collar shielding his chin. The orange tip of his cigarette flares up, revealing hollow eyes under a sodden fedora.\n\nAcross the narrow street, the wet neon sign of 'THE SPEAKEASY' flickers, casting a vibrant cyan pool of light on the asphalt.\n\nA sleek black automobile rolls quietly down the alleyway, its headlights slicing the sheets of rain. It stops.",
  ),
  const Scene(
    id: 'sc-02',
    projectId: 'long-goodbye',
    code: 'SC 02',
    title: 'The Client',
    act: 'Act 1: The Setup',
    status: SceneStatus.inProgress,
    description:
        "Marlowe's office. Dusty blinds slice the neon light from outside. EVELYN sits rigidly in the client chair, clutching a velvet purse. She refuses to make eye contact.",
    setting: SceneSetting.interior,
    timeOfDay: SceneTimeOfDay.night,
    locationId: 'loc-office',
    characterIds: ['marlowe', 'evelyn'],
    pages: 'Pages 3-4 (1 1/8)',
    estimatedHours: 2.0,
    actionDialogueText:
        "MARLOWE'S OFFICE - NIGHT\n\nDusty horizontal blinds slice the blinking orange light from the massive neon billboard across the street.\n\nEVELYN sits rigidly in the high-backed wooden chair, her knuckles white as she clutches a vintage velvet purse. She refuses to look at Marlowe directly, her eyes shifting to the shadows in the corner.\n\nMARLOWE shuffles a stack of glossy black-and-white photos across the desk.\n\nEVELYN\n(shivering)\nI never wanted him to find out. Not this way.\n\nMARLOWE\nThe truth has a habit of bleeding through, Mrs. Thorne. No matter how many layers of velvet you wrap it in.",
  ),
  const Scene(
    id: 'sc-03',
    projectId: 'long-goodbye',
    code: 'SC 03',
    title: 'The Docks',
    act: 'Act 2: The Confrontation',
    status: SceneStatus.drafting,
    description:
        'Fog rolls thick off the water. A single shot rings out, echoing against the shipping containers. Footsteps recede rapidly.',
    setting: SceneSetting.exterior,
    timeOfDay: SceneTimeOfDay.night,
    locationId: 'loc-alley',
    characterIds: ['goon1'],
    pages: 'Pages 10-12 (2 0/8)',
    estimatedHours: 4.0,
    actionDialogueText:
        "EXT. PIER 39 - NIGHT\n\nThe thick fog rolls off the water, swallowing the rusty metal hulls of the cargo ships. Everything is quiet. Almost dead.\n\nA single heavy shadow moves along the metal edge of shipping container SCN-01.\n\nSuddenly, a sharp, deafening CRACK rings out, slicing through the damp air.\n\nMICKEY (GOON 1) flinches, his hand shooting to his shoulder. He stumbles into the fog, his heavy leather boots thudding against the wet wood of the pier.",
  ),
  const Scene(
    id: 'sc-04',
    projectId: 'long-goodbye',
    code: 'SC 04',
    title: 'The Initial Briefing',
    act: 'Act 1: The Setup',
    status: SceneStatus.done,
    description:
        'The rain beats heavily against the frosted glass of the office door. MARLOWE sits behind his desk, the cherry of his cigarette the only light.',
    setting: SceneSetting.interior,
    timeOfDay: SceneTimeOfDay.night,
    locationId: 'loc-office',
    characterIds: ['marlowe'],
    pages: 'Pages 4-6 (2 1/8)',
    estimatedHours: 2.5,
    actionDialogueText:
        "The rain beats heavily against the frosted glass of the office door.\n\nMARLOWE sits behind his desk, the cherry of his cigarette the only light in the dim room besides the neon sign blinking erratically outside.\n\nHe shuffles the photos, his expression unreadable beneath the brim of his fedora.\n\nMARLOWE\n(Voiceover)\nIt wasn't just another missing persons case. Not with eyes like hers staring back from the glossies.",
  ),
  const Scene(
    id: 'sc-05',
    projectId: 'long-goodbye',
    code: 'SC 05',
    title: 'Reviewing the Evidence',
    act: 'Act 1: The Setup',
    status: SceneStatus.inProgress,
    description: 'Reviewing the secret dossiers and blackmail photos under the dim lamplight.',
    setting: SceneSetting.interior,
    timeOfDay: SceneTimeOfDay.night,
    locationId: 'loc-office',
    characterIds: ['marlowe', 'evelyn'],
    pages: 'Pages 6-7 (1 4/8)',
    estimatedHours: 2.0,
    actionDialogueText:
        "MARLOWE (CONT'D)\nTake a look at this. October twelfth, at the docks. This is your husband, Mrs. Thorne. Or what's left of his reputation.\n\nHe slides a damp envelope across the glass table.\n\nEvelyn stares at the photos, her lips trembling. She looks up, her eyes glossy under the desk lamp.\n\nEVELYN\nThis is blackmail. He would never go there. Not to the old warehouse.\n\nMARLOWE\nWell, the camera doesn't lie, Mrs. Thorne. But the people in front of it do. Every single day.",
  ),
  const Scene(
    id: 'sc-12',
    projectId: 'long-goodbye',
    code: 'SC 12',
    title: 'The Confrontation',
    act: 'Act 2: The Confrontation',
    status: SceneStatus.inProgress,
    description:
        'The final standoff in the rainy alleyway. Starlight and neon reflecting in the dark puddles.',
    setting: SceneSetting.exterior,
    timeOfDay: SceneTimeOfDay.night,
    locationId: 'loc-alley',
    characterIds: ['marlowe', 'evelyn'],
    pages: 'Pages 14-16 (2 4/8)',
    estimatedHours: 4.5,
    actionDialogueText:
        "EXT. ALLEYWAY - NIGHT - THE STAGE\n\nMarlowe stands in the pouring rain, his hands stuffed deep inside his trenchcoat pockets.\n\nMrs. Thorne stands ten paces away, a silver-plated snub-nosed revolver pointing directly at his chest. Her mascara runs down her cheeks like black tears.\n\nEVELYN\nYou should have walked away, Marlowe. Los Angeles is full of dead husbands. One more wouldn't make the front page.\n\nMARLOWE\nMaybe. But I've always had a bad habit of finishing what I start, Mrs. Thorne. Even if it ends with a bullet.",
  ),
];

final List<ShootingSession> initialSchedule = [
  const ShootingSession(
    id: 'sess-1',
    locationName: "DETECTIVE'S OFFICE - DAY 1",
    dayNumber: 1,
    settingHeader: 'INT. OFFICE - DAY',
    scenesCount: 3,
    estimatedHours: 6.0,
    sceneIds: ['sc-04', 'sc-05', 'sc-02'],
  ),
  const ShootingSession(
    id: 'sess-2',
    locationName: 'RAINY ALLEYWAY - NIGHT 2',
    dayNumber: 2,
    settingHeader: 'EXT. ALLEY - NIGHT',
    scenesCount: 2,
    estimatedHours: 4.5,
    sceneIds: ['sc-12', 'sc-01'],
  ),
];
