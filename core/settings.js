const fs=require("fs"),path=require("path");
let _sp=null;
function gp(){if(_sp)return _sp;try{const{app}=require("electron");_sp=path.join(app.getPath("userData"),"config.json")}catch{_sp=path.join(__dirname,"..","settings","config.json")}return _sp}
const D={spotify:{clientId:"",clientSecret:"",accessToken:null,refreshToken:null},ui:{colors:{primary:"#ffffff",accent:"#1DB954",background:"rgba(255,255,255,0.05)",textSecondary:"rgba(255,255,255,0.70)"},rainbow:{enabled:false,mode:"static"},showCover:true,showTitle:true,showArtist:true,showAlbum:true,showProgress:true,showVisualizer:true,visualizerSensitivity:1.0,visualizerBars:180},audio:{source:"voicemeeter",customDeviceId:null,desktopSourceId:null},behavior:{volumeOpacity:true,volumeOpacityMin:0.22,volumeOpacityMax:0.88,fadeDelay:3000,alwaysOnTop:true,developerMode:false},update:{url:"",autoCheck:true}};
let s=null;
function dm(t,src){const r={...t};for(const k of Object.keys(src)){if(src[k]!==null&&typeof src[k]==="object"&&!Array.isArray(src[k]))r[k]=dm(t[k]||{},src[k]);else if(src[k]!==undefined)r[k]=src[k]}return r}
function load(){try{const p=gp();if(fs.existsSync(p)){const raw=fs.readFileSync(p,"utf-8").trim();if(raw){s=dm(D,JSON.parse(raw));return s}}}catch(e){console.log("SETTINGS LOAD ERROR:",e.message)}s=JSON.parse(JSON.stringify(D));save();return s}
function save(){try{const p=gp(),dir=path.dirname(p);if(!fs.existsSync(dir))fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p,JSON.stringify(s,null,2),"utf-8")}catch(e){console.log("SETTINGS SAVE ERROR:",e.message)}}
function get(key){if(!s)load();const keys=key.split(".");let v=s;for(const k of keys){if(v===null||v===undefined||typeof v!=="object")return undefined;v=v[k]}return v}
function set(key,val){if(!s)load();const keys=key.split(".");let o=s;for(let i=0;i<keys.length-1;i++){if(!o[keys[i]]||typeof o[keys[i]]!=="object")o[keys[i]]={};o=o[keys[i]]}o[keys[keys.length-1]]=val;save()}
function getAll(){if(!s)load();return JSON.parse(JSON.stringify(s))}
function replaceAll(n){s=dm(D,n);save()}
module.exports={load,save,get,set,getAll,replaceAll};
