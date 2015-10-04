# luzlogr
Lightweight logging utilities for R scripts.

## Installing
To install this package:

1. Make sure you have `devtools` installed from CRAN and loaded.
2. `install_github("bpbond/luzlogr")`

Then:

```R
library(luzlogr)
help(package = 'luzlogr')
```

## Logging

Three functions - `openlog()`, `printlog()`, `closelog()` - provide logging of script output. They provide features including priority levels for logs and messages; optionally capturing all output (via `sink`); switching between logs; and logging to a text file or arbitrary [connection](https://stat.ethz.ch/R-manual/R-devel/library/base/html/connections.html). For example:
```R
openlog("test.log")
printlog("message")
closelog()
```
The resulting log file `test.log` looks like this:
```
Thu Sep 17 08:46:59 2015  Opening ./test.log
Thu Sep 17 08:46:59 2015  message
Thu Sep 17 08:46:59 2015  Closing test.log  flags = 0
-------
R version 3.2.0 (2015-04-16)
Platform: x86_64-apple-darwin13.4.0 (64-bit)
Running under: OS X 10.10.5 (Yosemite)
```

The following code snippets demonstrate three additional features: log and message levels, capturing all script output, and flagged messages.

```R
openlog("test.log", loglevel = 0, sink = TRUE)
printlog("This message will appear", level = 0)
print("This will also appear in the logfile, as sink is TRUE")
printlog("So will this (level 0 by default)")
printlog("This will not", level = -1)
printlog("Error!", flag = TRUE)
closelog(sessionInfo = FALSE)
```

results in:

```
Thu Oct  1 21:38:01 2015  Opening  ./test.log  
Thu Oct  1 21:38:34 2015  This message will appear  
[1] "This will also appear in the logfile, as sink is TRUE"
Thu Oct  1 21:38:45 2015  So will this (level 0 by default)  
** Flagged message: **
Thu Oct  1 21:39:13 2015  Error!  
Thu Oct  1 21:39:17 2015  Closing test.log  flags =  1  
```

For more details, see the documentation.
