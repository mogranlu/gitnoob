#/bin/bash
winetricks -q msxml4 ie7
sleep 5 # allow WINE to finish writing to disk 
#wine 'c:\iexplore.lnk' 'talent.capgemini.com'
wine /home/morten/.wine/dosdevices/c\:/Program\ Files\ \(x86\)/Internet\ Explorer/iexplore.exe

