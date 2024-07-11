#!rsc by RouterOS
# RouterOS script: capsman-rolling-upgrade.wifi
# Copyright (c) 2018-2024 Christian Hesse <mail@eworm.de>
#                         Michael Gisbers <michael@gisbers.de>
# https://git.eworm.de/cgit/routeros-scripts/about/COPYING.md
#
# provides: capsman-rolling-upgrade.wifi
# requires RouterOS, version=7.13
#
# upgrade CAPs one after another
# https://git.eworm.de/cgit/routeros-scripts/about/doc/capsman-rolling-upgrade.md
#
# !! Do not edit this file, it is generated from template!

:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:do {
  :local ScriptName [ :jobname ];

  :global LogPrint;
  :global ScriptLock;

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :error false;
  }

  :local InstalledVersion [ /system/package/update/get installed-version ];

  :local RemoteCapCount [ :len [ /interface/wifi/capsman/remote-cap/find ] ];
  :if ($RemoteCapCount > 0) do={
    :local Delay (600 / $RemoteCapCount);
    :if ($Delay > 120) do={ :set Delay 120; }
    :foreach RemoteCap in=[ /interface/wifi/capsman/remote-cap/find where version!=$InstalledVersion ] do={
      :local RemoteCapVal [ /interface/wifi/capsman/remote-cap/get $RemoteCap ];
      :if ([ :len $RemoteCapVal ] > 1) do={
        :set ($RemoteCapVal->"name") ($RemoteCapVal->"common-name");
        $LogPrint info $ScriptName ("Starting upgrade for " . $RemoteCapVal->"name" . \
          " (" . $RemoteCapVal->"identity" . ")...");
        /interface/wifi/capsman/remote-cap/upgrade $RemoteCap;
      } else={
        $LogPrint warning $ScriptName ("Remote CAP vanished, skipping upgrade.");
      }
      :delay ($Delay . "s");
    }
  }
} on-error={ }
