### Module: colors

- Purpose: define color variables and utilities for PS1/prompt

- Load:
```bash
szcdf_module_manager load colors
```

- Public commands:
  - `szcdf_colors define`: call `__init` to export color variables
  - `szcdf_colors undefine`: unset color variables

- Utilities:
  - `szcdf_colors__rgb R G B` -> 256-color index (R,G,B in 0..5)
  - `szcdf_colors__grayscale 0..100` -> 256-color index

- Variables set by `define` (subset):
  - `szcdfc_darkgray`, `szcdfc_gray20`, `szcdfc_gray`, `szcdfc_gray70`
  - `szcdfc_red_6`, `szcdfc_red_5`, `szcdfc_blue_6`, `szcdfc_blue_5`, `szcdfc_green_6`, `szcdfc_green_5`, `szcdfc_gold_6`, `szcdfc_gold_5`, `szcdfc_pink_6`, `szcdfc_pink_5`, `szcdfc_violet_6`, `szcdfc_violet_5`

- Example:
```bash
szcdf_module_manager load colors
szcdf_colors define
printf "\\e[38;5;${szcdfc_red_6}mred\\e[0m\n"
```