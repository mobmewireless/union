require 'open-uri'

# Let's disable SSL verification, and silence the constant reassignment warning while we're at it.
silence_warnings do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
