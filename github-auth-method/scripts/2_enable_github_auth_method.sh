#!/bin/bash

# Enable Github Auth
vault auth enable github

# Write out Github config for the zaius org:
vault write auth/github/config organization=ZaiusInc


vault write auth/github/map/teams/administrators value=administrators
vault write auth/github/map/users/dfedick value=dfedick
