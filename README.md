## mORMot for TMS WebCore

This repository contains a rough first stab at [mORMot v2](https://github.com/synopse/mORMot2) client code for [TMS WebCore](https://www.tmssoftware.com/site/tmswebcore.asp). The code has been extracted from the mORMot v1 CrossPlatform units and has some functionality missing (in particular the ORM functionality). My particular focus is on interface and method-based services so it's unlikely I'll be incorporating the ORM code - although pull requests are welcome.

Note that Web.mORMotClient.pas in the demo client has been manually modified - the creation of a mustache template file is on the to-do list.

### ToDo
- Restore DWScript compatibility (using Quartex)
- Mustache template
- Tests....

### Licence

See the original mORMot licence.