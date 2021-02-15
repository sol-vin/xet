# TODO: Bits::Reply?
command Bits::Request, id: 0x0586 do
  SPECIAL_SESSION_ID = 0x0001869f_u32 #TODO: This special session id must be present. Why?Check with ghidra? Binary disasm?
  field? bits, UInt32, "Bits"

  nest data_encryption_type, DataEncryptionType, "DataEncryptionType" do
    field? aes, Bool, "AES"
  end

  field? aes, Bool, "AES"
  field? encryption_algo, String, "EncryptAlgo"

  nest login_encryption_type, LoginEncryptionType, "LoginEncryptionType" do
    field? md5, Bool, "MD5"
    field? none, Bool, "NONE"
    field? rsa, Bool, "RSA"
  end
  field? public_key, String, "PublicKey"
end