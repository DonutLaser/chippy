@echo off

set mode=%1

if "%mode%"=="release" (
    echo Building release binary
    odin build . -o:speed
) else (
    echo Building debug binary
    odin build . -debug
)