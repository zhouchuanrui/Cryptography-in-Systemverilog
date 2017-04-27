
## Logging Issue

`aes_obj.setLogging()` turns on logging when `aes_obj` performs key expansion, encrytion or decryption. 
`aes_obj.setMuted() shuts the logging, and that is the default behavior of an `aes_obj`.
Note that `setLogging()` and `setMuted()` are static methods.
You can add `+define+NO_LOG` to compiling command to remove all logging facilities.

