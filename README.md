# Monster Menagerie

## Introduction
A project for a module, IS4302 - Blockchain and Distributed Ledeger Technologies, taken in National University of Singapore (NUS) in 2023. The project is a GameFi Dapp.

### Contributors
- Bryan Wong Jun Lin
- Conrad Rein Tang Ze Aw
- James Mak
- Luther Tan Xin Kang
- Seah Zhi Han Mervyn


### Problem Definition
GameFI integrates the concepts of both Non-Fungible Tokens (NFTs) and Decentralised Finance (DeFi) into a game, running blockchain’s financial system more intuitively. With the usage of NFTs, players have full ownership of these assets in a decentralised blockchain game [(Emmert et al., 2022)](https://www.nerdwallet.com/article/investing/gamefi). In essence, GameFi augments and enhances on boring DeFi transactions, adding entertainment and interactivity into blockchain finance and NFT. This allows traders to profit and trade through a gamified experience and social interaction.

With the rise of the popularity of Axie Infinity in 2021, the concepts of GameFi and Play-To-Earn (P2E) were popularised. An economy was created over the Axie Infinity where their main users are coming on the platform to earn a living, giving birth to a new virtual labour force [(Najumi, 2022)](https://sg.news.yahoo.com/rise-axie-infinity-p2e-phenomenon-122158764.html?guccounter=1). Axie Infinity excels at providing a platform and opportunity for users to earn a living. With the ease of accessibility available on the platform, Axie Infinity was attractive especially to low-income workers who lack financial mobility. 

The growth of Axie resulted in the game being overrun by value-extractive users who are extensively selling the tokens to earn a living. Alongside, it led to the P2E phenomenon with the creation of many similar current crypto GameFi projects. However, all these GameFi share a critical flaw, where they lack genuine fun and entertainment value. When the essence of the project is a monetisation model that focuses on generating revenue, the balance of demand and supply collapses, leading to a market full of sellers operating under the greater fool theory[^1] [(Lalani et al., 2022)](https://forkast.news/why-is-p2e-axie-infinity-declining-gamefi/). Ultimately, leading to Axie Infinity and similar GameFi projects’ downfall. 

As Riaz Lalani stated, “If Axie Infinity has taught us anything, it’s that earning is one thing, but it can’t be everything”.

[^1]: The greater fool theory suggests that one can sometimes make money through the purchase of overvalued assets and selling them for a profit later. As there will always be a buyer willing to pay a higher price.

### Proposed Solution

Our solution, Monster Menagerie, is a GameFi platform to be on the Polygon network, where players are able to trade NFTs. Monster Menagerie packages elements of fun, adventure and competition. Players will be able to mint an ERC-20 token known as Gems ($BGM) using ETH, which can subsequently be used to mint Beasts, a form of NFT. Beasts come with different stats and different rarities. They can be collected and form decks to be used in Fights. By winning Fights, players can acquire more Gems while gaining reputation and glory on the leaderboard. These Beasts can also be traded and auctioned off at the Menagerie, a marketplace for Beasts.

#### Augmenting Elements of Fun, Nostalgia & Competition
Taking inspiration from childhood card games like Pokemon, Magic: The Gathering and even Hearthstone, Monster Menagerie, incorporates elements of collection and competition. With the game being centred around the theme of different Beasts, this would emerge the player in a fictitious world of adventure, replicative of games and shows. Additionally, collection of the Beasts not only helps you build and strengthen your deck of Beasts, but it also contributes to a sense of achievement while completing the collection. Lastly, winning Fights grant reputation and matchmaking ranking (MMR), which feeds into the competitive nature of humans. This also incentivises players to collect more Beasts as they would want to collect stronger Beasts to win more Fights. 

#### Reason for Blockchain & GameFi
Compared to traditional online card games, the value gained from building Monster Menagerie on the blockchain network is paramount. Outside of financial gains, the reason for blockchain stems from creating value and lifespan for the players’ assets. Traditional online games assets, such as the coins, weapons earned never truly belonged to a player and had no real world value. They are also lost and valueless once the game is irrelevant and the platform shuts down. With the concept of NFT, players can own GameFi’s in-platform assets which can also be transferred across different games and platforms. This creates lifetime value for each player’s assets and an internal economy within the game, paving an economy based on player empowerment. 

### Targeted Users

Our target users are mainly those who are already in the NFT and Defi community who wish to earn from the game and for personal entertainment and pleasure. Additionally, by incorporating elements such as collection and competition, we plan to utilise nostalgia to attract new members of the general public into the Defi community. With easy to use features and simple game mechanics, this provides a small barrier of entry for new users and potential investors.

## Architecture & Design

### Gem
[`ERC20`]
In-game currency used to mint and purchase card packs. Can be purchased using ETH.
Functions of `Gem`:
- `getCredit()`: allows caller to check own credits
- `checkCredit()`: 
- `checkBal()`:
- `transfer()`: 
- `transferFrom()`: 
- `giveApproval()`: 

### Beast
[`ERC721`]
Properties of BeastCard:
- Health Points (HP)
- Attack Stat (AP)
- Nature (Verdant, Infernal, Aquatic)
- Rarity (Common, Rare, Epic, Legendary)
- Broken Status
- Repair Cost
  - based on Rarity status

### Fight
Take in an input of an array of Beast.

### Menagerie
To buy, sell and trade Beast with other players.
To make the game more gasless and make the game seamless... 

### Staking

## Challenge Mechanics

#
