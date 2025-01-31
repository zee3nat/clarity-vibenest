# VibeNest
A decentralized social network for discovering and sharing music playlists built on Stacks blockchain.

## Features
- Create and manage playlists
- Follow other users
- Like and comment on playlists
- Share playlist ownership
- Earn rewards for popular playlists
- Input validation for playlist names and songs

## Contracts
- `vibenest.clar`: Main contract handling playlists and social interactions
- `vibenest-token.clar`: Token contract for platform rewards

## Data Validation
- Playlist names must not be empty and must be 64 characters or less
- Song URLs must not be empty and must be 128 characters or less
- Maximum of 50 songs per playlist

## Testing
Run tests using Clarinet:
```bash
clarinet test
```
