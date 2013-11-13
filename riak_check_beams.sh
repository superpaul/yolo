#!/usr/bin/env bash

ps -ef | grep 'beam' | grep -v 'grep' | awk '{print $2" "$8}'