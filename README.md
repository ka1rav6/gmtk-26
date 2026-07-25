# GMTK 2026

A 2D action-platformer with time-manipulation and grab/throw mechanics. Built for the GMTK Game Jam 2026.

## How to Play

Fight through levels of enemies by slowing time, grabbing them, and flinging them into hazards — or just shoot them. Reach the portal to advance.

### Power Mode (E)

Activate to slow everything down. While active:

- **Left-click** an enemy or bullet to freeze it for 5 seconds independently
- **Right-click + drag** on a frozen enemy to slingshot-throw it
- Clicking an enemy exits global power mode but keeps that enemy frozen

### Grab (Q)

Pick up the nearest enemy within range, carry it, and release it somewhere else.

## Controls

| Key | Action |
|-----|--------|
| A / D | Move left / right |
| W / Space | Jump (works on walls too) |
| S | Fast-fall |
| E | Toggle Power Mode |
| Q | Grab / release enemy |
| Left-click | Freeze enemy/bullet (in Power Mode) |
| Right-click + drag | Slingshot throw (in Power Mode) |
| Escape | Pause |

## Enemies

| Enemy | Type | Description |
|-------|------|-------------|
| Basic | Melee | Walks toward you, jumps at walls. Simple but persistent. |
| Gunner | Ranged | Chases you AND fires projectiles. The all-rounder. |
| Sniper | Ranged | Stationary. Charges up and fires a deadly precision shot. |
| Laser | Ranged | Stationary. Pulses a high-damage beam every few seconds. |
| Long Laser | Ranged | Stationary. Sustained beam with on/off cycles. |
| Crate | Object | Stationary. Grab and throw into enemies or hazards. |

## Level Elements

- **Platforms** — Static, moving, and selectable (time-slowable) platforms
- **Portals** — Level exits. Some are locked and require a kill count to open
- **Saws** — Spinning hazards. Static and moving variants. Instant kill
- **Killzones** — Invisible death zones. Instant kill
- **Spawners** — Spawn enemies or objects on a timer
- **Destroyable Platforms** — Break when damaged

## Tech

- **Engine:** Godot 4.7
- **Language:** GDScript
- **Architecture:**
  - All enemies inherit from `generic_enemy.gd`
  - Global singleton (`Global`) manages shared state, power mode toggling, and level transitions
  - Enemies start deactivated and activate when the player enters their area
  - Movement animations for platforms/saws are built procedurally in code
  - Physics layers separate Player, World, Bullets, Enemies, and KillZones

## License

MIT — see [LICENSE](LICENSE)
