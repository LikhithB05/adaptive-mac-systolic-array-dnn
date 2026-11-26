from pathlib import Path

base = Path(__file__).resolve().parents[1] / "datasets"

def signed_words(name):
    words = [int(word, 16) for word in (base / name).read_text().split()]
    assert len(words) == 784
    return [word - (1 << 32) if word & (1 << 31) else word for word in words]

pairs = list(zip(signed_words("activations.mem"), signed_words("weights.mem")))
products = [a * b for a, b in pairs]
total = sum(products)
assert total == 3_995_709_172
print(f"{len(pairs)} pairs, {products.count(0)} zero products, signed dot product {total:,}")
