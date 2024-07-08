//#region CONFIG
let QUALITY = {
  VERY_LOW: "Very Low",
  LOW: "Low",
  MEDIUM: "Medium",
  HIGH: "High",
  VERY_HIGH: "Very High",
  CUSTOM: "Custom",
};
let QUALITY_INT = {
  VERY_LOW: 0.2,
  LOW: 0.4,
  MEDIUM: 0.6,
  HIGH: 0.8,
  VERY_HIGH: 1,
  CUSTOM: "",
};
let FILETYPE = {
  JPEG: "JPEG",
  PNG: "PNG",
};

let VideoDeviceIdCookieRef = "videoDeviceId";
let config = {
  videoDeviceId: GetCookie(VideoDeviceIdCookieRef),
  qualityOption: QUALITY.MEDIUM,
  qualityValue: QUALITY_INT.MEDIUM,
  imageType: FILETYPE.JPEG,
  resX: 30000,
  resY: 30000,
};
function InitDatabindings() {
  console.log("Control Addin - NPCamera: Initialize Databindings");
  ui.cams.addEventListener(
    "change",
    async (event) => await OnChangeCamera(event)
  );
  ui.qualityOpt.addEventListener(
    "change",
    async (event) => await OnChangeQualityEnum(event)
  );
  ui.qualityVal.addEventListener(
    "change",
    async (event) => await OnChangeQualityVal(event)
  );
  ui.imageTypeOpt.addEventListener(
    "change",
    async (event) => await OnChangeFileType(event)
  );
  ui.resX.addEventListener(
    "change",
    async (event) => await OnChangeResX(event)
  );
  ui.resY.addEventListener(
    "change",
    async (event) => await OnChangeResY(event)
  );
}

function OnChangeCamera(ev) {
  console.log(
    `Control Addin - NPCamera: (Device Changed) '${config.videoDeviceId}' --> '${ev.target.value}'`
  );
  config.videoDeviceId = ev.target.value;
  SetCookie(VideoDeviceIdCookieRef, config.videoDeviceId);
}

function OnChangeQualityEnum(ev) {
  console.log(
    `Control Addin - NPCamera: (QualityOption Changed) '${config.qualityOption}' --> '${ev.target.value}'`
  );
  debugger;
  config.qualityOption = ev.target.value;
  switch (ev.target.value) {
    case "Very Low":
      config.qualityValue = QUALITY_INT.VERY_LOW;
      ui.qualityVal.value = QUALITY_INT.VERY_LOW;
      break;
    case "Low":
      config.qualityValue = QUALITY_INT.LOW;
      ui.qualityVal.value = QUALITY_INT.LOW;
      break;
    case "Medium":
      config.qualityValue = QUALITY_INT.MEDIUM;
      ui.qualityVal.value = QUALITY_INT.MEDIUM;
      break;
    case "High":
      config.qualityValue = QUALITY_INT.HIGH;
      ui.qualityVal.value = QUALITY_INT.HIGH;
      break;
    case "Very High":
      config.qualityValue = QUALITY_INT.VERY_HIGH;
      ui.qualityVal.value = QUALITY_INT.VERY_HIGH;
      break;
    case "Custom":
      break;
  }
}
function OnChangeQualityVal(ev) {
  let val = Number.parseFloat(ev.target.value);
  if (val < 0) {
    val = 0;
  } else if (val > 1) {
    val = 1;
  }
  console.log(
    `Control Addin - NPCamera: (QualityValue Changed) '${config.qualityValue}' --> '${val}'`
  );
  config.qualityValue = val;
  ui.qualityVal.value = val;
  ui.qualityOpt.selectedIndex = 5;
}
function OnChangeFileType(ev) {
  console.log(
    `Control Addin - NPCamera: (QualityValue Changed) '${config.imageType}' --> '${ev.target.value}'`
  );
  config.imageType = ev.target.value;
  ui.qualityOpt.disabled = ev.target.value === FILETYPE.PNG;
  ui.qualityVal.disabled = ev.target.value === FILETYPE.PNG;
}
function OnChangeResX(ev) {
  console.log(
    `Control Addin - NPCamera: (QualityValue Changed) '${config.resX}' --> '${ev.target.value}'`
  );
  config.resX = Number(ev.target.value);
}
function OnChangeResY(ev) {
  console.log(
    `Control Addin - NPCamera: (QualityValue Changed) '${config.resY}' --> '${ev.target.value}'`
  );
  config.resY = Number(ev.target.value);
}
function SetConfig(InitJson) {
  if (InitJson.config) config = InitJson.config;
  if (!config.videoDeviceId) config.videoDeviceId = GetCookie(VideoDeviceIdCookieRef); 
  UpdateConfigUi();
}
function UpdateConfigUi() {
  let videoSrc = ui.cams.options.namedItem(config.videoDeviceId);
  if (videoSrc !== null) ui.cams.selectedIndex = videoSrc.index;
  let qualityOpt = ui.qualityOpt.options.namedItem(config.qualityOption);
  if (qualityOpt !== null) ui.qualityOpt.selectedIndex = qualityOpt.index;
  let fileType = ui.imageTypeOpt.options.namedItem(config.imageType);
  if (fileType !== null) ui.imageTypeOpt.selectedIndex = fileType.index;
  if (config.qualityValue) ui.qualityVal.value = config.qualityValue;
  if (config.resX) ui.resX.value = config.resX;
  if (config.resY) ui.resY.value = config.resY;
  ui.qualityOpt.disabled = config.imageType === FILETYPE.PNG;
  ui.qualityVal.disabled = config.imageType === FILETYPE.PNG;
}
//#endregion

