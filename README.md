     _/\/\/\/\/\___   ____________   ____________   _/\/\______/\/\_   ____________   ____________
    _/\/\____/\/\_   ___/\/\/\___   ___/\/\/\/\_   _/\/\/\__/\/\/\_   ___/\/\/\___   _/\/\/\/\___ 
   _/\/\/\/\/\___   _/\/\/\/\/\_   _/\/\__/\/\_   _/\/\/\/\/\/\/\_   _/\/\__/\/\_   _/\/\__/\/\_  
  _/\/\__/\/\___   _/\/\_______   ___/\/\/\/\_   _/\/\__/\__/\/\_   _/\/\__/\/\_   _/\/\__/\/\_   
 _/\/\____/\/\_   ___/\/\/\/\_   _______/\/\_   _/\/\______/\/\_   ___/\/\/\___   _/\/\__/\/\_    
______________   ____________   _/\/\/\/\___   ________________   ____________   ____________     


RegMon measurement tool set for wireless research with Atheros WiFi hardware
============================================================================

This git repo includes:

-RegMon measurement tool provided as patches for ath5k, ath9k and madwifi Linux drivers in OpenWRT
-shell scripts to set up measurements on OpenWRT WiFi routers
-parser scripts (mainly AWK) to bring the raw RegMon data in proper shape to ananlyse with R
-R scripts to perform statistics and generate plots

How to reference to  RegMon ?
RegMon is developed as measurement tool in the dissertation of Thomas Huehn as OpenSource.
(http://opus4.kobv.de/opus4-tuberlin/frontdoor/index/index/docId/3939)

It is to be referenced as:
@phdthesis{Huehn2013,
 author      = {Thomas H{\"u}hn},
 title       = {A Measurement-Based Joint Power and Rate Controller for IEEE 802.11 Networks},
 year        = {2013}
 urn         = {urn:nbn:de:kobv:83-opus4-39397},
}

