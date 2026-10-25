# Number Theory

## Key Algorithms

### GCD (Euclidean Algorithm)
```java
int gcd(int a, int b) {
    return b == 0 ? a : gcd(b, a % b);
}
int lcm(int a, int b) {
    return a / gcd(a, b) * b;
}
```

### Sieve of Eratosthenes
```java
boolean[] sieve(int n) {
    boolean[] isPrime = new boolean[n + 1];
    Arrays.fill(isPrime, true);
    isPrime[0] = isPrime[1] = false;
    for (int i = 2; i * i <= n; i++) {
        if (isPrime[i]) {
            for (int j = i * i; j <= n; j += i)
                isPrime[j] = false;
        }
    }
    return isPrime;
}
```

### Fast Exponentiation
```java
long power(long base, long exp, long mod) {
    long result = 1;
    base %= mod;
    while (exp > 0) {
        if ((exp & 1) == 1) result = result * base % mod;
        base = base * base % mod;
        exp >>= 1;
    }
    return result;
}
```

### Modular Inverse (Fermat's Little Theorem)
```java
// Only when mod is prime
long modInverse(long a, long mod) {
    return power(a, mod - 2, mod);
}
```

### Check Prime
```java
boolean isPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;
    }
    return true;
}
```

### nCr with Modular Arithmetic
```java
long MOD = 1_000_000_007;
long[] fact, invFact;

void precompute(int n) {
    fact = new long[n + 1];
    invFact = new long[n + 1];
    fact[0] = 1;
    for (int i = 1; i <= n; i++) fact[i] = fact[i - 1] * i % MOD;
    invFact[n] = power(fact[n], MOD - 2, MOD);
    for (int i = n - 1; i >= 0; i--) invFact[i] = invFact[i + 1] * (i + 1) % MOD;
}

long nCr(int n, int r) {
    if (r < 0 || r > n) return 0;
    return fact[n] % MOD * invFact[r] % MOD * invFact[n - r] % MOD;
}
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Count Primes | Sieve of Eratosthenes |
| GCD of Array | Iterative GCD |
| Power(x, n) | Fast exponentiation |
| Unique Paths | nCr(m+n-2, m-1) |
| Super Pow | Modular exponentiation |
