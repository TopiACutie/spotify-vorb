const{exec}=require("child_process");
module.exports={isVoicemeeterInstalled:()=>new Promise(r=>{exec('powershell -Command "Get-CimInstance Win32_PnPEntity|Where{$_.Name-match\'voicemeeter\'}|Select-Object -ExpandProperty Name"',{timeout:5000},(e,o)=>{r(!e&&o.trim().length>0)})})};
