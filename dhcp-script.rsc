#!rsc by RouterOS
# RouterOS script: ppp-on-up
# Copyright (c) 2013-2025 Christian Hesse <mail@eworm.de>
# https://rsc.eworm.de/COPYING.md
#
# requires RouterOS, version=7.15
#
# run scripts on ppp up
# https://rsc.eworm.de/doc/ppp-on-up.md

:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:local ExitOK false;
:do {
  :local ScriptName [ :jobname ];

  :global LogPrint;

  :local Interface $interface;

  :if ([ :typeof $"na-address" ] = "nothing" || \
       [ :typeof $"na-valid" ] = "nothing" || \
       [ :typeof $"pd-prefix" ] = "nothing" || \
       [ :typeof $"pd-valid" ] = "nothing") do={
    $LogPrint error $ScriptName ("This script is supposed to run from ip dhcp-client.");
    :set ExitOK true;
    :error false;
  }

  :global NaAddress $"na-address";
  :global NaValid $"na-valid";
  :global PdPrefix $"pd-prefix";
  :global PdValid $"pd-valid";

  :foreach Script in=[ /system/script/find where source~("\n# provides: dhcp-script\r?\n") ] do={
    :local ScriptName [ /system/script/get $Script name ];
    :do {
      $LogPrint debug $ScriptName ("Running script: " . $ScriptName);
      /system/script/run $Script;
    } on-error={
      $LogPrint warning $ScriptName ("Running script '" . $ScriptName . "' failed!");
    }
  }
} on-error={
  :global ExitError; $ExitError $ExitOK [ :jobname ];
}