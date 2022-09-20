#!/usr/bin/python

# Convert an alacrity config file to support Xresources color scheme

import yaml
import subprocess
from sys import argv

if len(argv) < 2:
    print("USAGE: CONFIG_FILE")
    exit(1)

fname = argv[1]

def printColor(color):
  if ('0x' in color):
    return '#'+color[2:]
  else:
    return '#'+color

with open(fname, encoding="utf-8") as file:
  yamlBody = yaml.unsafe_load(file)
  colorFile = yamlBody['colors']

  print(f"""
*background: {printColor(colorFile['primary']['background'])}
*foreground: {printColor(colorFile['primary']['foreground'])}

! black
*color0: {printColor(colorFile['normal']['black'])}
*color8: {printColor(colorFile['bright']['black'])}

! red
*color1: {printColor(colorFile['normal']['red'])}
*color9: {printColor(colorFile['bright']['red'])}

! green
*color2: {printColor(colorFile['normal']['green'])}
*color10: {printColor(colorFile['bright']['green'])}

! yellow
*color3: {printColor(colorFile['normal']['yellow'])}
*color11: {printColor(colorFile['bright']['yellow'])}

! blue
*color4: {printColor(colorFile['normal']['blue'])}
*color12: {printColor(colorFile['bright']['blue'])}

! magenta
*color5: {printColor(colorFile['normal']['magenta'])}
*color13: {printColor(colorFile['bright']['magenta'])}

! cyan
*color6: {printColor(colorFile['normal']['cyan'])}
*color14: {printColor(colorFile['bright']['cyan'])}

! white
*color7: {printColor(colorFile['normal']['white'])}
*color15: {printColor(colorFile['bright']['white'])}
""")
