# State lives for the login session and survives service restarts. This avoids
# reopening a dismissed warning just because Home Manager restarted the service.
state_dir="$XDG_RUNTIME_DIR/battery-warning"
mkdir -p "$state_dir"
acknowledged="$state_dir/acknowledged"

while true; do
  found=false
  critical=false
  recovered=true

  for battery in /sys/class/power_supply/*; do
    [[ -r "$battery/type" && -r "$battery/capacity" ]] || continue
    [[ $(cat "$battery/type") == Battery ]] || continue
    # Ignore batteries belonging to mice, keyboards and other peripherals.
    if [[ -r "$battery/scope" && $(cat "$battery/scope") == Device ]]; then
      continue
    fi
    if [[ -r "$battery/present" && $(cat "$battery/present") == 0 ]]; then
      continue
    fi

    capacity=$(cat "$battery/capacity")
    [[ "$capacity" =~ ^[0-9]+$ ]] || continue
    found=true
    if (( 10#$capacity <= 5 )); then
      recovered=false
      if [[ -r "$battery/status" && $(cat "$battery/status") == Discharging ]]; then
        critical=true
      fi
    fi
  done

  # A desktop without an internal battery does not need a polling service.
  if [[ "$found" == false ]]; then
    exit 0
  fi

  if [[ "$recovered" == true ]]; then
    rm -f "$acknowledged"
  elif [[ "$critical" == true && ! -e "$acknowledged" ]]; then
    echo "Internal battery at 5% or below; displaying fullscreen warning"
    # Failed launches are retried; a successful overlay stays until dismissed.
    if battery-warning; then
      touch "$acknowledged"
    else
      echo "Could not display battery warning; retrying in 15 seconds" >&2
    fi
  fi

  sleep 15
done
