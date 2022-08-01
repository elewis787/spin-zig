# spin-zig
zig sdk for spin


## Building 

The spin-zig sdk leverages the c bindings produced from `wit-bindgen`. The `build.zig` links all necessary c libraries in order for the sdk to compile. 

To build the example and sdk run:

`zig build` 

The example binary can be found in `zig-out/bin/`


## Running the example 

From the root project dir
```bash 
cd example 
spin up
```

### Addtional logging 
`export WASMTIME_BACKTRACE_DETAILS=1`
`export RUST_LOG=spin=trace`

log files for `stdout` and `stderr` can be found in your `.spin` installation directory 
