defmodule RSA do
  @moduledoc """
  Documentation for RSA.
  """

  defp big_num(s) do
    Enum.reduce(1..s+1, fn _, y -> y * 2 end)
  end

  defp big_pow_mod(x, s, n) do
    Enum.reduce(1..s+1, fn _, y -> y * x end) |> rem(n)
  end

  defp miller_rabin(n, k, r, s) do
    try do
      for _ <- 0..k do
        a = Enum.random(2..n-1)
        x = big_pow_mod(a, s, n)
        if x != 1 && x != n - 1 do
          for _ <- 0..r-1 do
            x = big_pow_mod(x, 2, n)
            if x == n - 1, do: throw(:true)
          end
          throw(:false)
        end
      end

      true
    catch
      :false -> false
      :true -> true
    end
  end

  defp max_cardinal(r, n) when rem(n, 2) != 0, do: {r, n}

  defp max_cardinal(r, n) do
    max_cardinal(r+1, div(n, 2))
  end

  defp is_prime?(n) when n in [2, 3], do: true

  defp is_prime?(n) when rem(n, 2) == 0, do: false

  defp is_prime?(n) do
    {r, s}= max_cardinal(0, n - 1)
    miller_rabin(n, 100, r, s)
  end

  defp prng() do
    :crypto.rand_uniform(big_num(7), big_num(8))
  end

  defp prng_prime() do
    n = prng()
    if is_prime?(n) == true, do: n, else: prng_prime()
  end

  defp gcd(a, b) when b == 0, do: a

  defp gcd(a, b) do
    gcd(b, rem(a, b))
  end

  defp lcm(a, b) do
    a * b / gcd(a, b) |> trunc
  end

  def rng_e(l) do
    Enum.find l..2, &(gcd(&1, l) == 1)
  end

  def rng_d(e, l) do
    Enum.find l..2, &rem(e * &1, l) == 1
  end

  def generate() do
    q = prng_prime()
    p = prng_prime()
    n = p * q
    l = lcm(q - 1, p - 1)
    e = rng_e(l)
    d = rng_d(e, l)
    {{e, n}, {d, n}}
  end

  def encrypt(plaintext, {e, n}) do
    p = plaintext
    big_pow_mod(p, e, n)
  end

  def decrypt(ciphertext, {d, n}) do
    c = ciphertext
    big_pow_mod(c, d, n)
  end

  def sign(plaintext, {d, n}) do
    p = plaintext
    big_pow_mod(p, d, n)
  end

  def verify(plaintext, signature, {e, n}) do
    s = signature
    big_pow_mod(s, e, n) == plaintext
  end
end
