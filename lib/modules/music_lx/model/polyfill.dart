final polyfillJS = """
// import compatibleConsole from './console.js';
// import { Buffer as BufferPolyfill } from './BufferPolyfill.js';
// import zlib from './zlib.js';
// import crypto from './crypto.js';

// 检查并应用兼容性补丁
if(typeof globalThis.window==='undefined') globalThis.window=globalThis;
if(typeof globalThis.self==='undefined') globalThis.self=globalThis;
if(typeof globalThis.top==='undefined') globalThis.top=globalThis;
if(typeof globalThis.parent==='undefined') globalThis.parent=globalThis;
if(typeof globalThis.global==='undefined') globalThis.global=globalThis;
globalThis.document=globalThis.document||{owner:null,readyState:'complete',cookie:'',referrer:'',domain:'localhost',location:{href:'https://localhost/',protocol:'https:',host:'localhost'},createElement:function(tag){var el={tagName:tag.toUpperCase(),nodeName:tag.toUpperCase(),style:{},className:'',innerHTML:'',innerText:'',textContent:'',outerHTML:'',children:[],childNodes:[],firstChild:null,lastChild:null,nextSibling:null,previousSibling:null,parentNode:null,parentElement:null,ownerDocument:globalThis.document,owner:null,nodeType:1,setAttribute:function(k,v){this[k]=v},getAttribute:function(k){return this[k]||null},removeAttribute:function(k){delete this[k]},appendChild:function(c){this.children.push(c);c.parentNode=this;return c},removeChild:function(c){var i=this.children.indexOf(c);if(i>=0)this.children.splice(i,1);return c},insertBefore:function(n,r){var i=this.children.indexOf(r);if(i>=0)this.children.splice(i,0,n);else this.children.push(n);n.parentNode=this;return n},addEventListener:function(){},removeEventListener:function(){},dispatchEvent:function(){return true},getElementsByClassName:function(){return[]},getElementsByTagName:function(){return[]},querySelector:function(){return null},querySelectorAll:function(){return[]},classList:{add:function(){},remove:function(){},contains:function(){return false},toggle:function(){}}};if(tag==='canvas'){el.getContext=function(){return{fillRect:function(){},clearRect:function(){},getImageData:function(x,y,w,h){return{data:new Uint8Array(w*h*4)}},putImageData:function(){},createImageData:function(){return{data:new Uint8Array(0)}},setTransform:function(){},drawImage:function(){},save:function(){},fillText:function(){},restore:function(){},beginPath:function(){},moveTo:function(){},lineTo:function(){},closePath:function(){},stroke:function(){},translate:function(){},scale:function(){},rotate:function(){},arc:function(){},fill:function(){},measureText:function(){return{width:0}}}};el.toDataURL=function(){return'data:image/png;base64,'}}if(tag==='input'||tag==='textarea'){el.value='';el.focus=function(){};el.blur=function(){}}if(tag==='form'){el.submit=function(){}}if(tag==='script'){el.src=''}return el},getElementById:function(){return null},getElementsByTagName:function(){return[]},getElementsByClassName:function(){return[]},querySelector:function(){return null},querySelectorAll:function(){return[]},addEventListener:function(){},removeEventListener:function(){},dispatchEvent:function(){return true},createEvent:function(){return{initEvent:function(){},preventDefault:function(){},stopPropagation:function(){}}},documentElement:{nodeName:'HTML',owner:null,nodeType:9,style:{}},body:{appendChild:function(){return null},removeChild:function(){return null},owner:null,nodeType:1,style:{}},head:{appendChild:function(){return null},removeChild:function(){return null},owner:null,nodeType:1,style:{}},createTextNode:function(t){return{textContent:t,nodeType:3,owner:null,parentNode:null}},createComment:function(t){return{textContent:t,nodeType:8,owner:null}},createDocumentFragment:function(){return{children:[],appendChild:function(c){this.children.push(c);return c},owner:null,nodeType:11}},createRange:function(){return{selectNode:function(){},collapse:function(){},getBoundingClientRect:function(){return{top:0,left:0,bottom:0,right:0,width:0,height:0}}}},implementation:{hasFeature:function(){return true},createHTMLDocument:function(){return globalThis.document}}};
globalThis.navigator=globalThis.navigator||{userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',platform:'Win32',language:'zh-CN',languages:['zh-CN','zh','en-US','en'],onLine:true,cookieEnabled:true,hardwareConcurrency:8,deviceMemory:8,maxTouchPoints:0,vendor:'Google Inc.',appName:'Netscape',appVersion:'5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',product:'Gecko',productSub:'20030107',userAgentData:{brands:[{brand:'Not_A Brand',version:'8'},{brand:'Chromium',version:'120'}],mobile:false,platform:'Windows'},connection:{effectiveType:'4g',downlink:10,rtt:50},mediaDevices:{enumerateDevices:function(){return Promise.resolve([])}},permissions:{query:function(){return Promise.resolve({state:'granted'})}},clipboard:{readText:function(){return Promise.resolve('')},writeText:function(){return Promise.resolve()}},getBattery:function(){return Promise.resolve({charging:true,chargingTime:0,dischargingTime:Infinity,level:1})},getGamepads:function(){return[]},sendBeacon:function(){return true},webkitGetUserMedia:function(){},mimeTypes:{length:0},plugins:{length:0}};
globalThis.location=globalThis.location||{href:'https://localhost/',protocol:'https:',host:'localhost',hostname:'localhost',origin:'https://localhost',port:'',pathname:'/',search:'',hash:''};
globalThis.screen=globalThis.screen||{width:1920,height:1080,colorDepth:24,pixelDepth:24,availWidth:1920,availHeight:1040,orientation:{type:'landscape-primary',angle:0}};
globalThis.history=globalThis.history||{length:1,pushState:function(){},replaceState:function(){},go:function(){},back:function(){},forward:function(){}};
globalThis.localStorage=globalThis.localStorage||{getItem:function(){return null},setItem:function(){},removeItem:function(){},clear:function(){},length:0};
globalThis.sessionStorage=globalThis.sessionStorage||{getItem:function(){return null},setItem:function(){},removeItem:function(){},clear:function(){},length:0};
// if(typeof globalThis.crypto==='undefined'||!globalThis.crypto.getRandomValues){
//   var _cryptoRng=function(){var _s=Date.now();return function(){_s=(_s*9301+49297)%233280;return _s/233280}};
//   globalThis.crypto={getRandomValues:function(arr){if(arr instanceof Uint8Array){for(var i=0;i<arr.length;i++)arr[i]=Math.floor(Math.random()*256)}else if(arr instanceof Uint16Array){for(var i=0;i<arr.length;i++)arr[i]=Math.floor(Math.random()*65536)}else if(arr instanceof Uint32Array){for(var i=0;i<arr.length;i++)arr[i]=Math.floor(Math.random()*4294967296)}else if(Array.isArray(arr)){for(var i=0;i<arr.length;i++)arr[i]=Math.floor(Math.random()*256)}return arr},randomUUID:function(){return'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,function(c){var r=Math.random()*16|0;return(c==='x'?r:(r&0x3|0x8)).toString(16)})},subtle:{digest:function(algo,data){return new Promise(function(resolve,reject){try{var algoName=typeof algo==='string'?algo:algo.name;var dataStr='';if(typeof data==='string'){dataStr=data}else if(data instanceof ArrayBuffer||data instanceof Uint8Array){var bytes=new Uint8Array(data);for(var i=0;i<bytes.length;i++)dataStr+=String.fromCharCode(bytes[i])}console.log('[Polyfill] crypto.subtle.digest called, algo='+algoName+', dataLen='+dataStr.length);var hexResult=__lx_native__('cf_worker_key','sha256_compute',dataStr);console.log('[Polyfill] crypto.subtle.digest result, hexLen='+(hexResult?hexResult.length:0)+', hexPrefix='+(hexResult?hexResult.substring(0,16):'null'));var ab=new ArrayBuffer(hexResult.length/2);var view=new Uint8Array(ab);for(var i=0;i<hexResult.length;i+=2)view[i/2]=parseInt(hexResult.substr(i,2),16);resolve(ab)}catch(e){console.log('[Polyfill] crypto.subtle.digest ERROR: '+e.message);reject(e)}})},importKey:function(){return Promise.resolve({})},exportKey:function(){return Promise.resolve(new ArrayBuffer(0))},encrypt:function(){return Promise.resolve(new ArrayBuffer(0))},decrypt:function(){return Promise.resolve(new ArrayBuffer(0))},sign:function(){return Promise.resolve(new ArrayBuffer(0))},verify:function(){return Promise.resolve(false)},generateKey:function(){return Promise.resolve({})},deriveBits:function(){return Promise.resolve(new ArrayBuffer(0))},deriveKey:function(){return Promise.resolve({})}}};
// }
if(typeof globalThis.performance==='undefined'){
  var _perfStart=Date.now();
  globalThis.performance={now:function(){return Date.now()-_perfStart},mark:function(){},measure:function(){},getEntries:function(){return[]},getEntriesByName:function(){return[]},getEntriesByType:function(){return[]},clearMarks:function(){},clearMeasures:function(){},timeOrigin:_perfStart};
}
if(typeof TextEncoder==='undefined'){globalThis.TextEncoder=function(){this.encode=function(s){var bytes=[];for(var i=0;i<s.length;i++){var c=s.charCodeAt(i);if(c<128)bytes.push(c);else if(c<2048){bytes.push((c>>6)|192);bytes.push((c&63)|128)}else{bytes.push((c>>12)|224);bytes.push(((c>>6)&63)|128);bytes.push((c&63)|128)}}return new Uint8Array(bytes)}}}
if(typeof TextDecoder==='undefined'){globalThis.TextDecoder=function(){this.decode=function(arr){var s='';for(var i=0;i<arr.length;i++)s+=String.fromCharCode(arr[i]);return s}}}
// if(typeof btoa==='undefined'){globalThis.btoa=function(str){var chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';var output='';for(var i=0;i<str.length;i+=3){var b1=str.charCodeAt(i);var b2=i+1<str.length?str.charCodeAt(i+1):0;var b3=i+2<str.length?str.charCodeAt(i+2):0;output+=chars.charAt(b1>>2)+chars.charAt(((b1&3)<<4)|(b2>>4))+(i+1<str.length?chars.charAt(((b2&15)<<2)|(b3>>6)):'=')+(i+2<str.length?chars.charAt(b3&63):'=')}return output}}
// if(typeof atob==='undefined'){globalThis.atob=function(b64){var chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';var output='';var i=0;b64=b64.replace(/[^A-Za-z0-9\\+\/\=]/g,'');while(i<b64.length){var e1=chars.indexOf(b64.charAt(i++));var e2=chars.indexOf(b64.charAt(i++));var e3=chars.indexOf(b64.charAt(i++));var e4=chars.indexOf(b64.charAt(i++));output+=String.fromCharCode((e1<<2)|(e2>>4))+(e3!==64?String.fromCharCode(((e2&15)<<4)|(e3>>2)):'')+(e4!==64?String.fromCharCode(((e3&3)<<6)|e4):'')}return output}}
// if(typeof globalThis.XMLHttpRequest==='undefined'){
//   globalThis.XMLHttpRequest=function(){this.readyState=0;this.status=0;this.statusText='';this.responseText='';this.responseXML=null;this.response=null;this.responseType='';this.withCredentials=false;this.timeout=0;this.onreadystatechange=null;this.onload=null;this.onerror=null;this.onabort=null;this.ontimeout=null;this.onprogress=null;this.upload={addEventListener:function(){}};this._headers={};this._method='GET';this._url='';this._async=true;this._aborted=false};
//   globalThis.XMLHttpRequest.prototype.open=function(method,url,async){this._method=method;this._url=url;this._async=async!==false;this.readyState=1};
//   globalThis.XMLHttpRequest.prototype.send=function(body){var self=this;this.readyState=2;if(this._url){globalThis.lx.request(this._url,{method:this._method,body:body,headers:this._headers},function(err,resp,respBody){if(self._aborted)return;if(err){self.readyState=4;self.status=0;if(self.onerror)self.onerror(err)}else{self.readyState=4;self.status=resp?resp.statusCode:0;self.statusText=resp?resp.statusMessage:'';self.responseText=typeof respBody==='string'?respBody:(respBody?JSON.stringify(respBody):'');self.response=self.responseText;if(self.onload)self.onload()}if(self.onreadystatechange)self.onreadystatechange()})}else{this.readyState=4;this.status=0;if(this.onerror)this.onerror(new Error('No URL'))}};
//   globalThis.XMLHttpRequest.prototype.abort=function(){this._aborted=true;this.readyState=4;if(this.onabort)this.onabort()};
//   globalThis.XMLHttpRequest.prototype.setRequestHeader=function(k,v){this._headers[k]=v};
//   globalThis.XMLHttpRequest.prototype.getResponseHeader=function(){return null};
//   globalThis.XMLHttpRequest.prototype.getAllResponseHeaders=function(){return''};
//   globalThis.XMLHttpRequest.prototype.addEventListener=function(type,fn){this['on'+type]=fn};
//   globalThis.XMLHttpRequest.prototype.removeEventListener=function(){};
//   globalThis.XMLHttpRequest.prototype.overrideMimeType=function(){};
// }
if(typeof globalThis.URL==='undefined'){
  globalThis.URL=function(url,base){this.href=url;this.protocol='';this.host='';this.hostname='';this.port='';this.pathname='';this.search='';this.hash='';this.origin='';try{var m=url.match(new RegExp('^(https?:)\\/\\/([^\\/:]+)(:\\d+)?([^?#]*)(\\?[^#]*)?(#.*)?\$'));if(m){this.protocol=m[1];this.hostname=m[2];this.port=m[3]?m[3].slice(1):'';this.host=this.hostname+(this.port?':'+this.port:'');this.pathname=m[4]||'/';this.search=m[5]||'';this.hash=m[6]||'';this.origin=this.protocol+'//'+this.host}}catch(e){}};
  globalThis.URL.createObjectURL=function(){return'blob:null'};
  globalThis.URL.revokeObjectURL=function(){};
}
if(typeof globalThis.URLSearchParams==='undefined'){
  globalThis.URLSearchParams=function(init){this._params=[];if(typeof init==='string'){if(init.charAt(0)==='?')init=init.slice(1);init.split('&').forEach(function(pair){var idx=pair.indexOf('=');if(idx>=0)this._params.push([decodeURIComponent(pair.slice(0,idx)),decodeURIComponent(pair.slice(idx+1))]);else if(pair)this._params.push([decodeURIComponent(pair),''])}.bind(this))}};
  globalThis.URLSearchParams.prototype.get=function(name){for(var i=0;i<this._params.length;i++){if(this._params[i][0]===name)return this._params[i][1]}return null};
  globalThis.URLSearchParams.prototype.set=function(name,value){var found=false;for(var i=0;i<this._params.length;i++){if(this._params[i][0]===name){this._params[i][1]=value;found=true;break}}if(!found)this._params.push([name,value])};
  globalThis.URLSearchParams.prototype.has=function(name){for(var i=0;i<this._params.length;i++){if(this._params[i][0]===name)return true}return false};
  globalThis.URLSearchParams.prototype.append=function(name,value){this._params.push([name,value])};
  globalThis.URLSearchParams.prototype.toString=function(){return this._params.map(function(p){return encodeURIComponent(p[0])+'='+encodeURIComponent(p[1])}).join('&')};
  globalThis.URLSearchParams.prototype.forEach=function(fn){this._params.forEach(function(p){fn(p[1],p[0])})};
}
if(typeof globalThis.Headers==='undefined'){
  globalThis.Headers=function(init){this._map={};if(init&&typeof init==='object'){if(init instanceof Array){init.forEach(function(pair){this._map[pair[0].toLowerCase()]=pair[1]}.bind(this))}else{Object.keys(init).forEach(function(k){this._map[k.toLowerCase()]=init[k]}.bind(this))}}};
  globalThis.Headers.prototype.get=function(name){return this._map[name.toLowerCase()]||null};
  globalThis.Headers.prototype.set=function(name,value){this._map[name.toLowerCase()]=value};
  globalThis.Headers.prototype.has=function(name){return name.toLowerCase()in this._map};
  globalThis.Headers.prototype.delete=function(name){delete this._map[name.toLowerCase()]};
  globalThis.Headers.prototype.append=function(name,value){this._map[name.toLowerCase()]=value};
  globalThis.Headers.prototype.forEach=function(fn){var self=this;Object.keys(this._map).forEach(function(k){fn(self._map[k],k)})};
}
if(typeof globalThis.FormData==='undefined'){
  globalThis.FormData=function(){this._data=[]};
  globalThis.FormData.prototype.append=function(name,value){this._data.push([name,value])};
  globalThis.FormData.prototype.get=function(name){for(var i=0;i<this._data.length;i++){if(this._data[i][0]===name)return this._data[i][1]}return null};
  globalThis.FormData.prototype.has=function(name){for(var i=0;i<this._data.length;i++){if(this._data[i][0]===name)return true}return false};
}
if(typeof globalThis.Blob==='undefined'){
  globalThis.Blob=function(parts,options){this.size=0;this.type=(options&&options.type)||'';var data=[];if(parts){parts.forEach(function(p){if(typeof p==='string'){for(var i=0;i<p.length;i++)data.push(p.charCodeAt(i))}else if(p instanceof Uint8Array||Array.isArray(p)){data=data.concat(Array.from(p))}})}this.size=data.length;this._data=data;this.arrayBuffer=function(){return Promise.resolve(new Uint8Array(data).buffer)};this.text=function(){var s='';for(var i=0;i<data.length;i++)s+=String.fromCharCode(data[i]);return Promise.resolve(s)};this.slice=function(start,end){return new Blob([new Uint8Array(data.slice(start,end))],{type:this.type})}};
}
if(typeof globalThis.File==='undefined'){
  globalThis.File=function(parts,name,options){Blob.call(this,parts,options);this.name=name;this.lastModified=Date.now()};
  globalThis.File.prototype=Object.create(Blob.prototype);
}
if(typeof globalThis.FileReader==='undefined'){
  globalThis.FileReader=function(){this.readyState=0;this.result=null;this.onload=null;this.onerror=null;this.readAsText=function(blob){var self=this;this.readyState=2;this.result=blob.text?blob.text():'';if(this.onload)setTimeout(function(){self.onload({target:self})},0)};this.readAsArrayBuffer=function(blob){var self=this;this.readyState=2;this.result=blob.arrayBuffer?blob.arrayBuffer():new ArrayBuffer(0);if(this.onload)setTimeout(function(){self.onload({target:self})},0)};this.readAsDataURL=function(blob){var self=this;this.readyState=2;this.result='data:'+blob.type+';base64,'+btoa(String.fromCharCode.apply(null,blob._data||[]));if(this.onload)setTimeout(function(){self.onload({target:self})},0)}};
}
if(typeof globalThis.AbortController==='undefined'){
  globalThis.AbortController=function(){this.signal={aborted:false,_listeners:[],addEventListener:function(type,fn){this._listeners.push(fn)},removeEventListener:function(){},throwIfAborted:function(){if(this.aborted)throw new Error('AbortError')}};this.abort=function(){this.signal.aborted=true;this.signal._listeners.forEach(function(fn){fn()})}};
  globalThis.AbortSignal=function(){this.aborted=false;this._listeners=[];this.addEventListener=function(type,fn){this._listeners.push(fn)};this.removeEventListener=function(){};this.throwIfAborted=function(){if(this.aborted)throw new Error('AbortError')}};
  globalThis.AbortSignal.abort=function(){var s=new AbortSignal();s.aborted=true;return s};
  globalThis.AbortSignal.timeout=function(ms){var s=new AbortSignal();setTimeout(function(){s.aborted=true;s._listeners.forEach(function(fn){fn()})},ms);return s};
}
if(typeof globalThis.Event==='undefined'){
  globalThis.Event=function(type,opts){this.type=type;this.bubbles=(opts&&opts.bubbles)||false;this.cancelable=(opts&&opts.cancelable)||false;this.defaultPrevented=false;this.target=null;this.currentTarget=null;this.timeStamp=Date.now()};
  globalThis.Event.prototype.preventDefault=function(){this.defaultPrevented=true};
  globalThis.Event.prototype.stopPropagation=function(){};
  globalThis.Event.prototype.stopImmediatePropagation=function(){};
}
if(typeof globalThis.CustomEvent==='undefined'){
  globalThis.CustomEvent=function(type,opts){Event.call(this,type,opts);this.detail=(opts&&opts.detail)||null};
  globalThis.CustomEvent.prototype=Object.create(Event.prototype);
}
if(typeof globalThis.EventTarget==='undefined'){
  globalThis.EventTarget=function(){this._listeners={}};
  globalThis.EventTarget.prototype.addEventListener=function(type,fn){if(!this._listeners[type])this._listeners[type]=[];this._listeners[type].push(fn)};
  globalThis.EventTarget.prototype.removeEventListener=function(type,fn){if(this._listeners[type]){var i=this._listeners[type].indexOf(fn);if(i>=0)this._listeners[type].splice(i,1)}};
  globalThis.EventTarget.prototype.dispatchEvent=function(event){event.target=this;event.currentTarget=this;if(this._listeners[event.type]){this._listeners[event.type].forEach(function(fn){fn(event)})}return!event.defaultPrevented};
}
if(typeof globalThis.DOMParser==='undefined'){
  globalThis.DOMParser=function(){};
  globalThis.DOMParser.prototype.parseFromString=function(str,type){return globalThis.document};
}
if(typeof globalThis.MutationObserver==='undefined'){
  globalThis.MutationObserver=function(cb){this._cb=cb};
  globalThis.MutationObserver.prototype.observe=function(){};
  globalThis.MutationObserver.prototype.disconnect=function(){};
  globalThis.MutationObserver.prototype.takeRecords=function(){return[]};
}
if(typeof globalThis.IntersectionObserver==='undefined'){
  globalThis.IntersectionObserver=function(cb){this._cb=cb};
  globalThis.IntersectionObserver.prototype.observe=function(){};
  globalThis.IntersectionObserver.prototype.disconnect=function(){};
  globalThis.IntersectionObserver.prototype.unobserve=function(){};
}
if(typeof globalThis.ResizeObserver==='undefined'){
  globalThis.ResizeObserver=function(cb){this._cb=cb};
  globalThis.ResizeObserver.prototype.observe=function(){};
  globalThis.ResizeObserver.prototype.disconnect=function(){};
  globalThis.ResizeObserver.prototype.unobserve=function(){};
}
if(typeof globalThis.requestAnimationFrame==='undefined'){
  globalThis.requestAnimationFrame=function(cb){return globalThis.setTimeout(cb,16)};
  globalThis.requestAnimationFrame=function(cb){return globalThis.setTimeout(cb,16)};
  globalThis.cancelAnimationFrame=function(id){globalThis.clearTimeout(id)};
}
if(typeof globalThis.queueMicrotask==='undefined'){
  globalThis.queueMicrotask=function(cb){Promise.resolve().then(cb)};
}
if(typeof globalThis.structuredClone==='undefined'){
  globalThis.structuredClone=function(obj){return JSON.parse(JSON.stringify(obj))};
}
if(typeof globalThis.MessageChannel==='undefined'){
  globalThis.MessageChannel=function(){this.port1={postMessage:function(){},onmessage:null,close:function(){}};this.port2={postMessage:function(){},onmessage:null,close:function(){}}};
}
if(typeof globalThis.Worker==='undefined'){
  globalThis.Worker=function(url){this.onmessage=null;this.onerror=null;this.postMessage=function(){};this.terminate=function(){};this.addEventListener=function(){}};
}
if(typeof globalThis.Image==='undefined'){
  globalThis.Image=function(){this.src='';this.onload=null;this.onerror=null;this.width=0;this.height=0;this.naturalWidth=0;this.naturalHeight=0};
}
if(typeof globalThis.Audio==='undefined'){
  globalThis.Audio=function(){this.src='';this.onload=null;this.onerror=null};
}

// fetch 由宿主注入
// if(typeof globalThis.fetch==='undefined'){
//   globalThis.fetch=function(url,options){
//     options=options||{};
//     return new Promise(function(resolve,reject){
//       var method=(options.method||'GET').toUpperCase();
//       var reqHeaders={};
//       if(options.headers){
//         if(options.headers instanceof Map){options.headers.forEach(function(v,k){reqHeaders[k]=v})}
//         else if(typeof options.headers==='object'){reqHeaders=options.headers}
//       }
//       if(method==='GET'&&reqHeaders['Content-Type'])delete reqHeaders['Content-Type'];
//       var lxReqOpts={
//         method:method,
//         headers:reqHeaders,
//         body:options.body||null,
//         form:options.form||null,
//         formData:options.formData||null,
//         binary:options.binary||null
//       };
//       globalThis.lx.request(url,lxReqOpts,function(err,resp,body){
//         if(err){reject(new Error('fetch error: '+(err.message||String(err))));return}
//         var bodyStr='';
//         if(typeof body==='string')bodyStr=body;
//         else if(body&&typeof body==='object'){
//           try{
//             bodyStr=JSON.stringify(body)
//           }catch(e){
//             bodyStr=String(body)
//           }
//         }
//         else bodyStr=body?String(body):'';
//         var respHeaders=new Map();
//         if(resp&&resp.headers){try{Object.keys(resp.headers).forEach(function(k){respHeaders.set(k,resp.headers[k])})}catch(e){}}
//         resolve({
//           ok:resp&&resp.statusCode>=200&&resp.statusCode<300,
//           status:resp?resp.statusCode:0,
//           statusText:resp?(resp.statusMessage||''):'',
//           headers:respHeaders,
//           url:url,
//           text:function(){return Promise.resolve(bodyStr)},
//           json:function(){return Promise.resolve(JSON.parse(bodyStr))},
//           arrayBuffer:function(){var bytes=new Uint8Array(bodyStr.length);for(var i=0;i<bodyStr.length;i++)bytes[i]=bodyStr.charCodeAt(i);return Promise.resolve(bytes.buffer)}
//         })
//       })
//     })
//   }
// }
if(typeof globalThis.Proxy==='undefined'){
  globalThis.Proxy=function(target,handler){
    if(!handler)return target;
    if(typeof target==='function'){
      var fn=function(){
        var args=Array.prototype.slice.call(arguments);
        if(handler.apply){try{return handler.apply(target,this,args)}catch(e){return target.apply(this,args)}}
        return target.apply(this,args);
      };
      fn.__target=target;
      fn.__handler=handler;
      for(var k in target){if(target.hasOwnProperty(k)){(function(key){Object.defineProperty(fn,key,{get:function(){if(handler.get)try{return handler.get(target,key,fn)}catch(e){return target[key]}return target[key]},set:function(v){if(handler.set)try{handler.set(target,key,v,fn)}catch(e){target[key]=v}target[key]=v},configurable:true,enumerable:true})})(k)}}
      return fn;
    }
    if(typeof target==='object'&&target!==null){
      var result={};
      var keys=Object.getOwnPropertyNames(target);
      for(var i=0;i<keys.length;i++){(function(key){Object.defineProperty(result,key,{get:function(){if(handler.get)try{return handler.get(target,key,result)}catch(e){return target[key]}return target[key]},set:function(v){if(handler.set)try{handler.set(target,key,v,result)}catch(e){target[key]=v}target[key]=v},configurable:true,enumerable:true})})(keys[i])}
      return result;
    }
    return target;
  };
  globalThis.Proxy.revocable=function(target,handler){return{proxy:new Proxy(target,handler),revoke:function(){}}};
}
if(typeof globalThis.Reflect==='undefined'){
  globalThis.Reflect={apply:function(target,thisArg,args){return target.apply(thisArg,args)},construct:function(target,args){return new(Function.prototype.bind.apply(target,[null].concat(args)))},get:function(target,prop){return target[prop]},set:function(target,prop,value){target[prop]=value;return true},has:function(target,prop){return prop in target},deleteProperty:function(target,prop){delete target[prop];return true},ownKeys:function(target){return Object.keys(target)},getOwnPropertyDescriptor:function(target,prop){return Object.getOwnPropertyDescriptor(target,prop)},defineProperty:function(target,prop,desc){Object.defineProperty(target,prop,desc);return true},getPrototypeOf:function(target){return Object.getPrototypeOf(target)},setPrototypeOf:function(target,proto){Object.setPrototypeOf(target,proto);return true},isExtensible:function(target){return Object.isExtensible(target)},preventExtensions:function(target){Object.preventExtensions(target);return true}};
}

if (!console.group) {
  const compatibleConsole = {
    // 保存原始的 log 等输出方法
    originalLog: console.log,
    originalInfo: console.info,
    originalWarn: console.warn,
    originalError: console.error,

    // 用一个栈来维护缩进级别
    groupStack: [],

    // 辅助函数：生成当前缩进位的前缀字符串
    getIndentPrefix() {
      return this.groupStack.map(() => '  ').join(''); // 每级缩进两个空格
    },

    // 实现统一输出（带当前分组缩进）
    formatWithIndent(args) {
      const prefix = this.getIndentPrefix();
      if (prefix) {
        // 第一个参数前面加上缩进（若存在）
        if (typeof args[0] === 'string')
          args[0] = prefix + args[0];
        else
          Array.prototype.unshift.call(args, prefix);
      }
      return args;
    },

    // 重写 console 方法：让它们自动携带缩进前缀
    log(...args) {
      this.originalLog.apply(console, this.formatWithIndent(args));
    },

    info(...args) {
      this.originalInfo.apply(console, this.formatWithIndent(args));
    },

    warn(...args) {
      this.originalWarn.apply(console, this.formatWithIndent(args));
    },

    error(...args) {
      this.originalError.apply(console, this.formatWithIndent(args));
    },

    // 实现 group(groupName)：输出组名称，随后增加缩进级别
    group(groupName = '') {
      // 输出组标签（当前缩进 + 组名）
      const prefix = this.getIndentPrefix();
      this.originalLog.call(console, prefix + (groupName !== '' ? groupName : '└─ (unnamed group)'));
      // 推入一个新层级（压栈）
      this.groupStack.push(true);
    },

    // 实现 groupCollapsed（可选，默认直接等价于 group）
    groupCollapsed(groupName = '') {
      // 可选行为：根据需要设定一个折叠标签; 此处实现简化为与 group 相同
      this.group.apply(this, [groupName]);
    },

    // 实现 groupEnd：检查确保栈非空，弹出一层
    groupEnd() {
      if (this.groupStack.length === 0) {
        this.originalWarn.call(console, 'console.groupEnd() 调用不匹配: 没有对应的 console.group()');
        return;
      }
      this.groupStack.pop();
    }
  };

  // 如果原生 console 没有 group 方法，则使用我们的实现
  console.log = compatibleConsole.log.bind(compatibleConsole);
  console.info = compatibleConsole.info.bind(compatibleConsole);
  console.warn = compatibleConsole.warn.bind(compatibleConsole);
  console.error = compatibleConsole.error.bind(compatibleConsole);
  console.group = compatibleConsole.group.bind(compatibleConsole);
  console.groupCollapsed = compatibleConsole.groupCollapsed.bind(compatibleConsole);
  console.groupEnd = compatibleConsole.groupEnd.bind(compatibleConsole);
}

// if (typeof globalThis.Buffer === 'undefined') globalThis.Buffer = BufferPolyfill;
// if (typeof globalThis.zlib === 'undefined') globalThis.zlib = zlib;
// if (typeof globalThis.crypto === 'undefined') globalThis.crypto = crypto;

if (typeof globalThis.Buffer === 'undefined') globalThis.Buffer = {
  from: function(data, encoding) {
    encoding = encoding || 'utf8';
    var hex;
    if (typeof data === 'string') {
      hex = __go_buffer_from(data, encoding);
    } else if (data && typeof data._hex === 'string') {
      // Already a Buffer-like object from our polyfill
      hex = data._hex;
    } else if (typeof ArrayBuffer !== 'undefined' && data instanceof ArrayBuffer) {
      // ArrayBuffer: convert bytes to hex
      var bytes = new Uint8Array(data);
      var h = '';
      for (var i = 0; i < bytes.length; i++) h += ('0' + bytes[i].toString(16)).slice(-2);
      hex = h;
    } else if (typeof Uint8Array !== 'undefined' && data instanceof Uint8Array) {
      // TypedArray: convert bytes to hex
      var h = '';
      for (var i = 0; i < data.length; i++) h += ('0' + data[i].toString(16)).slice(-2);
      hex = h;
    } else if (Array.isArray(data) || (data && typeof data === 'object' && typeof data.length === 'number')) {
      // Array or array-like: treat as byte array
      var h = '';
      for (var i = 0; i < data.length; i++) h += ('0' + ((data[i] || 0) & 0xff).toString(16)).slice(-2);
      hex = h;
    } else {
      hex = __go_buffer_from(String(data), encoding);
    }
    var buf = {
      _hex: hex,
      toString: function(fmt) {
        if (typeof this._hex !== 'string') return String(this._hex);
        return __go_buffer_to_string(this._hex, fmt || 'utf8');
      },
      valueOf: function() {
        // When used in string concatenation or implicit conversion, return UTF-8 string
        if (typeof this._hex !== 'string') return String(this._hex);
        return __go_buffer_to_string(this._hex, 'utf8');
      },
      length: typeof hex === 'string' ? hex.length / 2 : 0
    };
    // Support Symbol.toPrimitive for proper string coercion in template literals etc.
    if (typeof Symbol !== 'undefined' && Symbol.toPrimitive) {
      buf[Symbol.toPrimitive] = function(hint) {
        if (typeof this._hex !== 'string') return String(this._hex);
        if (hint === 'number') return this.length;
        return __go_buffer_to_string(this._hex, 'utf8');
      };
    }
    return buf;
  },
  alloc: function(size) {
    var h = '';
    for (var i = 0; i < size; i++) h += '00';
    var buf = {
      _hex: h,
      toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'utf8'); },
      valueOf: function() { return __go_buffer_to_string(this._hex, 'utf8'); },
      length: size
    };
    if (typeof Symbol !== 'undefined' && Symbol.toPrimitive) {
      buf[Symbol.toPrimitive] = function(hint) {
        if (hint === 'number') return this.length;
        return __go_buffer_to_string(this._hex, 'utf8');
      };
    }
    return buf;
  },
  isBuffer: function(obj) {
    return obj && typeof obj === 'object' && typeof obj._hex === 'string';
  },
  concat: function(list) {
    var hex = '';
    for (var i = 0; i < list.length; i++) {
      if (list[i] && list[i]._hex) hex += list[i]._hex;
    }
    return { _hex: hex, toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'utf8'); }, length: hex.length / 2 };
  }
};
if (typeof globalThis.zlib === 'undefined') globalThis.zlib = {
  inflate: function(buffer) {
    var dataHex = (buffer && buffer._hex) ? buffer._hex : __go_buffer_from(String(buffer), 'utf8');
    var hex = __go_zlib_inflate(dataHex);
    return { _hex: hex, toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'utf8'); } };
  },
  deflate: function(buffer) {
    var dataHex = (buffer && buffer._hex) ? buffer._hex : __go_buffer_from(String(buffer), 'utf8');
    var hex = __go_zlib_deflate(dataHex);
    return { _hex: hex, toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'utf8'); } };
  }
};;
if (typeof globalThis.crypto === 'undefined') globalThis.crypto = {
  md5: function(str) { return __go_crypto_md5(str || ''); },
  aesEncrypt: function(buffer, mode, key, iv) {
    var dataHex = (buffer && buffer._hex) ? buffer._hex : __go_buffer_from(String(buffer), 'utf8');
    var keyHex = (key && key._hex) ? key._hex : __go_buffer_from(String(key), 'utf8');
    var ivHex = (iv && iv._hex) ? iv._hex : (iv ? __go_buffer_from(String(iv), 'utf8') : '');
    return { _hex: __go_crypto_aes_encrypt(dataHex, mode || 'cbc', keyHex, ivHex),
      toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'base64'); } };
  },
  rsaEncrypt: function(buffer, key) {
    var dataHex = (buffer && buffer._hex) ? buffer._hex : __go_buffer_from(String(buffer), 'utf8');
    return { _hex: __go_crypto_rsa_encrypt(dataHex, String(key)),
      toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'base64'); } };
  },
  randomBytes: function(size) {
    var hex = __go_crypto_random_bytes(size);
    return { _hex: hex, toString: function(fmt) { return __go_buffer_to_string(this._hex, fmt || 'hex'); },
      length: size };
  }
};;

// btoa / atob polyfill (Base64 encoding/decoding)
if (typeof globalThis.btoa === 'undefined') globalThis.btoa = function(str) {
  var bytes = [];
  for (var i = 0; i < str.length; i++) {
    var charCode = str.charCodeAt(i);
    if (charCode > 255) throw new Error('btoa: invalid character');
    bytes.push(charCode);
  }
  var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  var result = '';
  for (var i = 0; i < bytes.length; i += 3) {
    var b1 = bytes[i], b2 = bytes[i+1], b3 = bytes[i+2];
    result += chars[b1 >> 2];
    result += chars[((b1 & 3) << 4) | (b2 >> 4)];
    result += (i + 1 < bytes.length) ? chars[((b2 & 15) << 2) | (b3 >> 6)] : '=';
    result += (i + 2 < bytes.length) ? chars[b3 & 63] : '=';
  }
  return result;
};
if (typeof globalThis.atob === 'undefined') globalThis.atob = function(str) {
  var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  str = str.replace(/=+\$/, '');
  var result = '';
  for (var i = 0; i < str.length; i += 4) {
    var b1 = chars.indexOf(str[i]);
    var b2 = chars.indexOf(str[i+1]);
    var b3 = chars.indexOf(str[i+2]);
    var b4 = chars.indexOf(str[i+3]);
    result += String.fromCharCode((b1 << 2) | (b2 >> 4));
    if (b3 !== -1) result += String.fromCharCode(((b2 & 15) << 4) | (b3 >> 2));
    if (b4 !== -1) result += String.fromCharCode(((b3 & 3) << 6) | b4);
  }
  return result;
};
console.log('Polyfill setup complete.');

""";
