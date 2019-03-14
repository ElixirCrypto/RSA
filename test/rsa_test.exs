defmodule RsaTest do
  use ExUnit.Case
  doctest RSA

  test "test generate, encrypt, decrypt" do
    {{pk, n}, {psk, n}} = RSA.generate()
    IO.puts "PK is #{pk}, PSK is #{psk}, n is #{n}"
    plaintext = 10
    ciphertext = RSA.encrypt(plaintext, {pk, n})
    assert RSA.decrypt(ciphertext, {psk, n}) == plaintext
  end

  test "test sign, verify" do
    {{pk, n}, {psk, n}} = RSA.generate()
    IO.puts "PK is #{pk}, PSK is #{psk}, n is #{n}"
    plaintext = 10
    signature = RSA.sign(plaintext, {pk, n})
    assert RSA.verify(plaintext, signature, {psk, n}) == true
  end
end
