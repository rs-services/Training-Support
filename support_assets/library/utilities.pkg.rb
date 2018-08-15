name "LIB - Common utilities"
rs_ca_ver 20161221
short_description "Helpful utilities"

package "training/support/utilities"

# create an audit entry 
define log($summary, $details) do
  rs_cm.audit_entries.create(notify: "None", audit_entry: { auditee_href: @@deployment, summary: $summary , detail: $details})
end