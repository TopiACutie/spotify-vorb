const fs=require("fs"),path=require("path");
let _sp=null;
function gp(){if(_sp)return _sp;try{const{app}=require("electron");_sp=path.join(app.getPath("userData"),"config.json")}catch{_sp=path.join(__dirname,"..","settings","config.json")}return _sp}
const VP={spiky:{sensitivity:1,bars:180},wavy:{sensitivity:1,bars:180},rounded:{sensitivity:1,bars:180},bars:{sensitivity:1,bars:180},dots:{sensitivity:1,bars:180},lines:{sensitivity:1,bars:180}};
const D={spotify:{clientId:"",clientSecret:"",accessToken:null,refreshToken:null},ui:{colors:{titleColor:"#ffffff",artistColor:"rgba(255,255,255,0.74)",vizColor:"#ffffff",accent:"#1DB954",background:"rgba(255,255,255,0.05)",textSecondary:"rgba(255,255,255,0.70)",progressFadeColor:"#ffffff"},rainbow:{enabled:false,mode:"static"},showCover:true,showTitle:true,showArtist:true,showAlbum:true,showProgress:true,showVisualizer:true,showStatusBar:true,vizStyle:"spiky",vizProfiles:VP},audio:{source:"voicemeeter",customDeviceId:null,desktopSourceId:null},behavior:{volumeOpacity:true,volumeOpacityMin:0.22,volumeOpacityMax:0.88,fadeDelay:3000,fadeOnPause:true,hiddenUntilPlaying:true,alwaysOnTop:true,developerMode:false,darkMode:false},update:{url:"",autoCheck:true}};
let s=null;
function dm(t,src){const r={...t};for(const k of Object.keys(src)){const v=src[k];if(v==null)continue;if(typeof v==="object"&&!Array.isArray(v))r[k]=dm(t[k]||{},v);else r[k]=v}return r}
function load(){try{const p=gp();if(fs.existsSync(p)){const raw=fs.readFileSync(p,"utf-8").trim();if(raw){s=dm(D,JSON.parse(raw));return s}}}catch(e){console.log("SETTINGS LOAD ERROR:",e.message)}s=JSON.parse(JSON.stringify(D));save();return s}
function save(){try{const p=gp(),dir=path.dirname(p);if(!fs.existsSync(dir))fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p,JSON.stringify(s,null,2),"utf-8")}catch(e){console.log("SETTINGS SAVE ERROR:",e.message)}}
function get(key){if(!s)load();const keys=key.split(".");let v=s;for(const k of keys){if(v==null||typeof v!=="object")return;v=v[k]}return v}
function set(key,val){if(!s)load();const keys=key.split(".");let o=s;for(let i=0;i<keys.length-1;i++){if(!o[keys[i]]||typeof o[keys[i]]!=="object")o[keys[i]]={};o=o[keys[i]]}o[keys[keys.length-1]]=val;save()}
function getAll(){if(!s)load();return JSON.parse(JSON.stringify(s))}
function replaceAll(n){if(!n||typeof n!=="object")return;s=dm(D,n);save()}
module.exports={load,save,get,set,getAll,replaceAll};
