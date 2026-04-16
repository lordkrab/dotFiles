_gdi_config_root="${${(%):-%N}:A:h:h}"
typeset -g GDI_PYTHON_BIN="$_gdi_config_root/bin/gdi"

gdi() {
  python3 "$GDI_PYTHON_BIN" "$@"
}

gdi-view() {
  python3 "$GDI_PYTHON_BIN" view "$@"
}

gdi-select() {
  python3 "$GDI_PYTHON_BIN" select "$@"
}

unset _gdi_config_root