//#region LABELS
let labels = {
  use: "Use",
  retake: "Retake",
  restart: "Restart Camera",
  cancel: "Cancel",
  saving: "Saving...",
  camErr: "Error",
};

function SetLabels(InitJson) {
  labels.use = InitJson.label_use;
  labels.retake = InitJson.label_retake;
  labels.restart = InitJson.label_restart;
  labels.cancel = InitJson.label_cancel;
  labels.saving = InitJson.label_saving;
  labels.camErr = InitJson.label_camErr;
}
//#endregion

//#region UI ELEMENT REF
let ui = {
  video: null,
  canvas: null,
  image: null,

  videoView: null,
  imageView: null,
  configView: null,
  msgView: null,
  msg: null,
  btnpanel1: null,
  btnpanel2: null,
  configOpen: false,

  takeBtn: null,
  restartBtn: null,
  retakeBtn: null,
  useBtn: null,
  cancelBtn1: null,
  cancelBtn2: null,
  configBtn: null,

  resX: null,
  resY: null,
  cams: null,
  qualityOpt: null,
  qualityVal: null,
  imageTypeOpt: null,
};
function InitUi() {
  SetUIRefs();
  SetUIConfigOptions();
  InsertLabel();
  SetUIEventListeners();
}
function SetUIRefs() {
  ui.video = document.getElementById("video");
  ui.canvas = document.getElementById("canvas");
  ui.image = document.getElementById("image");
  ui.msgView = document.getElementById("msgView");
  ui.msg = document.getElementById("msg");
  ui.takeBtn = document.getElementById("takebtn");
  ui.restartBtn = document.getElementById("restartbtn");
  ui.retakeBtn = document.getElementById("retakebtn");
  ui.useBtn = document.getElementById("usebtn");
  ui.cancelBtn1 = document.getElementById("cancelbtn1");
  ui.cancelBtn2 = document.getElementById("cancelbtn2");
  ui.configBtn = document.getElementById("configbtn");
  ui.resX = document.getElementById("resolution-x-input");
  ui.resY = document.getElementById("resolution-y-input");
  ui.cams = document.getElementById("device-input");
  ui.qualityOpt = document.getElementById("qualityOpt");
  ui.imageTypeOpt = document.getElementById("imageType");
  ui.videoView = document.getElementById("videoview");
  ui.imageView = document.getElementById("imageview");
  ui.configView = document.getElementById("configview");
  ui.btnpanel1 = document.getElementById("btn-panel1");
  ui.btnpanel2 = document.getElementById("btn-panel2");
  ui.qualityVal = document.getElementById("qualityVal");
}
function SetUIConfigOptions() {
  Object.keys(QUALITY).forEach((val) => {
    let opt = QUALITY[val];
    let optEle = document.createElement("option");
    optEle.id = opt;
    optEle.label = opt;
    optEle.value = opt;
    ui.qualityOpt.options.add(optEle);
  });
  Object.keys(FILETYPE).forEach((val) => {
    let optEle = document.createElement("option");
    let opt = FILETYPE[val];
    optEle.id = opt;
    optEle.label = opt;
    optEle.value = opt;
    ui.imageTypeOpt.options.add(optEle);
  });
}
function InsertLabel() {
  ui.msgView.innerHTML = labels.saving;
  ui.restartBtn.innerHTML = labels.restart;
  ui.cancelBtn1.innerHTML = labels.cancel;
  ui.useBtn.innerHTML = labels.use;
  ui.retakeBtn.innerHTML = labels.retake;
  ui.cancelBtn2.innerHTML = labels.cancel;
}

