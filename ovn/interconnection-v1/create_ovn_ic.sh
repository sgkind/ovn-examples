#!/bin/bash -x

/usr/share/ovn/scripts/ovn-ctl \
    --db-ic-nb-create-insecure-remote=yes \
    --db-ic-sb-create-insecure-remote=yes \
    start_ic_ovsdb

ovn-ic-nbctl ts-add ts1
 