# Deck of Cards API Plugin
#
# API Doc: http://deckofcardsapi.com/
#
# Why a Plugin for This?
# - Simple to understand API
# - Has an object structure that lends itself to plugins.
# - Doesn't require any authentication and so is useful for training purposes.


name 'rs_deckofcards'
type 'plugin'
rs_ca_ver 20161221
short_description "Deck of Cards"
long_description "Version: 0.1"
package "plugins/rs_deckofcards"
import "sys_log"

plugin "rs_deckofcards" do
  
  endpoint do
    default_host "https://deckofcardsapi.com"  
    path "/api"
    default_scheme "https"
  end
  
  type "deck" do
    href_templates "/deck/{{deck_id}}"  
    
    output "deck_id", "remaining", "shuffled", "success"

    action "create" do
      verb "GET"
      path "/new/"
    end
    
    action "shuffle" do
      verb "GET"
      path "$href/shuffle/"
    end
    
    action "draw" do
      verb "GET"
      path "$href/draw/"
      
      field "count" do
        location "query"
      end
      
      output_path "cards"
    end
    
    action "get", "show"  # default GET on the HREF (i.e. /api/deck/DECK_ID)
    
    provision "create_deck"
    delete "no_operation" # there is no delete operation for this API. Decks are automatically deleted after 2 weeks of nonuse

  end    
end

resource_pool "deckofcards" do
  plugin $rs_deckofcards
end

define create_deck(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $type = $object["type"]
    $fields = $object["fields"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ",$type]))
    call sys_log.detail($object)
    @operation = rs_deckofcards.deck.create($fields) 
    call sys_log.detail("CREATE HREF: "+to_s(@operation))
    call sys_log.detail("CREATE HREF OBJECT: "+to_s(to_object(@operation)))
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
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

# Some actions, e.g. delete is not supported by this API, so just no-op 
define no_operation(@declaration) do
end 