function SetUIEventListeners() {
  ui.takeBtn.addEventListener("click", async (event) => await TakePhoto(event));
  ui.retakeBtn.addEventListener(
    "click",
    async (event) => await StartVideoFeed()
  );
  ui.restartBtn.addEventListener(
    "click",
    async (event) => await StartVideoFeed()
  );
  ui.useBtn.addEventListener("click", async (event) => await UsePhoto());
  ui.cancelBtn1.addEventListener("click", async (event) => await Cancel());
  ui.cancelBtn2.addEventListener("click", async (event) => await Cancel());
  ui.configBtn.addEventListener("click", async () => await SetView("config"));
  ui.video.addEventListener(
    "canplay",
    async (event) => await OnVideoFeedStart()
  );
}
//#endregion

async function Initialize(InitJson) {
  console.log("Control Addin - NPCamera: Initialize");
  SetLabels(InitJson);
  InsertHtml(InitJson);
  InitUi();
  InitDatabindings();
  SetConfig(InitJson);
  await StartVideoFeed();
}

async function OnVideoFeedStart() {
  console.log("Control Addin - NPCamera: OnVideoFeddStart");
  config.resX = ui.video.videoWidth;
  config.resY = ui.video.videoHeight;
  ui.resX.value = ui.video.videoWidth;
  ui.resY.value = ui.video.videoHeight;
  let videoAspect = ui.video.videoWidth / ui.video.videoHeight;
  //The values of the media box in which it is showed.
  let viewAspect = 600.0 / 300.0;
  let classs = videoAspect < viewAspect ? "media-vertical" : "media-horizontal";
  console.log(
    "Resolution: " + ui.video.videoWidth + " x " + ui.video.videoHeight
  );
  console.log(
    "Video Aspect: " +
      videoAspect +
      " View Aspect: " +
      viewAspect +
      " select: " +
      classs
  );
  ui.video.className = classs;
  ui.image.className = classs;
  await SetView("video");
}

async function SetView(view, message) {
  console.log("Control Addin - NPCamera: SetView");
  ui.msgView.className = "hidden";
  if (view === "video") {
    ui.videoView.className = "view";
    ui.imageView.className = "hidden";
    ui.btnpanel1.className = "btn-panel";
    ui.btnpanel2.className = "hidden";
  } else if (view === "image") {
    ui.videoView.className = "hidden";
    ui.imageView.className = "view";
    ui.btnpanel1.className = "hidden";
    ui.btnpanel2.className = "btn-panel";
  } else if (view === "config") {
    if (!ui.configOpen) {
      await FillDevices();
      ui.msgView.className = "hidden";
      ui.configView.className = "modal-container";
    } else {
      ui.configView.className = "hidden";
      if (ui.videoView.className !== "hidden") StartVideoFeed();
    }
    ui.configOpen = !ui.configOpen;
  } else if (view === "message" && !ui.configOpen) {
    ui.msgView.className = "msg-loader";
    ui.msg.innerHTML = message;
  }
}
async function StartVideoFeed() {
  console.log("Control Addin - NPCamera: StartVideoFeed");
  try {
    let stream;
    if (config.videoDeviceId) {
      try{
        stream = await navigator.mediaDevices.getUserMedia({
          video: {
            deviceId: { exact: config.videoDeviceId },
            width: { ideal: config.resX },
            height: { ideal: config.resY },
            frameRate: { ideal: 30 },
          },
          audio: false,
        });
      } catch(e)
      {
        console.log("Control Addin - NPCamera: StartVideoFeed - GetUserMedia with Device Id failed.");
      }
    }
    if (!stream)
    {
      stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: config.resX },
          height: { ideal: config.resY },
          frameRate: { ideal: 30 },
        },
        audio: false,
      });
    }
    config.videoDeviceId = stream.getVideoTracks()[0].getSettings().deviceId;
    SetCookie(VideoDeviceIdCookieRef, config.videoDeviceId);
    ui.video.srcObject = stream;
    ui.video.play();
  } catch (e) {
    console.error(e);
    await SetView("message", labels.camErr);
  }
}
async function HasPermission() {
  console.log("Control Addin - NPCamera: HasPermission");
  let res = await navigator.permissions.query({ name: "camera" });
  if (res === "granted") return true;
  else return false;
}
async function GetDevices() {
  console.log("Control Addin - NPCamera: GetDevices");
  return await navigator.mediaDevices.enumerateDevices();
}
async function FillDevices() {
  console.log("Control Addin - NPCamera: FillDevices");
  let devices = await GetDevices();
  ui.cams.innerHTML = "";
  let i = 0;
  devices.forEach((d) => {
    if (d.kind === "videoinput") {
      let opt = document.createElement("option");
      opt.id = d.deviceId ? d.deviceId : "(" + i + ")";
      opt.value = d.deviceId ? d.deviceId : "(" + i + ")";
      opt.label = d.label ? d.label : "(" + i + ") - No Name found";
      ui.cams.options.add(opt);
      if (config.videoDeviceId === d.deviceId) {
        ui.selected = i;
        ui.cams.selectedIndex = i;
      }
      i++;
    }
  });
}
//#region BUTTON CLICKS
async function TakePhoto(ev) {
  console.log("Control Addin - NPCamera: TakePhoto");
  ev.preventDefault();
  const context = ui.canvas.getContext("2d");
  ui.canvas.width = ui.video.videoWidth;
  ui.canvas.height = ui.video.videoHeight;
  context.drawImage(ui.video, 0, 0, ui.video.videoWidth, ui.video.videoHeight);
  const data = ui.canvas.toDataURL(
    `image/${config.imageType.toLowerCase()}`,
    config.qualityValue
  );
  console.log(
    "Filesize: " + window.atob(data.split("base64,")[1]).length / 1024 + " kb"
  );
  ui.image.setAttribute("src", data);
  await SetView("image");
}

