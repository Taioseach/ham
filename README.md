# ham
Fast Linux util for overwriting files with random data, written in assembly.

It targets to be poorer, but faster version of `shred`.

## Usage
```bash
$ ham FILE
```
All bytes are replaced in place with random data.
At this moment `ham` supports only overwriting regular files. Block devices (e.g. partitions) cannot be formatted using `ham`.

## Building
Requirements: `nasm`, `ld` (or another linker) and `strip`.

To simply build `ham` in `build/<arch>` for all supported architectures run:

```bash
$ make
```

If you want to use different linker than default (`ld`), overwrite `LINKER` when running `make`. For example, for LLVM linker:

```bash
$ make LINKER=ld.lld
```

Supported instruction sets:
* `x86_64`
* *others in progress*

## Comparison with `shred`
Benchmarks were performed using `Intel Core i7-8700 CPU` and `WD10EZEX-21WN4A0 HDD`.

All values are averaged over 10 runs.

| Tool        | 32 MB       | 256 MB      | 1 GB        |
| ----------- | ----------- | ----------- | ----------- |
| `shred -n1` | 0.331s      | 2.186s      | 8.653s      |
| `ham`       | **0.017s**  | **0.320s**  | **0.429s**  |

