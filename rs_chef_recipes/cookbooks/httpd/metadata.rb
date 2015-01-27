maintainer       "RightScale"
maintainer_email "ryan.geyer@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures httpd"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "httpd::install_httpd", "Installs the apache2 package on Ubuntu"
recipe "httpd::setup_index_page", "Creates a custom index page from a Chef template"

attribute "httpd/your_name",
  :display_name => "Your Name",
  :required => "required",
  :recipes => ["httpd::setup_index_page"]