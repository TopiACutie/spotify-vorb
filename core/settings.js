const fs=require("fs"),path=require("path");
let _settingsPath=null;
function getSettingsPath(){if(_settingsPath)return _settingsPath;try{const{app}=require("electron");_settingsPath=path.join(app.getPath("userData"),"config.json")}catch{_settingsPath=path.join(__dirname,"..","settings","config.json")}return _settingsPath}
const DEFAULTS={spotify:{clientId:"",clientSecret:"",accessToken:null,refreshToken:null},ui:{colors:{primary:"#ffffff",accent:"#1DB954",background:"rgba(255,255,255,0.05)",textSecondary:"rgba(255,255,255,0.70)"},rainbow:{enabled:false,mode:"static"},showCover:true,showTitle:true,showArtist:true,showAlbum:true,showProgress:true,showVisualizer:true,visualizerSensitivity:1.0,visualizerBars:180},audio:{source:"voicemeeter",customDeviceId:null,desktopSourceId:null},behavior:{volumeOpacity:true,volumeOpacityMin:0.22,volumeOpacityMax:0.88,fadeDelay:3000,alwaysOnTop:true},update:{url:"",autoCheck:true}};
let settings=null;
function deepMerge(t,s){const r={...t};for(const k of Object.keys(s)){if(s[k]!==null&&typeof s[k]==="object"&&!Array.isArray(s[k]))r[k]=deepMerge(t[k]||{},s[k]);else if(s[k]!==undefined)r[k]=s[k]}return r}
function load(){try{const sp=getSettingsPath();if(fs.existsSync(sp)){const raw=fs.readFileSync(sp,"utf-8").trim();if(raw){settings=deepMerge(DEFAULTS,JSON.parse(raw));return settings}}}catch(e){console.log("SETTINGS LOAD ERROR:",e.message)}settings=JSON.parse(JSON.stringify(DEFAULTS));save();return settings}
function save(){try{const sp=getSettingsPath(),dir=path.dirname(sp);if(!fs.existsSync(dir))fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(sp,JSON.stringify(settings,null,2),"utf-8")}catch(e){console.log("SETTINGS SAVE ERROR:",e.message)}}
function get(key){if(!settings)load();const keys=key.split(".");let val=settings;for(const k of keys){if(val===null||val===undefined||typeof val!=="object")return undefined;val=val[k]}return val}
function set(key,value){if(!settings)load();const keys=key.split(".");let obj=settings;for(let i=0;i<keys.length-1;i++){if(!obj[keys[i]]||typeof obj[keys[i]]!=="object")obj[keys[i]]={};obj=obj[keys[i]]}obj[keys[keys.length-1]]=value;save()}
function getAll(){if(!settings)load();return JSON.parse(JSON.stringify(settings))}
function replaceAll(n){settings=deepMerge(DEFAULTS,n);save()}
module.exports={load,save,get,set,getAll,replaceAll};
