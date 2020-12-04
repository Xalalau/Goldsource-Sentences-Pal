setlocal enableextensions enabledelayedexpansion
@echo off
cls

cd "%~dp0/lua"

.\core\lua54 ./gsp.lua

pause