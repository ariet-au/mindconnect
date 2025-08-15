// luxon@3.7.1 downloaded from https://ga.jspm.io/npm:luxon@3.7.1/src/luxon.js

class LuxonError extends Error{}class InvalidDateTimeError extends LuxonError{constructor(e){super(`Invalid DateTime: ${e.toMessage()}`)}}class InvalidIntervalError extends LuxonError{constructor(e){super(`Invalid Interval: ${e.toMessage()}`)}}class InvalidDurationError extends LuxonError{constructor(e){super(`Invalid Duration: ${e.toMessage()}`)}}class ConflictingSpecificationError extends LuxonError{}class InvalidUnitError extends LuxonError{constructor(e){super(`Invalid unit ${e}`)}}class InvalidArgumentError extends LuxonError{}class ZoneIsAbstractError extends LuxonError{constructor(){super("Zone is an abstract class")}}const e="numeric",t="short",n="long";const r={year:e,month:e,day:e};const s={year:e,month:t,day:e};const i={year:e,month:t,day:e,weekday:t};const a={year:e,month:n,day:e};const o={year:e,month:n,day:e,weekday:n};const u={hour:e,minute:e};const l={hour:e,minute:e,second:e};const c={hour:e,minute:e,second:e,timeZoneName:t};const h={hour:e,minute:e,second:e,timeZoneName:n};const d={hour:e,minute:e,hourCycle:"h23"};const m={hour:e,minute:e,second:e,hourCycle:"h23"};const f={hour:e,minute:e,second:e,hourCycle:"h23",timeZoneName:t};const y={hour:e,minute:e,second:e,hourCycle:"h23",timeZoneName:n};const g={year:e,month:e,day:e,hour:e,minute:e};const w={year:e,month:e,day:e,hour:e,minute:e,second:e};const p={year:e,month:t,day:e,hour:e,minute:e};const v={year:e,month:t,day:e,hour:e,minute:e,second:e};const k={year:e,month:t,day:e,weekday:t,hour:e,minute:e};const S={year:e,month:n,day:e,hour:e,minute:e,timeZoneName:t};const T={year:e,month:n,day:e,hour:e,minute:e,second:e,timeZoneName:t};const D={year:e,month:n,day:e,weekday:n,hour:e,minute:e,timeZoneName:n};const O={year:e,month:n,day:e,weekday:n,hour:e,minute:e,second:e,timeZoneName:n};class Zone{
/**
   * The type of zone
   * @abstract
   * @type {string}
   */
get type(){throw new ZoneIsAbstractError}
/**
   * The name of this zone.
   * @abstract
   * @type {string}
   */get name(){throw new ZoneIsAbstractError}
/**
   * The IANA name of this zone.
   * Defaults to `name` if not overwritten by a subclass.
   * @abstract
   * @type {string}
   */get ianaName(){return this.name}
/**
   * Returns whether the offset is known to be fixed for the whole year.
   * @abstract
   * @type {boolean}
   */get isUniversal(){throw new ZoneIsAbstractError}
/**
   * Returns the offset's common name (such as EST) at the specified timestamp
   * @abstract
   * @param {number} ts - Epoch milliseconds for which to get the name
   * @param {Object} opts - Options to affect the format
   * @param {string} opts.format - What style of offset to return. Accepts 'long' or 'short'.
   * @param {string} opts.locale - What locale to return the offset name in.
   * @return {string}
   */offsetName(e,t){throw new ZoneIsAbstractError}
/**
   * Returns the offset's value as a string
   * @abstract
   * @param {number} ts - Epoch milliseconds for which to get the offset
   * @param {string} format - What style of offset to return.
   *                          Accepts 'narrow', 'short', or 'techie'. Returning '+6', '+06:00', or '+0600' respectively
   * @return {string}
   */formatOffset(e,t){throw new ZoneIsAbstractError}
/**
   * Return the offset in minutes for this zone at the specified timestamp.
   * @abstract
   * @param {number} ts - Epoch milliseconds for which to compute the offset
   * @return {number}
   */offset(e){throw new ZoneIsAbstractError}
/**
   * Return whether this Zone is equal to another zone
   * @abstract
   * @param {Zone} otherZone - the zone to compare
   * @return {boolean}
   */equals(e){throw new ZoneIsAbstractError}
/**
   * Return whether this Zone is valid.
   * @abstract
   * @type {boolean}
   */get isValid(){throw new ZoneIsAbstractError}}let b=null;class SystemZone extends Zone{static get instance(){b===null&&(b=new SystemZone);return b}get type(){return"system"}get name(){return(new Intl.DateTimeFormat).resolvedOptions().timeZone}get isUniversal(){return false}offsetName(e,{format:t,locale:n}){return st(e,t,n)}formatOffset(e,t){return ut(this.offset(e),t)}offset(e){return-new Date(e).getTimezoneOffset()}equals(e){return e.type==="system"}get isValid(){return true}}const I=new Map;function N(e){let t=I.get(e);if(t===void 0){t=new Intl.DateTimeFormat("en-US",{hour12:false,timeZone:e,year:"numeric",month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",second:"2-digit",era:"short"});I.set(e,t)}return t}const M={year:0,month:1,day:2,era:3,hour:4,minute:5,second:6};function E(e,t){const n=e.format(t).replace(/\u200E/g,""),r=/(\d+)\/(\d+)\/(\d+) (AD|BC),? (\d+):(\d+):(\d+)/.exec(n),[,s,i,a,o,u,l,c]=r;return[a,s,i,o,u,l,c]}function x(e,t){const n=e.formatToParts(t);const r=[];for(let e=0;e<n.length;e++){const{type:t,value:s}=n[e];const i=M[t];t==="era"?r[i]=s:Ze(i)||(r[i]=parseInt(s,10))}return r}const F=new Map;class IANAZone extends Zone{
/**
   * @param {string} name - Zone name
   * @return {IANAZone}
   */
static create(e){let t=F.get(e);t===void 0&&F.set(e,t=new IANAZone(e));return t}static resetCache(){F.clear();I.clear()}
/**
   * Returns whether the provided string is a valid specifier. This only checks the string's format, not that the specifier identifies a known zone; see isValidZone for that.
   * @param {string} s - The string to check validity on
   * @example IANAZone.isValidSpecifier("America/New_York") //=> true
   * @example IANAZone.isValidSpecifier("Sport~~blorp") //=> false
   * @deprecated For backward compatibility, this forwards to isValidZone, better use `isValidZone()` directly instead.
   * @return {boolean}
   */static isValidSpecifier(e){return this.isValidZone(e)}
/**
   * Returns whether the provided string identifies a real zone
   * @param {string} zone - The string to check
   * @example IANAZone.isValidZone("America/New_York") //=> true
   * @example IANAZone.isValidZone("Fantasia/Castle") //=> false
   * @example IANAZone.isValidZone("Sport~~blorp") //=> false
   * @return {boolean}
   */static isValidZone(e){if(!e)return false;try{new Intl.DateTimeFormat("en-US",{timeZone:e}).format();return true}catch(e){return false}}constructor(e){super();this.zoneName=e;this.valid=IANAZone.isValidZone(e)}
/**
   * The type of zone. `iana` for all instances of `IANAZone`.
   * @override
   * @type {string}
   */get type(){return"iana"}
/**
   * The name of this zone (i.e. the IANA zone name).
   * @override
   * @type {string}
   */get name(){return this.zoneName}
/**
   * Returns whether the offset is known to be fixed for the whole year:
   * Always returns false for all IANA zones.
   * @override
   * @type {boolean}
   */get isUniversal(){return false}
/**
   * Returns the offset's common name (such as EST) at the specified timestamp
   * @override
   * @param {number} ts - Epoch milliseconds for which to get the name
   * @param {Object} opts - Options to affect the format
   * @param {string} opts.format - What style of offset to return. Accepts 'long' or 'short'.
   * @param {string} opts.locale - What locale to return the offset name in.
   * @return {string}
   */offsetName(e,{format:t,locale:n}){return st(e,t,n,this.name)}
/**
   * Returns the offset's value as a string
   * @override
   * @param {number} ts - Epoch milliseconds for which to get the offset
   * @param {string} format - What style of offset to return.
   *                          Accepts 'narrow', 'short', or 'techie'. Returning '+6', '+06:00', or '+0600' respectively
   * @return {string}
   */formatOffset(e,t){return ut(this.offset(e),t)}
/**
   * Return the offset in minutes for this zone at the specified timestamp.
   * @override
   * @param {number} ts - Epoch milliseconds for which to compute the offset
   * @return {number}
   */offset(e){if(!this.valid)return NaN;const t=new Date(e);if(isNaN(t))return NaN;const n=N(this.name);let[r,s,i,a,o,u,l]=n.formatToParts?x(n,t):E(n,t);a==="BC"&&(r=1-Math.abs(r));const c=o===24?0:o;const h=et({year:r,month:s,day:i,hour:c,minute:u,second:l,millisecond:0});let d=+t;const m=d%1e3;d-=m>=0?m:1e3+m;return(h-d)/6e4}
/**
   * Return whether this Zone is equal to another zone
   * @override
   * @param {Zone} otherZone - the zone to compare
   * @return {boolean}
   */equals(e){return e.type==="iana"&&e.name===this.name}
/**
   * Return whether this Zone is valid.
   * @override
   * @type {boolean}
   */get isValid(){return this.valid}}let Z={};function V(e,t={}){const n=JSON.stringify([e,t]);let r=Z[n];if(!r){r=new Intl.ListFormat(e,t);Z[n]=r}return r}const L=new Map;function C(e,t={}){const n=JSON.stringify([e,t]);let r=L.get(n);if(r===void 0){r=new Intl.DateTimeFormat(e,t);L.set(n,r)}return r}const $=new Map;function A(e,t={}){const n=JSON.stringify([e,t]);let r=$.get(n);if(r===void 0){r=new Intl.NumberFormat(e,t);$.set(n,r)}return r}const W=new Map;function z(e,t={}){const{base:n,...r}=t;const s=JSON.stringify([e,r]);let i=W.get(s);if(i===void 0){i=new Intl.RelativeTimeFormat(e,t);W.set(s,i)}return i}let j=null;function q(){if(j)return j;j=(new Intl.DateTimeFormat).resolvedOptions().locale;return j}const U=new Map;function _(e){let t=U.get(e);if(t===void 0){t=new Intl.DateTimeFormat(e).resolvedOptions();U.set(e,t)}return t}const Y=new Map;function R(e){let t=Y.get(e);if(!t){const n=new Intl.Locale(e);t="getWeekInfo"in n?n.getWeekInfo():n.weekInfo;"minimalDays"in t||(t={...K,...t});Y.set(e,t)}return t}function P(e){const t=e.indexOf("-x-");t!==-1&&(e=e.substring(0,t));const n=e.indexOf("-u-");if(n===-1)return[e];{let t;let r;try{t=C(e).resolvedOptions();r=e}catch(s){const i=e.substring(0,n);t=C(i).resolvedOptions();r=i}const{numberingSystem:s,calendar:i}=t;return[r,s,i]}}function H(e,t,n){if(n||t){e.includes("-u-")||(e+="-u");n&&(e+=`-ca-${n}`);t&&(e+=`-nu-${t}`);return e}return e}function J(e){const t=[];for(let n=1;n<=12;n++){const r=DateTime.utc(2009,n,1);t.push(e(r))}return t}function G(e){const t=[];for(let n=1;n<=7;n++){const r=DateTime.utc(2016,11,13+n);t.push(e(r))}return t}function B(e,t,n,r){const s=e.listingMode();return s==="error"?null:s==="en"?n(t):r(t)}function Q(e){return(!e.numberingSystem||e.numberingSystem==="latn")&&(e.numberingSystem==="latn"||!e.locale||e.locale.startsWith("en")||_(e.locale).numberingSystem==="latn")}class PolyNumberFormatter{constructor(e,t,n){this.padTo=n.padTo||0;this.floor=n.floor||false;const{padTo:r,floor:s,...i}=n;if(!t||Object.keys(i).length>0){const t={useGrouping:false,...n};n.padTo>0&&(t.minimumIntegerDigits=n.padTo);this.inf=A(e,t)}}format(e){if(this.inf){const t=this.floor?Math.floor(e):e;return this.inf.format(t)}{const t=this.floor?Math.floor(e):Be(e,3);return Pe(t,this.padTo)}}}class PolyDateFormatter{constructor(e,t,n){this.opts=n;this.originalZone=void 0;let r;if(this.opts.timeZone)this.dt=e;else if(e.zone.type==="fixed"){const t=e.offset/60*-1;const n=t>=0?`Etc/GMT+${t}`:`Etc/GMT${t}`;if(e.offset!==0&&IANAZone.create(n).valid){r=n;this.dt=e}else{r="UTC";this.dt=e.offset===0?e:e.setZone("UTC").plus({minutes:e.offset});this.originalZone=e.zone}}else if(e.zone.type==="system")this.dt=e;else if(e.zone.type==="iana"){this.dt=e;r=e.zone.name}else{r="UTC";this.dt=e.setZone("UTC").plus({minutes:e.offset});this.originalZone=e.zone}const s={...this.opts};s.timeZone=s.timeZone||r;this.dtf=C(t,s)}format(){return this.originalZone?this.formatToParts().map((({value:e})=>e)).join(""):this.dtf.format(this.dt.toJSDate())}formatToParts(){const e=this.dtf.formatToParts(this.dt.toJSDate());return this.originalZone?e.map((e=>{if(e.type==="timeZoneName"){const t=this.originalZone.offsetName(this.dt.ts,{locale:this.dt.locale,format:this.opts.timeZoneName});return{...e,value:t}}return e})):e}resolvedOptions(){return this.dtf.resolvedOptions()}}class PolyRelFormatter{constructor(e,t,n){this.opts={style:"long",...n};!t&&Ae()&&(this.rtf=z(e,n))}format(e,t){return this.rtf?this.rtf.format(e,t):Nt(t,e,this.opts.numeric,this.opts.style!=="long")}formatToParts(e,t){return this.rtf?this.rtf.formatToParts(e,t):[]}}const K={firstDay:1,minimalDays:4,weekend:[6,7]};class Locale{static fromOpts(e){return Locale.create(e.locale,e.numberingSystem,e.outputCalendar,e.weekSettings,e.defaultToEN)}static create(e,t,n,r,s=false){const i=e||Settings.defaultLocale;const a=i||(s?"en-US":q());const o=t||Settings.defaultNumberingSystem;const u=n||Settings.defaultOutputCalendar;const l=_e(r)||Settings.defaultWeekSettings;return new Locale(a,o,u,l,i)}static resetCache(){j=null;L.clear();$.clear();W.clear();U.clear();Y.clear()}static fromObject({locale:e,numberingSystem:t,outputCalendar:n,weekSettings:r}={}){return Locale.create(e,t,n,r)}constructor(e,t,n,r,s){const[i,a,o]=P(e);this.locale=i;this.numberingSystem=t||a||null;this.outputCalendar=n||o||null;this.weekSettings=r;this.intl=H(this.locale,this.numberingSystem,this.outputCalendar);this.weekdaysCache={format:{},standalone:{}};this.monthsCache={format:{},standalone:{}};this.meridiemCache=null;this.eraCache={};this.specifiedLocale=s;this.fastNumbersCached=null}get fastNumbers(){this.fastNumbersCached==null&&(this.fastNumbersCached=Q(this));return this.fastNumbersCached}listingMode(){const e=this.isEnglish();const t=(this.numberingSystem===null||this.numberingSystem==="latn")&&(this.outputCalendar===null||this.outputCalendar==="gregory");return e&&t?"en":"intl"}clone(e){return e&&Object.getOwnPropertyNames(e).length!==0?Locale.create(e.locale||this.specifiedLocale,e.numberingSystem||this.numberingSystem,e.outputCalendar||this.outputCalendar,_e(e.weekSettings)||this.weekSettings,e.defaultToEN||false):this}redefaultToEN(e={}){return this.clone({...e,defaultToEN:true})}redefaultToSystem(e={}){return this.clone({...e,defaultToEN:false})}months(e,t=false){return B(this,e,mt,(()=>{const n=this.intl==="ja"||this.intl.startsWith("ja-");t&=!n;const r=t?{month:e,day:"numeric"}:{month:e},s=t?"format":"standalone";if(!this.monthsCache[s][e]){const t=n?e=>this.dtFormatter(e,r).format():e=>this.extract(e,r,"month");this.monthsCache[s][e]=J(t)}return this.monthsCache[s][e]}))}weekdays(e,t=false){return B(this,e,wt,(()=>{const n=t?{weekday:e,year:"numeric",month:"long",day:"numeric"}:{weekday:e},r=t?"format":"standalone";this.weekdaysCache[r][e]||(this.weekdaysCache[r][e]=G((e=>this.extract(e,n,"weekday"))));return this.weekdaysCache[r][e]}))}meridiems(){return B(this,void 0,(()=>pt),(()=>{if(!this.meridiemCache){const e={hour:"numeric",hourCycle:"h12"};this.meridiemCache=[DateTime.utc(2016,11,13,9),DateTime.utc(2016,11,13,19)].map((t=>this.extract(t,e,"dayperiod")))}return this.meridiemCache}))}eras(e){return B(this,e,Tt,(()=>{const t={era:e};this.eraCache[e]||(this.eraCache[e]=[DateTime.utc(-40,1,1),DateTime.utc(2017,1,1)].map((e=>this.extract(e,t,"era"))));return this.eraCache[e]}))}extract(e,t,n){const r=this.dtFormatter(e,t),s=r.formatToParts(),i=s.find((e=>e.type.toLowerCase()===n));return i?i.value:null}numberFormatter(e={}){return new PolyNumberFormatter(this.intl,e.forceSimple||this.fastNumbers,e)}dtFormatter(e,t={}){return new PolyDateFormatter(e,this.intl,t)}relFormatter(e={}){return new PolyRelFormatter(this.intl,this.isEnglish(),e)}listFormatter(e={}){return V(this.intl,e)}isEnglish(){return this.locale==="en"||this.locale.toLowerCase()==="en-us"||_(this.intl).locale.startsWith("en-us")}getWeekSettings(){return this.weekSettings?this.weekSettings:We()?R(this.locale):K}getStartOfWeek(){return this.getWeekSettings().firstDay}getMinDaysInFirstWeek(){return this.getWeekSettings().minimalDays}getWeekendDays(){return this.getWeekSettings().weekend}equals(e){return this.locale===e.locale&&this.numberingSystem===e.numberingSystem&&this.outputCalendar===e.outputCalendar}toString(){return`Locale(${this.locale}, ${this.numberingSystem}, ${this.outputCalendar})`}}let X=null;class FixedOffsetZone extends Zone{static get utcInstance(){X===null&&(X=new FixedOffsetZone(0));return X}
/**
   * Get an instance with a specified offset
   * @param {number} offset - The offset in minutes
   * @return {FixedOffsetZone}
   */static instance(e){return e===0?FixedOffsetZone.utcInstance:new FixedOffsetZone(e)}
/**
   * Get an instance of FixedOffsetZone from a UTC offset string, like "UTC+6"
   * @param {string} s - The offset string to parse
   * @example FixedOffsetZone.parseSpecifier("UTC+6")
   * @example FixedOffsetZone.parseSpecifier("UTC+06")
   * @example FixedOffsetZone.parseSpecifier("UTC-6:00")
   * @return {FixedOffsetZone}
   */static parseSpecifier(e){if(e){const t=e.match(/^utc(?:([+-]\d{1,2})(?::(\d{2}))?)?$/i);if(t)return new FixedOffsetZone(it(t[1],t[2]))}return null}constructor(e){super();this.fixed=e}
/**
   * The type of zone. `fixed` for all instances of `FixedOffsetZone`.
   * @override
   * @type {string}
   */get type(){return"fixed"}
/**
   * The name of this zone.
   * All fixed zones' names always start with "UTC" (plus optional offset)
   * @override
   * @type {string}
   */get name(){return this.fixed===0?"UTC":`UTC${ut(this.fixed,"narrow")}`}
/**
   * The IANA name of this zone, i.e. `Etc/UTC` or `Etc/GMT+/-nn`
   *
   * @override
   * @type {string}
   */get ianaName(){return this.fixed===0?"Etc/UTC":`Etc/GMT${ut(-this.fixed,"narrow")}`}offsetName(){return this.name}
/**
   * Returns the offset's value as a string
   * @override
   * @param {number} ts - Epoch milliseconds for which to get the offset
   * @param {string} format - What style of offset to return.
   *                          Accepts 'narrow', 'short', or 'techie'. Returning '+6', '+06:00', or '+0600' respectively
   * @return {string}
   */formatOffset(e,t){return ut(this.fixed,t)}
/**
   * Returns whether the offset is known to be fixed for the whole year:
   * Always returns true for all fixed offset zones.
   * @override
   * @type {boolean}
   */get isUniversal(){return true}offset(){return this.fixed}
/**
   * Return whether this Zone is equal to another zone (i.e. also fixed and same offset)
   * @override
   * @param {Zone} otherZone - the zone to compare
   * @return {boolean}
   */equals(e){return e.type==="fixed"&&e.fixed===this.fixed}
/**
   * Return whether this Zone is valid:
   * All fixed offset zones are valid.
   * @override
   * @type {boolean}
   */get isValid(){return true}}class InvalidZone extends Zone{constructor(e){super();this.zoneName=e}get type(){return"invalid"}get name(){return this.zoneName}get isUniversal(){return false}offsetName(){return null}formatOffset(){return""}offset(){return NaN}equals(){return false}get isValid(){return false}}function ee(e,t){if(Ze(e)||e===null)return t;if(e instanceof Zone)return e;if(Ce(e)){const n=e.toLowerCase();return n==="default"?t:n==="local"||n==="system"?SystemZone.instance:n==="utc"||n==="gmt"?FixedOffsetZone.utcInstance:FixedOffsetZone.parseSpecifier(n)||IANAZone.create(e)}return Ve(e)?FixedOffsetZone.instance(e):typeof e==="object"&&"offset"in e&&typeof e.offset==="function"?e:new InvalidZone(e)}const te={arab:"[٠-٩]",arabext:"[۰-۹]",bali:"[᭐-᭙]",beng:"[০-৯]",deva:"[०-९]",fullwide:"[０-９]",gujr:"[૦-૯]",hanidec:"[〇|一|二|三|四|五|六|七|八|九]",khmr:"[០-៩]",knda:"[೦-೯]",laoo:"[໐-໙]",limb:"[᥆-᥏]",mlym:"[൦-൯]",mong:"[᠐-᠙]",mymr:"[၀-၉]",orya:"[୦-୯]",tamldec:"[௦-௯]",telu:"[౦-౯]",thai:"[๐-๙]",tibt:"[༠-༩]",latn:"\\d"};const ne={arab:[1632,1641],arabext:[1776,1785],bali:[6992,7001],beng:[2534,2543],deva:[2406,2415],fullwide:[65296,65303],gujr:[2790,2799],khmr:[6112,6121],knda:[3302,3311],laoo:[3792,3801],limb:[6470,6479],mlym:[3430,3439],mong:[6160,6169],mymr:[4160,4169],orya:[2918,2927],tamldec:[3046,3055],telu:[3174,3183],thai:[3664,3673],tibt:[3872,3881]};const re=te.hanidec.replace(/[\[|\]]/g,"").split("");function se(e){let t=parseInt(e,10);if(isNaN(t)){t="";for(let n=0;n<e.length;n++){const r=e.charCodeAt(n);if(e[n].search(te.hanidec)!==-1)t+=re.indexOf(e[n]);else for(const e in ne){const[n,s]=ne[e];r>=n&&r<=s&&(t+=r-n)}}return parseInt(t,10)}return t}const ie=new Map;function ae(){ie.clear()}function oe({numberingSystem:e},t=""){const n=e||"latn";let r=ie.get(n);if(r===void 0){r=new Map;ie.set(n,r)}let s=r.get(t);if(s===void 0){s=new RegExp(`${te[n]}${t}`);r.set(t,s)}return s}let ue,le=()=>Date.now(),ce="system",he=null,de=null,me=null,fe=60,ye=null;class Settings{
/**
   * Get the callback for returning the current timestamp.
   * @type {function}
   */
static get now(){return le}
/**
   * Set the callback for returning the current timestamp.
   * The function should return a number, which will be interpreted as an Epoch millisecond count
   * @type {function}
   * @example Settings.now = () => Date.now() + 3000 // pretend it is 3 seconds in the future
   * @example Settings.now = () => 0 // always pretend it's Jan 1, 1970 at midnight in UTC time
   */static set now(e){le=e}
/**
   * Set the default time zone to create DateTimes in. Does not affect existing instances.
   * Use the value "system" to reset this value to the system's time zone.
   * @type {string}
   */static set defaultZone(e){ce=e}
/**
   * Get the default time zone object currently used to create DateTimes. Does not affect existing instances.
   * The default value is the system's time zone (the one set on the machine that runs this code).
   * @type {Zone}
   */static get defaultZone(){return ee(ce,SystemZone.instance)}
/**
   * Get the default locale to create DateTimes with. Does not affect existing instances.
   * @type {string}
   */static get defaultLocale(){return he}
/**
   * Set the default locale to create DateTimes with. Does not affect existing instances.
   * @type {string}
   */static set defaultLocale(e){he=e}
/**
   * Get the default numbering system to create DateTimes with. Does not affect existing instances.
   * @type {string}
   */static get defaultNumberingSystem(){return de}
/**
   * Set the default numbering system to create DateTimes with. Does not affect existing instances.
   * @type {string}
   */static set defaultNumberingSystem(e){de=e}
/**
   * Get the default output calendar to create DateTimes with. Does not affect existing instances.
   * @type {string}
   */static get defaultOutputCalendar(){return me}
/**
   * Set the default output calendar to create DateTimes with. Does not affect existing instances.
   * @type {string}
   */static set defaultOutputCalendar(e){me=e}
/**
   * @typedef {Object} WeekSettings
   * @property {number} firstDay
   * @property {number} minimalDays
   * @property {number[]} weekend
   */static get defaultWeekSettings(){return ye}
/**
   * Allows overriding the default locale week settings, i.e. the start of the week, the weekend and
   * how many days are required in the first week of a year.
   * Does not affect existing instances.
   *
   * @param {WeekSettings|null} weekSettings
   */static set defaultWeekSettings(e){ye=_e(e)}
/**
   * Get the cutoff year for whether a 2-digit year string is interpreted in the current or previous century. Numbers higher than the cutoff will be considered to mean 19xx and numbers lower or equal to the cutoff will be considered 20xx.
   * @type {number}
   */static get twoDigitCutoffYear(){return fe}
/**
   * Set the cutoff year for whether a 2-digit year string is interpreted in the current or previous century. Numbers higher than the cutoff will be considered to mean 19xx and numbers lower or equal to the cutoff will be considered 20xx.
   * @type {number}
   * @example Settings.twoDigitCutoffYear = 0 // all 'yy' are interpreted as 20th century
   * @example Settings.twoDigitCutoffYear = 99 // all 'yy' are interpreted as 21st century
   * @example Settings.twoDigitCutoffYear = 50 // '49' -> 2049; '50' -> 1950
   * @example Settings.twoDigitCutoffYear = 1950 // interpreted as 50
   * @example Settings.twoDigitCutoffYear = 2050 // ALSO interpreted as 50
   */static set twoDigitCutoffYear(e){fe=e%100}
/**
   * Get whether Luxon will throw when it encounters invalid DateTimes, Durations, or Intervals
   * @type {boolean}
   */static get throwOnInvalid(){return ue}
/**
   * Set whether Luxon will throw when it encounters invalid DateTimes, Durations, or Intervals
   * @type {boolean}
   */static set throwOnInvalid(e){ue=e}static resetCaches(){Locale.resetCache();IANAZone.resetCache();DateTime.resetCache();ae()}}class Invalid{constructor(e,t){this.reason=e;this.explanation=t}toMessage(){return this.explanation?`${this.reason}: ${this.explanation}`:this.reason}}const ge=[0,31,59,90,120,151,181,212,243,273,304,334],we=[0,31,60,91,121,152,182,213,244,274,305,335];function pe(e,t){return new Invalid("unit out of range",`you specified ${t} (of type ${typeof t}) as a ${e}, which is invalid`)}function ve(e,t,n){const r=new Date(Date.UTC(e,t-1,n));e<100&&e>=0&&r.setUTCFullYear(r.getUTCFullYear()-1900);const s=r.getUTCDay();return s===0?7:s}function ke(e,t,n){return n+(Qe(e)?we:ge)[t-1]}function Se(e,t){const n=Qe(e)?we:ge,r=n.findIndex((e=>e<t)),s=t-n[r];return{month:r+1,day:s}}function Te(e,t){return(e-t+7)%7+1}function De(e,t=4,n=1){const{year:r,month:s,day:i}=e,a=ke(r,s,i),o=Te(ve(r,s,i),n);let u,l=Math.floor((a-o+14-t)/7);if(l<1){u=r-1;l=nt(u,t,n)}else if(l>nt(r,t,n)){u=r+1;l=1}else u=r;return{weekYear:u,weekNumber:l,weekday:o,...lt(e)}}function Oe(e,t=4,n=1){const{weekYear:r,weekNumber:s,weekday:i}=e,a=Te(ve(r,1,t),n),o=Ke(r);let u,l=s*7+i-a-7+t;if(l<1){u=r-1;l+=Ke(u)}else if(l>o){u=r+1;l-=Ke(r)}else u=r;const{month:c,day:h}=Se(u,l);return{year:u,month:c,day:h,...lt(e)}}function be(e){const{year:t,month:n,day:r}=e;const s=ke(t,n,r);return{year:t,ordinal:s,...lt(e)}}function Ie(e){const{year:t,ordinal:n}=e;const{month:r,day:s}=Se(t,n);return{year:t,month:r,day:s,...lt(e)}}
/**
 * Check if local week units like localWeekday are used in obj.
 * If so, validates that they are not mixed with ISO week units and then copies them to the normal week unit properties.
 * Modifies obj in-place!
 * @param obj the object values
 */function Ne(e,t){const n=!Ze(e.localWeekday)||!Ze(e.localWeekNumber)||!Ze(e.localWeekYear);if(n){const n=!Ze(e.weekday)||!Ze(e.weekNumber)||!Ze(e.weekYear);if(n)throw new ConflictingSpecificationError("Cannot mix locale-based week fields with ISO-based week fields");Ze(e.localWeekday)||(e.weekday=e.localWeekday);Ze(e.localWeekNumber)||(e.weekNumber=e.localWeekNumber);Ze(e.localWeekYear)||(e.weekYear=e.localWeekYear);delete e.localWeekday;delete e.localWeekNumber;delete e.localWeekYear;return{minDaysInFirstWeek:t.getMinDaysInFirstWeek(),startOfWeek:t.getStartOfWeek()}}return{minDaysInFirstWeek:4,startOfWeek:1}}function Me(e,t=4,n=1){const r=Le(e.weekYear),s=Ye(e.weekNumber,1,nt(e.weekYear,t,n)),i=Ye(e.weekday,1,7);return r?s?!i&&pe("weekday",e.weekday):pe("week",e.weekNumber):pe("weekYear",e.weekYear)}function Ee(e){const t=Le(e.year),n=Ye(e.ordinal,1,Ke(e.year));return t?!n&&pe("ordinal",e.ordinal):pe("year",e.year)}function xe(e){const t=Le(e.year),n=Ye(e.month,1,12),r=Ye(e.day,1,Xe(e.year,e.month));return t?n?!r&&pe("day",e.day):pe("month",e.month):pe("year",e.year)}function Fe(e){const{hour:t,minute:n,second:r,millisecond:s}=e;const i=Ye(t,0,23)||t===24&&n===0&&r===0&&s===0,a=Ye(n,0,59),o=Ye(r,0,59),u=Ye(s,0,999);return i?a?o?!u&&pe("millisecond",s):pe("second",r):pe("minute",n):pe("hour",t)}function Ze(e){return typeof e==="undefined"}function Ve(e){return typeof e==="number"}function Le(e){return typeof e==="number"&&e%1===0}function Ce(e){return typeof e==="string"}function $e(e){return Object.prototype.toString.call(e)==="[object Date]"}function Ae(){try{return typeof Intl!=="undefined"&&!!Intl.RelativeTimeFormat}catch(e){return false}}function We(){try{return typeof Intl!=="undefined"&&!!Intl.Locale&&("weekInfo"in Intl.Locale.prototype||"getWeekInfo"in Intl.Locale.prototype)}catch(e){return false}}function ze(e){return Array.isArray(e)?e:[e]}function je(e,t,n){if(e.length!==0)return e.reduce(((e,r)=>{const s=[t(r),r];return e&&n(e[0],s[0])===e[0]?e:s}),null)[1]}function qe(e,t){return t.reduce(((t,n)=>{t[n]=e[n];return t}),{})}function Ue(e,t){return Object.prototype.hasOwnProperty.call(e,t)}function _e(e){if(e==null)return null;if(typeof e!=="object")throw new InvalidArgumentError("Week settings must be an object");if(!Ye(e.firstDay,1,7)||!Ye(e.minimalDays,1,7)||!Array.isArray(e.weekend)||e.weekend.some((e=>!Ye(e,1,7))))throw new InvalidArgumentError("Invalid week settings");return{firstDay:e.firstDay,minimalDays:e.minimalDays,weekend:Array.from(e.weekend)}}function Ye(e,t,n){return Le(e)&&e>=t&&e<=n}function Re(e,t){return e-t*Math.floor(e/t)}function Pe(e,t=2){const n=e<0;let r;r=n?"-"+(""+-e).padStart(t,"0"):(""+e).padStart(t,"0");return r}function He(e){return Ze(e)||e===null||e===""?void 0:parseInt(e,10)}function Je(e){return Ze(e)||e===null||e===""?void 0:parseFloat(e)}function Ge(e){if(!Ze(e)&&e!==null&&e!==""){const t=parseFloat("0."+e)*1e3;return Math.floor(t)}}function Be(e,t,n="round"){const r=10**t;switch(n){case"expand":return e>0?Math.ceil(e*r)/r:Math.floor(e*r)/r;case"trunc":return Math.trunc(e*r)/r;case"round":return Math.round(e*r)/r;case"floor":return Math.floor(e*r)/r;case"ceil":return Math.ceil(e*r)/r;default:throw new RangeError(`Value rounding ${n} is out of range`)}}function Qe(e){return e%4===0&&(e%100!==0||e%400===0)}function Ke(e){return Qe(e)?366:365}function Xe(e,t){const n=Re(t-1,12)+1,r=e+(t-n)/12;return n===2?Qe(r)?29:28:[31,null,31,30,31,30,31,31,30,31,30,31][n-1]}function et(e){let t=Date.UTC(e.year,e.month-1,e.day,e.hour,e.minute,e.second,e.millisecond);if(e.year<100&&e.year>=0){t=new Date(t);t.setUTCFullYear(e.year,e.month-1,e.day)}return+t}function tt(e,t,n){const r=Te(ve(e,1,t),n);return-r+t-1}function nt(e,t=4,n=1){const r=tt(e,t,n);const s=tt(e+1,t,n);return(Ke(e)-r+s)/7}function rt(e){return e>99?e:e>Settings.twoDigitCutoffYear?1900+e:2e3+e}function st(e,t,n,r=null){const s=new Date(e),i={hourCycle:"h23",year:"numeric",month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit"};r&&(i.timeZone=r);const a={timeZoneName:t,...i};const o=new Intl.DateTimeFormat(n,a).formatToParts(s).find((e=>e.type.toLowerCase()==="timezonename"));return o?o.value:null}function it(e,t){let n=parseInt(e,10);Number.isNaN(n)&&(n=0);const r=parseInt(t,10)||0,s=n<0||Object.is(n,-0)?-r:r;return n*60+s}function at(e){const t=Number(e);if(typeof e==="boolean"||e===""||!Number.isFinite(t))throw new InvalidArgumentError(`Invalid unit value ${e}`);return t}function ot(e,t){const n={};for(const r in e)if(Ue(e,r)){const s=e[r];if(s===void 0||s===null)continue;n[t(r)]=at(s)}return n}
/**
 * Returns the offset's value as a string
 * @param {number} ts - Epoch milliseconds for which to get the offset
 * @param {string} format - What style of offset to return.
 *                          Accepts 'narrow', 'short', or 'techie'. Returning '+6', '+06:00', or '+0600' respectively
 * @return {string}
 */function ut(e,t){const n=Math.trunc(Math.abs(e/60)),r=Math.trunc(Math.abs(e%60)),s=e>=0?"+":"-";switch(t){case"short":return`${s}${Pe(n,2)}:${Pe(r,2)}`;case"narrow":return`${s}${n}${r>0?`:${r}`:""}`;case"techie":return`${s}${Pe(n,2)}${Pe(r,2)}`;default:throw new RangeError(`Value format ${t} is out of range for property format`)}}function lt(e){return qe(e,["hour","minute","second","millisecond"])}const ct=["January","February","March","April","May","June","July","August","September","October","November","December"];const ht=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];const dt=["J","F","M","A","M","J","J","A","S","O","N","D"];function mt(e){switch(e){case"narrow":return[...dt];case"short":return[...ht];case"long":return[...ct];case"numeric":return["1","2","3","4","5","6","7","8","9","10","11","12"];case"2-digit":return["01","02","03","04","05","06","07","08","09","10","11","12"];default:return null}}const ft=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];const yt=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];const gt=["M","T","W","T","F","S","S"];function wt(e){switch(e){case"narrow":return[...gt];case"short":return[...yt];case"long":return[...ft];case"numeric":return["1","2","3","4","5","6","7"];default:return null}}const pt=["AM","PM"];const vt=["Before Christ","Anno Domini"];const kt=["BC","AD"];const St=["B","A"];function Tt(e){switch(e){case"narrow":return[...St];case"short":return[...kt];case"long":return[...vt];default:return null}}function Dt(e){return pt[e.hour<12?0:1]}function Ot(e,t){return wt(t)[e.weekday-1]}function bt(e,t){return mt(t)[e.month-1]}function It(e,t){return Tt(t)[e.year<0?0:1]}function Nt(e,t,n="always",r=false){const s={years:["year","yr."],quarters:["quarter","qtr."],months:["month","mo."],weeks:["week","wk."],days:["day","day","days"],hours:["hour","hr."],minutes:["minute","min."],seconds:["second","sec."]};const i=["hours","minutes","seconds"].indexOf(e)===-1;if(n==="auto"&&i){const n=e==="days";switch(t){case 1:return n?"tomorrow":`next ${s[e][0]}`;case-1:return n?"yesterday":`last ${s[e][0]}`;case 0:return n?"today":`this ${s[e][0]}`;default:}}const a=Object.is(t,-0)||t<0,o=Math.abs(t),u=o===1,l=s[e],c=r?u?l[1]:l[2]||l[1]:u?s[e][0]:e;return a?`${o} ${c} ago`:`in ${o} ${c}`}function Mt(e,t){let n="";for(const r of e)r.literal?n+=r.val:n+=t(r.val);return n}const Et={D:r,DD:s,DDD:a,DDDD:o,t:u,tt:l,ttt:c,tttt:h,T:d,TT:m,TTT:f,TTTT:y,f:g,ff:p,fff:S,ffff:D,F:w,FF:v,FFF:T,FFFF:O};class Formatter{static create(e,t={}){return new Formatter(e,t)}static parseFormat(e){let t=null,n="",r=false;const s=[];for(let i=0;i<e.length;i++){const a=e.charAt(i);if(a==="'"){(n.length>0||r)&&s.push({literal:r||/^\s+$/.test(n),val:n===""?"'":n});t=null;n="";r=!r}else if(r)n+=a;else if(a===t)n+=a;else{n.length>0&&s.push({literal:/^\s+$/.test(n),val:n});n=a;t=a}}n.length>0&&s.push({literal:r||/^\s+$/.test(n),val:n});return s}static macroTokenToFormatOpts(e){return Et[e]}constructor(e,t){this.opts=t;this.loc=e;this.systemLoc=null}formatWithSystemDefault(e,t){this.systemLoc===null&&(this.systemLoc=this.loc.redefaultToSystem());const n=this.systemLoc.dtFormatter(e,{...this.opts,...t});return n.format()}dtFormatter(e,t={}){return this.loc.dtFormatter(e,{...this.opts,...t})}formatDateTime(e,t){return this.dtFormatter(e,t).format()}formatDateTimeParts(e,t){return this.dtFormatter(e,t).formatToParts()}formatInterval(e,t){const n=this.dtFormatter(e.start,t);return n.dtf.formatRange(e.start.toJSDate(),e.end.toJSDate())}resolvedOptions(e,t){return this.dtFormatter(e,t).resolvedOptions()}num(e,t=0,n=void 0){if(this.opts.forceSimple)return Pe(e,t);const r={...this.opts};t>0&&(r.padTo=t);n&&(r.signDisplay=n);return this.loc.numberFormatter(r).format(e)}formatDateTimeFromString(e,t){const n=this.loc.listingMode()==="en",r=this.loc.outputCalendar&&this.loc.outputCalendar!=="gregory",s=(t,n)=>this.loc.extract(e,t,n),i=t=>e.isOffsetFixed&&e.offset===0&&t.allowZ?"Z":e.isValid?e.zone.formatOffset(e.ts,t.format):"",a=()=>n?Dt(e):s({hour:"numeric",hourCycle:"h12"},"dayperiod"),o=(t,r)=>n?bt(e,t):s(r?{month:t}:{month:t,day:"numeric"},"month"),u=(t,r)=>n?Ot(e,t):s(r?{weekday:t}:{weekday:t,month:"long",day:"numeric"},"weekday"),l=t=>{const n=Formatter.macroTokenToFormatOpts(t);return n?this.formatWithSystemDefault(e,n):t},c=t=>n?It(e,t):s({era:t},"era"),h=t=>{switch(t){case"S":return this.num(e.millisecond);case"u":case"SSS":return this.num(e.millisecond,3);case"s":return this.num(e.second);case"ss":return this.num(e.second,2);case"uu":return this.num(Math.floor(e.millisecond/10),2);case"uuu":return this.num(Math.floor(e.millisecond/100));case"m":return this.num(e.minute);case"mm":return this.num(e.minute,2);case"h":return this.num(e.hour%12===0?12:e.hour%12);case"hh":return this.num(e.hour%12===0?12:e.hour%12,2);case"H":return this.num(e.hour);case"HH":return this.num(e.hour,2);case"Z":return i({format:"narrow",allowZ:this.opts.allowZ});case"ZZ":return i({format:"short",allowZ:this.opts.allowZ});case"ZZZ":return i({format:"techie",allowZ:this.opts.allowZ});case"ZZZZ":return e.zone.offsetName(e.ts,{format:"short",locale:this.loc.locale});case"ZZZZZ":return e.zone.offsetName(e.ts,{format:"long",locale:this.loc.locale});case"z":return e.zoneName;case"a":return a();case"d":return r?s({day:"numeric"},"day"):this.num(e.day);case"dd":return r?s({day:"2-digit"},"day"):this.num(e.day,2);case"c":return this.num(e.weekday);case"ccc":return u("short",true);case"cccc":return u("long",true);case"ccccc":return u("narrow",true);case"E":return this.num(e.weekday);case"EEE":return u("short",false);case"EEEE":return u("long",false);case"EEEEE":return u("narrow",false);case"L":return r?s({month:"numeric",day:"numeric"},"month"):this.num(e.month);case"LL":return r?s({month:"2-digit",day:"numeric"},"month"):this.num(e.month,2);case"LLL":return o("short",true);case"LLLL":return o("long",true);case"LLLLL":return o("narrow",true);case"M":return r?s({month:"numeric"},"month"):this.num(e.month);case"MM":return r?s({month:"2-digit"},"month"):this.num(e.month,2);case"MMM":return o("short",false);case"MMMM":return o("long",false);case"MMMMM":return o("narrow",false);case"y":return r?s({year:"numeric"},"year"):this.num(e.year);case"yy":return r?s({year:"2-digit"},"year"):this.num(e.year.toString().slice(-2),2);case"yyyy":return r?s({year:"numeric"},"year"):this.num(e.year,4);case"yyyyyy":return r?s({year:"numeric"},"year"):this.num(e.year,6);case"G":return c("short");case"GG":return c("long");case"GGGGG":return c("narrow");case"kk":return this.num(e.weekYear.toString().slice(-2),2);case"kkkk":return this.num(e.weekYear,4);case"W":return this.num(e.weekNumber);case"WW":return this.num(e.weekNumber,2);case"n":return this.num(e.localWeekNumber);case"nn":return this.num(e.localWeekNumber,2);case"ii":return this.num(e.localWeekYear.toString().slice(-2),2);case"iiii":return this.num(e.localWeekYear,4);case"o":return this.num(e.ordinal);case"ooo":return this.num(e.ordinal,3);case"q":return this.num(e.quarter);case"qq":return this.num(e.quarter,2);case"X":return this.num(Math.floor(e.ts/1e3));case"x":return this.num(e.ts);default:return l(t)}};return Mt(Formatter.parseFormat(t),h)}formatDurationFromString(e,t){const n=this.opts.signMode==="negativeLargestOnly"?-1:1;const r=e=>{switch(e[0]){case"S":return"milliseconds";case"s":return"seconds";case"m":return"minutes";case"h":return"hours";case"d":return"days";case"w":return"weeks";case"M":return"months";case"y":return"years";default:return null}},s=(e,t)=>s=>{const i=r(s);if(i){const r=t.isNegativeDuration&&i!==t.largestUnit?n:1;let a;a=this.opts.signMode==="negativeLargestOnly"&&i!==t.largestUnit?"never":this.opts.signMode==="all"?"always":"auto";return this.num(e.get(i)*r,s.length,a)}return s},i=Formatter.parseFormat(t),a=i.reduce(((e,{literal:t,val:n})=>t?e:e.concat(n)),[]),o=e.shiftTo(...a.map(r).filter((e=>e))),u={isNegativeDuration:o<0,largestUnit:Object.keys(o.values)[0]};return Mt(i,s(o,u))}}const xt=/[A-Za-z_+-]{1,256}(?::?\/[A-Za-z0-9_+-]{1,256}(?:\/[A-Za-z0-9_+-]{1,256})?)?/;function Ft(...e){const t=e.reduce(((e,t)=>e+t.source),"");return RegExp(`^${t}$`)}function Zt(...e){return t=>e.reduce((([e,n,r],s)=>{const[i,a,o]=s(t,r);return[{...e,...i},a||n,o]}),[{},null,1]).slice(0,2)}function Vt(e,...t){if(e==null)return[null,null];for(const[n,r]of t){const t=n.exec(e);if(t)return r(t)}return[null,null]}function Lt(...e){return(t,n)=>{const r={};let s;for(s=0;s<e.length;s++)r[e[s]]=He(t[n+s]);return[r,null,n+s]}}const Ct=/(?:([Zz])|([+-]\d\d)(?::?(\d\d))?)/;const $t=`(?:${Ct.source}?(?:\\[(${xt.source})\\])?)?`;const At=/(\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d{1,30}))?)?)?/;const Wt=RegExp(`${At.source}${$t}`);const zt=RegExp(`(?:[Tt]${Wt.source})?`);const jt=/([+-]\d{6}|\d{4})(?:-?(\d\d)(?:-?(\d\d))?)?/;const qt=/(\d{4})-?W(\d\d)(?:-?(\d))?/;const Ut=/(\d{4})-?(\d{3})/;const _t=Lt("weekYear","weekNumber","weekDay");const Yt=Lt("year","ordinal");const Rt=/(\d{4})-(\d\d)-(\d\d)/;const Pt=RegExp(`${At.source} ?(?:${Ct.source}|(${xt.source}))?`);const Ht=RegExp(`(?: ${Pt.source})?`);function Jt(e,t,n){const r=e[t];return Ze(r)?n:He(r)}function Gt(e,t){const n={year:Jt(e,t),month:Jt(e,t+1,1),day:Jt(e,t+2,1)};return[n,null,t+3]}function Bt(e,t){const n={hours:Jt(e,t,0),minutes:Jt(e,t+1,0),seconds:Jt(e,t+2,0),milliseconds:Ge(e[t+3])};return[n,null,t+4]}function Qt(e,t){const n=!e[t]&&!e[t+1],r=it(e[t+1],e[t+2]),s=n?null:FixedOffsetZone.instance(r);return[{},s,t+3]}function Kt(e,t){const n=e[t]?IANAZone.create(e[t]):null;return[{},n,t+1]}const Xt=RegExp(`^T?${At.source}$`);const en=/^-?P(?:(?:(-?\d{1,20}(?:\.\d{1,20})?)Y)?(?:(-?\d{1,20}(?:\.\d{1,20})?)M)?(?:(-?\d{1,20}(?:\.\d{1,20})?)W)?(?:(-?\d{1,20}(?:\.\d{1,20})?)D)?(?:T(?:(-?\d{1,20}(?:\.\d{1,20})?)H)?(?:(-?\d{1,20}(?:\.\d{1,20})?)M)?(?:(-?\d{1,20})(?:[.,](-?\d{1,20}))?S)?)?)$/;function tn(e){const[t,n,r,s,i,a,o,u,l]=e;const c=t[0]==="-";const h=u&&u[0]==="-";const d=(e,t=false)=>e!==void 0&&(t||e&&c)?-e:e;return[{years:d(Je(n)),months:d(Je(r)),weeks:d(Je(s)),days:d(Je(i)),hours:d(Je(a)),minutes:d(Je(o)),seconds:d(Je(u),u==="-0"),milliseconds:d(Ge(l),h)}]}const nn={GMT:0,EDT:-240,EST:-300,CDT:-300,CST:-360,MDT:-360,MST:-420,PDT:-420,PST:-480};function rn(e,t,n,r,s,i,a){const o={year:t.length===2?rt(He(t)):He(t),month:ht.indexOf(n)+1,day:He(r),hour:He(s),minute:He(i)};a&&(o.second=He(a));e&&(o.weekday=e.length>3?ft.indexOf(e)+1:yt.indexOf(e)+1);return o}const sn=/^(?:(Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s)?(\d{1,2})\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(\d{2,4})\s(\d\d):(\d\d)(?::(\d\d))?\s(?:(UT|GMT|[ECMP][SD]T)|([Zz])|(?:([+-]\d\d)(\d\d)))$/;function an(e){const[,t,n,r,s,i,a,o,u,l,c,h]=e,d=rn(t,s,r,n,i,a,o);let m;m=u?nn[u]:l?0:it(c,h);return[d,new FixedOffsetZone(m)]}function on(e){return e.replace(/\([^()]*\)|[\n\t]/g," ").replace(/(\s\s+)/g," ").trim()}const un=/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (\d\d) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d{4}) (\d\d):(\d\d):(\d\d) GMT$/,ln=/^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday), (\d\d)-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-(\d\d) (\d\d):(\d\d):(\d\d) GMT$/,cn=/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ( \d|\d\d) (\d\d):(\d\d):(\d\d) (\d{4})$/;function hn(e){const[,t,n,r,s,i,a,o]=e,u=rn(t,s,r,n,i,a,o);return[u,FixedOffsetZone.utcInstance]}function dn(e){const[,t,n,r,s,i,a,o]=e,u=rn(t,o,n,r,s,i,a);return[u,FixedOffsetZone.utcInstance]}const mn=Ft(jt,zt);const fn=Ft(qt,zt);const yn=Ft(Ut,zt);const gn=Ft(Wt);const wn=Zt(Gt,Bt,Qt,Kt);const pn=Zt(_t,Bt,Qt,Kt);const vn=Zt(Yt,Bt,Qt,Kt);const kn=Zt(Bt,Qt,Kt);function Sn(e){return Vt(e,[mn,wn],[fn,pn],[yn,vn],[gn,kn])}function Tn(e){return Vt(on(e),[sn,an])}function Dn(e){return Vt(e,[un,hn],[ln,hn],[cn,dn])}function On(e){return Vt(e,[en,tn])}const bn=Zt(Bt);function In(e){return Vt(e,[Xt,bn])}const Nn=Ft(Rt,Ht);const Mn=Ft(Pt);const En=Zt(Bt,Qt,Kt);function xn(e){return Vt(e,[Nn,wn],[Mn,En])}const Fn="Invalid Duration";const Zn={weeks:{days:7,hours:168,minutes:10080,seconds:604800,milliseconds:6048e5},days:{hours:24,minutes:1440,seconds:86400,milliseconds:864e5},hours:{minutes:60,seconds:3600,milliseconds:36e5},minutes:{seconds:60,milliseconds:6e4},seconds:{milliseconds:1e3}},Vn={years:{quarters:4,months:12,weeks:52,days:365,hours:8760,minutes:525600,seconds:31536e3,milliseconds:31536e6},quarters:{months:3,weeks:13,days:91,hours:2184,minutes:131040,seconds:7862400,milliseconds:78624e5},months:{weeks:4,days:30,hours:720,minutes:43200,seconds:2592e3,milliseconds:2592e6},...Zn},Ln=365.2425,Cn=30.436875,$n={years:{quarters:4,months:12,weeks:Ln/7,days:Ln,hours:Ln*24,minutes:Ln*24*60,seconds:Ln*24*60*60,milliseconds:Ln*24*60*60*1e3},quarters:{months:3,weeks:Ln/28,days:Ln/4,hours:Ln*24/4,minutes:Ln*24*60/4,seconds:Ln*24*60*60/4,milliseconds:Ln*24*60*60*1e3/4},months:{weeks:Cn/7,days:Cn,hours:Cn*24,minutes:Cn*24*60,seconds:Cn*24*60*60,milliseconds:Cn*24*60*60*1e3},...Zn};const An=["years","quarters","months","weeks","days","hours","minutes","seconds","milliseconds"];const Wn=An.slice(0).reverse();function zn(e,t,n=false){const r={values:n?t.values:{...e.values,...t.values||{}},loc:e.loc.clone(t.loc),conversionAccuracy:t.conversionAccuracy||e.conversionAccuracy,matrix:t.matrix||e.matrix};return new Duration(r)}function jn(e,t){let n=t.milliseconds??0;for(const r of Wn.slice(1))t[r]&&(n+=t[r]*e[r].milliseconds);return n}function qn(e,t){const n=jn(e,t)<0?-1:1;An.reduceRight(((r,s)=>{if(Ze(t[s]))return r;if(r){const i=t[r]*n;const a=e[s][r];const o=Math.floor(i/a);t[s]+=o*n;t[r]-=o*a*n}return s}),null);An.reduce(((n,r)=>{if(Ze(t[r]))return n;if(n){const s=t[n]%1;t[n]-=s;t[r]+=s*e[n][r]}return r}),null)}function Un(e){const t={};for(const[n,r]of Object.entries(e))r!==0&&(t[n]=r);return t}class Duration{constructor(e){const t=e.conversionAccuracy==="longterm"||false;let n=t?$n:Vn;e.matrix&&(n=e.matrix);this.values=e.values;this.loc=e.loc||Locale.create();this.conversionAccuracy=t?"longterm":"casual";this.invalid=e.invalid||null;this.matrix=n;this.isLuxonDuration=true}
/**
   * Create Duration from a number of milliseconds.
   * @param {number} count of milliseconds
   * @param {Object} opts - options for parsing
   * @param {string} [opts.locale='en-US'] - the locale to use
   * @param {string} opts.numberingSystem - the numbering system to use
   * @param {string} [opts.conversionAccuracy='casual'] - the conversion system to use
   * @return {Duration}
   */static fromMillis(e,t){return Duration.fromObject({milliseconds:e},t)}
/**
   * Create a Duration from a JavaScript object with keys like 'years' and 'hours'.
   * If this object is empty then a zero milliseconds duration is returned.
   * @param {Object} obj - the object to create the DateTime from
   * @param {number} obj.years
   * @param {number} obj.quarters
   * @param {number} obj.months
   * @param {number} obj.weeks
   * @param {number} obj.days
   * @param {number} obj.hours
   * @param {number} obj.minutes
   * @param {number} obj.seconds
   * @param {number} obj.milliseconds
   * @param {Object} [opts=[]] - options for creating this Duration
   * @param {string} [opts.locale='en-US'] - the locale to use
   * @param {string} opts.numberingSystem - the numbering system to use
   * @param {string} [opts.conversionAccuracy='casual'] - the preset conversion system to use
   * @param {string} [opts.matrix=Object] - the custom conversion system to use
   * @return {Duration}
   */static fromObject(e,t={}){if(e==null||typeof e!=="object")throw new InvalidArgumentError("Duration.fromObject: argument expected to be an object, got "+(e===null?"null":typeof e));return new Duration({values:ot(e,Duration.normalizeUnit),loc:Locale.fromObject(t),conversionAccuracy:t.conversionAccuracy,matrix:t.matrix})}
/**
   * Create a Duration from DurationLike.
   *
   * @param {Object | number | Duration} durationLike
   * One of:
   * - object with keys like 'years' and 'hours'.
   * - number representing milliseconds
   * - Duration instance
   * @return {Duration}
   */static fromDurationLike(e){if(Ve(e))return Duration.fromMillis(e);if(Duration.isDuration(e))return e;if(typeof e==="object")return Duration.fromObject(e);throw new InvalidArgumentError(`Unknown duration argument ${e} of type ${typeof e}`)}
/**
   * Create a Duration from an ISO 8601 duration string.
   * @param {string} text - text to parse
   * @param {Object} opts - options for parsing
   * @param {string} [opts.locale='en-US'] - the locale to use
   * @param {string} opts.numberingSystem - the numbering system to use
   * @param {string} [opts.conversionAccuracy='casual'] - the preset conversion system to use
   * @param {string} [opts.matrix=Object] - the preset conversion system to use
   * @see https://en.wikipedia.org/wiki/ISO_8601#Durations
   * @example Duration.fromISO('P3Y6M1W4DT12H30M5S').toObject() //=> { years: 3, months: 6, weeks: 1, days: 4, hours: 12, minutes: 30, seconds: 5 }
   * @example Duration.fromISO('PT23H').toObject() //=> { hours: 23 }
   * @example Duration.fromISO('P5Y3M').toObject() //=> { years: 5, months: 3 }
   * @return {Duration}
   */static fromISO(e,t){const[n]=On(e);return n?Duration.fromObject(n,t):Duration.invalid("unparsable",`the input "${e}" can't be parsed as ISO 8601`)}
/**
   * Create a Duration from an ISO 8601 time string.
   * @param {string} text - text to parse
   * @param {Object} opts - options for parsing
   * @param {string} [opts.locale='en-US'] - the locale to use
   * @param {string} opts.numberingSystem - the numbering system to use
   * @param {string} [opts.conversionAccuracy='casual'] - the preset conversion system to use
   * @param {string} [opts.matrix=Object] - the conversion system to use
   * @see https://en.wikipedia.org/wiki/ISO_8601#Times
   * @example Duration.fromISOTime('11:22:33.444').toObject() //=> { hours: 11, minutes: 22, seconds: 33, milliseconds: 444 }
   * @example Duration.fromISOTime('11:00').toObject() //=> { hours: 11, minutes: 0, seconds: 0 }
   * @example Duration.fromISOTime('T11:00').toObject() //=> { hours: 11, minutes: 0, seconds: 0 }
   * @example Duration.fromISOTime('1100').toObject() //=> { hours: 11, minutes: 0, seconds: 0 }
   * @example Duration.fromISOTime('T1100').toObject() //=> { hours: 11, minutes: 0, seconds: 0 }
   * @return {Duration}
   */static fromISOTime(e,t){const[n]=In(e);return n?Duration.fromObject(n,t):Duration.invalid("unparsable",`the input "${e}" can't be parsed as ISO 8601`)}
/**
   * Create an invalid Duration.
   * @param {string} reason - simple string of why this datetime is invalid. Should not contain parameters or anything else data-dependent
   * @param {string} [explanation=null] - longer explanation, may include parameters and other useful debugging information
   * @return {Duration}
   */static invalid(e,t=null){if(!e)throw new InvalidArgumentError("need to specify a reason the Duration is invalid");const n=e instanceof Invalid?e:new Invalid(e,t);if(Settings.throwOnInvalid)throw new InvalidDurationError(n);return new Duration({invalid:n})}static normalizeUnit(e){const t={year:"years",years:"years",quarter:"quarters",quarters:"quarters",month:"months",months:"months",week:"weeks",weeks:"weeks",day:"days",days:"days",hour:"hours",hours:"hours",minute:"minutes",minutes:"minutes",second:"seconds",seconds:"seconds",millisecond:"milliseconds",milliseconds:"milliseconds"}[e?e.toLowerCase():e];if(!t)throw new InvalidUnitError(e);return t}
/**
   * Check if an object is a Duration. Works across context boundaries
   * @param {object} o
   * @return {boolean}
   */static isDuration(e){return e&&e.isLuxonDuration||false}
/**
   * Get  the locale of a Duration, such 'en-GB'
   * @type {string}
   */get locale(){return this.isValid?this.loc.locale:null}
/**
   * Get the numbering system of a Duration, such 'beng'. The numbering system is used when formatting the Duration
   *
   * @type {string}
   */get numberingSystem(){return this.isValid?this.loc.numberingSystem:null}
/**
   * Returns a string representation of this Duration formatted according to the specified format string. You may use these tokens:
   * * `S` for milliseconds
   * * `s` for seconds
   * * `m` for minutes
   * * `h` for hours
   * * `d` for days
   * * `w` for weeks
   * * `M` for months
   * * `y` for years
   * Notes:
   * * Add padding by repeating the token, e.g. "yy" pads the years to two digits, "hhhh" pads the hours out to four digits
   * * Tokens can be escaped by wrapping with single quotes.
   * * The duration will be converted to the set of units in the format string using {@link Duration#shiftTo} and the Durations's conversion accuracy setting.
   * @param {string} fmt - the format string
   * @param {Object} opts - options
   * @param {boolean} [opts.floor=true] - floor numerical values
   * @param {'negative'|'all'|'negativeLargestOnly'} [opts.signMode=negative] - How to handle signs
   * @example Duration.fromObject({ years: 1, days: 6, seconds: 2 }).toFormat("y d s") //=> "1 6 2"
   * @example Duration.fromObject({ years: 1, days: 6, seconds: 2 }).toFormat("yy dd sss") //=> "01 06 002"
   * @example Duration.fromObject({ years: 1, days: 6, seconds: 2 }).toFormat("M S") //=> "12 518402000"
   * @example Duration.fromObject({ days: 6, seconds: 2 }).toFormat("d s", { signMode: "all" }) //=> "+6 +2"
   * @example Duration.fromObject({ days: -6, seconds: -2 }).toFormat("d s", { signMode: "all" }) //=> "-6 -2"
   * @example Duration.fromObject({ days: -6, seconds: -2 }).toFormat("d s", { signMode: "negativeLargestOnly" }) //=> "-6 2"
   * @return {string}
   */toFormat(e,t={}){const n={...t,floor:t.round!==false&&t.floor!==false};return this.isValid?Formatter.create(this.loc,n).formatDurationFromString(this,e):Fn}
/**
   * Returns a string representation of a Duration with all units included.
   * To modify its behavior, use `listStyle` and any Intl.NumberFormat option, though `unitDisplay` is especially relevant.
   * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat#options
   * @param {Object} opts - Formatting options. Accepts the same keys as the options parameter of the native `Intl.NumberFormat` constructor, as well as `listStyle`.
   * @param {string} [opts.listStyle='narrow'] - How to format the merged list. Corresponds to the `style` property of the options parameter of the native `Intl.ListFormat` constructor.
   * @param {boolean} [opts.showZeros=true] - Show all units previously used by the duration even if they are zero
   * @example
   * ```js
   * var dur = Duration.fromObject({ months: 1, weeks: 0, hours: 5, minutes: 6 })
   * dur.toHuman() //=> '1 month, 0 weeks, 5 hours, 6 minutes'
   * dur.toHuman({ listStyle: "long" }) //=> '1 month, 0 weeks, 5 hours, and 6 minutes'
   * dur.toHuman({ unitDisplay: "short" }) //=> '1 mth, 0 wks, 5 hr, 6 min'
   * dur.toHuman({ showZeros: false }) //=> '1 month, 5 hours, 6 minutes'
   * ```
   */toHuman(e={}){if(!this.isValid)return Fn;const t=e.showZeros!==false;const n=An.map((n=>{const r=this.values[n];return Ze(r)||r===0&&!t?null:this.loc.numberFormatter({style:"unit",unitDisplay:"long",...e,unit:n.slice(0,-1)}).format(r)})).filter((e=>e));return this.loc.listFormatter({type:"conjunction",style:e.listStyle||"narrow",...e}).format(n)}toObject(){return this.isValid?{...this.values}:{}}toISO(){if(!this.isValid)return null;let e="P";this.years!==0&&(e+=this.years+"Y");this.months===0&&this.quarters===0||(e+=this.months+this.quarters*3+"M");this.weeks!==0&&(e+=this.weeks+"W");this.days!==0&&(e+=this.days+"D");this.hours===0&&this.minutes===0&&this.seconds===0&&this.milliseconds===0||(e+="T");this.hours!==0&&(e+=this.hours+"H");this.minutes!==0&&(e+=this.minutes+"M");this.seconds===0&&this.milliseconds===0||(e+=Be(this.seconds+this.milliseconds/1e3,3)+"S");e==="P"&&(e+="T0S");return e}
/**
   * Returns an ISO 8601-compliant string representation of this Duration, formatted as a time of day.
   * Note that this will return null if the duration is invalid, negative, or equal to or greater than 24 hours.
   * @see https://en.wikipedia.org/wiki/ISO_8601#Times
   * @param {Object} opts - options
   * @param {boolean} [opts.suppressMilliseconds=false] - exclude milliseconds from the format if they're 0
   * @param {boolean} [opts.suppressSeconds=false] - exclude seconds from the format if they're 0
   * @param {boolean} [opts.includePrefix=false] - include the `T` prefix
   * @param {string} [opts.format='extended'] - choose between the basic and extended format
   * @example Duration.fromObject({ hours: 11 }).toISOTime() //=> '11:00:00.000'
   * @example Duration.fromObject({ hours: 11 }).toISOTime({ suppressMilliseconds: true }) //=> '11:00:00'
   * @example Duration.fromObject({ hours: 11 }).toISOTime({ suppressSeconds: true }) //=> '11:00'
   * @example Duration.fromObject({ hours: 11 }).toISOTime({ includePrefix: true }) //=> 'T11:00:00.000'
   * @example Duration.fromObject({ hours: 11 }).toISOTime({ format: 'basic' }) //=> '110000.000'
   * @return {string}
   */toISOTime(e={}){if(!this.isValid)return null;const t=this.toMillis();if(t<0||t>=864e5)return null;e={suppressMilliseconds:false,suppressSeconds:false,includePrefix:false,format:"extended",...e,includeOffset:false};const n=DateTime.fromMillis(t,{zone:"UTC"});return n.toISOTime(e)}toJSON(){return this.toISO()}toString(){return this.toISO()}[Symbol.for("nodejs.util.inspect.custom")](){return this.isValid?`Duration { values: ${JSON.stringify(this.values)} }`:`Duration { Invalid, reason: ${this.invalidReason} }`}toMillis(){return this.isValid?jn(this.matrix,this.values):NaN}valueOf(){return this.toMillis()}
/**
   * Make this Duration longer by the specified amount. Return a newly-constructed Duration.
   * @param {Duration|Object|number} duration - The amount to add. Either a Luxon Duration, a number of milliseconds, the object argument to Duration.fromObject()
   * @return {Duration}
   */plus(e){if(!this.isValid)return this;const t=Duration.fromDurationLike(e),n={};for(const e of An)(Ue(t.values,e)||Ue(this.values,e))&&(n[e]=t.get(e)+this.get(e));return zn(this,{values:n},true)}
/**
   * Make this Duration shorter by the specified amount. Return a newly-constructed Duration.
   * @param {Duration|Object|number} duration - The amount to subtract. Either a Luxon Duration, a number of milliseconds, the object argument to Duration.fromObject()
   * @return {Duration}
   */minus(e){if(!this.isValid)return this;const t=Duration.fromDurationLike(e);return this.plus(t.negate())}
/**
   * Scale this Duration by the specified amount. Return a newly-constructed Duration.
   * @param {function} fn - The function to apply to each unit. Arity is 1 or 2: the value of the unit and, optionally, the unit name. Must return a number.
   * @example Duration.fromObject({ hours: 1, minutes: 30 }).mapUnits(x => x * 2) //=> { hours: 2, minutes: 60 }
   * @example Duration.fromObject({ hours: 1, minutes: 30 }).mapUnits((x, u) => u === "hours" ? x * 2 : x) //=> { hours: 2, minutes: 30 }
   * @return {Duration}
   */mapUnits(e){if(!this.isValid)return this;const t={};for(const n of Object.keys(this.values))t[n]=at(e(this.values[n],n));return zn(this,{values:t},true)}
/**
   * Get the value of unit.
   * @param {string} unit - a unit such as 'minute' or 'day'
   * @example Duration.fromObject({years: 2, days: 3}).get('years') //=> 2
   * @example Duration.fromObject({years: 2, days: 3}).get('months') //=> 0
   * @example Duration.fromObject({years: 2, days: 3}).get('days') //=> 3
   * @return {number}
   */get(e){return this[Duration.normalizeUnit(e)]}
/**
   * "Set" the values of specified units. Return a newly-constructed Duration.
   * @param {Object} values - a mapping of units to numbers
   * @example dur.set({ years: 2017 })
   * @example dur.set({ hours: 8, minutes: 30 })
   * @return {Duration}
   */set(e){if(!this.isValid)return this;const t={...this.values,...ot(e,Duration.normalizeUnit)};return zn(this,{values:t})}reconfigure({locale:e,numberingSystem:t,conversionAccuracy:n,matrix:r}={}){const s=this.loc.clone({locale:e,numberingSystem:t});const i={loc:s,matrix:r,conversionAccuracy:n};return zn(this,i)}
/**
   * Return the length of the duration in the specified unit.
   * @param {string} unit - a unit such as 'minutes' or 'days'
   * @example Duration.fromObject({years: 1}).as('days') //=> 365
   * @example Duration.fromObject({years: 1}).as('months') //=> 12
   * @example Duration.fromObject({hours: 60}).as('days') //=> 2.5
   * @return {number}
   */as(e){return this.isValid?this.shiftTo(e).get(e):NaN}normalize(){if(!this.isValid)return this;const e=this.toObject();qn(this.matrix,e);return zn(this,{values:e},true)}rescale(){if(!this.isValid)return this;const e=Un(this.normalize().shiftToAll().toObject());return zn(this,{values:e},true)}shiftTo(...e){if(!this.isValid)return this;if(e.length===0)return this;e=e.map((e=>Duration.normalizeUnit(e)));const t={},n={},r=this.toObject();let s;for(const i of An)if(e.indexOf(i)>=0){s=i;let e=0;for(const t in n){e+=this.matrix[t][i]*n[t];n[t]=0}Ve(r[i])&&(e+=r[i]);const a=Math.trunc(e);t[i]=a;n[i]=(e*1e3-a*1e3)/1e3}else Ve(r[i])&&(n[i]=r[i]);for(const e in n)n[e]!==0&&(t[s]+=e===s?n[e]:n[e]/this.matrix[s][e]);qn(this.matrix,t);return zn(this,{values:t},true)}shiftToAll(){return this.isValid?this.shiftTo("years","months","weeks","days","hours","minutes","seconds","milliseconds"):this}negate(){if(!this.isValid)return this;const e={};for(const t of Object.keys(this.values))e[t]=this.values[t]===0?0:-this.values[t];return zn(this,{values:e},true)}removeZeros(){if(!this.isValid)return this;const e=Un(this.values);return zn(this,{values:e},true)}
/**
   * Get the years.
   * @type {number}
   */get years(){return this.isValid?this.values.years||0:NaN}
/**
   * Get the quarters.
   * @type {number}
   */get quarters(){return this.isValid?this.values.quarters||0:NaN}
/**
   * Get the months.
   * @type {number}
   */get months(){return this.isValid?this.values.months||0:NaN}
/**
   * Get the weeks
   * @type {number}
   */get weeks(){return this.isValid?this.values.weeks||0:NaN}
/**
   * Get the days.
   * @type {number}
   */get days(){return this.isValid?this.values.days||0:NaN}
/**
   * Get the hours.
   * @type {number}
   */get hours(){return this.isValid?this.values.hours||0:NaN}
/**
   * Get the minutes.
   * @type {number}
   */get minutes(){return this.isValid?this.values.minutes||0:NaN}get seconds(){return this.isValid?this.values.seconds||0:NaN}get milliseconds(){return this.isValid?this.values.milliseconds||0:NaN}get isValid(){return this.invalid===null}get invalidReason(){return this.invalid?this.invalid.reason:null}
/**
   * Returns an explanation of why this Duration became invalid, or null if the Duration is valid
   * @type {string}
   */get invalidExplanation(){return this.invalid?this.invalid.explanation:null}
/**
   * Equality check
   * Two Durations are equal iff they have the same units and the same values for each unit.
   * @param {Duration} other
   * @return {boolean}
   */equals(e){if(!this.isValid||!e.isValid)return false;if(!this.loc.equals(e.loc))return false;function t(e,t){return e===void 0||e===0?t===void 0||t===0:e===t}for(const n of An)if(!t(this.values[n],e.values[n]))return false;return true}}const _n="Invalid Interval";function Yn(e,t){return e&&e.isValid?t&&t.isValid?t<e?Interval.invalid("end before start",`The end of an interval must be after its start, but you had start=${e.toISO()} and end=${t.toISO()}`):null:Interval.invalid("missing or invalid end"):Interval.invalid("missing or invalid start")}class Interval{constructor(e){this.s=e.start;this.e=e.end;this.invalid=e.invalid||null;this.isLuxonInterval=true}
/**
   * Create an invalid Interval.
   * @param {string} reason - simple string of why this Interval is invalid. Should not contain parameters or anything else data-dependent
   * @param {string} [explanation=null] - longer explanation, may include parameters and other useful debugging information
   * @return {Interval}
   */static invalid(e,t=null){if(!e)throw new InvalidArgumentError("need to specify a reason the Interval is invalid");const n=e instanceof Invalid?e:new Invalid(e,t);if(Settings.throwOnInvalid)throw new InvalidIntervalError(n);return new Interval({invalid:n})}
/**
   * Create an Interval from a start DateTime and an end DateTime. Inclusive of the start but not the end.
   * @param {DateTime|Date|Object} start
   * @param {DateTime|Date|Object} end
   * @return {Interval}
   */static fromDateTimes(e,t){const n=Pr(e),r=Pr(t);const s=Yn(n,r);return s==null?new Interval({start:n,end:r}):s}
/**
   * Create an Interval from a start DateTime and a Duration to extend to.
   * @param {DateTime|Date|Object} start
   * @param {Duration|Object|number} duration - the length of the Interval.
   * @return {Interval}
   */static after(e,t){const n=Duration.fromDurationLike(t),r=Pr(e);return Interval.fromDateTimes(r,r.plus(n))}
/**
   * Create an Interval from an end DateTime and a Duration to extend backwards to.
   * @param {DateTime|Date|Object} end
   * @param {Duration|Object|number} duration - the length of the Interval.
   * @return {Interval}
   */static before(e,t){const n=Duration.fromDurationLike(t),r=Pr(e);return Interval.fromDateTimes(r.minus(n),r)}
/**
   * Create an Interval from an ISO 8601 string.
   * Accepts `<start>/<end>`, `<start>/<duration>`, and `<duration>/<end>` formats.
   * @param {string} text - the ISO string to parse
   * @param {Object} [opts] - options to pass {@link DateTime#fromISO} and optionally {@link Duration#fromISO}
   * @see https://en.wikipedia.org/wiki/ISO_8601#Time_intervals
   * @return {Interval}
   */static fromISO(e,t){const[n,r]=(e||"").split("/",2);if(n&&r){let e,s;try{e=DateTime.fromISO(n,t);s=e.isValid}catch(r){s=false}let i,a;try{i=DateTime.fromISO(r,t);a=i.isValid}catch(r){a=false}if(s&&a)return Interval.fromDateTimes(e,i);if(s){const n=Duration.fromISO(r,t);if(n.isValid)return Interval.after(e,n)}else if(a){const e=Duration.fromISO(n,t);if(e.isValid)return Interval.before(i,e)}}return Interval.invalid("unparsable",`the input "${e}" can't be parsed as ISO 8601`)}
/**
   * Check if an object is an Interval. Works across context boundaries
   * @param {object} o
   * @return {boolean}
   */static isInterval(e){return e&&e.isLuxonInterval||false}
/**
   * Returns the start of the Interval
   * @type {DateTime}
   */get start(){return this.isValid?this.s:null}
/**
   * Returns the end of the Interval. This is the first instant which is not part of the interval
   * (Interval is half-open).
   * @type {DateTime}
   */get end(){return this.isValid?this.e:null}
/**
   * Returns the last DateTime included in the interval (since end is not part of the interval)
   * @type {DateTime}
   */get lastDateTime(){return this.isValid&&this.e?this.e.minus(1):null}
/**
   * Returns whether this Interval's end is at least its start, meaning that the Interval isn't 'backwards'.
   * @type {boolean}
   */get isValid(){return this.invalidReason===null}
/**
   * Returns an error code if this Interval is invalid, or null if the Interval is valid
   * @type {string}
   */get invalidReason(){return this.invalid?this.invalid.reason:null}
/**
   * Returns an explanation of why this Interval became invalid, or null if the Interval is valid
   * @type {string}
   */get invalidExplanation(){return this.invalid?this.invalid.explanation:null}
/**
   * Returns the length of the Interval in the specified unit.
   * @param {string} unit - the unit (such as 'hours' or 'days') to return the length in.
   * @return {number}
   */length(e="milliseconds"){return this.isValid?this.toDuration(e).get(e):NaN}
/**
   * Returns the count of minutes, hours, days, months, or years included in the Interval, even in part.
   * Unlike {@link Interval#length} this counts sections of the calendar, not periods of time, e.g. specifying 'day'
   * asks 'what dates are included in this interval?', not 'how many days long is this interval?'
   * @param {string} [unit='milliseconds'] - the unit of time to count.
   * @param {Object} opts - options
   * @param {boolean} [opts.useLocaleWeeks=false] - If true, use weeks based on the locale, i.e. use the locale-dependent start of the week; this operation will always use the locale of the start DateTime
   * @return {number}
   */count(e="milliseconds",t){if(!this.isValid)return NaN;const n=this.start.startOf(e,t);let r;r=t?.useLocaleWeeks?this.end.reconfigure({locale:n.locale}):this.end;r=r.startOf(e,t);return Math.floor(r.diff(n,e).get(e))+(r.valueOf()!==this.end.valueOf())}
/**
   * Returns whether this Interval's start and end are both in the same unit of time
   * @param {string} unit - the unit of time to check sameness on
   * @return {boolean}
   */hasSame(e){return!!this.isValid&&(this.isEmpty()||this.e.minus(1).hasSame(this.s,e))}isEmpty(){return this.s.valueOf()===this.e.valueOf()}
/**
   * Return whether this Interval's start is after the specified DateTime.
   * @param {DateTime} dateTime
   * @return {boolean}
   */isAfter(e){return!!this.isValid&&this.s>e}
/**
   * Return whether this Interval's end is before the specified DateTime.
   * @param {DateTime} dateTime
   * @return {boolean}
   */isBefore(e){return!!this.isValid&&this.e<=e}
/**
   * Return whether this Interval contains the specified DateTime.
   * @param {DateTime} dateTime
   * @return {boolean}
   */contains(e){return!!this.isValid&&(this.s<=e&&this.e>e)}
/**
   * "Sets" the start and/or end dates. Returns a newly-constructed Interval.
   * @param {Object} values - the values to set
   * @param {DateTime} values.start - the starting DateTime
   * @param {DateTime} values.end - the ending DateTime
   * @return {Interval}
   */set({start:e,end:t}={}){return this.isValid?Interval.fromDateTimes(e||this.s,t||this.e):this}
/**
   * Split this Interval at each of the specified DateTimes
   * @param {...DateTime} dateTimes - the unit of time to count.
   * @return {Array}
   */splitAt(...e){if(!this.isValid)return[];const t=e.map(Pr).filter((e=>this.contains(e))).sort(((e,t)=>e.toMillis()-t.toMillis())),n=[];let{s:r}=this,s=0;while(r<this.e){const e=t[s]||this.e,i=+e>+this.e?this.e:e;n.push(Interval.fromDateTimes(r,i));r=i;s+=1}return n}
/**
   * Split this Interval into smaller Intervals, each of the specified length.
   * Left over time is grouped into a smaller interval
   * @param {Duration|Object|number} duration - The length of each resulting interval.
   * @return {Array}
   */splitBy(e){const t=Duration.fromDurationLike(e);if(!this.isValid||!t.isValid||t.as("milliseconds")===0)return[];let n,{s:r}=this,s=1;const i=[];while(r<this.e){const e=this.start.plus(t.mapUnits((e=>e*s)));n=+e>+this.e?this.e:e;i.push(Interval.fromDateTimes(r,n));r=n;s+=1}return i}
/**
   * Split this Interval into the specified number of smaller intervals.
   * @param {number} numberOfParts - The number of Intervals to divide the Interval into.
   * @return {Array}
   */divideEqually(e){return this.isValid?this.splitBy(this.length()/e).slice(0,e):[]}
/**
   * Return whether this Interval overlaps with the specified Interval
   * @param {Interval} other
   * @return {boolean}
   */overlaps(e){return this.e>e.s&&this.s<e.e}
/**
   * Return whether this Interval's end is adjacent to the specified Interval's start.
   * @param {Interval} other
   * @return {boolean}
   */abutsStart(e){return!!this.isValid&&+this.e===+e.s}
/**
   * Return whether this Interval's start is adjacent to the specified Interval's end.
   * @param {Interval} other
   * @return {boolean}
   */abutsEnd(e){return!!this.isValid&&+e.e===+this.s}
/**
   * Returns true if this Interval fully contains the specified Interval, specifically if the intersect (of this Interval and the other Interval) is equal to the other Interval; false otherwise.
   * @param {Interval} other
   * @return {boolean}
   */engulfs(e){return!!this.isValid&&(this.s<=e.s&&this.e>=e.e)}
/**
   * Return whether this Interval has the same start and end as the specified Interval.
   * @param {Interval} other
   * @return {boolean}
   */equals(e){return!(!this.isValid||!e.isValid)&&(this.s.equals(e.s)&&this.e.equals(e.e))}
/**
   * Return an Interval representing the intersection of this Interval and the specified Interval.
   * Specifically, the resulting Interval has the maximum start time and the minimum end time of the two Intervals.
   * Returns null if the intersection is empty, meaning, the intervals don't intersect.
   * @param {Interval} other
   * @return {Interval}
   */intersection(e){if(!this.isValid)return this;const t=this.s>e.s?this.s:e.s,n=this.e<e.e?this.e:e.e;return t>=n?null:Interval.fromDateTimes(t,n)}
/**
   * Return an Interval representing the union of this Interval and the specified Interval.
   * Specifically, the resulting Interval has the minimum start time and the maximum end time of the two Intervals.
   * @param {Interval} other
   * @return {Interval}
   */union(e){if(!this.isValid)return this;const t=this.s<e.s?this.s:e.s,n=this.e>e.e?this.e:e.e;return Interval.fromDateTimes(t,n)}
/**
   * Merge an array of Intervals into an equivalent minimal set of Intervals.
   * Combines overlapping and adjacent Intervals.
   * The resulting array will contain the Intervals in ascending order, that is, starting with the earliest Interval
   * and ending with the latest.
   *
   * @param {Array} intervals
   * @return {Array}
   */static merge(e){const[t,n]=e.sort(((e,t)=>e.s-t.s)).reduce((([e,t],n)=>t?t.overlaps(n)||t.abutsStart(n)?[e,t.union(n)]:[e.concat([t]),n]:[e,n]),[[],null]);n&&t.push(n);return t}
/**
   * Return an array of Intervals representing the spans of time that only appear in one of the specified Intervals.
   * @param {Array} intervals
   * @return {Array}
   */static xor(e){let t=null,n=0;const r=[],s=e.map((e=>[{time:e.s,type:"s"},{time:e.e,type:"e"}])),i=Array.prototype.concat(...s),a=i.sort(((e,t)=>e.time-t.time));for(const e of a){n+=e.type==="s"?1:-1;if(n===1)t=e.time;else{t&&+t!==+e.time&&r.push(Interval.fromDateTimes(t,e.time));t=null}}return Interval.merge(r)}
/**
   * Return an Interval representing the span of time in this Interval that doesn't overlap with any of the specified Intervals.
   * @param {...Interval} intervals
   * @return {Array}
   */difference(...e){return Interval.xor([this].concat(e)).map((e=>this.intersection(e))).filter((e=>e&&!e.isEmpty()))}toString(){return this.isValid?`[${this.s.toISO()} – ${this.e.toISO()})`:_n}[Symbol.for("nodejs.util.inspect.custom")](){return this.isValid?`Interval { start: ${this.s.toISO()}, end: ${this.e.toISO()} }`:`Interval { Invalid, reason: ${this.invalidReason} }`}
/**
   * Returns a localized string representing this Interval. Accepts the same options as the
   * Intl.DateTimeFormat constructor and any presets defined by Luxon, such as
   * {@link DateTime.DATE_FULL} or {@link DateTime.TIME_SIMPLE}. The exact behavior of this method
   * is browser-specific, but in general it will return an appropriate representation of the
   * Interval in the assigned locale. Defaults to the system's locale if no locale has been
   * specified.
   * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
   * @param {Object} [formatOpts=DateTime.DATE_SHORT] - Either a DateTime preset or
   * Intl.DateTimeFormat constructor options.
   * @param {Object} opts - Options to override the configuration of the start DateTime.
   * @example Interval.fromISO('2022-11-07T09:00Z/2022-11-08T09:00Z').toLocaleString(); //=> 11/7/2022 – 11/8/2022
   * @example Interval.fromISO('2022-11-07T09:00Z/2022-11-08T09:00Z').toLocaleString(DateTime.DATE_FULL); //=> November 7 – 8, 2022
   * @example Interval.fromISO('2022-11-07T09:00Z/2022-11-08T09:00Z').toLocaleString(DateTime.DATE_FULL, { locale: 'fr-FR' }); //=> 7–8 novembre 2022
   * @example Interval.fromISO('2022-11-07T17:00Z/2022-11-07T19:00Z').toLocaleString(DateTime.TIME_SIMPLE); //=> 6:00 – 8:00 PM
   * @example Interval.fromISO('2022-11-07T17:00Z/2022-11-07T19:00Z').toLocaleString({ weekday: 'short', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }); //=> Mon, Nov 07, 6:00 – 8:00 p
   * @return {string}
   */toLocaleString(e=r,t={}){return this.isValid?Formatter.create(this.s.loc.clone(t),e).formatInterval(this):_n}
/**
   * Returns an ISO 8601-compliant string representation of this Interval.
   * @see https://en.wikipedia.org/wiki/ISO_8601#Time_intervals
   * @param {Object} opts - The same options as {@link DateTime#toISO}
   * @return {string}
   */toISO(e){return this.isValid?`${this.s.toISO(e)}/${this.e.toISO(e)}`:_n}toISODate(){return this.isValid?`${this.s.toISODate()}/${this.e.toISODate()}`:_n}
/**
   * Returns an ISO 8601-compliant string representation of time of this Interval.
   * The date components are ignored.
   * @see https://en.wikipedia.org/wiki/ISO_8601#Time_intervals
   * @param {Object} opts - The same options as {@link DateTime#toISO}
   * @return {string}
   */toISOTime(e){return this.isValid?`${this.s.toISOTime(e)}/${this.e.toISOTime(e)}`:_n}
/**
   * Returns a string representation of this Interval formatted according to the specified format
   * string. **You may not want this.** See {@link Interval#toLocaleString} for a more flexible
   * formatting tool.
   * @param {string} dateFormat - The format string. This string formats the start and end time.
   * See {@link DateTime#toFormat} for details.
   * @param {Object} opts - Options.
   * @param {string} [opts.separator =  ' – '] - A separator to place between the start and end
   * representations.
   * @return {string}
   */toFormat(e,{separator:t=" – "}={}){return this.isValid?`${this.s.toFormat(e)}${t}${this.e.toFormat(e)}`:_n}
/**
   * Return a Duration representing the time spanned by this interval.
   * @param {string|string[]} [unit=['milliseconds']] - the unit or units (such as 'hours' or 'days') to include in the duration.
   * @param {Object} opts - options that affect the creation of the Duration
   * @param {string} [opts.conversionAccuracy='casual'] - the conversion system to use
   * @example Interval.fromDateTimes(dt1, dt2).toDuration().toObject() //=> { milliseconds: 88489257 }
   * @example Interval.fromDateTimes(dt1, dt2).toDuration('days').toObject() //=> { days: 1.0241812152777778 }
   * @example Interval.fromDateTimes(dt1, dt2).toDuration(['hours', 'minutes']).toObject() //=> { hours: 24, minutes: 34.82095 }
   * @example Interval.fromDateTimes(dt1, dt2).toDuration(['hours', 'minutes', 'seconds']).toObject() //=> { hours: 24, minutes: 34, seconds: 49.257 }
   * @example Interval.fromDateTimes(dt1, dt2).toDuration('seconds').toObject() //=> { seconds: 88489.257 }
   * @return {Duration}
   */toDuration(e,t){return this.isValid?this.e.diff(this.s,e,t):Duration.invalid(this.invalidReason)}
/**
   * Run mapFn on the interval start and end, returning a new Interval from the resulting DateTimes
   * @param {function} mapFn
   * @return {Interval}
   * @example Interval.fromDateTimes(dt1, dt2).mapEndpoints(endpoint => endpoint.toUTC())
   * @example Interval.fromDateTimes(dt1, dt2).mapEndpoints(endpoint => endpoint.plus({ hours: 2 }))
   */mapEndpoints(e){return Interval.fromDateTimes(e(this.s),e(this.e))}}class Info{
/**
   * Return whether the specified zone contains a DST.
   * @param {string|Zone} [zone='local'] - Zone to check. Defaults to the environment's local zone.
   * @return {boolean}
   */
static hasDST(e=Settings.defaultZone){const t=DateTime.now().setZone(e).set({month:12});return!e.isUniversal&&t.offset!==t.set({month:6}).offset}
/**
   * Return whether the specified zone is a valid IANA specifier.
   * @param {string} zone - Zone to check
   * @return {boolean}
   */static isValidIANAZone(e){return IANAZone.isValidZone(e)}
/**
   * Converts the input into a {@link Zone} instance.
   *
   * * If `input` is already a Zone instance, it is returned unchanged.
   * * If `input` is a string containing a valid time zone name, a Zone instance
   *   with that name is returned.
   * * If `input` is a string that doesn't refer to a known time zone, a Zone
   *   instance with {@link Zone#isValid} == false is returned.
   * * If `input is a number, a Zone instance with the specified fixed offset
   *   in minutes is returned.
   * * If `input` is `null` or `undefined`, the default zone is returned.
   * @param {string|Zone|number} [input] - the value to be converted
   * @return {Zone}
   */static normalizeZone(e){return ee(e,Settings.defaultZone)}
/**
   * Get the weekday on which the week starts according to the given locale.
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @returns {number} the start of the week, 1 for Monday through 7 for Sunday
   */static getStartOfWeek({locale:e=null,locObj:t=null}={}){return(t||Locale.create(e)).getStartOfWeek()}
/**
   * Get the minimum number of days necessary in a week before it is considered part of the next year according
   * to the given locale.
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @returns {number}
   */static getMinimumDaysInFirstWeek({locale:e=null,locObj:t=null}={}){return(t||Locale.create(e)).getMinDaysInFirstWeek()}
/**
   * Get the weekdays, which are considered the weekend according to the given locale
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @returns {number[]} an array of weekdays, 1 for Monday through 7 for Sunday
   */static getWeekendWeekdays({locale:e=null,locObj:t=null}={}){return(t||Locale.create(e)).getWeekendDays().slice()}
/**
   * Return an array of standalone month names.
   * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
   * @param {string} [length='long'] - the length of the month representation, such as "numeric", "2-digit", "narrow", "short", "long"
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @param {string} [opts.numberingSystem=null] - the numbering system
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @param {string} [opts.outputCalendar='gregory'] - the calendar
   * @example Info.months()[0] //=> 'January'
   * @example Info.months('short')[0] //=> 'Jan'
   * @example Info.months('numeric')[0] //=> '1'
   * @example Info.months('short', { locale: 'fr-CA' } )[0] //=> 'janv.'
   * @example Info.months('numeric', { locale: 'ar' })[0] //=> '١'
   * @example Info.months('long', { outputCalendar: 'islamic' })[0] //=> 'Rabiʻ I'
   * @return {Array}
   */static months(e="long",{locale:t=null,numberingSystem:n=null,locObj:r=null,outputCalendar:s="gregory"}={}){return(r||Locale.create(t,n,s)).months(e)}
/**
   * Return an array of format month names.
   * Format months differ from standalone months in that they're meant to appear next to the day of the month. In some languages, that
   * changes the string.
   * See {@link Info#months}
   * @param {string} [length='long'] - the length of the month representation, such as "numeric", "2-digit", "narrow", "short", "long"
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @param {string} [opts.numberingSystem=null] - the numbering system
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @param {string} [opts.outputCalendar='gregory'] - the calendar
   * @return {Array}
   */static monthsFormat(e="long",{locale:t=null,numberingSystem:n=null,locObj:r=null,outputCalendar:s="gregory"}={}){return(r||Locale.create(t,n,s)).months(e,true)}
/**
   * Return an array of standalone week names.
   * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
   * @param {string} [length='long'] - the length of the weekday representation, such as "narrow", "short", "long".
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @param {string} [opts.numberingSystem=null] - the numbering system
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @example Info.weekdays()[0] //=> 'Monday'
   * @example Info.weekdays('short')[0] //=> 'Mon'
   * @example Info.weekdays('short', { locale: 'fr-CA' })[0] //=> 'lun.'
   * @example Info.weekdays('short', { locale: 'ar' })[0] //=> 'الاثنين'
   * @return {Array}
   */static weekdays(e="long",{locale:t=null,numberingSystem:n=null,locObj:r=null}={}){return(r||Locale.create(t,n,null)).weekdays(e)}
/**
   * Return an array of format week names.
   * Format weekdays differ from standalone weekdays in that they're meant to appear next to more date information. In some languages, that
   * changes the string.
   * See {@link Info#weekdays}
   * @param {string} [length='long'] - the length of the month representation, such as "narrow", "short", "long".
   * @param {Object} opts - options
   * @param {string} [opts.locale=null] - the locale code
   * @param {string} [opts.numberingSystem=null] - the numbering system
   * @param {string} [opts.locObj=null] - an existing locale object to use
   * @return {Array}
   */static weekdaysFormat(e="long",{locale:t=null,numberingSystem:n=null,locObj:r=null}={}){return(r||Locale.create(t,n,null)).weekdays(e,true)}
/**
   * Return an array of meridiems.
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @example Info.meridiems() //=> [ 'AM', 'PM' ]
   * @example Info.meridiems({ locale: 'my' }) //=> [ 'နံနက်', 'ညနေ' ]
   * @return {Array}
   */static meridiems({locale:e=null}={}){return Locale.create(e).meridiems()}
/**
   * Return an array of eras, such as ['BC', 'AD']. The locale can be specified, but the calendar system is always Gregorian.
   * @param {string} [length='short'] - the length of the era representation, such as "short" or "long".
   * @param {Object} opts - options
   * @param {string} [opts.locale] - the locale code
   * @example Info.eras() //=> [ 'BC', 'AD' ]
   * @example Info.eras('long') //=> [ 'Before Christ', 'Anno Domini' ]
   * @example Info.eras('long', { locale: 'fr' }) //=> [ 'avant Jésus-Christ', 'après Jésus-Christ' ]
   * @return {Array}
   */static eras(e="short",{locale:t=null}={}){return Locale.create(t,null,"gregory").eras(e)}static features(){return{relative:Ae(),localeWeek:We()}}}function Rn(e,t){const n=e=>e.toUTC(0,{keepLocalTime:true}).startOf("day").valueOf(),r=n(t)-n(e);return Math.floor(Duration.fromMillis(r).as("days"))}function Pn(e,t,n){const r=[["years",(e,t)=>t.year-e.year],["quarters",(e,t)=>t.quarter-e.quarter+4*(t.year-e.year)],["months",(e,t)=>t.month-e.month+12*(t.year-e.year)],["weeks",(e,t)=>{const n=Rn(e,t);return(n-n%7)/7}],["days",Rn]];const s={};const i=e;let a,o;for(const[u,l]of r)if(n.indexOf(u)>=0){a=u;s[u]=l(e,t);o=i.plus(s);if(o>t){s[u]--;e=i.plus(s);if(e>t){o=e;s[u]--;e=i.plus(s)}}else e=o}return[e,s,o,a]}function Hn(e,t,n,r){let[s,i,a,o]=Pn(e,t,n);const u=t-s;const l=n.filter((e=>["hours","minutes","seconds","milliseconds"].indexOf(e)>=0));if(l.length===0){a<t&&(a=s.plus({[o]:1}));a!==s&&(i[o]=(i[o]||0)+u/(a-s))}const c=Duration.fromObject(i,r);return l.length>0?Duration.fromMillis(u,r).shiftTo(...l).plus(c):c}const Jn="missing Intl.DateTimeFormat.formatToParts support";function Gn(e,t=e=>e){return{regex:e,deser:([e])=>t(se(e))}}const Bn=String.fromCharCode(160);const Qn=`[ ${Bn}]`;const Kn=new RegExp(Qn,"g");function Xn(e){return e.replace(/\./g,"\\.?").replace(Kn,Qn)}function er(e){return e.replace(/\./g,"").replace(Kn," ").toLowerCase()}function tr(e,t){return e===null?null:{regex:RegExp(e.map(Xn).join("|")),deser:([n])=>e.findIndex((e=>er(n)===er(e)))+t}}function nr(e,t){return{regex:e,deser:([,e,t])=>it(e,t),groups:t}}function rr(e){return{regex:e,deser:([e])=>e}}function sr(e){return e.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g,"\\$&")}