async function UsePhoto() {
  console.log("Control Addin - NPCamera: GetImageBase64");
  await SetView("message", labels.saving);
  let data = ui.canvas.toDataURL(
    `image/${config.imageType.toLowerCase()}`,
    config.qualityValue
  );
  let base64data = data.split("base64,")[1];
  if (window.Microsoft) {
    await Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("UsePhoto", [
      { base64: base64data },
    ]);
  } else {
    alert("base64 lenght: " + base64data.length);
  }
}
function Cancel() {
  console.log("Control Addin - NPCamera: Cancel");
  if (window.Microsoft) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Cancel");
  } else {
    alert("Cancel");
  }
}
//#endregion
//#region COOKIES
function SetCookie(CookieName, CookieValue) {
  const d = new Date();
  d.setTime(d.getTime() + 360 * 24 * 60 * 60 * 1000);
  let expires = "expires=" + d.toUTCString();
  document.cookie = CookieName + "=" + CookieValue + ";" + expires + ";path=/";
}
function GetCookie(CookieName) {
  let name = CookieName + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(";");
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == " ") {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}
//#endregion
function InsertHtml(json) {
  let controlAddIn = document.getElementById("controlAddIn");
  if (!controlAddIn) return;
  controlAddIn.innerHTML = `
     <div id="npcamera" class="npcamera">
     <div class="header">
       <div class="header-wrap">
         <div class="title">
           Take a photo
         </div>
       </div>
       <div class="header-wrap">
         <div class="config">
           <div id="configbtn" class="btn-config">
             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" height="24px" width="24px" fill="grey">
               <path d="M495.9 166.6c3.2 8.7 .5 18.4-6.4 24.6l-43.3 39.4c1.1 8.3 1.7 16.8 1.7 25.4s-.6 17.1-1.7 25.4l43.3 39.4c6.9 6.2 9.6 15.9 6.4 24.6c-4.4 11.9-9.7 23.3-15.8 34.3l-4.7 8.1c-6.6 11-14 21.4-22.1 31.2c-5.9 7.2-15.7 9.6-24.5 6.8l-55.7-17.7c-13.4 10.3-28.2 18.9-44 25.4l-12.5 57.1c-2 9.1-9 16.3-18.2 17.8c-13.8 2.3-28 3.5-42.5 3.5s-28.7-1.2-42.5-3.5c-9.2-1.5-16.2-8.7-18.2-17.8l-12.5-57.1c-15.8-6.5-30.6-15.1-44-25.4L83.1 425.9c-8.8 2.8-18.6 .3-24.5-6.8c-8.1-9.8-15.5-20.2-22.1-31.2l-4.7-8.1c-6.1-11-11.4-22.4-15.8-34.3c-3.2-8.7-.5-18.4 6.4-24.6l43.3-39.4C64.6 273.1 64 264.6 64 256s.6-17.1 1.7-25.4L22.4 191.2c-6.9-6.2-9.6-15.9-6.4-24.6c4.4-11.9 9.7-23.3 15.8-34.3l4.7-8.1c6.6-11 14-21.4 22.1-31.2c5.9-7.2 15.7-9.6 24.5-6.8l55.7 17.7c13.4-10.3 28.2-18.9 44-25.4l12.5-57.1c2-9.1 9-16.3 18.2-17.8C227.3 1.2 241.5 0 256 0s28.7 1.2 42.5 3.5c9.2 1.5 16.2 8.7 18.2 17.8l12.5 57.1c15.8 6.5 30.6 15.1 44 25.4l55.7-17.7c8.8-2.8 18.6-.3 24.5 6.8c8.1 9.8 15.5 20.2 22.1 31.2l4.7 8.1c6.1 11 11.4 22.4 15.8 34.3zM256 336a80 80 0 1 0 0-160 80 80 0 1 0 0 160z"/>
             </svg>
           </div>
         </div>
       </div>
     </div>
     <div class="body">
       <div id="videoview" class="view">
         <div class="media-container">
           <div class="video-wrapper">
             <video id="video"></video>
           </div>
           <div class="take-container">
             <div class="takebtn-outer"></div>
             <div id="takebtn" class="btn-take"></div>
           </div>
         </div>
       </div>
       <div id="imageview" class="hidden">
         <div class="media-container">
           <div class="image-wrapper">
             <img id="image" class="image"/>
             <canvas id="canvas" class="hidden"></canvas>
           </div>
         </div>
       </div>
       <div id="configview" class="hidden">
             <div class="modal">
               <div class="input-group">
                 <div class="input-wrapper">
                   <div class="input-label">Camera</div>
                   <select id="device-input" class="input">
                   </select>
                 </div>
                 <div class="input-wrapper">
                   <div class="input-label">Quality</div>
                     <select id="qualityOpt" class="input">
                      
                     </select>
                 </div>
                 <div class="input-wrapper">
                   <div class="input-label">Quality Value</div>
                   <input id="qualityVal" min="0.0" max="1.0" class="input" type="number"></input>
                 </div>
                 <div class="input-wrapper">
                   <div class="input-label">File type</div>
                   <select id="imageType" class="input">
                   </select>
                 </div>
                 <div class="input-wrapper">
                   <div class="input-label">Resolution X</div>
                   <input id="resolution-x-input" class="input" type="number"></input>
                 </div>
                 <div class="input-wrapper">
                   <div class="input-label">Resolution Y</div>
                   <input id="resolution-y-input" class="input" type="number"></input>
                 </div>
               </div>
             </div>
       </div>
       <div id="msgView" class="hidden">
           <div class="msg-modal">
             <div id="msg">Saving...</div>
           </div>
       </div>
     </div>
     <div class="footer">
       <div id="btn-panel1" class="btn-panel">
         <div class="button-group">
           <div id="restartbtn" class="btn">Restart Camera</div>
           <div id="cancelbtn1" class="btn">Cancel</div>
         </div>
       </div>
       <div id="btn-panel2" class="hidden">
         <div class="button-group">
           <div id="usebtn" class="btn btn-use">Use</div>
           <div id="retakebtn" class="btn">Retake</div>
           <div id="cancelbtn2" class="btn">Cancel</div>
         </div>
       </div>
     </div>
   </div>
       `;
}

if (window.Microsoft) {
  console.log("Control Addin - NPCamera: Ready");
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready");
} else {
  console.log("Control Addin - NPCamera: Loaded");
  window.addEventListener(
    "load",
    async () =>
      await Initialize({
        label_use: "Use",
        label_retake: "Retake",
        label_restart: "Restart Camera",
        label_cancel: "Cancel",
        label_saving: "Saving",
        label_camErr: "Error",
        config: {
          videoDeviceId: GetCookie(VideoDeviceIdCookieRef),
          qualityOption: QUALITY.MEDIUM,
          qualityValue: QUALITY_INT.MEDIUM,
          imageType: FILETYPE.JPEG,
          resX: 30000,
          resY: 30000,
        },
      })
  );
}
