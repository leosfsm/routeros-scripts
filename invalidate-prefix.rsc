#!rsc by RouterOS
# RouterOS script: ipv6-update
# Copyright (c) 2013-2025 Christian Hesse <mail@eworm.de>
#                         Leonardo David Monteiro <leo@cub3.xyz>
# https://rsc.eworm.de/COPYING.md
#
# provides: dhcp-script
# requires RouterOS, version=7.15
#
# update firewall and dns settings on IPv6 prefix change
# https://rsc.eworm.de/doc/ipv6-update.md

# Ensure global variable exists;
:global storedPrefix;
:global PdPrefix;
:global PdValid;

# File where we store the old prefix;
:local fileName "oldPrefix.txt";

# Read content from the file if the global variable is empty;
:if ($storedPrefix = "") do={
    :if ([/file find name=$fileName] != "") do={
        :local fileContent [/file get $fileName contents];
        :set storedPrefix $fileContent;
        :log info ("Loaded stored prefix: " . $storedPrefix);
    } else={
        /file add name=$fileName;
        :log info "No stored prefix found in file, starting with empty value.";
    };
};

# Get current prefix (e.g., "2001:db8:1234::/56");
:local currentPrefix $PdPrefix;

# Remove the "/56" (or whatever length is assigned) to use it in RA settings;
:set currentPrefix [:pick $currentPrefix 0 [:find $currentPrefix "/"]];

# Check if the prefix changed;
:if ($storedPrefix != "" && $storedPrefix != $currentPrefix) do={

    # Invalidate the old prefix in Router Advertisements;
    /ipv6 nd prefix add prefix=($storedPrefix . "/64") preferred-lifetime=0s valid-lifetime=0s interface=bridge;

    :log info ("Prefix changed. Updated from: " . $storedPrefix . " to: " . $currentPrefix);
};

# Update stored prefix to the new one;
:set storedPrefix $currentPrefix;

# Save the stored prefix to a file (outside the if statement);
/file set $fileName contents=$storedPrefix;
:log info ("Saved prefix to file: " . $storedPrefix);

# Log the current prefix (even if it hasn't changed);
:log info ("Current prefix: " . $currentPrefix);