/**
 * @param token
 * @param {Locale} loc
 */function ir(e,t){const n=oe(t),r=oe(t,"{2}"),s=oe(t,"{3}"),i=oe(t,"{4}"),a=oe(t,"{6}"),o=oe(t,"{1,2}"),u=oe(t,"{1,3}"),l=oe(t,"{1,6}"),c=oe(t,"{1,9}"),h=oe(t,"{2,4}"),d=oe(t,"{4,6}"),m=e=>({regex:RegExp(sr(e.val)),deser:([e])=>e,literal:true}),f=f=>{if(e.literal)return m(f);switch(f.val){case"G":return tr(t.eras("short"),0);case"GG":return tr(t.eras("long"),0);case"y":return Gn(l);case"yy":return Gn(h,rt);case"yyyy":return Gn(i);case"yyyyy":return Gn(d);case"yyyyyy":return Gn(a);case"M":return Gn(o);case"MM":return Gn(r);case"MMM":return tr(t.months("short",true),1);case"MMMM":return tr(t.months("long",true),1);case"L":return Gn(o);case"LL":return Gn(r);case"LLL":return tr(t.months("short",false),1);case"LLLL":return tr(t.months("long",false),1);case"d":return Gn(o);case"dd":return Gn(r);case"o":return Gn(u);case"ooo":return Gn(s);case"HH":return Gn(r);case"H":return Gn(o);case"hh":return Gn(r);case"h":return Gn(o);case"mm":return Gn(r);case"m":return Gn(o);case"q":return Gn(o);case"qq":return Gn(r);case"s":return Gn(o);case"ss":return Gn(r);case"S":return Gn(u);case"SSS":return Gn(s);case"u":return rr(c);case"uu":return rr(o);case"uuu":return Gn(n);case"a":return tr(t.meridiems(),0);case"kkkk":return Gn(i);case"kk":return Gn(h,rt);case"W":return Gn(o);case"WW":return Gn(r);case"E":case"c":return Gn(n);case"EEE":return tr(t.weekdays("short",false),1);case"EEEE":return tr(t.weekdays("long",false),1);case"ccc":return tr(t.weekdays("short",true),1);case"cccc":return tr(t.weekdays("long",true),1);case"Z":case"ZZ":return nr(new RegExp(`([+-]${o.source})(?::(${r.source}))?`),2);case"ZZZ":return nr(new RegExp(`([+-]${o.source})(${r.source})?`),2);case"z":return rr(/[a-z_+-/]{1,256}?/i);case" ":return rr(/[^\S\n\r]/);default:return m(f)}};const y=f(e)||{invalidReason:Jn};y.token=e;return y}const ar={year:{"2-digit":"yy",numeric:"yyyyy"},month:{numeric:"M","2-digit":"MM",short:"MMM",long:"MMMM"},day:{numeric:"d","2-digit":"dd"},weekday:{short:"EEE",long:"EEEE"},dayperiod:"a",dayPeriod:"a",hour12:{numeric:"h","2-digit":"hh"},hour24:{numeric:"H","2-digit":"HH"},minute:{numeric:"m","2-digit":"mm"},second:{numeric:"s","2-digit":"ss"},timeZoneName:{long:"ZZZZZ",short:"ZZZ"}};function or(e,t,n){const{type:r,value:s}=e;if(r==="literal"){const e=/^\s+$/.test(s);return{literal:!e,val:e?" ":s}}const i=t[r];let a=r;r==="hour"&&(a=t.hour12!=null?t.hour12?"hour12":"hour24":t.hourCycle!=null?t.hourCycle==="h11"||t.hourCycle==="h12"?"hour12":"hour24":n.hour12?"hour12":"hour24");let o=ar[a];typeof o==="object"&&(o=o[i]);if(o)return{literal:false,val:o}}function ur(e){const t=e.map((e=>e.regex)).reduce(((e,t)=>`${e}(${t.source})`),"");return[`^${t}$`,e]}function lr(e,t,n){const r=e.match(t);if(r){const e={};let t=1;for(const s in n)if(Ue(n,s)){const i=n[s],a=i.groups?i.groups+1:1;!i.literal&&i.token&&(e[i.token.val[0]]=i.deser(r.slice(t,t+a)));t+=a}return[r,e]}return[r,{}]}function cr(e){const t=e=>{switch(e){case"S":return"millisecond";case"s":return"second";case"m":return"minute";case"h":case"H":return"hour";case"d":return"day";case"o":return"ordinal";case"L":case"M":return"month";case"y":return"year";case"E":case"c":return"weekday";case"W":return"weekNumber";case"k":return"weekYear";case"q":return"quarter";default:return null}};let n=null;let r;Ze(e.z)||(n=IANAZone.create(e.z));if(!Ze(e.Z)){n||(n=new FixedOffsetZone(e.Z));r=e.Z}Ze(e.q)||(e.M=3*(e.q-1)+1);Ze(e.h)||(e.h<12&&e.a===1?e.h+=12:e.h===12&&e.a===0&&(e.h=0));e.G===0&&e.y&&(e.y=-e.y);Ze(e.u)||(e.S=Ge(e.u));const s=Object.keys(e).reduce(((n,r)=>{const s=t(r);s&&(n[s]=e[r]);return n}),{});return[s,n,r]}let hr=null;function dr(){hr||(hr=DateTime.fromMillis(1555555555555));return hr}function mr(e,t){if(e.literal)return e;const n=Formatter.macroTokenToFormatOpts(e.val);const r=wr(n,t);return r==null||r.includes(void 0)?e:r}function fr(e,t){return Array.prototype.concat(...e.map((e=>mr(e,t))))}class TokenParser{constructor(e,t){this.locale=e;this.format=t;this.tokens=fr(Formatter.parseFormat(t),e);this.units=this.tokens.map((t=>ir(t,e)));this.disqualifyingUnit=this.units.find((e=>e.invalidReason));if(!this.disqualifyingUnit){const[e,t]=ur(this.units);this.regex=RegExp(e,"i");this.handlers=t}}explainFromTokens(e){if(this.isValid){const[t,n]=lr(e,this.regex,this.handlers),[r,s,i]=n?cr(n):[null,null,void 0];if(Ue(n,"a")&&Ue(n,"H"))throw new ConflictingSpecificationError("Can't include meridiem when specifying 24-hour format");return{input:e,tokens:this.tokens,regex:this.regex,rawMatches:t,matches:n,result:r,zone:s,specificOffset:i}}return{input:e,tokens:this.tokens,invalidReason:this.invalidReason}}get isValid(){return!this.disqualifyingUnit}get invalidReason(){return this.disqualifyingUnit?this.disqualifyingUnit.invalidReason:null}}function yr(e,t,n){const r=new TokenParser(e,n);return r.explainFromTokens(t)}function gr(e,t,n){const{result:r,zone:s,specificOffset:i,invalidReason:a}=yr(e,t,n);return[r,s,i,a]}function wr(e,t){if(!e)return null;const n=Formatter.create(t,e);const r=n.dtFormatter(dr());const s=r.formatToParts();const i=r.resolvedOptions();return s.map((t=>or(t,e,i)))}const pr="Invalid DateTime";const vr=864e13;function kr(e){return new Invalid("unsupported zone",`the zone "${e.name}" is not supported`)}
