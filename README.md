
a simple motd plugin.


### install
- Make sure database info in webplugin.php  
- Upload webplugin.php to your web host  
- Upload motdex.smx to your {game dir}/addons/sourcemod/plugins
- Set the right wen url in {game dir}/cfg/KyleLu/motdex.cfg  
- Make sure 'motdex' in your database.cfg 
``` keyvalues
"motdex"
{
    "driver"    "mysql" // mysql support only
    "host"      "<HOSTNAME>"
    "database"  "<DATABASE>"
    "user"      "<USERNAME>"
    "pass"      "<PASSWORD>"
    "port"      "<PORT>"
}
```
- Start your server