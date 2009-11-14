# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_oupsnow_session',
  :secret      => '3271ab4a527b62e55bc83792948283b0044c9df4e22c774eab635e125a43fbec4257a81b20156b9b1a866534245e98246d3587b466cd06df934176270bc1dccf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
