max_brightness=$(cat "/sys/class/backlight/intel_backlight/max_brightness")
min_brightness="100"
curr=$(cat "/sys/class/backlight/intel_backlight/brightness")

echo "curr is $curr"

step=$((max_brightness/20))
echo "step is: $step"

new=$((curr - step))
echo "new is $new"

if ((new < min_brightness)); then
  tee "/sys/class/backlight/intel_backlight/brightness" <<< $min_brightness
else
  tee "/sys/class/backlight/intel_backlight/brightness" <<< $new
fi

