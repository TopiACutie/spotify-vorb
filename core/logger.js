const fs=require("fs"),path=require("path"),LOG_DIR=path.join(__dirname,"..","settings"),LOG_FILE=path.join(LOG_DIR,"debug.log");
function ensureDir(){try{if(!fs.existsSync(LOG_DIR))fs.mkdirSync(LOG_DIR,{recursive:true})}catch{}}
function pad(n){return String(n).padStart(2,"0")}
function write(level,source,message,data){try{ensureDir();const d=new Date(),ts=d.getFullYear()+"-"+pad(d.getMonth()+1)+"-"+pad(d.getDate())+" "+pad(d.getHours())+":"+pad(d.getMinutes())+":"+pad(d.getSeconds());let line=`[${ts}] [${level}] [${source}] ${message}`;if(data!==undefined)line+=` | ${typeof data==="object"?JSON.stringify(data):String(data)}`.slice(0,520);fs.appendFileSync(LOG_FILE,line+"\n","utf-8")}catch{}}
module.exports={info:(s,m,d)=>write("INFO",s,m,d),warn:(s,m,d)=>write("WARN",s,m,d),error:(s,m,d)=>write("ERROR",s,m,d),clear:()=>{try{ensureDir();fs.writeFileSync(LOG_FILE,"","utf-8")}catch{}}};
