# Balatrogether

Ever wanted a multiplayer solution for Balatro? Balatrogether allows players to connect to lobbies and play either co-op or versus runs of Balatro. The first player in a lobby can set up run options, choosing the deck and stake the lobby will play the run on.

As a free independently-developed mod, Balatrogether does not provide its own public servers. However, the [server software](https://github.com/Irreflexive/Balatrogether-Server) used to run Balatrogether servers is open-source and available for anyone to set up.

## Installation

This mod requires [Steamodded 1.0.0-Alpha](https://github.com/Steamopollys/Steamodded) and [lovely](https://github.com/ethangreen-dev/lovely-injector) to function. Please download and install these dependencies according to their installation instructions. 

In addition, Balatrogether requires [LuaSec](https://github.com/26F-Studio/love-luasec/releases/tag/v1.0.3) as a Lua binding to OpenSSL. Download the release corresponding to your operating system and the extract the ZIP file in the same location as specified by lovely.

The mod itself can be installed in the same way as any other Steamodded mods. Download the source code ZIP file and extract it to your Mods folder.

## Game Modes

### Co-op Mode

In co-op mode, players control the entire run together: every card selection, purchase, and reroll is mirrored between all players. This mode is best used between players that are directly communicating and planning their run decisions together. There are no additional items unique to co-op mode, and unlike versus mode, they can continue as far into a run as in singleplayer.

### Versus Mode

In versus mode, players are now pitted against one another. The lobby host selects their desired game length, choosing between 4, 8, 12, and 16 antes, and all players begin the run on the same seed. Every handful of antes, players will encounter **The Duel** boss blind, eliminating roughly half of the bottom round scorers each time the boss is encountered. These will appear at the same ante for every player, so players must wait for everyone to be ready for the boss blind (the Hieroglyph and Petroglyph vouchers are disabled). Once they reach the final ante set by the host, the **Final Showdown** blind awards the win to the highest scorer.

Along the way, players can use brand new jokers, cards, and other abilities to affect the other players:

- **Annie and Hallie**: This legendary joker, when sold, swaps your jokers with a random opponent's. This joker will even swap eternal jokers!
- **Network Pack**: A booster pack that allows players to pick playing cards and jokers that opponents possess, bringing along any accumulated chips, +mult, or Xmult with them.
- **Secure Edition**: Emits strange jamming signals to prevent the selected card from being transmitted to opponents. Secure jokers will not be swapped when Annie and Hallie is activated and will not appear in any Network Packs. The Wheel of Fortune and Aura can both be used to apply Secure edition in versus mode.
- **The Cup**: This tarot card gives you $8 for every player that has been eliminated so far this run.
- **Green Seal**: When a card is played and scored, subtract $1 from every opponent, then award the user with $1. Comes with the **Siphon** spectral card to add the green seal to a card.
- **Eraser** and **Paint Bucket** - A new pair of vouchers, affecting the hand size of opponents. The first voucher will subtract 1 hand size from a *random* opponent, while the stronger voucher will subtract 1 hand size from *all* opponents.