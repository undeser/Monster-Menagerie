Monster Menagerie

------

## Content Page
- [Introduction](https://github.com/undeser/Monster-Menagerie#introduction)
  - [Problem Definition](https://github.com/undeser/Monster-Menagerie#problem-definition)
  - [Proposed Solutiion](https://github.com/undeser/Monster-Menagerie#proposed-solution)
  - [Targeted Users](https://github.com/undeser/Monster-Menagerie#targeted-users)
  - [Business Logic](https://github.com/undeser/Monster-Menagerie#business-logic)
  - [Gameplay Logic](https://github.com/undeser/Monster-Menagerie#gameplay-users)
- [Architecture](https://github.com/undeser/Monster-Menagerie#architecture)


# Introduction
A project for a module, IS4302 - Blockchain and Distributed Ledeger Technologies, taken in National University of Singapore (NUS) in 2023. The project is a GameFi Dapp.

### Contributors
- [Bryan Wong Jun Lin](https://github.com/bryanwonggy)
- [Conrad Rein Tang Ze Aw](https://github.com/cReintang)
- [James Mak](https://github.com/jamesmakjxnp)
- [Luther Tan Xin Kang](https://github.com/luthertan98)
- [Seah Zhi Han Mervyn](https://github.com/undeser)


## Problem Definition
GameFI integrates the concepts of both Non-Fungible Tokens (NFTs) and Decentralised Finance (DeFi) into a game, running blockchain’s financial system more intuitively. With the usage of NFTs, players have full ownership of these assets in a decentralised blockchain game [(Emmert et al., 2022)](https://www.nerdwallet.com/article/investing/gamefi). In essence, GameFi augments and enhances on boring DeFi transactions, adding entertainment and interactivity into blockchain finance and NFT. This allows traders to profit and trade through a gamified experience and social interaction.

With the rise of the popularity of Axie Infinity in 2021, the concepts of GameFi and Play-To-Earn (P2E) were popularised. An economy was created over the Axie Infinity where their main users are coming on the platform to earn a living, giving birth to a new virtual labour force [(Najumi, 2022)](https://sg.news.yahoo.com/rise-axie-infinity-p2e-phenomenon-122158764.html?guccounter=1). Axie Infinity excels at providing a platform and opportunity for users to earn a living. With the ease of accessibility available on the platform, Axie Infinity was attractive especially to low-income workers who lack financial mobility. 

The growth of Axie resulted in the game being overrun by value-extractive users who are extensively selling the tokens to earn a living. Alongside, it led to the P2E phenomenon with the creation of many similar current crypto GameFi projects. However, all these GameFi share a critical flaw, where they lack genuine fun and entertainment value. When the essence of the project is a monetisation model that focuses on generating revenue, the balance of demand and supply collapses, leading to a market full of sellers operating under the greater fool theory[^1] [(Lalani et al., 2022)](https://forkast.news/why-is-p2e-axie-infinity-declining-gamefi/). Ultimately, leading to Axie Infinity and similar GameFi projects’ downfall. 

As Riaz Lalani stated
>“If Axie Infinity has taught us anything, it’s that earning is one thing, but it can’t be everything”.

[^1]: The greater fool theory suggests that one can sometimes make money through the purchase of overvalued assets and selling them for a profit later. As there will always be a buyer willing to pay a higher price.

## Proposed Solution

Our solution, Monster Menagerie, is a GameFi platform to be on the Polygon network, where players are able to trade NFTs. Monster Menagerie packages elements of fun, adventure and competition. Players will be able to mint an ERC-20 token known as Gems ($BGM) using ETH, which can subsequently be used to mint Beasts, a form of NFT. Beasts come with different stats and different rarities. They can be collected and form decks to be used in Fights. By winning Fights, players can acquire more Gems while gaining reputation and glory on the leaderboard. These Beasts can also be traded and auctioned off at the Menagerie, a marketplace for Beasts.

### Augmenting Elements of Fun, Nostalgia & Competition
Taking inspiration from childhood card games like Pokemon, Magic: The Gathering and even Hearthstone, Monster Menagerie, incorporates elements of collection and competition. With the game being centred around the theme of different Beasts, this would emerge the player in a fictitious world of adventure, replicative of games and shows. Additionally, collection of the Beasts not only helps you build and strengthen your deck of Beasts, but it also contributes to a sense of achievement while completing the collection. Lastly, winning Fights grant reputation and matchmaking ranking (MMR), which feeds into the competitive nature of humans. This also incentivises players to collect more Beasts as they would want to collect stronger Beasts to win more Fights. 

### Reason for Blockchain & GameFi
Compared to traditional online card games, the value gained from building Monster Menagerie on the blockchain network is paramount. Outside of financial gains, the reason for blockchain stems from creating value and lifespan for the players’ assets. Traditional online games assets, such as the coins, weapons earned never truly belonged to a player and had no real world value. They are also lost and valueless once the game is irrelevant and the platform shuts down. With the concept of NFT, players can own GameFi’s in-platform assets which can also be transferred across different games and platforms. This creates lifetime value for each player’s assets and an internal economy within the game, paving an economy based on player empowerment. 

## Targeted Users

Our target users are mainly those who are already in the NFT and Defi community who wish to earn from the game and for personal entertainment and pleasure. Additionally, by incorporating elements such as collection and competition, we plan to utilise nostalgia to attract new members of the general public into the Defi community. With easy to use features and simple game mechanics, this provides a small barrier of entry for new users and potential investors.

## Business Logic

Monster Menagerie adopts a **play-AND-earn model**, where gaming allows for an open economy and provides financial benefits to players who play the game. 

### Tokenomics

The Monster Menagerie platform will use a native ERC-20 token, Gems ($BGM), for all in-game transactions. Users will be able to mint Gems using ETH and the tokenomics is designed to have a maximum supply cap of 1,000,000 Gems. The main utility of Gems are: 

- Purchasing of Monster pack / Monster from the Marketplace
- Fighting with other players
- Used to repair cards after battling
- Provide liquidity with USD Coin (USDC) and stake on the platform for reward

To ensure that there is not only inflationary pressure on the token, the Gems token is designed with several sinks, making it a deflationary token. These sinks aim to reduce the overall supply of Gems over time, preserving the token's value and ensuring a healthy balance in the platform's economy.

Some of the deflationary mechanisms built into the Gems token design include:

- Implementing a repair fee in Gems after battling. When cards are damaged during Fights, players will need to use Gems to repair them. 50% of the Gems will be burnt to reduce circulating supply in the market and the remaining will be sent to the treasury. 
- Charging a transaction fee for trades and auctions in the Menagerie Marketplace.
- Implementing a staking mechanism where users can lock their Gems tokens with USDC to provide liquidity to the platform. These locked tokens will be taken out of circulation temporarily, reducing the available supply and contributing to deflationary pressure.

The future implementation details for the tokenomics can be found at [Chapter 3.2.4. BGM Token Release Schedule](https://github.com/undeser/Monster-Menagerie#bgm-token-release). 

### Monster NFTs

By implementing and building our solution on the Blockchain and GameFi network, the game assets gained by the players not only have real world value, but lifetime value. Beasts can be minted as NFTs using Gems ($BGM). Beasts’ stats are generated upon minting, having different Attack Points (AP), Health Points (HP), Rarity type and Natures. These combat stats affect their performance in Fights and their value in the Menagerie Marketplace, which will be briefly discussed in [Chapter 1.4.4 The Menagerie Marketplace](https://github.com/undeser/Monster-Menagerie#the-menagerie-marketplace).

### The Menagerie Marketplace

The Menagerie Marketplace is a centralised marketplace where players can trade and auction their Beasts, offering the players a platform to monetise their in-game assets. With a user-friendly interface, players can list and bid for Beasts with ease and no fuss. Similar to Fights, a portion of the sale price will be charged as platform fee in Gems. Additionally, the Menagerie Marketplace will have integration with popular wallets and platforms for seamless trading and asset management.

### Staking

In an effort to promote price stability and mitigate excessive volatility for the $BGM token, users will be able to stake their Uniswap Liquidity Provider (LP) tokens on the Monster Menagerie platform. To obtain LP tokens, users need to provide liquidity for the $BGM-USDC trading pair on Uniswap. The LP tokens can then be staked on our platform to earn $BGM rewards, incentivising users to contribute liquidity to the trading pair.

### Marketing and User Acquisition

To attract new users and investors, various marketing strategies will be employed, such as collaborating with influencers and content creators in the gaming, NFT, and DeFi spaces, social media marketing on platforms like Twitter, Instagram, and Reddit, and organising in-game events, competitions, and giveaways to promote user engagement and platform growth. 

### Revenue Streams

Monster Menagerie's primary revenue streams include platform fees charged on Beasts minting, trading, and auctioning transactions and fees from Fights.

### Self-Development Retention

Our business model focuses on monetising experience, this way, we can attract players to the game based on skill. This means that players who have devoted time to mastering the game and its mechanics should earn the most. On the other hand, new and lower-skilled players will be incentivised by the future possibilities, rather than the idea of immediate earning. By using the addictive quality of self-improvement, it keeps players interested in the game and creates player retention as they have invested time to learn and master the game. 

In addition, our reward system incentivises players by rewarding them more Gems if they beat a player with higher MMR. Similarly, if a player were to lose to another player with lower MMR, they would also stand to lose more Gems. This system encourages players to come up with new and better strategies in order to beat more skilled players, developing different “metas” and strategies as more Beasts are added to the game. With the Menagerie Marketplace, players can then use those Gems earned to purchase rarer and more powerful cards, this creates more possibilities for players to formulate different strategies, as they have access to a wider variety of cards with different abilities and strengths.

Additionally, the Menagerie Marketplace can provide a sense of progression and achievement for players as they earn more Gems and mint more powerful cards. This can keep players engaged and motivated to continue playing the game, as they work towards acquiring the most powerful cards and achieving victory.

### Roadmap & Development Plan

The development of Monster Menagerie will follow a structured roadmap that includes:

1. Initial development of the platform, including smart contracts, tokenomics, and NFT design (Launch of MVP). This stage focuses on creating the foundation of the Monster Menagerie ecosystem and establishing core functionalities. This is the current stage.
2. Alpha and beta testing to gather user feedback and optimise the platform. During this stage, we will work on refining the platform's front end, ensuring a seamless user experience while addressing any bugs or issues that arise during testing.
3. Development of the Leaderboard and MMR algorithm for the battling function. This stage involves creating a competitive environment for players, implementing a ranking system to match players of similar skill levels, and fostering a sense of achievement and progress.
4. Integration of oracles for NFT mints, NFT minting restrictions, and tokenomics improvement. This stage aims to enhance the platform's security and fairness, ensuring that the minting process is transparent and adheres to the designed rarity distribution.
5. Launching the platform and organising marketing campaigns to acquire users. This stage focuses on promoting Monster Menagerie to the target audience, using various marketing channels and strategies to attract users and establish a strong user base.
6. Regular updates and improvements, including new Monster releases, events, and in-game features. We will continue to enhance the gameplay experience, introducing new content and strategies to keep players engaged and maintain the platform's growth.

By following this roadmap, we aim to create a thriving and sustainable GameFi platform that balances both the entertainment and financial aspects, providing users with a fun, engaging, and rewarding experience.

## Gameplay Logic

### Monster Cards
Each Beast upon minting, will come with a unique combination of Attack Points (AP), Health Points (HP), Rarity, cost and Nature. Both AP and HP are integer values and come in a range. There are four Rarity types[^2] in total – Common, Rare, Epic and Legendary. The cost of the Beasts is dependent on the Rarity type. As of now, there are only three Natures in Monster Menagerie – Verdant, Infernal and Aquatic. 

[^2]: Rarity Types are indicated by the symbol at the top of the cards, represented by different shapes for different Rarity Types.

Defeated Beast cards will be broken after a Fight, rendering them unplayable until fixed. They can be fixed using Gems, where their Rarity type would determine the cost of Gems needed for this process.

### Entering a Fight

Players are required to wager an amount of Gems to participate in a Fight. Apart from wagering (and ensuring that the player has sufficient Gems), players would be required to select five Beasts **in sequence** from their collection to form a Deck. The Deck must have a total cost of no more than 65. After which, they would be placed in a matchmaking lobby where they will be assigned an opponent using our algorithm. 

### Scaling and Nature Advantage

During a Fight, Beasts will fight opponent’s Beasts in the sequence which they were selected (ie. first Beast Fight opponent’s first Beast). Both Beasts’ AP and HP will be scaled using our algorithm. 

The algorithm will consider two factors:
1. Cost of each player’s Deck: 
  - The lower the cost of a player’s Deck, the greater the scaling of stats is.
2. Nature advantages: 
  - A Beast is considered Nature-advantaged when its Nature is strong against the opponent Beast’s Nature. 
  - Verdant is strong against Aquatic; Aquatic is strong against Infernal; Infernal is strong against Verdant. 
  - There are no Nature “disadvantages”.

### During a Fight

After scaling is done, both Beasts will fight against each other. Each Beast’s scaled HP will be deducted based on the opponent’s scaled AP. If the opponent’s scaled AP exceeds the Beast’s scaled HP, the Beasting card will be broken. Any residual damage will be stored and recorded as Damage Points (DP). If the opponent’s scaled AP does not exceed the scaled HP, nothing happens. This would repeat for each of the five Beasts. The player with the higher Damage Points (DP) would win the game. 

### Victory

Winning a Fight not only allows you to climb the leaderboard, but also gaining MMR and Gems in the process. The winner of the Fight will receive the majority of the pool of wagered Gems, while the remaining is distributed as platform fees.

-----

# Architecture

## System Illustration

## How This System Works

## Gem
[`ERC20`]
In-game currency used to mint and purchase card packs. Can be purchased using ETH.
Functions of `Gem`:
- `getCredit()`: allows caller to check own credits
- `checkCredit()`: 
- `checkBal()`:
- `transfer()`: 
- `transferFrom()`: 
- `giveApproval()`: 

## Beast
[`ERC721`]
Properties of BeastCard:
- Health Points (HP)
- Attack Stat (AP)
- Nature (Verdant, Infernal, Aquatic)
- Rarity (Common, Rare, Epic, Legendary)
- Broken Status
- Repair Cost
  - based on Rarity status

## Fight
Take in an input of an array of Beast.

## Menagerie
To buy, sell and trade Beast with other players.
To make the game more gasless and make the game seamless... 

## Staking

# Challenge Mechanics