/**
 * @param {DateTime} dt
 */function Sr(e){e.weekData===null&&(e.weekData=De(e.c));return e.weekData}
/**
 * @param {DateTime} dt
 */function Tr(e){e.localWeekData===null&&(e.localWeekData=De(e.c,e.loc.getMinDaysInFirstWeek(),e.loc.getStartOfWeek()));return e.localWeekData}function Dr(e,t){const n={ts:e.ts,zone:e.zone,c:e.c,o:e.o,loc:e.loc,invalid:e.invalid};return new DateTime({...n,...t,old:n})}function Or(e,t,n){let r=e-t*60*1e3;const s=n.offset(r);if(t===s)return[r,t];r-=60*(s-t)*1e3;const i=n.offset(r);return s===i?[r,s]:[e-Math.min(s,i)*60*1e3,Math.max(s,i)]}function br(e,t){e+=t*60*1e3;const n=new Date(e);return{year:n.getUTCFullYear(),month:n.getUTCMonth()+1,day:n.getUTCDate(),hour:n.getUTCHours(),minute:n.getUTCMinutes(),second:n.getUTCSeconds(),millisecond:n.getUTCMilliseconds()}}function Ir(e,t,n){return Or(et(e),t,n)}function Nr(e,t){const n=e.o,r=e.c.year+Math.trunc(t.years),s=e.c.month+Math.trunc(t.months)+Math.trunc(t.quarters)*3,i={...e.c,year:r,month:s,day:Math.min(e.c.day,Xe(r,s))+Math.trunc(t.days)+Math.trunc(t.weeks)*7},a=Duration.fromObject({years:t.years-Math.trunc(t.years),quarters:t.quarters-Math.trunc(t.quarters),months:t.months-Math.trunc(t.months),weeks:t.weeks-Math.trunc(t.weeks),days:t.days-Math.trunc(t.days),hours:t.hours,minutes:t.minutes,seconds:t.seconds,milliseconds:t.milliseconds}).as("milliseconds"),o=et(i);let[u,l]=Or(o,n,e.zone);if(a!==0){u+=a;l=e.zone.offset(u)}return{ts:u,o:l}}function Mr(e,t,n,r,s,i){const{setZone:a,zone:o}=n;if(e&&Object.keys(e).length!==0||t){const r=t||o,s=DateTime.fromObject(e,{...n,zone:r,specificOffset:i});return a?s:s.setZone(o)}return DateTime.invalid(new Invalid("unparsable",`the input "${s}" can't be parsed as ${r}`))}function Er(e,t,n=true){return e.isValid?Formatter.create(Locale.create("en-US"),{allowZ:n,forceSimple:true}).formatDateTimeFromString(e,t):null}function xr(e,t,n){const r=e.c.year>9999||e.c.year<0;let s="";r&&e.c.year>=0&&(s+="+");s+=Pe(e.c.year,r?6:4);if(n==="year")return s;if(t){s+="-";s+=Pe(e.c.month);if(n==="month")return s;s+="-"}else{s+=Pe(e.c.month);if(n==="month")return s}s+=Pe(e.c.day);return s}function Fr(e,t,n,r,s,i,a){let o=!n||e.c.millisecond!==0||e.c.second!==0,u="";switch(a){case"day":case"month":case"year":break;default:u+=Pe(e.c.hour);if(a==="hour")break;if(t){u+=":";u+=Pe(e.c.minute);if(a==="minute")break;if(o){u+=":";u+=Pe(e.c.second)}}else{u+=Pe(e.c.minute);if(a==="minute")break;o&&(u+=Pe(e.c.second))}if(a==="second")break;if(o&&(!r||e.c.millisecond!==0)){u+=".";u+=Pe(e.c.millisecond,3)}}if(s)if(e.isOffsetFixed&&e.offset===0&&!i)u+="Z";else if(e.o<0){u+="-";u+=Pe(Math.trunc(-e.o/60));u+=":";u+=Pe(Math.trunc(-e.o%60))}else{u+="+";u+=Pe(Math.trunc(e.o/60));u+=":";u+=Pe(Math.trunc(e.o%60))}i&&(u+="["+e.zone.ianaName+"]");return u}const Zr={month:1,day:1,hour:0,minute:0,second:0,millisecond:0},Vr={weekNumber:1,weekday:1,hour:0,minute:0,second:0,millisecond:0},Lr={ordinal:1,hour:0,minute:0,second:0,millisecond:0};const Cr=["year","month","day","hour","minute","second","millisecond"],$r=["weekYear","weekNumber","weekday","hour","minute","second","millisecond"],Ar=["year","ordinal","hour","minute","second","millisecond"];function Wr(e){const t={year:"year",years:"year",month:"month",months:"month",day:"day",days:"day",hour:"hour",hours:"hour",minute:"minute",minutes:"minute",quarter:"quarter",quarters:"quarter",second:"second",seconds:"second",millisecond:"millisecond",milliseconds:"millisecond",weekday:"weekday",weekdays:"weekday",weeknumber:"weekNumber",weeksnumber:"weekNumber",weeknumbers:"weekNumber",weekyear:"weekYear",weekyears:"weekYear",ordinal:"ordinal"}[e.toLowerCase()];if(!t)throw new InvalidUnitError(e);return t}function zr(e){switch(e.toLowerCase()){case"localweekday":case"localweekdays":return"localWeekday";case"localweeknumber":case"localweeknumbers":return"localWeekNumber";case"localweekyear":case"localweekyears":return"localWeekYear";default:return Wr(e)}}
