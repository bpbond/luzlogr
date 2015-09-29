# JGCRIutils
Common utilities for [JGCRI](http://www.globalchange.umd.edu) work, to save people work and assist in documentation and reproducibility. In progress.

## Installing
To install this package:

1. Make sure you have `devtools` installed from CRAN and loaded.
2. `install_github("JGCRI/JGCRIutils")`

Then:

```R
library(JGCRIutils)
help(package = 'JGCRIutils')
```

## Logging

Three functions - `openlog()`, `printlog()`, `closelog()` - provide logging of script output. Lightweight but provides priority levels, custom logfiles, capturing all output (via `sink`), etc. For example:
```R
openlog("test")
printlog("message")
print("This will also appear in the logfile, as sink is TRUE")
closelog()
```
The resulting log file `./output/test/test.log.txt` looks like this:
```
Thu Sep 17 08:46:59 2015  Opening ./output/test/test.log.txt
Thu Sep 17 08:46:59 2015  message
[1] "This will also appear in the logfile, as sink is TRUE"
Thu Sep 17 08:46:59 2015  Closing ./output/test/test.log.txt
-------
R version 3.2.0 (2015-04-16)
Platform: x86_64-apple-darwin13.4.0 (64-bit)
Running under: OS X 10.10.5 (Yosemite)
```
For more details, see the documentation.
