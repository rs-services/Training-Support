name 'Deck Of Cards Plugin Test CAT'
rs_ca_ver 20161221
short_description "Deck of Cards Plugin Test CAT"

import "sys_log"
import "plugins/rs_deckofcards"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "param_numbercards" do
  label "Number of Cards to Draw from Deck"
  type "number"
  operations "draw_cards"
  default 5
end


##########################
##########################
#######  Outputs  ########
##########################
##########################

output "deck_id" do
    label "Deck ID"
    category "Outputs"
end

output "remaining" do
    label "Remaining Cards in Deck"
    category "Outputs"
end

output "shuffled" do
    label "Shuffle Status of Deck"
    category "Outputs"
end

output "hand" do
    label "A Hand of Cards"
    category "Outputs"
end


##########################
##########################
####### Resources ########
##########################
##########################
    

resource "deck", type: "rs_deckofcards.deck" do
  name "a new deck"
end

##########################
##########################
###### Operations ########
##########################
##########################

operation "enable" do
  label "Getting Deck Info"
  definition "post_launch"
  output_mappings do {
    $deck_id => $deckid,
    $shuffled => $shuffle_status,
    $remaining => $remaining_status
  }
  end
end

# Post launch action to shuffle the deck
operation "shuffle_deck" do
  label "Shuffle the Deck"
  definition "shuffle_deck"
  output_mappings do {
      $shuffled => $shuffle_status,
      $remaining => $remaining_status,
      $hand => $drawn_cards
  } end
end

operation "draw_cards" do
  label "Draw a Hand"
  definition "draw_cards"
  output_mappings do {
    $hand => $drawn_cards,
    $remaining => $remaining_status
  }
  end
end


##########################
##########################
###### Definitions #######
##########################
##########################

define post_launch(@deck) return $deckid, $shuffle_status, $remaining_status do
  $deck_object = to_object(@deck)
  call log("deck object", to_s($deck_object))
  $deckid = @deck.deck_id
  $shuffle_status = switch(@deck.shuffled, "shuffled", "not shuffled")
  $remaining_status = to_s(@deck.remaining)
  call log("deck attributes", $deckid + "; " + $shuffle_status + "; " + $remaining_status)
end

define shuffle_deck(@deck) return $shuffle_status, $remaining_status, $drawn_cards do
  # when a deck is shuffled any drawn cards are returned to the deck
  $drawn_cards = null
  $deck_info = @deck.shuffle()
  call log("deck info", to_s($deck_info))

  $shuffle_status = switch(@deck.shuffled, "shuffled", "not shuffled")
  $remaining_status = to_s(@deck.remaining)
end

define draw_cards(@deck, $param_numbercards) return $drawn_cards, $remaining_status do
 
  # The draw action is defined to return the "cards" array which is returned by the draw API
  $drawn_hand = @deck.draw(count: $param_numbercards)
  call log("drawn hand", to_s($drawn_hand))

  $drawn_cards = to_s($drawn_hand)
  $remaining_status = to_s(@deck.remaining)
end

define log($summary, $details) do
  rs_cm.audit_entries.create(notify: "None", audit_entry: { auditee_href: @@deployment, summary: $summary , detail: $details})
end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end