
if [[ $# -lt 2 ]]
then
  echo "Please pass device name & app name without white spaces in the names use _ instead"
  echo "Example: get_temp_and_fps_chromeos.sh HP_Dragonfly Fifa_Soccer "
  exit 1
fi

device=$1
app=$2
date=$(date +"%m_%d_%Y_%H-%M-%S") 
app_surface_view=""
thermal_zones_count=0
label_count=0
hwmon=0
case "$app" in 
  'Asphalt9') app_surface_view="com.gameloft.android.ANMP.GloftA9HM/com.gameloft.android.ANMP.GloftA9HM.MainActivity"
  ;;
  
  'Candy_Crush_Saga') app_surface_view="com.king.candycrushsaga/com.king.candycrushsaga.CandyCrushSagaActivity"
  ;;

  'Fifa_Soccer') app_surface_view="com.ea.gp.fifamobile/com.ea.gp.fifamobile.FifaMainActivity"
  ;;

  'Raid_Shadow_Legends') app_surface_view="com.plarium.raidlegends/com.plarium.unity_app.UnityMainActivity"
  ;;

  'Roblox') app_surface_view="com.roblox.client/com.roblox.client.ActivityNativeMain"
  ;;
    
  'Dota_Underlords') app_surface_view="com.valvesoftware.underlords/com.valvesoftware.underlords.appmain" 
  ;;
    
  'Homescapes') app_surface_view="com.playrix.homescapes/com.playrix.homescapes.GoogleGameActivity"
  ;;
   
  'Toca_Life') app_surface_view="com.tocaboca.tocalifeworld/com.tocaboca.activity.TocaBocaGameActivity"
  ;;

  'Geometry_Dash') app_surface_view='com.robtopx.geometryjumplite/com.robtopx.geometryjumplite.GeometryDashLite'
  ;;
  
  'Archero') app_surface_view="com.habby.archero/com.habby.archero.UnityPlayerActivity"
  ;;

  'Free_Fire') app_surface_view="com.dts.freefireth/com.dts.freefireth.FFMainActivity"
  ;;

  'Spider_Solitaire') app_surface_view="com.mobilityware.spider/com.mobilityware.spider.Spider"
  ;;

  'Gacha_Club') app_surface_view="air.com.lunime.gachaclub/air.com.lunime.gachaclub.AIRAppEntry"
  ;;
 
  'Among_Us') app_surface_view="com.innersloth.spacemafia/com.innersloth.spacemafia.EosUnityPlayerActivity"
  ;;

  'Minecraft_EDU') app_surface_view="com.mojang.minecraftedu/com.mojang.minecraftpe.MainActivity"
  ;;

  'Minecraft') app_surface_view="com.mojang.minecraftpe/com.mojang.minecraftpe.MainActivity"
  ;;
  
  'Netflix') app_surface_view="com.netflix.mediaclient/com.netflix.mediaclient.ui.launch.UIWebViewActivity"
  ;;
  
  'Hulu') app_surface_view="com.hulu.plus/com.hulu.features.playback.PlayerActivity"
  ;;

  'Disney+') app_surface_view="com.disney.disneyplus/com.bamtechmedia.dominguez.player.ui.experiences.legacy.v1.MobilePlaybackActivity"
  ;;
  *) echo "${app} is not supported yet. Supported apps are :"
     echo "Asphalt9"
     echo "Candy_Crush_Saga"
     echo "Fifa_Soccer"
     echo "Raid_Shadow_Legends"
     echo "Roblox"
     echo "Dota_Underlords"
     echo "Homescapes"
     echo "Toca_Life"
     echo "Geometry_Dash"
     echo "Archero"
     echo "Free_Fire"
     echo "Spider_Solitaire"
     echo "Among_Us"
     echo "Minecraft_EDU"
     echo "Minecraft"
     echo "Netflix"
     echo "Hulu"
     echo "Disney+"
     exit 2
  ;;
esac


case "$device" in 
  'HP_Dragonfly') thermal_zones_count=8
  ;;

  'Lenovo_Duet5') thermal_zones_count=28
  ;;
  'Asus_C425') thermal_zones_count=7
  ;;
  'HP_14a') thermal_zones_count=6 ; label_count=5 ; hwmon=2
  ;;
  'Acer_315') thermal_zones_count=6 ; label_count=3 ; hwmon=1
  ;;
  'Acer_712') thermal_zones_count=6 ; label_count=3 ; hwmon=1
  ;;
  *)echo "${device} is not supported yet. Supported apps are :"
    echo "HP_Dragonfly"
    echo "Lenovo_Duet5"
    echo "Asus_C425"
    echo "HP_14a"
    echo "Acer_315"
    echo "Acer_712"
    exit 3
  ;;
esac


csv_file_name="/home/chronos/user/Downloads/thermal_zones_fps_${device}_${app}_${date}.csv"
touch "$csv_file_name"

adb shell 'dumpsys SurfaceFlinger --timestats -enable'

for i in `seq 1 900` ;
do
  echo -n $( date +"%m_%d_%Y  %T, ") | tee -a $csv_file_name ;
  fps=$(adb shell 'dumpsys SurfaceFlinger --timestats -dump -clear' | grep "$app_surface_view" -A40 | grep 'averageFPS' | cut -d '=' -f2)
  if [[ $i -eq 1 ]]
  then
    echo -n "FPS," | tee -a $csv_file_name;
    for l in `seq 1 $label_count`
    do
      cat /sys/class/hwmon/hwmon${hwmon}/temp${l}_label | tr '\n' ','  | tee -a $csv_file_name
    done
  for j in `seq 0 $thermal_zones_count`;
  do
    cat /sys/class/thermal/thermal_zone${j}/type | tr '\n' ','  |  tee -a $csv_file_name ;
  done
  else
    echo -n "${fps}," | tee -a $csv_file_name;
   # for s in `seq 1 $label_count`
   # do
     cat /sys/class/hwmon/hwmon${hwmon}/temp*_input | tr '\n' ','  | tee -a $csv_file_name
   # done  
    #echo -n "    "| tee -a $csv_file_name ; 
    cat /sys/class/thermal/thermal_zone*/temp | tr '\n' ','  |  tee -a $csv_file_name ;  
  sleep 1 ;
 fi
 echo | tee -a $csv_file_name ;
done
