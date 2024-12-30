
MkKeyfilesDir = "MkKeyfilesDir" #needed for Zeitwerk
module Vault
  Dir.mkdir KEYFILES_DIR unless Dir.exist? KEYFILES_DIR
end
