# Deck of Cards API Plugin

## Overview
The Deck of Cards API plugin interacts with the Deck of Cards API documented here:
https://github.com/crobertsbmw/deckofcards
It is offered as a service here: http://deckofcardsapi.com/

The API is useful for plugin training since it is a simple API that does not require any authentication or specific cloud access.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- Access to http://deckofcardsapi.com/ or stand up a server using the git repo found here: https://github.com/crobertsbmw/deckofcards
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Getting Started

### Installation
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `deckofcardsapi.plugin.rb` file located in this repository
 
### How to Use
The  Plugin has been packaged as `plugins/rs_deckofcards`. To use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_deckofcards"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- deck

## Resource: `deck`

#### Usage
```
# Creates a host record with the next available IP address.
resource "deck", type: "rs_deckofcards.deck" do
    name "a new deck"
end
```

#### Supported Fields

| Field Name | Required? | Field Type | Default Value | Description |
|------------|-----------|------------|---------------|-------------|
| name | yes | string | empty | any name is allowed

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | /api/deck/new/ | supported |
| show | /api/deck/<DECK_ID>/| supported |
| draw | /api/deck/<DECK_ID>/draw/?count=<NUMBER_CARDS> | supported |
| shuffle| /api/deck/<DECK_ID>/shuffle/ | supported |

#### Supported Outputs
- "deck_id" - Deck ID
- "remaining" - Number of cards remaining in the deck
- "shuffled" - Whether or not the deck is shuffled
- "success" - Whether or not the action was successful
- "cards" - An array of cards returned when using the draw action

#### Supported Links
NONE

## Examples
See [test_deckofcardsapi.cat.rb](./test_deckofcardsapi.cat.rb) for an example decalaration use of draw and shuffle actions.

## Known Issues / Limitations
- The API does not have an object definition for a drawn hand of cards. So there is no way to get a drawn hand of cards. You get the list when the draw action is called and it needs to be stored elsewhere if it needs to be recalled.

## License
The Deck of Cards API Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