/**
 * @param {Zone} zone
 * @return {number}
 */function jr(e){Yr===void 0&&(Yr=Settings.now());if(e.type!=="iana")return e.offset(Yr);const t=e.name;let n=Rr.get(t);if(n===void 0){n=e.offset(Yr);Rr.set(t,n)}return n}function qr(e,t){const n=ee(t.zone,Settings.defaultZone);if(!n.isValid)return DateTime.invalid(kr(n));const r=Locale.fromObject(t);let s,i;if(Ze(e.year))s=Settings.now();else{for(const t of Cr)Ze(e[t])&&(e[t]=Zr[t]);const t=xe(e)||Fe(e);if(t)return DateTime.invalid(t);const r=jr(n);[s,i]=Ir(e,r,n)}return new DateTime({ts:s,zone:n,loc:r,o:i})}function Ur(e,t,n){const r=!!Ze(n.round)||n.round,s=Ze(n.rounding)?"trunc":n.rounding,i=(e,i)=>{e=Be(e,r||n.calendary?0:2,n.calendary?"round":s);const a=t.loc.clone(n).relFormatter(n);return a.format(e,i)},a=r=>n.calendary?t.hasSame(e,r)?0:t.startOf(r).diff(e.startOf(r),r).get(r):t.diff(e,r).get(r);if(n.unit)return i(a(n.unit),n.unit);for(const e of n.units){const t=a(e);if(Math.abs(t)>=1)return i(t,e)}return i(e>t?-0:0,n.units[n.units.length-1])}function _r(e){let t,n={};if(e.length>0&&typeof e[e.length-1]==="object"){n=e[e.length-1];t=Array.from(e).slice(0,e.length-1)}else t=Array.from(e);return[n,t]}let Yr;const Rr=new Map;class DateTime{constructor(e){const t=e.zone||Settings.defaultZone;let n=e.invalid||(Number.isNaN(e.ts)?new Invalid("invalid input"):null)||(t.isValid?null:kr(t));this.ts=Ze(e.ts)?Settings.now():e.ts;let r=null,s=null;if(!n){const i=e.old&&e.old.ts===this.ts&&e.old.zone.equals(t);if(i)[r,s]=[e.old.c,e.old.o];else{const i=Ve(e.o)&&!e.old?e.o:t.offset(this.ts);r=br(this.ts,i);n=Number.isNaN(r.year)?new Invalid("invalid input"):null;r=n?null:r;s=n?null:i}}this._zone=t;this.loc=e.loc||Locale.create();this.invalid=n;this.weekData=null;this.localWeekData=null;this.c=r;this.o=s;this.isLuxonDateTime=true}static now(){return new DateTime({})}
/**
   * Create a local DateTime
   * @param {number} [year] - The calendar year. If omitted (as in, call `local()` with no arguments), the current time will be used
   * @param {number} [month=1] - The month, 1-indexed
   * @param {number} [day=1] - The day of the month, 1-indexed
   * @param {number} [hour=0] - The hour of the day, in 24-hour time
   * @param {number} [minute=0] - The minute of the hour, meaning a number between 0 and 59
   * @param {number} [second=0] - The second of the minute, meaning a number between 0 and 59
   * @param {number} [millisecond=0] - The millisecond of the second, meaning a number between 0 and 999
   * @example DateTime.local()                                  //~> now
   * @example DateTime.local({ zone: "America/New_York" })      //~> now, in US east coast time
   * @example DateTime.local(2017)                              //~> 2017-01-01T00:00:00
   * @example DateTime.local(2017, 3)                           //~> 2017-03-01T00:00:00
   * @example DateTime.local(2017, 3, 12, { locale: "fr" })     //~> 2017-03-12T00:00:00, with a French locale
   * @example DateTime.local(2017, 3, 12, 5)                    //~> 2017-03-12T05:00:00
   * @example DateTime.local(2017, 3, 12, 5, { zone: "utc" })   //~> 2017-03-12T05:00:00, in UTC
   * @example DateTime.local(2017, 3, 12, 5, 45)                //~> 2017-03-12T05:45:00
   * @example DateTime.local(2017, 3, 12, 5, 45, 10)            //~> 2017-03-12T05:45:10
   * @example DateTime.local(2017, 3, 12, 5, 45, 10, 765)       //~> 2017-03-12T05:45:10.765
   * @return {DateTime}
   */static local(){const[e,t]=_r(arguments),[n,r,s,i,a,o,u]=t;return qr({year:n,month:r,day:s,hour:i,minute:a,second:o,millisecond:u},e)}
/**
   * Create a DateTime in UTC
   * @param {number} [year] - The calendar year. If omitted (as in, call `utc()` with no arguments), the current time will be used
   * @param {number} [month=1] - The month, 1-indexed
   * @param {number} [day=1] - The day of the month
   * @param {number} [hour=0] - The hour of the day, in 24-hour time
   * @param {number} [minute=0] - The minute of the hour, meaning a number between 0 and 59
   * @param {number} [second=0] - The second of the minute, meaning a number between 0 and 59
   * @param {number} [millisecond=0] - The millisecond of the second, meaning a number between 0 and 999
   * @param {Object} options - configuration options for the DateTime
   * @param {string} [options.locale] - a locale to set on the resulting DateTime instance
   * @param {string} [options.outputCalendar] - the output calendar to set on the resulting DateTime instance
   * @param {string} [options.numberingSystem] - the numbering system to set on the resulting DateTime instance
   * @param {string} [options.weekSettings] - the week settings to set on the resulting DateTime instance
   * @example DateTime.utc()                                              //~> now
   * @example DateTime.utc(2017)                                          //~> 2017-01-01T00:00:00Z
   * @example DateTime.utc(2017, 3)                                       //~> 2017-03-01T00:00:00Z
   * @example DateTime.utc(2017, 3, 12)                                   //~> 2017-03-12T00:00:00Z
   * @example DateTime.utc(2017, 3, 12, 5)                                //~> 2017-03-12T05:00:00Z
   * @example DateTime.utc(2017, 3, 12, 5, 45)                            //~> 2017-03-12T05:45:00Z
   * @example DateTime.utc(2017, 3, 12, 5, 45, { locale: "fr" })          //~> 2017-03-12T05:45:00Z with a French locale
   * @example DateTime.utc(2017, 3, 12, 5, 45, 10)                        //~> 2017-03-12T05:45:10Z
   * @example DateTime.utc(2017, 3, 12, 5, 45, 10, 765, { locale: "fr" }) //~> 2017-03-12T05:45:10.765Z with a French locale
   * @return {DateTime}
   */static utc(){const[e,t]=_r(arguments),[n,r,s,i,a,o,u]=t;e.zone=FixedOffsetZone.utcInstance;return qr({year:n,month:r,day:s,hour:i,minute:a,second:o,millisecond:u},e)}
/**
   * Create a DateTime from a JavaScript Date object. Uses the default zone.
   * @param {Date} date - a JavaScript Date object
   * @param {Object} options - configuration options for the DateTime
   * @param {string|Zone} [options.zone='local'] - the zone to place the DateTime into
   * @return {DateTime}
   */static fromJSDate(e,t={}){const n=$e(e)?e.valueOf():NaN;if(Number.isNaN(n))return DateTime.invalid("invalid input");const r=ee(t.zone,Settings.defaultZone);return r.isValid?new DateTime({ts:n,zone:r,loc:Locale.fromObject(t)}):DateTime.invalid(kr(r))}
/**
   * Create a DateTime from a number of milliseconds since the epoch (meaning since 1 January 1970 00:00:00 UTC). Uses the default zone.
   * @param {number} milliseconds - a number of milliseconds since 1970 UTC
   * @param {Object} options - configuration options for the DateTime
   * @param {string|Zone} [options.zone='local'] - the zone to place the DateTime into
   * @param {string} [options.locale] - a locale to set on the resulting DateTime instance
   * @param {string} options.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @param {string} options.numberingSystem - the numbering system to set on the resulting DateTime instance
   * @param {string} options.weekSettings - the week settings to set on the resulting DateTime instance
   * @return {DateTime}
   */static fromMillis(e,t={}){if(Ve(e))return e<-864e13||e>vr?DateTime.invalid("Timestamp out of range"):new DateTime({ts:e,zone:ee(t.zone,Settings.defaultZone),loc:Locale.fromObject(t)});throw new InvalidArgumentError(`fromMillis requires a numerical input, but received a ${typeof e} with value ${e}`)}
/**
   * Create a DateTime from a number of seconds since the epoch (meaning since 1 January 1970 00:00:00 UTC). Uses the default zone.
   * @param {number} seconds - a number of seconds since 1970 UTC
   * @param {Object} options - configuration options for the DateTime
   * @param {string|Zone} [options.zone='local'] - the zone to place the DateTime into
   * @param {string} [options.locale] - a locale to set on the resulting DateTime instance
   * @param {string} options.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @param {string} options.numberingSystem - the numbering system to set on the resulting DateTime instance
   * @param {string} options.weekSettings - the week settings to set on the resulting DateTime instance
   * @return {DateTime}
   */static fromSeconds(e,t={}){if(Ve(e))return new DateTime({ts:e*1e3,zone:ee(t.zone,Settings.defaultZone),loc:Locale.fromObject(t)});throw new InvalidArgumentError("fromSeconds requires a numerical input")}
/**
   * Create a DateTime from a JavaScript object with keys like 'year' and 'hour' with reasonable defaults.
   * @param {Object} obj - the object to create the DateTime from
   * @param {number} obj.year - a year, such as 1987
   * @param {number} obj.month - a month, 1-12
   * @param {number} obj.day - a day of the month, 1-31, depending on the month
   * @param {number} obj.ordinal - day of the year, 1-365 or 366
   * @param {number} obj.weekYear - an ISO week year
   * @param {number} obj.weekNumber - an ISO week number, between 1 and 52 or 53, depending on the year
   * @param {number} obj.weekday - an ISO weekday, 1-7, where 1 is Monday and 7 is Sunday
   * @param {number} obj.localWeekYear - a week year, according to the locale
   * @param {number} obj.localWeekNumber - a week number, between 1 and 52 or 53, depending on the year, according to the locale
   * @param {number} obj.localWeekday - a weekday, 1-7, where 1 is the first and 7 is the last day of the week, according to the locale
   * @param {number} obj.hour - hour of the day, 0-23
   * @param {number} obj.minute - minute of the hour, 0-59
   * @param {number} obj.second - second of the minute, 0-59
   * @param {number} obj.millisecond - millisecond of the second, 0-999
   * @param {Object} opts - options for creating this DateTime
   * @param {string|Zone} [opts.zone='local'] - interpret the numbers in the context of a particular zone. Can take any value taken as the first argument to setZone()
   * @param {string} [opts.locale='system\'s locale'] - a locale to set on the resulting DateTime instance
   * @param {string} opts.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @param {string} opts.numberingSystem - the numbering system to set on the resulting DateTime instance
   * @param {string} opts.weekSettings - the week settings to set on the resulting DateTime instance
   * @example DateTime.fromObject({ year: 1982, month: 5, day: 25}).toISODate() //=> '1982-05-25'
   * @example DateTime.fromObject({ year: 1982 }).toISODate() //=> '1982-01-01'
   * @example DateTime.fromObject({ hour: 10, minute: 26, second: 6 }) //~> today at 10:26:06
   * @example DateTime.fromObject({ hour: 10, minute: 26, second: 6 }, { zone: 'utc' }),
   * @example DateTime.fromObject({ hour: 10, minute: 26, second: 6 }, { zone: 'local' })
   * @example DateTime.fromObject({ hour: 10, minute: 26, second: 6 }, { zone: 'America/New_York' })
   * @example DateTime.fromObject({ weekYear: 2016, weekNumber: 2, weekday: 3 }).toISODate() //=> '2016-01-13'
   * @example DateTime.fromObject({ localWeekYear: 2022, localWeekNumber: 1, localWeekday: 1 }, { locale: "en-US" }).toISODate() //=> '2021-12-26'
   * @return {DateTime}
   */static fromObject(e,t={}){e=e||{};const n=ee(t.zone,Settings.defaultZone);if(!n.isValid)return DateTime.invalid(kr(n));const r=Locale.fromObject(t);const s=ot(e,zr);const{minDaysInFirstWeek:i,startOfWeek:a}=Ne(s,r);const o=Settings.now(),u=Ze(t.specificOffset)?n.offset(o):t.specificOffset,l=!Ze(s.ordinal),c=!Ze(s.year),h=!Ze(s.month)||!Ze(s.day),d=c||h,m=s.weekYear||s.weekNumber;if((d||l)&&m)throw new ConflictingSpecificationError("Can't mix weekYear/weekNumber units with year/month/day or ordinals");if(h&&l)throw new ConflictingSpecificationError("Can't mix ordinal dates with month/day");const f=m||s.weekday&&!d;let y,g,w=br(o,u);if(f){y=$r;g=Vr;w=De(w,i,a)}else if(l){y=Ar;g=Lr;w=be(w)}else{y=Cr;g=Zr}let p=false;for(const e of y){const t=s[e];Ze(t)?s[e]=p?g[e]:w[e]:p=true}const v=f?Me(s,i,a):l?Ee(s):xe(s),k=v||Fe(s);if(k)return DateTime.invalid(k);const S=f?Oe(s,i,a):l?Ie(s):s,[T,D]=Ir(S,u,n),O=new DateTime({ts:T,zone:n,o:D,loc:r});return s.weekday&&d&&e.weekday!==O.weekday?DateTime.invalid("mismatched weekday",`you can't specify both a weekday of ${s.weekday} and a date of ${O.toISO()}`):O.isValid?O:DateTime.invalid(O.invalid)}
/**
   * Create a DateTime from an ISO 8601 string
   * @param {string} text - the ISO string
   * @param {Object} opts - options to affect the creation
   * @param {string|Zone} [opts.zone='local'] - use this zone if no offset is specified in the input string itself. Will also convert the time to this zone
   * @param {boolean} [opts.setZone=false] - override the zone with a fixed-offset zone specified in the string itself, if it specifies one
   * @param {string} [opts.locale='system's locale'] - a locale to set on the resulting DateTime instance
   * @param {string} [opts.outputCalendar] - the output calendar to set on the resulting DateTime instance
   * @param {string} [opts.numberingSystem] - the numbering system to set on the resulting DateTime instance
   * @param {string} [opts.weekSettings] - the week settings to set on the resulting DateTime instance
   * @example DateTime.fromISO('2016-05-25T09:08:34.123')
   * @example DateTime.fromISO('2016-05-25T09:08:34.123+06:00')
   * @example DateTime.fromISO('2016-05-25T09:08:34.123+06:00', {setZone: true})
   * @example DateTime.fromISO('2016-05-25T09:08:34.123', {zone: 'utc'})
   * @example DateTime.fromISO('2016-W05-4')
   * @return {DateTime}
   */static fromISO(e,t={}){const[n,r]=Sn(e);return Mr(n,r,t,"ISO 8601",e)}
/**
   * Create a DateTime from an RFC 2822 string
   * @param {string} text - the RFC 2822 string
   * @param {Object} opts - options to affect the creation
   * @param {string|Zone} [opts.zone='local'] - convert the time to this zone. Since the offset is always specified in the string itself, this has no effect on the interpretation of string, merely the zone the resulting DateTime is expressed in.
   * @param {boolean} [opts.setZone=false] - override the zone with a fixed-offset zone specified in the string itself, if it specifies one
   * @param {string} [opts.locale='system's locale'] - a locale to set on the resulting DateTime instance
   * @param {string} opts.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @param {string} opts.numberingSystem - the numbering system to set on the resulting DateTime instance
   * @param {string} opts.weekSettings - the week settings to set on the resulting DateTime instance
   * @example DateTime.fromRFC2822('25 Nov 2016 13:23:12 GMT')
   * @example DateTime.fromRFC2822('Fri, 25 Nov 2016 13:23:12 +0600')
   * @example DateTime.fromRFC2822('25 Nov 2016 13:23 Z')
   * @return {DateTime}
   */static fromRFC2822(e,t={}){const[n,r]=Tn(e);return Mr(n,r,t,"RFC 2822",e)}
/**
   * Create a DateTime from an HTTP header date
   * @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
   * @param {string} text - the HTTP header date
   * @param {Object} opts - options to affect the creation
   * @param {string|Zone} [opts.zone='local'] - convert the time to this zone. Since HTTP dates are always in UTC, this has no effect on the interpretation of string, merely the zone the resulting DateTime is expressed in.
   * @param {boolean} [opts.setZone=false] - override the zone with the fixed-offset zone specified in the string. For HTTP dates, this is always UTC, so this option is equivalent to setting the `zone` option to 'utc', but this option is included for consistency with similar methods.
   * @param {string} [opts.locale='system's locale'] - a locale to set on the resulting DateTime instance
   * @param {string} opts.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @param {string} opts.numberingSystem - the numbering system to set on the resulting DateTime instance
   * @param {string} opts.weekSettings - the week settings to set on the resulting DateTime instance
   * @example DateTime.fromHTTP('Sun, 06 Nov 1994 08:49:37 GMT')
   * @example DateTime.fromHTTP('Sunday, 06-Nov-94 08:49:37 GMT')
   * @example DateTime.fromHTTP('Sun Nov  6 08:49:37 1994')
   * @return {DateTime}
   */static fromHTTP(e,t={}){const[n,r]=Dn(e);return Mr(n,r,t,"HTTP",t)}
/**
   * Create a DateTime from an input string and format string.
   * Defaults to en-US if no locale has been specified, regardless of the system's locale. For a table of tokens and their interpretations, see [here](https://moment.github.io/luxon/#/parsing?id=table-of-tokens).
   * @param {string} text - the string to parse
   * @param {string} fmt - the format the string is expected to be in (see the link below for the formats)
   * @param {Object} opts - options to affect the creation
   * @param {string|Zone} [opts.zone='local'] - use this zone if no offset is specified in the input string itself. Will also convert the DateTime to this zone
   * @param {boolean} [opts.setZone=false] - override the zone with a zone specified in the string itself, if it specifies one
   * @param {string} [opts.locale='en-US'] - a locale string to use when parsing. Will also set the DateTime to this locale
   * @param {string} opts.numberingSystem - the numbering system to use when parsing. Will also set the resulting DateTime to this numbering system
   * @param {string} opts.weekSettings - the week settings to set on the resulting DateTime instance
   * @param {string} opts.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @return {DateTime}
   */static fromFormat(e,t,n={}){if(Ze(e)||Ze(t))throw new InvalidArgumentError("fromFormat requires an input string and a format");const{locale:r=null,numberingSystem:s=null}=n,i=Locale.fromOpts({locale:r,numberingSystem:s,defaultToEN:true}),[a,o,u,l]=gr(i,e,t);return l?DateTime.invalid(l):Mr(a,o,n,`format ${t}`,e,u)}
/**
   * @deprecated use fromFormat instead
   */static fromString(e,t,n={}){return DateTime.fromFormat(e,t,n)}
/**
   * Create a DateTime from a SQL date, time, or datetime
   * Defaults to en-US if no locale has been specified, regardless of the system's locale
   * @param {string} text - the string to parse
   * @param {Object} opts - options to affect the creation
   * @param {string|Zone} [opts.zone='local'] - use this zone if no offset is specified in the input string itself. Will also convert the DateTime to this zone
   * @param {boolean} [opts.setZone=false] - override the zone with a zone specified in the string itself, if it specifies one
   * @param {string} [opts.locale='en-US'] - a locale string to use when parsing. Will also set the DateTime to this locale
   * @param {string} opts.numberingSystem - the numbering system to use when parsing. Will also set the resulting DateTime to this numbering system
   * @param {string} opts.weekSettings - the week settings to set on the resulting DateTime instance
   * @param {string} opts.outputCalendar - the output calendar to set on the resulting DateTime instance
   * @example DateTime.fromSQL('2017-05-15')
   * @example DateTime.fromSQL('2017-05-15 09:12:34')
   * @example DateTime.fromSQL('2017-05-15 09:12:34.342')
   * @example DateTime.fromSQL('2017-05-15 09:12:34.342+06:00')
   * @example DateTime.fromSQL('2017-05-15 09:12:34.342 America/Los_Angeles')
   * @example DateTime.fromSQL('2017-05-15 09:12:34.342 America/Los_Angeles', { setZone: true })
   * @example DateTime.fromSQL('2017-05-15 09:12:34.342', { zone: 'America/Los_Angeles' })
   * @example DateTime.fromSQL('09:12:34.342')
   * @return {DateTime}
   */static fromSQL(e,t={}){const[n,r]=xn(e);return Mr(n,r,t,"SQL",e)}
/**
   * Create an invalid DateTime.
   * @param {string} reason - simple string of why this DateTime is invalid. Should not contain parameters or anything else data-dependent.
   * @param {string} [explanation=null] - longer explanation, may include parameters and other useful debugging information
   * @return {DateTime}
   */static invalid(e,t=null){if(!e)throw new InvalidArgumentError("need to specify a reason the DateTime is invalid");const n=e instanceof Invalid?e:new Invalid(e,t);if(Settings.throwOnInvalid)throw new InvalidDateTimeError(n);return new DateTime({invalid:n})}
/**
   * Check if an object is an instance of DateTime. Works across context boundaries
   * @param {object} o
   * @return {boolean}
   */static isDateTime(e){return e&&e.isLuxonDateTime||false}
/**
   * Produce the format string for a set of options
   * @param formatOpts
   * @param localeOpts
   * @returns {string}
   */static parseFormatForOpts(e,t={}){const n=wr(e,Locale.fromObject(t));return n?n.map((e=>e?e.val:null)).join(""):null}
/**
   * Produce the the fully expanded format token for the locale
   * Does NOT quote characters, so quoted tokens will not round trip correctly
   * @param fmt
   * @param localeOpts
   * @returns {string}
   */static expandFormat(e,t={}){const n=fr(Formatter.parseFormat(e),Locale.fromObject(t));return n.map((e=>e.val)).join("")}static resetCache(){Yr=void 0;Rr.clear()}
/**
   * Get the value of unit.
   * @param {string} unit - a unit such as 'minute' or 'day'
   * @example DateTime.local(2017, 7, 4).get('month'); //=> 7
   * @example DateTime.local(2017, 7, 4).get('day'); //=> 4
   * @return {number}
   */
get(e){return this[e]}
/**
   * Returns whether the DateTime is valid. Invalid DateTimes occur when:
   * * The DateTime was created from invalid calendar information, such as the 13th month or February 30
   * * The DateTime was created by an operation on another invalid date
   * @type {boolean}
   */get isValid(){return this.invalid===null}
/**
   * Returns an error code if this DateTime is invalid, or null if the DateTime is valid
   * @type {string}
   */get invalidReason(){return this.invalid?this.invalid.reason:null}
/**
   * Returns an explanation of why this DateTime became invalid, or null if the DateTime is valid
   * @type {string}
   */get invalidExplanation(){return this.invalid?this.invalid.explanation:null}
/**
   * Get the locale of a DateTime, such 'en-GB'. The locale is used when formatting the DateTime
   *
   * @type {string}
   */get locale(){return this.isValid?this.loc.locale:null}
/**
   * Get the numbering system of a DateTime, such 'beng'. The numbering system is used when formatting the DateTime
   *
   * @type {string}
   */get numberingSystem(){return this.isValid?this.loc.numberingSystem:null}
/**
   * Get the output calendar of a DateTime, such 'islamic'. The output calendar is used when formatting the DateTime
   *
   * @type {string}
   */get outputCalendar(){return this.isValid?this.loc.outputCalendar:null}
/**
   * Get the time zone associated with this DateTime.
   * @type {Zone}
   */get zone(){return this._zone}
/**
   * Get the name of the time zone.
   * @type {string}
   */get zoneName(){return this.isValid?this.zone.name:null}
/**
   * Get the year
   * @example DateTime.local(2017, 5, 25).year //=> 2017
   * @type {number}
   */get year(){return this.isValid?this.c.year:NaN}
/**
   * Get the quarter
   * @example DateTime.local(2017, 5, 25).quarter //=> 2
   * @type {number}
   */get quarter(){return this.isValid?Math.ceil(this.c.month/3):NaN}
/**
   * Get the month (1-12).
   * @example DateTime.local(2017, 5, 25).month //=> 5
   * @type {number}
   */get month(){return this.isValid?this.c.month:NaN}
/**
   * Get the day of the month (1-30ish).
   * @example DateTime.local(2017, 5, 25).day //=> 25
   * @type {number}
   */get day(){return this.isValid?this.c.day:NaN}
/**
   * Get the hour of the day (0-23).
   * @example DateTime.local(2017, 5, 25, 9).hour //=> 9
   * @type {number}
   */get hour(){return this.isValid?this.c.hour:NaN}
/**
   * Get the minute of the hour (0-59).
   * @example DateTime.local(2017, 5, 25, 9, 30).minute //=> 30
   * @type {number}
   */get minute(){return this.isValid?this.c.minute:NaN}
/**
   * Get the second of the minute (0-59).
   * @example DateTime.local(2017, 5, 25, 9, 30, 52).second //=> 52
   * @type {number}
   */get second(){return this.isValid?this.c.second:NaN}
/**
   * Get the millisecond of the second (0-999).
   * @example DateTime.local(2017, 5, 25, 9, 30, 52, 654).millisecond //=> 654
   * @type {number}
   */get millisecond(){return this.isValid?this.c.millisecond:NaN}
/**
   * Get the week year
   * @see https://en.wikipedia.org/wiki/ISO_week_date
   * @example DateTime.local(2014, 12, 31).weekYear //=> 2015
   * @type {number}
   */get weekYear(){return this.isValid?Sr(this).weekYear:NaN}
/**
   * Get the week number of the week year (1-52ish).
   * @see https://en.wikipedia.org/wiki/ISO_week_date
   * @example DateTime.local(2017, 5, 25).weekNumber //=> 21
   * @type {number}
   */get weekNumber(){return this.isValid?Sr(this).weekNumber:NaN}
/**
   * Get the day of the week.
   * 1 is Monday and 7 is Sunday
   * @see https://en.wikipedia.org/wiki/ISO_week_date
   * @example DateTime.local(2014, 11, 31).weekday //=> 4
   * @type {number}
   */get weekday(){return this.isValid?Sr(this).weekday:NaN}
/**
   * Returns true if this date is on a weekend according to the locale, false otherwise
   * @returns {boolean}
   */get isWeekend(){return this.isValid&&this.loc.getWeekendDays().includes(this.weekday)}
/**
   * Get the day of the week according to the locale.
   * 1 is the first day of the week and 7 is the last day of the week.
   * If the locale assigns Sunday as the first day of the week, then a date which is a Sunday will return 1,
   * @returns {number}
   */get localWeekday(){return this.isValid?Tr(this).weekday:NaN}
/**
   * Get the week number of the week year according to the locale. Different locales assign week numbers differently,
   * because the week can start on different days of the week (see localWeekday) and because a different number of days
   * is required for a week to count as the first week of a year.
   * @returns {number}
   */get localWeekNumber(){return this.isValid?Tr(this).weekNumber:NaN}
/**
   * Get the week year according to the locale. Different locales assign week numbers (and therefor week years)
   * differently, see localWeekNumber.
   * @returns {number}
   */get localWeekYear(){return this.isValid?Tr(this).weekYear:NaN}
/**
   * Get the ordinal (meaning the day of the year)
   * @example DateTime.local(2017, 5, 25).ordinal //=> 145
   * @type {number|DateTime}
   */get ordinal(){return this.isValid?be(this.c).ordinal:NaN}
/**
   * Get the human readable short month name, such as 'Oct'.
   * Defaults to the system's locale if no locale has been specified
   * @example DateTime.local(2017, 10, 30).monthShort //=> Oct
   * @type {string}
   */get monthShort(){return this.isValid?Info.months("short",{locObj:this.loc})[this.month-1]:null}
/**
   * Get the human readable long month name, such as 'October'.
   * Defaults to the system's locale if no locale has been specified
   * @example DateTime.local(2017, 10, 30).monthLong //=> October
   * @type {string}
   */get monthLong(){return this.isValid?Info.months("long",{locObj:this.loc})[this.month-1]:null}
/**
   * Get the human readable short weekday, such as 'Mon'.
   * Defaults to the system's locale if no locale has been specified
   * @example DateTime.local(2017, 10, 30).weekdayShort //=> Mon
   * @type {string}
   */get weekdayShort(){return this.isValid?Info.weekdays("short",{locObj:this.loc})[this.weekday-1]:null}
/**
   * Get the human readable long weekday, such as 'Monday'.
   * Defaults to the system's locale if no locale has been specified
   * @example DateTime.local(2017, 10, 30).weekdayLong //=> Monday
   * @type {string}
   */get weekdayLong(){return this.isValid?Info.weekdays("long",{locObj:this.loc})[this.weekday-1]:null}
/**
   * Get the UTC offset of this DateTime in minutes
   * @example DateTime.now().offset //=> -240
   * @example DateTime.utc().offset //=> 0
   * @type {number}
   */get offset(){return this.isValid?+this.o:NaN}
/**
   * Get the short human name for the zone's current offset, for example "EST" or "EDT".
   * Defaults to the system's locale if no locale has been specified
   * @type {string}
   */get offsetNameShort(){return this.isValid?this.zone.offsetName(this.ts,{format:"short",locale:this.locale}):null}
/**
   * Get the long human name for the zone's current offset, for example "Eastern Standard Time" or "Eastern Daylight Time".
   * Defaults to the system's locale if no locale has been specified
   * @type {string}
   */get offsetNameLong(){return this.isValid?this.zone.offsetName(this.ts,{format:"long",locale:this.locale}):null}
/**
   * Get whether this zone's offset ever changes, as in a DST.
   * @type {boolean}
   */get isOffsetFixed(){return this.isValid?this.zone.isUniversal:null}
/**
   * Get whether the DateTime is in a DST.
   * @type {boolean}
   */get isInDST(){return!this.isOffsetFixed&&(this.offset>this.set({month:1,day:1}).offset||this.offset>this.set({month:5}).offset)}
/**
   * Get those DateTimes which have the same local time as this DateTime, but a different offset from UTC
   * in this DateTime's zone. During DST changes local time can be ambiguous, for example
   * `2023-10-29T02:30:00` in `Europe/Berlin` can have offset `+01:00` or `+02:00`.
   * This method will return both possible DateTimes if this DateTime's local time is ambiguous.
   * @returns {DateTime[]}
   */getPossibleOffsets(){if(!this.isValid||this.isOffsetFixed)return[this];const e=864e5;const t=6e4;const n=et(this.c);const r=this.zone.offset(n-e);const s=this.zone.offset(n+e);const i=this.zone.offset(n-r*t);const a=this.zone.offset(n-s*t);if(i===a)return[this];const o=n-i*t;const u=n-a*t;const l=br(o,i);const c=br(u,a);return l.hour===c.hour&&l.minute===c.minute&&l.second===c.second&&l.millisecond===c.millisecond?[Dr(this,{ts:o}),Dr(this,{ts:u})]:[this]}
/**
   * Returns true if this DateTime is in a leap year, false otherwise
   * @example DateTime.local(2016).isInLeapYear //=> true
   * @example DateTime.local(2013).isInLeapYear //=> false
   * @type {boolean}
   */get isInLeapYear(){return Qe(this.year)}
/**
   * Returns the number of days in this DateTime's month
   * @example DateTime.local(2016, 2).daysInMonth //=> 29
   * @example DateTime.local(2016, 3).daysInMonth //=> 31
   * @type {number}
   */get daysInMonth(){return Xe(this.year,this.month)}
/**
   * Returns the number of days in this DateTime's year
   * @example DateTime.local(2016).daysInYear //=> 366
   * @example DateTime.local(2013).daysInYear //=> 365
   * @type {number}
   */get daysInYear(){return this.isValid?Ke(this.year):NaN}
/**
   * Returns the number of weeks in this DateTime's year
   * @see https://en.wikipedia.org/wiki/ISO_week_date
   * @example DateTime.local(2004).weeksInWeekYear //=> 53
   * @example DateTime.local(2013).weeksInWeekYear //=> 52
   * @type {number}
   */get weeksInWeekYear(){return this.isValid?nt(this.weekYear):NaN}
/**
   * Returns the number of weeks in this DateTime's local week year
   * @example DateTime.local(2020, 6, {locale: 'en-US'}).weeksInLocalWeekYear //=> 52
   * @example DateTime.local(2020, 6, {locale: 'de-DE'}).weeksInLocalWeekYear //=> 53
   * @type {number}
   */get weeksInLocalWeekYear(){return this.isValid?nt(this.localWeekYear,this.loc.getMinDaysInFirstWeek(),this.loc.getStartOfWeek()):NaN}
/**
   * Returns the resolved Intl options for this DateTime.
   * This is useful in understanding the behavior of formatting methods
   * @param {Object} opts - the same options as toLocaleString
   * @return {Object}
   */resolvedLocaleOptions(e={}){const{locale:t,numberingSystem:n,calendar:r}=Formatter.create(this.loc.clone(e),e).resolvedOptions(this);return{locale:t,numberingSystem:n,outputCalendar:r}}
/**
   * "Set" the DateTime's zone to UTC. Returns a newly-constructed DateTime.
   *
   * Equivalent to {@link DateTime#setZone}('utc')
   * @param {number} [offset=0] - optionally, an offset from UTC in minutes
   * @param {Object} [opts={}] - options to pass to `setZone()`
   * @return {DateTime}
   */
toUTC(e=0,t={}){return this.setZone(FixedOffsetZone.instance(e),t)}toLocal(){return this.setZone(Settings.defaultZone)}
/**
   * "Set" the DateTime's zone to specified zone. Returns a newly-constructed DateTime.
   *
   * By default, the setter keeps the underlying time the same (as in, the same timestamp), but the new instance will report different local times and consider DSTs when making computations, as with {@link DateTime#plus}. You may wish to use {@link DateTime#toLocal} and {@link DateTime#toUTC} which provide simple convenience wrappers for commonly used zones.
   * @param {string|Zone} [zone='local'] - a zone identifier. As a string, that can be any IANA zone supported by the host environment, or a fixed-offset name of the form 'UTC+3', or the strings 'local' or 'utc'. You may also supply an instance of a {@link DateTime#Zone} class.
   * @param {Object} opts - options
   * @param {boolean} [opts.keepLocalTime=false] - If true, adjust the underlying time so that the local time stays the same, but in the target zone. You should rarely need this.
   * @return {DateTime}
   */setZone(e,{keepLocalTime:t=false,keepCalendarTime:n=false}={}){e=ee(e,Settings.defaultZone);if(e.equals(this.zone))return this;if(e.isValid){let r=this.ts;if(t||n){const t=e.offset(this.ts);const n=this.toObject();[r]=Ir(n,t,e)}return Dr(this,{ts:r,zone:e})}return DateTime.invalid(kr(e))}
/**
   * "Set" the locale, numberingSystem, or outputCalendar. Returns a newly-constructed DateTime.
   * @param {Object} properties - the properties to set
   * @example DateTime.local(2017, 5, 25).reconfigure({ locale: 'en-GB' })
   * @return {DateTime}
   */reconfigure({locale:e,numberingSystem:t,outputCalendar:n}={}){const r=this.loc.clone({locale:e,numberingSystem:t,outputCalendar:n});return Dr(this,{loc:r})}setLocale(e){return this.reconfigure({locale:e})}
/**
   * "Set" the values of specified units. Returns a newly-constructed DateTime.
   * You can only set units with this method; for "setting" metadata, see {@link DateTime#reconfigure} and {@link DateTime#setZone}.
   *
   * This method also supports setting locale-based week units, i.e. `localWeekday`, `localWeekNumber` and `localWeekYear`.
   * They cannot be mixed with ISO-week units like `weekday`.
   * @param {Object} values - a mapping of units to numbers
   * @example dt.set({ year: 2017 })
   * @example dt.set({ hour: 8, minute: 30 })
   * @example dt.set({ weekday: 5 })
   * @example dt.set({ year: 2005, ordinal: 234 })
   * @return {DateTime}
   */set(e){if(!this.isValid)return this;const t=ot(e,zr);const{minDaysInFirstWeek:n,startOfWeek:r}=Ne(t,this.loc);const s=!Ze(t.weekYear)||!Ze(t.weekNumber)||!Ze(t.weekday),i=!Ze(t.ordinal),a=!Ze(t.year),o=!Ze(t.month)||!Ze(t.day),u=a||o,l=t.weekYear||t.weekNumber;if((u||i)&&l)throw new ConflictingSpecificationError("Can't mix weekYear/weekNumber units with year/month/day or ordinals");if(o&&i)throw new ConflictingSpecificationError("Can't mix ordinal dates with month/day");let c;if(s)c=Oe({...De(this.c,n,r),...t},n,r);else if(Ze(t.ordinal)){c={...this.toObject(),...t};Ze(t.day)&&(c.day=Math.min(Xe(c.year,c.month),c.day))}else c=Ie({...be(this.c),...t});const[h,d]=Ir(c,this.o,this.zone);return Dr(this,{ts:h,o:d})}
/**
   * Add a period of time to this DateTime and return the resulting DateTime
   *
   * Adding hours, minutes, seconds, or milliseconds increases the timestamp by the right number of milliseconds. Adding days, months, or years shifts the calendar, accounting for DSTs and leap years along the way. Thus, `dt.plus({ hours: 24 })` may result in a different time than `dt.plus({ days: 1 })` if there's a DST shift in between.
   * @param {Duration|Object|number} duration - The amount to add. Either a Luxon Duration, a number of milliseconds, the object argument to Duration.fromObject()
   * @example DateTime.now().plus(123) //~> in 123 milliseconds
   * @example DateTime.now().plus({ minutes: 15 }) //~> in 15 minutes
   * @example DateTime.now().plus({ days: 1 }) //~> this time tomorrow
   * @example DateTime.now().plus({ days: -1 }) //~> this time yesterday
   * @example DateTime.now().plus({ hours: 3, minutes: 13 }) //~> in 3 hr, 13 min
   * @example DateTime.now().plus(Duration.fromObject({ hours: 3, minutes: 13 })) //~> in 3 hr, 13 min
   * @return {DateTime}
   */plus(e){if(!this.isValid)return this;const t=Duration.fromDurationLike(e);return Dr(this,Nr(this,t))}
/**
   * Subtract a period of time to this DateTime and return the resulting DateTime
   * See {@link DateTime#plus}
   * @param {Duration|Object|number} duration - The amount to subtract. Either a Luxon Duration, a number of milliseconds, the object argument to Duration.fromObject()
   @return {DateTime}
   */minus(e){if(!this.isValid)return this;const t=Duration.fromDurationLike(e).negate();return Dr(this,Nr(this,t))}
/**
   * "Set" this DateTime to the beginning of a unit of time.
   * @param {string} unit - The unit to go to the beginning of. Can be 'year', 'quarter', 'month', 'week', 'day', 'hour', 'minute', 'second', or 'millisecond'.
   * @param {Object} opts - options
   * @param {boolean} [opts.useLocaleWeeks=false] - If true, use weeks based on the locale, i.e. use the locale-dependent start of the week
   * @example DateTime.local(2014, 3, 3).startOf('month').toISODate(); //=> '2014-03-01'
   * @example DateTime.local(2014, 3, 3).startOf('year').toISODate(); //=> '2014-01-01'
   * @example DateTime.local(2014, 3, 3).startOf('week').toISODate(); //=> '2014-03-03', weeks always start on Mondays
   * @example DateTime.local(2014, 3, 3, 5, 30).startOf('day').toISOTime(); //=> '00:00.000-05:00'
   * @example DateTime.local(2014, 3, 3, 5, 30).startOf('hour').toISOTime(); //=> '05:00:00.000-05:00'
   * @return {DateTime}
   */startOf(e,{useLocaleWeeks:t=false}={}){if(!this.isValid)return this;const n={},r=Duration.normalizeUnit(e);switch(r){case"years":n.month=1;case"quarters":case"months":n.day=1;case"weeks":case"days":n.hour=0;case"hours":n.minute=0;case"minutes":n.second=0;case"seconds":n.millisecond=0;break;case"milliseconds":break}if(r==="weeks")if(t){const e=this.loc.getStartOfWeek();const{weekday:t}=this;t<e&&(n.weekNumber=this.weekNumber-1);n.weekday=e}else n.weekday=1;if(r==="quarters"){const e=Math.ceil(this.month/3);n.month=3*(e-1)+1}return this.set(n)}
/**
   * "Set" this DateTime to the end (meaning the last millisecond) of a unit of time
   * @param {string} unit - The unit to go to the end of. Can be 'year', 'quarter', 'month', 'week', 'day', 'hour', 'minute', 'second', or 'millisecond'.
   * @param {Object} opts - options
   * @param {boolean} [opts.useLocaleWeeks=false] - If true, use weeks based on the locale, i.e. use the locale-dependent start of the week
   * @example DateTime.local(2014, 3, 3).endOf('month').toISO(); //=> '2014-03-31T23:59:59.999-05:00'
   * @example DateTime.local(2014, 3, 3).endOf('year').toISO(); //=> '2014-12-31T23:59:59.999-05:00'
   * @example DateTime.local(2014, 3, 3).endOf('week').toISO(); // => '2014-03-09T23:59:59.999-05:00', weeks start on Mondays
   * @example DateTime.local(2014, 3, 3, 5, 30).endOf('day').toISO(); //=> '2014-03-03T23:59:59.999-05:00'
   * @example DateTime.local(2014, 3, 3, 5, 30).endOf('hour').toISO(); //=> '2014-03-03T05:59:59.999-05:00'
   * @return {DateTime}
   */endOf(e,t){return this.isValid?this.plus({[e]:1}).startOf(e,t).minus(1):this}
/**
   * Returns a string representation of this DateTime formatted according to the specified format string.
   * **You may not want this.** See {@link DateTime#toLocaleString} for a more flexible formatting tool. For a table of tokens and their interpretations, see [here](https://moment.github.io/luxon/#/formatting?id=table-of-tokens).
   * Defaults to en-US if no locale has been specified, regardless of the system's locale.
   * @param {string} fmt - the format string
   * @param {Object} opts - opts to override the configuration options on this DateTime
   * @example DateTime.now().toFormat('yyyy LLL dd') //=> '2017 Apr 22'
   * @example DateTime.now().setLocale('fr').toFormat('yyyy LLL dd') //=> '2017 avr. 22'
   * @example DateTime.now().toFormat('yyyy LLL dd', { locale: "fr" }) //=> '2017 avr. 22'
   * @example DateTime.now().toFormat("HH 'hours and' mm 'minutes'") //=> '20 hours and 55 minutes'
   * @return {string}
   */
toFormat(e,t={}){return this.isValid?Formatter.create(this.loc.redefaultToEN(t)).formatDateTimeFromString(this,e):pr}
/**
   * Returns a localized string representing this date. Accepts the same options as the Intl.DateTimeFormat constructor and any presets defined by Luxon, such as `DateTime.DATE_FULL` or `DateTime.TIME_SIMPLE`.
   * The exact behavior of this method is browser-specific, but in general it will return an appropriate representation
   * of the DateTime in the assigned locale.
   * Defaults to the system's locale if no locale has been specified
   * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
   * @param formatOpts {Object} - Intl.DateTimeFormat constructor options and configuration options
   * @param {Object} opts - opts to override the configuration options on this DateTime
   * @example DateTime.now().toLocaleString(); //=> 4/20/2017
   * @example DateTime.now().setLocale('en-gb').toLocaleString(); //=> '20/04/2017'
   * @example DateTime.now().toLocaleString(DateTime.DATE_FULL); //=> 'April 20, 2017'
   * @example DateTime.now().toLocaleString(DateTime.DATE_FULL, { locale: 'fr' }); //=> '28 août 2022'
   * @example DateTime.now().toLocaleString(DateTime.TIME_SIMPLE); //=> '11:32 AM'
   * @example DateTime.now().toLocaleString(DateTime.DATETIME_SHORT); //=> '4/20/2017, 11:32 AM'
   * @example DateTime.now().toLocaleString({ weekday: 'long', month: 'long', day: '2-digit' }); //=> 'Thursday, April 20'
   * @example DateTime.now().toLocaleString({ weekday: 'short', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }); //=> 'Thu, Apr 20, 11:27 AM'
   * @example DateTime.now().toLocaleString({ hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }); //=> '11:32'
   * @return {string}
   */toLocaleString(e=r,t={}){return this.isValid?Formatter.create(this.loc.clone(t),e).formatDateTime(this):pr}
/**
   * Returns an array of format "parts", meaning individual tokens along with metadata. This is allows callers to post-process individual sections of the formatted output.
   * Defaults to the system's locale if no locale has been specified
   * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat/formatToParts
   * @param opts {Object} - Intl.DateTimeFormat constructor options, same as `toLocaleString`.
   * @example DateTime.now().toLocaleParts(); //=> [
   *                                   //=>   { type: 'day', value: '25' },
   *                                   //=>   { type: 'literal', value: '/' },
   *                                   //=>   { type: 'month', value: '05' },
   *                                   //=>   { type: 'literal', value: '/' },
   *                                   //=>   { type: 'year', value: '1982' }
   *                                   //=> ]
   */toLocaleParts(e={}){return this.isValid?Formatter.create(this.loc.clone(e),e).formatDateTimeParts(this):[]}
/**
   * Returns an ISO 8601-compliant string representation of this DateTime
   * @param {Object} opts - options
   * @param {boolean} [opts.suppressMilliseconds=false] - exclude milliseconds from the format if they're 0
   * @param {boolean} [opts.suppressSeconds=false] - exclude seconds from the format if they're 0
   * @param {boolean} [opts.includeOffset=true] - include the offset, such as 'Z' or '-04:00'
   * @param {boolean} [opts.extendedZone=false] - add the time zone format extension
   * @param {string} [opts.format='extended'] - choose between the basic and extended format
   * @param {string} [opts.precision='milliseconds'] - truncate output to desired presicion: 'years', 'months', 'days', 'hours', 'minutes', 'seconds' or 'milliseconds'. When precision and suppressSeconds or suppressMilliseconds are used together, precision sets the maximum unit shown in the output, however seconds or milliseconds will still be suppressed if they are 0.
   * @example DateTime.utc(1983, 5, 25).toISO() //=> '1982-05-25T00:00:00.000Z'
   * @example DateTime.now().toISO() //=> '2017-04-22T20:47:05.335-04:00'
   * @example DateTime.now().toISO({ includeOffset: false }) //=> '2017-04-22T20:47:05.335'
   * @example DateTime.now().toISO({ format: 'basic' }) //=> '20170422T204705.335-0400'
   * @example DateTime.now().toISO({ precision: 'day' }) //=> '2017-04-22Z'
   * @example DateTime.now().toISO({ precision: 'minute' }) //=> '2017-04-22T20:47Z'
   * @return {string|null}
   */toISO({format:e="extended",suppressSeconds:t=false,suppressMilliseconds:n=false,includeOffset:r=true,extendedZone:s=false,precision:i="milliseconds"}={}){if(!this.isValid)return null;i=Wr(i);const a=e==="extended";let o=xr(this,a,i);Cr.indexOf(i)>=3&&(o+="T");o+=Fr(this,a,t,n,r,s,i);return o}
/**
   * Returns an ISO 8601-compliant string representation of this DateTime's date component
   * @param {Object} opts - options
   * @param {string} [opts.format='extended'] - choose between the basic and extended format
   * @param {string} [opts.precision='day'] - truncate output to desired precision: 'years', 'months', or 'days'.
   * @example DateTime.utc(1982, 5, 25).toISODate() //=> '1982-05-25'
   * @example DateTime.utc(1982, 5, 25).toISODate({ format: 'basic' }) //=> '19820525'
   * @example DateTime.utc(1982, 5, 25).toISODate({ precision: 'month' }) //=> '1982-05'
   * @return {string|null}
   */toISODate({format:e="extended",precision:t="day"}={}){return this.isValid?xr(this,e==="extended",Wr(t)):null}toISOWeekDate(){return Er(this,"kkkk-'W'WW-c")}
/**
   * Returns an ISO 8601-compliant string representation of this DateTime's time component
   * @param {Object} opts - options
   * @param {boolean} [opts.suppressMilliseconds=false] - exclude milliseconds from the format if they're 0
   * @param {boolean} [opts.suppressSeconds=false] - exclude seconds from the format if they're 0
   * @param {boolean} [opts.includeOffset=true] - include the offset, such as 'Z' or '-04:00'
   * @param {boolean} [opts.extendedZone=true] - add the time zone format extension
   * @param {boolean} [opts.includePrefix=false] - include the `T` prefix
   * @param {string} [opts.format='extended'] - choose between the basic and extended format
   * @param {string} [opts.precision='milliseconds'] - truncate output to desired presicion: 'hours', 'minutes', 'seconds' or 'milliseconds'. When precision and suppressSeconds or suppressMilliseconds are used together, precision sets the maximum unit shown in the output, however seconds or milliseconds will still be suppressed if they are 0.
   * @example DateTime.utc().set({ hour: 7, minute: 34 }).toISOTime() //=> '07:34:19.361Z'
   * @example DateTime.utc().set({ hour: 7, minute: 34, seconds: 0, milliseconds: 0 }).toISOTime({ suppressSeconds: true }) //=> '07:34Z'
   * @example DateTime.utc().set({ hour: 7, minute: 34 }).toISOTime({ format: 'basic' }) //=> '073419.361Z'
   * @example DateTime.utc().set({ hour: 7, minute: 34 }).toISOTime({ includePrefix: true }) //=> 'T07:34:19.361Z'
   * @example DateTime.utc().set({ hour: 7, minute: 34, second: 56 }).toISOTime({ precision: 'minute' }) //=> '07:34Z'
   * @return {string}
   */toISOTime({suppressMilliseconds:e=false,suppressSeconds:t=false,includeOffset:n=true,includePrefix:r=false,extendedZone:s=false,format:i="extended",precision:a="milliseconds"}={}){if(!this.isValid)return null;a=Wr(a);let o=r&&Cr.indexOf(a)>=3?"T":"";return o+Fr(this,i==="extended",t,e,n,s,a)}toRFC2822(){return Er(this,"EEE, dd LLL yyyy HH:mm:ss ZZZ",false)}toHTTP(){return Er(this.toUTC(),"EEE, dd LLL yyyy HH:mm:ss 'GMT'")}toSQLDate(){return this.isValid?xr(this,true):null}
/**
   * Returns a string representation of this DateTime appropriate for use in SQL Time
   * @param {Object} opts - options
   * @param {boolean} [opts.includeZone=false] - include the zone, such as 'America/New_York'. Overrides includeOffset.
   * @param {boolean} [opts.includeOffset=true] - include the offset, such as 'Z' or '-04:00'
   * @param {boolean} [opts.includeOffsetSpace=true] - include the space between the time and the offset, such as '05:15:16.345 -04:00'
   * @example DateTime.utc().toSQL() //=> '05:15:16.345'
   * @example DateTime.now().toSQL() //=> '05:15:16.345 -04:00'
   * @example DateTime.now().toSQL({ includeOffset: false }) //=> '05:15:16.345'
   * @example DateTime.now().toSQL({ includeZone: false }) //=> '05:15:16.345 America/New_York'
   * @return {string}
   */toSQLTime({includeOffset:e=true,includeZone:t=false,includeOffsetSpace:n=true}={}){let r="HH:mm:ss.SSS";if(t||e){n&&(r+=" ");t?r+="z":e&&(r+="ZZ")}return Er(this,r,true)}
/**
   * Returns a string representation of this DateTime appropriate for use in SQL DateTime
   * @param {Object} opts - options
   * @param {boolean} [opts.includeZone=false] - include the zone, such as 'America/New_York'. Overrides includeOffset.
   * @param {boolean} [opts.includeOffset=true] - include the offset, such as 'Z' or '-04:00'
   * @param {boolean} [opts.includeOffsetSpace=true] - include the space between the time and the offset, such as '05:15:16.345 -04:00'
   * @example DateTime.utc(2014, 7, 13).toSQL() //=> '2014-07-13 00:00:00.000 Z'
   * @example DateTime.local(2014, 7, 13).toSQL() //=> '2014-07-13 00:00:00.000 -04:00'
   * @example DateTime.local(2014, 7, 13).toSQL({ includeOffset: false }) //=> '2014-07-13 00:00:00.000'
   * @example DateTime.local(2014, 7, 13).toSQL({ includeZone: true }) //=> '2014-07-13 00:00:00.000 America/New_York'
   * @return {string}
   */toSQL(e={}){return this.isValid?`${this.toSQLDate()} ${this.toSQLTime(e)}`:null}toString(){return this.isValid?this.toISO():pr}[Symbol.for("nodejs.util.inspect.custom")](){return this.isValid?`DateTime { ts: ${this.toISO()}, zone: ${this.zone.name}, locale: ${this.locale} }`:`DateTime { Invalid, reason: ${this.invalidReason} }`}valueOf(){return this.toMillis()}toMillis(){return this.isValid?this.ts:NaN}toSeconds(){return this.isValid?this.ts/1e3:NaN}toUnixInteger(){return this.isValid?Math.floor(this.ts/1e3):NaN}toJSON(){return this.toISO()}toBSON(){return this.toJSDate()}
/**
   * Returns a JavaScript object with this DateTime's year, month, day, and so on.
   * @param opts - options for generating the object
   * @param {boolean} [opts.includeConfig=false] - include configuration attributes in the output
   * @example DateTime.now().toObject() //=> { year: 2017, month: 4, day: 22, hour: 20, minute: 49, second: 42, millisecond: 268 }
   * @return {Object}
   */toObject(e={}){if(!this.isValid)return{};const t={...this.c};if(e.includeConfig){t.outputCalendar=this.outputCalendar;t.numberingSystem=this.loc.numberingSystem;t.locale=this.loc.locale}return t}toJSDate(){return new Date(this.isValid?this.ts:NaN)}
/**
   * Return the difference between two DateTimes as a Duration.
   * @param {DateTime} otherDateTime - the DateTime to compare this one to
   * @param {string|string[]} [unit=['milliseconds']] - the unit or array of units (such as 'hours' or 'days') to include in the duration.
   * @param {Object} opts - options that affect the creation of the Duration
   * @param {string} [opts.conversionAccuracy='casual'] - the conversion system to use
   * @example
   * var i1 = DateTime.fromISO('1982-05-25T09:45'),
   *     i2 = DateTime.fromISO('1983-10-14T10:30');
   * i2.diff(i1).toObject() //=> { milliseconds: 43807500000 }
   * i2.diff(i1, 'hours').toObject() //=> { hours: 12168.75 }
   * i2.diff(i1, ['months', 'days']).toObject() //=> { months: 16, days: 19.03125 }
   * i2.diff(i1, ['months', 'days', 'hours']).toObject() //=> { months: 16, days: 19, hours: 0.75 }
   * @return {Duration}
   */
diff(e,t="milliseconds",n={}){if(!this.isValid||!e.isValid)return Duration.invalid("created by diffing an invalid DateTime");const r={locale:this.locale,numberingSystem:this.numberingSystem,...n};const s=ze(t).map(Duration.normalizeUnit),i=e.valueOf()>this.valueOf(),a=i?this:e,o=i?e:this,u=Hn(a,o,s,r);return i?u.negate():u}
/**
   * Return the difference between this DateTime and right now.
   * See {@link DateTime#diff}
   * @param {string|string[]} [unit=['milliseconds']] - the unit or units units (such as 'hours' or 'days') to include in the duration
   * @param {Object} opts - options that affect the creation of the Duration
   * @param {string} [opts.conversionAccuracy='casual'] - the conversion system to use
   * @return {Duration}
   */diffNow(e="milliseconds",t={}){return this.diff(DateTime.now(),e,t)}
/**
   * Return an Interval spanning between this DateTime and another DateTime
   * @param {DateTime} otherDateTime - the other end point of the Interval
   * @return {Interval|DateTime}
   */until(e){return this.isValid?Interval.fromDateTimes(this,e):this}
/**
   * Return whether this DateTime is in the same unit of time as another DateTime.
   * Higher-order units must also be identical for this function to return `true`.
   * Note that time zones are **ignored** in this comparison, which compares the **local** calendar time. Use {@link DateTime#setZone} to convert one of the dates if needed.
   * @param {DateTime} otherDateTime - the other DateTime
   * @param {string} unit - the unit of time to check sameness on
   * @param {Object} opts - options
   * @param {boolean} [opts.useLocaleWeeks=false] - If true, use weeks based on the locale, i.e. use the locale-dependent start of the week; only the locale of this DateTime is used
   * @example DateTime.now().hasSame(otherDT, 'day'); //~> true if otherDT is in the same current calendar day
   * @return {boolean}
   */hasSame(e,t,n){if(!this.isValid)return false;const r=e.valueOf();const s=this.setZone(e.zone,{keepLocalTime:true});return s.startOf(t,n)<=r&&r<=s.endOf(t,n)}
/**
   * Equality check
   * Two DateTimes are equal if and only if they represent the same millisecond, have the same zone and location, and are both valid.
   * To compare just the millisecond values, use `+dt1 === +dt2`.
   * @param {DateTime} other - the other DateTime
   * @return {boolean}
   */equals(e){return this.isValid&&e.isValid&&this.valueOf()===e.valueOf()&&this.zone.equals(e.zone)&&this.loc.equals(e.loc)}
/**
   * Returns a string representation of a this time relative to now, such as "in two days". Can only internationalize if your
   * platform supports Intl.RelativeTimeFormat. Rounds towards zero by default.
   * @param {Object} options - options that affect the output
   * @param {DateTime} [options.base=DateTime.now()] - the DateTime to use as the basis to which this time is compared. Defaults to now.
   * @param {string} [options.style="long"] - the style of units, must be "long", "short", or "narrow"
   * @param {string|string[]} options.unit - use a specific unit or array of units; if omitted, or an array, the method will pick the best unit. Use an array or one of "years", "quarters", "months", "weeks", "days", "hours", "minutes", or "seconds"
   * @param {boolean} [options.round=true] - whether to round the numbers in the output.
   * @param {string} [options.rounding="trunc"] - rounding method to use when rounding the numbers in the output. Can be "trunc" (toward zero), "expand" (away from zero), "round", "floor", or "ceil".
   * @param {number} [options.padding=0] - padding in milliseconds. This allows you to round up the result if it fits inside the threshold. Don't use in combination with {round: false} because the decimal output will include the padding.
   * @param {string} options.locale - override the locale of this DateTime
   * @param {string} options.numberingSystem - override the numberingSystem of this DateTime. The Intl system may choose not to honor this
   * @example DateTime.now().plus({ days: 1 }).toRelative() //=> "in 1 day"
   * @example DateTime.now().setLocale("es").toRelative({ days: 1 }) //=> "dentro de 1 día"
   * @example DateTime.now().plus({ days: 1 }).toRelative({ locale: "fr" }) //=> "dans 23 heures"
   * @example DateTime.now().minus({ days: 2 }).toRelative() //=> "2 days ago"
   * @example DateTime.now().minus({ days: 2 }).toRelative({ unit: "hours" }) //=> "48 hours ago"
   * @example DateTime.now().minus({ hours: 36 }).toRelative({ round: false }) //=> "1.5 days ago"
   */toRelative(e={}){if(!this.isValid)return null;const t=e.base||DateTime.fromObject({},{zone:this.zone}),n=e.padding?this<t?-e.padding:e.padding:0;let r=["years","months","days","hours","minutes","seconds"];let s=e.unit;if(Array.isArray(e.unit)){r=e.unit;s=void 0}return Ur(t,this.plus(n),{...e,numeric:"always",units:r,unit:s})}
/**
   * Returns a string representation of this date relative to today, such as "yesterday" or "next month".
   * Only internationalizes on platforms that supports Intl.RelativeTimeFormat.
   * @param {Object} options - options that affect the output
   * @param {DateTime} [options.base=DateTime.now()] - the DateTime to use as the basis to which this time is compared. Defaults to now.
   * @param {string} options.locale - override the locale of this DateTime
   * @param {string} options.unit - use a specific unit; if omitted, the method will pick the unit. Use one of "years", "quarters", "months", "weeks", or "days"
   * @param {string} options.numberingSystem - override the numberingSystem of this DateTime. The Intl system may choose not to honor this
   * @example DateTime.now().plus({ days: 1 }).toRelativeCalendar() //=> "tomorrow"
   * @example DateTime.now().setLocale("es").plus({ days: 1 }).toRelative() //=> ""mañana"
   * @example DateTime.now().plus({ days: 1 }).toRelativeCalendar({ locale: "fr" }) //=> "demain"
   * @example DateTime.now().minus({ days: 2 }).toRelativeCalendar() //=> "2 days ago"
   */toRelativeCalendar(e={}){return this.isValid?Ur(e.base||DateTime.fromObject({},{zone:this.zone}),this,{...e,numeric:"auto",units:["years","months","days"],calendary:true}):null}
/**
   * Return the min of several date times
   * @param {...DateTime} dateTimes - the DateTimes from which to choose the minimum
   * @return {DateTime} the min DateTime, or undefined if called with no argument
   */static min(...e){if(!e.every(DateTime.isDateTime))throw new InvalidArgumentError("min requires all arguments be DateTimes");return je(e,(e=>e.valueOf()),Math.min)}
/**
   * Return the max of several date times
   * @param {...DateTime} dateTimes - the DateTimes from which to choose the maximum
   * @return {DateTime} the max DateTime, or undefined if called with no argument
   */static max(...e){if(!e.every(DateTime.isDateTime))throw new InvalidArgumentError("max requires all arguments be DateTimes");return je(e,(e=>e.valueOf()),Math.max)}
/**
   * Explain how a string would be parsed by fromFormat()
   * @param {string} text - the string to parse
   * @param {string} fmt - the format the string is expected to be in (see description)
   * @param {Object} options - options taken by fromFormat()
   * @return {Object}
   */
static fromFormatExplain(e,t,n={}){const{locale:r=null,numberingSystem:s=null}=n,i=Locale.fromOpts({locale:r,numberingSystem:s,defaultToEN:true});return yr(i,e,t)}
/**
   * @deprecated use fromFormatExplain instead
   */static fromStringExplain(e,t,n={}){return DateTime.fromFormatExplain(e,t,n)}
/**
   * Build a parser for `fmt` using the given locale. This parser can be passed
   * to {@link DateTime.fromFormatParser} to a parse a date in this format. This
   * can be used to optimize cases where many dates need to be parsed in a
   * specific format.
   *
   * @param {String} fmt - the format the string is expected to be in (see
   * description)
   * @param {Object} options - options used to set locale and numberingSystem
   * for parser
   * @returns {TokenParser} - opaque object to be used
   */static buildFormatParser(e,t={}){const{locale:n=null,numberingSystem:r=null}=t,s=Locale.fromOpts({locale:n,numberingSystem:r,defaultToEN:true});return new TokenParser(s,e)}
/**
   * Create a DateTime from an input string and format parser.
   *
   * The format parser must have been created with the same locale as this call.
   *
   * @param {String} text - the string to parse
   * @param {TokenParser} formatParser - parser from {@link DateTime.buildFormatParser}
   * @param {Object} opts - options taken by fromFormat()
   * @returns {DateTime}
   */static fromFormatParser(e,t,n={}){if(Ze(e)||Ze(t))throw new InvalidArgumentError("fromFormatParser requires an input string and a format parser");const{locale:r=null,numberingSystem:s=null}=n,i=Locale.fromOpts({locale:r,numberingSystem:s,defaultToEN:true});if(!i.equals(t.locale))throw new InvalidArgumentError(`fromFormatParser called with a locale of ${i}, but the format parser was created for ${t.locale}`);const{result:a,zone:o,specificOffset:u,invalidReason:l}=t.explainFromTokens(e);return l?DateTime.invalid(l):Mr(a,o,n,`format ${t.format}`,e,u)}
/**
   * {@link DateTime#toLocaleString} format like 10/14/1983
   * @type {Object}
   */
static get DATE_SHORT(){return r}
/**
   * {@link DateTime#toLocaleString} format like 'Oct 14, 1983'
   * @type {Object}
   */static get DATE_MED(){return s}
/**
   * {@link DateTime#toLocaleString} format like 'Fri, Oct 14, 1983'
   * @type {Object}
   */static get DATE_MED_WITH_WEEKDAY(){return i}
/**
   * {@link DateTime#toLocaleString} format like 'October 14, 1983'
   * @type {Object}
   */static get DATE_FULL(){return a}
/**
   * {@link DateTime#toLocaleString} format like 'Tuesday, October 14, 1983'
   * @type {Object}
   */static get DATE_HUGE(){return o}
/**
   * {@link DateTime#toLocaleString} format like '09:30 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get TIME_SIMPLE(){return u}
/**
   * {@link DateTime#toLocaleString} format like '09:30:23 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get TIME_WITH_SECONDS(){return l}
/**
   * {@link DateTime#toLocaleString} format like '09:30:23 AM EDT'. Only 12-hour if the locale is.
   * @type {Object}
   */static get TIME_WITH_SHORT_OFFSET(){return c}
/**
   * {@link DateTime#toLocaleString} format like '09:30:23 AM Eastern Daylight Time'. Only 12-hour if the locale is.
   * @type {Object}
   */static get TIME_WITH_LONG_OFFSET(){return h}
/**
   * {@link DateTime#toLocaleString} format like '09:30', always 24-hour.
   * @type {Object}
   */static get TIME_24_SIMPLE(){return d}
/**
   * {@link DateTime#toLocaleString} format like '09:30:23', always 24-hour.
   * @type {Object}
   */static get TIME_24_WITH_SECONDS(){return m}
/**
   * {@link DateTime#toLocaleString} format like '09:30:23 EDT', always 24-hour.
   * @type {Object}
   */static get TIME_24_WITH_SHORT_OFFSET(){return f}
/**
   * {@link DateTime#toLocaleString} format like '09:30:23 Eastern Daylight Time', always 24-hour.
   * @type {Object}
   */static get TIME_24_WITH_LONG_OFFSET(){return y}
/**
   * {@link DateTime#toLocaleString} format like '10/14/1983, 9:30 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_SHORT(){return g}
/**
   * {@link DateTime#toLocaleString} format like '10/14/1983, 9:30:33 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_SHORT_WITH_SECONDS(){return w}
/**
   * {@link DateTime#toLocaleString} format like 'Oct 14, 1983, 9:30 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_MED(){return p}
/**
   * {@link DateTime#toLocaleString} format like 'Oct 14, 1983, 9:30:33 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_MED_WITH_SECONDS(){return v}
/**
   * {@link DateTime#toLocaleString} format like 'Fri, 14 Oct 1983, 9:30 AM'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_MED_WITH_WEEKDAY(){return k}
/**
   * {@link DateTime#toLocaleString} format like 'October 14, 1983, 9:30 AM EDT'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_FULL(){return S}
/**
   * {@link DateTime#toLocaleString} format like 'October 14, 1983, 9:30:33 AM EDT'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_FULL_WITH_SECONDS(){return T}
/**
   * {@link DateTime#toLocaleString} format like 'Friday, October 14, 1983, 9:30 AM Eastern Daylight Time'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_HUGE(){return D}
/**
   * {@link DateTime#toLocaleString} format like 'Friday, October 14, 1983, 9:30:33 AM Eastern Daylight Time'. Only 12-hour if the locale is.
   * @type {Object}
   */static get DATETIME_HUGE_WITH_SECONDS(){return O}}function Pr(e){if(DateTime.isDateTime(e))return e;if(e&&e.valueOf&&Ve(e.valueOf()))return DateTime.fromJSDate(e);if(e&&typeof e==="object")return DateTime.fromObject(e);throw new InvalidArgumentError(`Unknown datetime argument: ${e}, of type ${typeof e}`)}const Hr="3.7.1";export{DateTime,Duration,FixedOffsetZone,IANAZone,Info,Interval,InvalidZone,Settings,SystemZone,Hr as VERSION,Zone};

