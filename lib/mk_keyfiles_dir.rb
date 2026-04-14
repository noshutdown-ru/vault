MkKeyfilesDir = "MkKeyfilesDir"

module Vault
  Dir.mkdir KEYFILES_DIR unless Dir.exist? KEYFILES_DIR 
end
