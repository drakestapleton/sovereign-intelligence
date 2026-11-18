"""Independent GGUF directory reader and numeric oracle. Test dependency: gguf==0.17.1."""
import hashlib
import pathlib
import struct
import sys

from gguf import GGUFReader


def inspect(path):
    reader = GGUFReader(path)
    def field(name):
        return reader.get_field(name).contents()
    tensor = next(t for t in reader.tensors if t.name == "blk.0.attn_q.weight")
    assert tensor.tensor_type.name == "Q8_0"
    width = int(tensor.shape[0])
    assert width % 32 == 0
    length = width // 32 * 34
    with open(path, "rb") as stream:
        stream.seek(tensor.data_offset)
        row = stream.read(length)
    # Integral activations and signed bytes give exact integer block sums.
    total = 0.0
    for start in range(0, length, 34):
        scale, *weights = struct.unpack_from("<e32b", row, start)
        base = start // 34 * 32
        total += scale * sum(q * ((base + j) % 7 - 3) for j, q in enumerate(weights))
    bits, = struct.unpack("<I", struct.pack("<f", total))
    print(field("general.architecture"), field("tokenizer.ggml.model"), field("general.file_type"),
          width, tensor.data_offset, length, pathlib.Path(path).stat().st_size,
          hashlib.sha256(row).hexdigest(), bits)


for model in sys.argv[1:]:
    inspect(model)
