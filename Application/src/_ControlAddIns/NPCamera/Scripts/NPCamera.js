
let env = {
    ui: {
        video: null,
        canvas: null,
        image: null,

        videoView: null,
        imageView : null,
        configView: null,
        msgView: null,
        msg: null,
        btnpanel1: null,
        btnpanel2: null,
        configOpen: false,
        qualContainer: null,

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
        selected: 0
    },
    labels: {
        use: "",
        retake: "",
        restart: "",
        cancel: "",
        saving: "",
        camErr: "",
    },
    config: {
        resX: 30000,
        resY: 30000,
        imageType: "jpg",
        quality: 0.5,
        videoDeviceId: getCookie("videoDeviceId")
    }
};

async function Initialize(InitJson)
{
    console.log("Control Addin - NPCamera: Initialize");
    env.labels.use = InitJson.label_use;
    env.labels.retake = InitJson.label_retake;
    env.labels.restart = InitJson.label_restart;
    env.labels.cancel = InitJson.label_cancel;
    env.labels.saving = InitJson.label_saving;
    env.labels.camErr = InitJson.label_camErr;
    env.config.resX = InitJson.config.pixelX;
    env.config.resY = InitJson.config.pixelY;
    env.config.quality = InitJson.config.qualityVal;
    env.config.imageType = InitJson.config.imageType;

    if (true || window.Microsoft) InsertHtml();
    env.ui.video = document.getElementById("video");
    env.ui.canvas = document.getElementById("canvas");
    env.ui.image = document.getElementById("image");
    env.ui.msgView = document.getElementById("msgView");
    env.ui.msg = document.getElementById("msg");
    env.ui.takeBtn = document.getElementById("takebtn");
    env.ui.restartBtn = document.getElementById("restartbtn");
    env.ui.retakeBtn = document.getElementById("retakebtn");
    env.ui.useBtn = document.getElementById("usebtn");
    env.ui.cancelBtn1 = document.getElementById("cancelbtn1");
    env.ui.cancelBtn2 = document.getElementById("cancelbtn2");
    env.ui.configBtn = document.getElementById("configbtn");
    env.ui.resX = document.getElementById("resolution-x-input");
    env.ui.resY = document.getElementById("resolution-y-input");
    env.ui.cams = document.getElementById("device-input");
    env.ui.qualityOpt = document.getElementById("qualityOpt");
    env.ui.imageTypeOpt = document.getElementById("imageType");
    env.ui.videoView = document.getElementById("videoview");
    env.ui.imageView = document.getElementById("imageview");
    env.ui.configView = document.getElementById("configview");
    env.ui.btnpanel1 = document.getElementById("btn-panel1");
    env.ui.btnpanel2 = document.getElementById("btn-panel2");
    env.ui.qualContainer = document.getElementById("qualityVal-container");
    env.ui.qualityVal = document.getElementById("qualityVal");
    env.ui.qualityOpt.selectedIndex = 5;

    env.ui.imageTypeOpt.selectedIndex = (env.config.imageType.toLowerCase() === "jpeg" ? 0 : 1); 
    env.ui.qualityVal.value = env.config.quality;
    env.ui.useBtn.innerHTML = env.labels.use;
    env.ui.restartBtn.innerHTML = env.labels.restart;
    env.ui.retakeBtn.innerHTML = env.labels.retake;
    env.ui.cancelBtn1.innerHTML = env.labels.cancel;
    env.ui.cancelBtn2.innerHTML = env.labels.cancel;

    env.ui.takeBtn.addEventListener("click", async (event) => await TakePhoto(event));
    env.ui.retakeBtn.addEventListener("click", async (event) => await StartVideoFeed());
    env.ui.restartBtn.addEventListener("click", async (event) => await StartVideoFeed());
    env.ui.useBtn.addEventListener("click", async (event) => await UsePhoto());
    env.ui.cancelBtn1.addEventListener("click", async (event) => await Cancel());
    env.ui.cancelBtn2.addEventListener("click", async (event) => await Cancel());
    env.ui.configBtn.addEventListener("click", async () => await SetView("config"));
    env.ui.resX.addEventListener("change", async (event) => await OnConfigChange("resX", event))
    env.ui.resY.addEventListener("change", async (event) => await OnConfigChange("resY", event))
    env.ui.cams.addEventListener("change", async (event) => await OnConfigChange("videoDeviceId", event))
    env.ui.qualityOpt.addEventListener("change", async (event) => await OnConfigChange("qualityOpt", event))
    env.ui.qualityVal.addEventListener("change", async (event) => await OnConfigChange("qualityVal", event))
    env.ui.imageTypeOpt.addEventListener("change", async (event) => await OnConfigChange("imageType", event))
    env.ui.video.addEventListener("canplay", async (event) => await OnVideoFeedStart());

    await StartVideoFeed();
}

async function OnVideoFeedStart()
{
    console.log("Control Addin - NPCamera: OnVideoFeddStart");
    env.config.resX = env.ui.video.videoWidth;
    env.config.resY = env.ui.video.videoHeight;
    env.ui.resX.value = env.ui.video.videoWidth;
    env.ui.resY.value = env.ui.video.videoHeight;
    let videoAspect = (env.ui.video.videoWidth / env.ui.video.videoHeight);
    //The values of the media box in which it is showed.
    let viewAspect = (600.0 / 300.0);
    let classs = (videoAspect < viewAspect ? "media-vertical": "media-horizontal");
    console.log("Resolution: " + env.ui.video.videoWidth + " x " + env.ui.video.videoHeight);
    console.log("Video Aspect: " + videoAspect + " View Aspect: " + viewAspect + " select: " + classs);
    env.ui.video.className = classs;
    env.ui.image.className = classs;
    await SetView("video");
}
async function OnConfigChange(configName, ev)
{
    console.log("Control Addin - NPCamera: OnConfigChange");
    if (configName === "resX")
    {
        env.config.resX = Number(ev.target.value);
    }
    else if (configName === "resY")
    {
        env.config.resY = Number(ev.target.value);
    }
    else if(configName === "videoDeviceId") {
        env.config.videoDeviceId = ev.target.value;
        env.ui.selected = ev.target.selectedIndex;
    }
    else if(configName === "qualityOpt") {
        if (ev.target.value !== "custom")
        {
            env.config.quality = ev.target.value;
            env.ui.qualityVal.value = ev.target.value;
        }
    }
    else if(configName === "qualityVal") {
        env.config.quality = ev.target.value;
        env.ui.qualityOpt.selectedIndex = 5;
        if(ev.target.value < 0)
        {
            env.config.quality = 0;
            env.ui.qualityVal.value = 0;
        }
        if(ev.target.value > 1)
        {
            env.config.quality = 1;
            env.ui.qualityVal.value = 1;
        }
            
    }
    else if(configName === "imageType") {
        env.config.imageType = ev.target.value;
    }
}

async function SetView(view, message)
{
    console.log("Control Addin - NPCamera: SetView");
    env.ui.msgView.className = "hidden";
    if (view === "video")
    {
        env.ui.videoView.className = "view";
        env.ui.imageView.className = "hidden";
        env.ui.btnpanel1.className = "btn-panel";
        env.ui.btnpanel2.className = "hidden";
    }
    else if (view === "image")
    {
        env.ui.videoView.className = "hidden";
        env.ui.imageView.className = "view";
        env.ui.btnpanel1.className = "hidden";
        env.ui.btnpanel2.className = "btn-panel";
        
    }
    else if (view === "config")
    { 
        if (!env.ui.configOpen)
        {
            await FillDevices();
            env.ui.msgView.className = "hidden";
            env.ui.configView.className = "modal-container";
        }
        else
        {
            env.ui.configView.className = "hidden";
            if(env.ui.videoView.className !== "hidden")
                StartVideoFeed();
            
        }
        env.ui.configOpen = !env.ui.configOpen;
    }
    else if (view === "message" && !env.ui.configOpen)
    {
        env.ui.msgView.className = "msg-loader";
        env.ui.msg.innerHTML = message;
           
    }
}
async function StartVideoFeed()
{
    console.log("Control Addin - NPCamera: StartVideoFeed");
    try{
        let stream;
        if (env.config.videoDeviceId)
        {
            stream = await navigator.mediaDevices.getUserMedia({ video: {
                deviceId: {ideal: env.config.videoDeviceId},
                width: { ideal: env.config.resX  },
                height: { ideal: env.config.resY },
                frameRate: { ideal: 30}
            }, audio: false });
        }
        else
        {
            stream = await navigator.mediaDevices.getUserMedia({ video: {
                width: { ideal: env.config.resX  },
                height: { ideal: env.config.resY },
                frameRate: { ideal: 30}
            }, audio: false });
        }
        env.config.videoDeviceId = stream.getVideoTracks()[0].getSettings().deviceId;
        setCookie("videoDeviceId", env.config.videoDeviceId);
        env.ui.video.srcObject = stream;
        env.ui.video.play();
    } catch (e)
    {
        console.error(e);
        await SetView("message", env.labels.camErr);
    }
}
async function HasPermission()
{
    console.log("Control Addin - NPCamera: HasPermission");
    let res = await navigator.permissions.query({name: "camera"});
    if (res === "granted") return true;
    else return false;
}
async function GetDevices()
{
    console.log("Control Addin - NPCamera: GetDevices");
    return await navigator.mediaDevices.enumerateDevices();
}
async function FillDevices()
{
    console.log("Control Addin - NPCamera: FillDevices");
    let devices = await GetDevices();
    env.ui.cams.innerHTML = "";
    let i = 0;
    devices.forEach((d) => {
        if (d.kind === "videoinput")
        {
            let opt = document.createElement("option");
            opt.value = (d.deviceId ? d.deviceId : "("+i+")");
            opt.label = (d.label ? d.label : "("+i+") - No Name found");;
            env.ui.cams.options.add(opt);
            if(env.config.videoDeviceId === d.deviceId)
            {
                env.ui.selected = i;
                env.ui.cams.selectedIndex = i;
            }
            i++;
        }
    });
}

async function TakePhoto(ev)
{
    console.log("Control Addin - NPCamera: TakePhoto");
    ev.preventDefault();
    const context = env.ui.canvas.getContext("2d");
    env.ui.canvas.width = env.ui.video.videoWidth;
    env.ui.canvas.height = env.ui.video.videoHeight;
    context.drawImage(env.ui.video, 0, 0, env.ui.video.videoWidth, env.ui.video.videoHeight);
    const data = env.ui.canvas.toDataURL(`image/${env.config.imageType.toLowerCase()}`, env.config.quality);
    console.log("Filesize: " + window.atob(data.split("base64,")[1]).length / 1024 + " kb");
    env.ui.image.setAttribute("src", data);
    await SetView("image");
}

async function UsePhoto()
{
    console.log("Control Addin - NPCamera: GetImageBase64");
    await SetView("message", env.labels.saving);
    let data = env.ui.canvas.toDataURL(`image/${env.config.imageType.toLowerCase()}`, env.config.quality);
    let base64data = data.split("base64,")[1];
    if(window.Microsoft)
    {
        await Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("UsePhoto", [{ base64: base64data }]);
    } else
    {
        alert("base64 lenght: " + base64data.length);
    }
}
function Cancel()
{
    console.log("Control Addin - NPCamera: Cancel");
    if(window.Microsoft)
    {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Cancel");
    } else
    {
        alert("Cancel");
    }
}



function InsertHtml()
{
	let controlAddIn = document.getElementById("controlAddIn");
	let controlAddIn_0 = document.createElement("div");
	controlAddIn_0.setAttribute("id", "npcamera");
	controlAddIn_0.setAttribute("class", "npcamera");
	let controlAddIn_0_0 = document.createElement("div");
	controlAddIn_0_0.setAttribute("class", "header");
	let controlAddIn_0_0_0 = document.createElement("div");
	controlAddIn_0_0_0.setAttribute("class", "header-wrap");
	let controlAddIn_0_0_0_0 = document.createElement("div");
	controlAddIn_0_0_0_0.setAttribute("class", "title");
	controlAddIn_0_0_0_0.innerHTML = "\n          Take a photo\n        ";
	controlAddIn_0_0_0.appendChild(controlAddIn_0_0_0_0);
	controlAddIn_0_0.appendChild(controlAddIn_0_0_0);
	let controlAddIn_0_0_1 = document.createElement("div");
	controlAddIn_0_0_1.setAttribute("class", "header-wrap");
	let controlAddIn_0_0_1_0 = document.createElement("div");
	controlAddIn_0_0_1_0.setAttribute("class", "config");
	let controlAddIn_0_0_1_0_0 = document.createElement("div");
	controlAddIn_0_0_1_0_0.setAttribute("id", "configbtn");
	controlAddIn_0_0_1_0_0.setAttribute("class", "btn-config");
	let controlAddIn_0_0_1_0_0_0 = document.createElementNS("http://www.w3.org/2000/svg", "svg");
	controlAddIn_0_0_1_0_0_0.setAttribute("xmlns", "http://www.w3.org/2000/svg");
	controlAddIn_0_0_1_0_0_0.setAttribute("viewBox", "0 0 512 512");
	controlAddIn_0_0_1_0_0_0.setAttribute("height", "24px");
	controlAddIn_0_0_1_0_0_0.setAttribute("width", "24px");
	controlAddIn_0_0_1_0_0_0.setAttribute("fill", "grey");
	let controlAddIn_0_0_1_0_0_0_0 = document.createElementNS("http://www.w3.org/2000/svg", "path");
	controlAddIn_0_0_1_0_0_0_0.setAttribute("d", "M495.9 166.6c3.2 8.7 .5 18.4-6.4 24.6l-43.3 39.4c1.1 8.3 1.7 16.8 1.7 25.4s-.6 17.1-1.7 25.4l43.3 39.4c6.9 6.2 9.6 15.9 6.4 24.6c-4.4 11.9-9.7 23.3-15.8 34.3l-4.7 8.1c-6.6 11-14 21.4-22.1 31.2c-5.9 7.2-15.7 9.6-24.5 6.8l-55.7-17.7c-13.4 10.3-28.2 18.9-44 25.4l-12.5 57.1c-2 9.1-9 16.3-18.2 17.8c-13.8 2.3-28 3.5-42.5 3.5s-28.7-1.2-42.5-3.5c-9.2-1.5-16.2-8.7-18.2-17.8l-12.5-57.1c-15.8-6.5-30.6-15.1-44-25.4L83.1 425.9c-8.8 2.8-18.6 .3-24.5-6.8c-8.1-9.8-15.5-20.2-22.1-31.2l-4.7-8.1c-6.1-11-11.4-22.4-15.8-34.3c-3.2-8.7-.5-18.4 6.4-24.6l43.3-39.4C64.6 273.1 64 264.6 64 256s.6-17.1 1.7-25.4L22.4 191.2c-6.9-6.2-9.6-15.9-6.4-24.6c4.4-11.9 9.7-23.3 15.8-34.3l4.7-8.1c6.6-11 14-21.4 22.1-31.2c5.9-7.2 15.7-9.6 24.5-6.8l55.7 17.7c13.4-10.3 28.2-18.9 44-25.4l12.5-57.1c2-9.1 9-16.3 18.2-17.8C227.3 1.2 241.5 0 256 0s28.7 1.2 42.5 3.5c9.2 1.5 16.2 8.7 18.2 17.8l12.5 57.1c15.8 6.5 30.6 15.1 44 25.4l55.7-17.7c8.8-2.8 18.6-.3 24.5 6.8c8.1 9.8 15.5 20.2 22.1 31.2l4.7 8.1c6.1 11 11.4 22.4 15.8 34.3zM256 336a80 80 0 1 0 0-160 80 80 0 1 0 0 160z");
	controlAddIn_0_0_1_0_0_0_0.innerHTML = "";
	controlAddIn_0_0_1_0_0_0.appendChild(controlAddIn_0_0_1_0_0_0_0);
	controlAddIn_0_0_1_0_0.appendChild(controlAddIn_0_0_1_0_0_0);
	controlAddIn_0_0_1_0.appendChild(controlAddIn_0_0_1_0_0);
	controlAddIn_0_0_1.appendChild(controlAddIn_0_0_1_0);
	controlAddIn_0_0.appendChild(controlAddIn_0_0_1);
	controlAddIn_0.appendChild(controlAddIn_0_0);
	let controlAddIn_0_1 = document.createElement("div");
	controlAddIn_0_1.setAttribute("class", "body");
	let controlAddIn_0_1_0 = document.createElement("div");
	controlAddIn_0_1_0.setAttribute("id", "videoview");
	controlAddIn_0_1_0.setAttribute("class", "view");
	let controlAddIn_0_1_0_0 = document.createElement("div");
	controlAddIn_0_1_0_0.setAttribute("class", "media-container");
	let controlAddIn_0_1_0_0_0 = document.createElement("div");
	controlAddIn_0_1_0_0_0.setAttribute("class", "video-wrapper");
	let controlAddIn_0_1_0_0_0_0 = document.createElement("video");
	controlAddIn_0_1_0_0_0_0.setAttribute("id", "video");
	controlAddIn_0_1_0_0_0_0.innerHTML = "";
	controlAddIn_0_1_0_0_0.appendChild(controlAddIn_0_1_0_0_0_0);
	controlAddIn_0_1_0_0.appendChild(controlAddIn_0_1_0_0_0);
	let controlAddIn_0_1_0_0_1 = document.createElement("div");
	controlAddIn_0_1_0_0_1.setAttribute("class", "take-container");
	let controlAddIn_0_1_0_0_1_0 = document.createElement("div");
	controlAddIn_0_1_0_0_1_0.setAttribute("class", "takebtn-outer");
	controlAddIn_0_1_0_0_1_0.innerHTML = "";
	controlAddIn_0_1_0_0_1.appendChild(controlAddIn_0_1_0_0_1_0);
	let controlAddIn_0_1_0_0_1_1 = document.createElement("div");
	controlAddIn_0_1_0_0_1_1.setAttribute("id", "takebtn");
	controlAddIn_0_1_0_0_1_1.setAttribute("class", "btn-take");
	controlAddIn_0_1_0_0_1_1.innerHTML = "";
	controlAddIn_0_1_0_0_1.appendChild(controlAddIn_0_1_0_0_1_1);
	controlAddIn_0_1_0_0.appendChild(controlAddIn_0_1_0_0_1);
	controlAddIn_0_1_0.appendChild(controlAddIn_0_1_0_0);
	controlAddIn_0_1.appendChild(controlAddIn_0_1_0);
	let controlAddIn_0_1_1 = document.createElement("div");
	controlAddIn_0_1_1.setAttribute("id", "imageview");
	controlAddIn_0_1_1.setAttribute("class", "hidden");
	let controlAddIn_0_1_1_0 = document.createElement("div");
	controlAddIn_0_1_1_0.setAttribute("class", "media-container");
	let controlAddIn_0_1_1_0_0 = document.createElement("div");
	controlAddIn_0_1_1_0_0.setAttribute("class", "image-wrapper");
	let controlAddIn_0_1_1_0_0_0 = document.createElement("img");
	controlAddIn_0_1_1_0_0_0.setAttribute("id", "image");
	controlAddIn_0_1_1_0_0_0.setAttribute("class", "image");
	controlAddIn_0_1_1_0_0_0.innerHTML = "";
	controlAddIn_0_1_1_0_0.appendChild(controlAddIn_0_1_1_0_0_0);
	let controlAddIn_0_1_1_0_0_1 = document.createElement("canvas");
	controlAddIn_0_1_1_0_0_1.setAttribute("id", "canvas");
	controlAddIn_0_1_1_0_0_1.setAttribute("class", "hidden");
	controlAddIn_0_1_1_0_0_1.innerHTML = "";
	controlAddIn_0_1_1_0_0.appendChild(controlAddIn_0_1_1_0_0_1);
	controlAddIn_0_1_1_0.appendChild(controlAddIn_0_1_1_0_0);
	controlAddIn_0_1_1.appendChild(controlAddIn_0_1_1_0);
	controlAddIn_0_1.appendChild(controlAddIn_0_1_1);
	let controlAddIn_0_1_2 = document.createElement("div");
	controlAddIn_0_1_2.setAttribute("id", "configview");
	controlAddIn_0_1_2.setAttribute("class", "hidden");
	let controlAddIn_0_1_2_0 = document.createElement("div");
	controlAddIn_0_1_2_0.setAttribute("class", "modal");
	let controlAddIn_0_1_2_0_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0.setAttribute("class", "input-group");
	let controlAddIn_0_1_2_0_0_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_0.setAttribute("class", "input-wrapper");
	let controlAddIn_0_1_2_0_0_0_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_0_0.setAttribute("class", "input-label");
	controlAddIn_0_1_2_0_0_0_0.innerHTML = "Camera";
	controlAddIn_0_1_2_0_0_0.appendChild(controlAddIn_0_1_2_0_0_0_0);
	let controlAddIn_0_1_2_0_0_0_1 = document.createElement("select");
	controlAddIn_0_1_2_0_0_0_1.setAttribute("id", "device-input");
	controlAddIn_0_1_2_0_0_0_1.setAttribute("class", "input");
	controlAddIn_0_1_2_0_0_0_1.innerHTML = "\n                  ";
	controlAddIn_0_1_2_0_0_0.appendChild(controlAddIn_0_1_2_0_0_0_1);
	controlAddIn_0_1_2_0_0.appendChild(controlAddIn_0_1_2_0_0_0);
	let controlAddIn_0_1_2_0_0_1 = document.createElement("div");
	controlAddIn_0_1_2_0_0_1.setAttribute("class", "input-wrapper");
	let controlAddIn_0_1_2_0_0_1_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_1_0.setAttribute("class", "input-label");
	controlAddIn_0_1_2_0_0_1_0.innerHTML = "Quality";
	controlAddIn_0_1_2_0_0_1.appendChild(controlAddIn_0_1_2_0_0_1_0);
	let controlAddIn_0_1_2_0_0_1_1 = document.createElement("select");
	controlAddIn_0_1_2_0_0_1_1.setAttribute("id", "qualityOpt");
	controlAddIn_0_1_2_0_0_1_1.setAttribute("class", "input");
	let controlAddIn_0_1_2_0_0_1_1_0 = document.createElement("option");
	controlAddIn_0_1_2_0_0_1_1_0.setAttribute("value", "0.2");
	controlAddIn_0_1_2_0_0_1_1_0.innerHTML = "Very Low";
	controlAddIn_0_1_2_0_0_1_1.appendChild(controlAddIn_0_1_2_0_0_1_1_0);
	let controlAddIn_0_1_2_0_0_1_1_1 = document.createElement("option");
	controlAddIn_0_1_2_0_0_1_1_1.setAttribute("value", "0.4");
	controlAddIn_0_1_2_0_0_1_1_1.innerHTML = "Low";
	controlAddIn_0_1_2_0_0_1_1.appendChild(controlAddIn_0_1_2_0_0_1_1_1);
	let controlAddIn_0_1_2_0_0_1_1_2 = document.createElement("option");
	controlAddIn_0_1_2_0_0_1_1_2.setAttribute("value", "0.6");
	controlAddIn_0_1_2_0_0_1_1_2.innerHTML = "Medium";
	controlAddIn_0_1_2_0_0_1_1.appendChild(controlAddIn_0_1_2_0_0_1_1_2);
	let controlAddIn_0_1_2_0_0_1_1_3 = document.createElement("option");
	controlAddIn_0_1_2_0_0_1_1_3.setAttribute("value", "0.8");
	controlAddIn_0_1_2_0_0_1_1_3.innerHTML = "High";
	controlAddIn_0_1_2_0_0_1_1.appendChild(controlAddIn_0_1_2_0_0_1_1_3);
	let controlAddIn_0_1_2_0_0_1_1_4 = document.createElement("option");
	controlAddIn_0_1_2_0_0_1_1_4.setAttribute("value", "1");
	controlAddIn_0_1_2_0_0_1_1_4.innerHTML = "Very High";
	controlAddIn_0_1_2_0_0_1_1.appendChild(controlAddIn_0_1_2_0_0_1_1_4);
	let controlAddIn_0_1_2_0_0_1_1_5 = document.createElement("option");
	controlAddIn_0_1_2_0_0_1_1_5.setAttribute("value", "custom");
	controlAddIn_0_1_2_0_0_1_1_5.innerHTML = "Custom";
	controlAddIn_0_1_2_0_0_1_1.appendChild(controlAddIn_0_1_2_0_0_1_1_5);
	controlAddIn_0_1_2_0_0_1.appendChild(controlAddIn_0_1_2_0_0_1_1);
	controlAddIn_0_1_2_0_0.appendChild(controlAddIn_0_1_2_0_0_1);
	let controlAddIn_0_1_2_0_0_2 = document.createElement("div");
	controlAddIn_0_1_2_0_0_2.setAttribute("id", "qualityVal-container");
	controlAddIn_0_1_2_0_0_2.setAttribute("class", "input-wrapper");
	let controlAddIn_0_1_2_0_0_2_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_2_0.setAttribute("class", "input-label");
	controlAddIn_0_1_2_0_0_2_0.innerHTML = "Quality Value";
	controlAddIn_0_1_2_0_0_2.appendChild(controlAddIn_0_1_2_0_0_2_0);
	let controlAddIn_0_1_2_0_0_2_1 = document.createElement("input");
	controlAddIn_0_1_2_0_0_2_1.setAttribute("id", "qualityVal");
	controlAddIn_0_1_2_0_0_2_1.setAttribute("min", "0.0");
	controlAddIn_0_1_2_0_0_2_1.setAttribute("max", "1.0");
	controlAddIn_0_1_2_0_0_2_1.setAttribute("class", "input");
	controlAddIn_0_1_2_0_0_2_1.setAttribute("type", "number");
	controlAddIn_0_1_2_0_0_2_1.innerHTML = "";
	controlAddIn_0_1_2_0_0_2.appendChild(controlAddIn_0_1_2_0_0_2_1);
	controlAddIn_0_1_2_0_0.appendChild(controlAddIn_0_1_2_0_0_2);
	let controlAddIn_0_1_2_0_0_3 = document.createElement("div");
	controlAddIn_0_1_2_0_0_3.setAttribute("class", "input-wrapper");
	let controlAddIn_0_1_2_0_0_3_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_3_0.setAttribute("class", "input-label");
	controlAddIn_0_1_2_0_0_3_0.innerHTML = "File type";
	controlAddIn_0_1_2_0_0_3.appendChild(controlAddIn_0_1_2_0_0_3_0);
	let controlAddIn_0_1_2_0_0_3_1 = document.createElement("select");
	controlAddIn_0_1_2_0_0_3_1.setAttribute("id", "imageType");
	controlAddIn_0_1_2_0_0_3_1.setAttribute("class", "input");
	let controlAddIn_0_1_2_0_0_3_1_0 = document.createElement("option");
	controlAddIn_0_1_2_0_0_3_1_0.setAttribute("value", "jpeg");
	controlAddIn_0_1_2_0_0_3_1_0.innerHTML = "JPEG";
	controlAddIn_0_1_2_0_0_3_1.appendChild(controlAddIn_0_1_2_0_0_3_1_0);
	let controlAddIn_0_1_2_0_0_3_1_1 = document.createElement("option");
	controlAddIn_0_1_2_0_0_3_1_1.setAttribute("value", "png");
	controlAddIn_0_1_2_0_0_3_1_1.innerHTML = "PNG";
	controlAddIn_0_1_2_0_0_3_1.appendChild(controlAddIn_0_1_2_0_0_3_1_1);
	controlAddIn_0_1_2_0_0_3.appendChild(controlAddIn_0_1_2_0_0_3_1);
	controlAddIn_0_1_2_0_0.appendChild(controlAddIn_0_1_2_0_0_3);
	let controlAddIn_0_1_2_0_0_4 = document.createElement("div");
	controlAddIn_0_1_2_0_0_4.setAttribute("class", "input-wrapper");
	let controlAddIn_0_1_2_0_0_4_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_4_0.setAttribute("class", "input-label");
	controlAddIn_0_1_2_0_0_4_0.innerHTML = "Resolution X";
	controlAddIn_0_1_2_0_0_4.appendChild(controlAddIn_0_1_2_0_0_4_0);
	let controlAddIn_0_1_2_0_0_4_1 = document.createElement("input");
	controlAddIn_0_1_2_0_0_4_1.setAttribute("id", "resolution-x-input");
	controlAddIn_0_1_2_0_0_4_1.setAttribute("class", "input");
	controlAddIn_0_1_2_0_0_4_1.setAttribute("type", "number");
	controlAddIn_0_1_2_0_0_4_1.innerHTML = "";
	controlAddIn_0_1_2_0_0_4.appendChild(controlAddIn_0_1_2_0_0_4_1);
	controlAddIn_0_1_2_0_0.appendChild(controlAddIn_0_1_2_0_0_4);
	let controlAddIn_0_1_2_0_0_5 = document.createElement("div");
	controlAddIn_0_1_2_0_0_5.setAttribute("class", "input-wrapper");
	let controlAddIn_0_1_2_0_0_5_0 = document.createElement("div");
	controlAddIn_0_1_2_0_0_5_0.setAttribute("class", "input-label");
	controlAddIn_0_1_2_0_0_5_0.innerHTML = "Resolution Y";
	controlAddIn_0_1_2_0_0_5.appendChild(controlAddIn_0_1_2_0_0_5_0);
	let controlAddIn_0_1_2_0_0_5_1 = document.createElement("input");
	controlAddIn_0_1_2_0_0_5_1.setAttribute("id", "resolution-y-input");
	controlAddIn_0_1_2_0_0_5_1.setAttribute("class", "input");
	controlAddIn_0_1_2_0_0_5_1.setAttribute("type", "number");
	controlAddIn_0_1_2_0_0_5_1.innerHTML = "";
	controlAddIn_0_1_2_0_0_5.appendChild(controlAddIn_0_1_2_0_0_5_1);
	controlAddIn_0_1_2_0_0.appendChild(controlAddIn_0_1_2_0_0_5);
	controlAddIn_0_1_2_0.appendChild(controlAddIn_0_1_2_0_0);
	controlAddIn_0_1_2.appendChild(controlAddIn_0_1_2_0);
	controlAddIn_0_1.appendChild(controlAddIn_0_1_2);
	let controlAddIn_0_1_3 = document.createElement("div");
	controlAddIn_0_1_3.setAttribute("id", "msgView");
	controlAddIn_0_1_3.setAttribute("class", "hidden");
	let controlAddIn_0_1_3_0 = document.createElement("div");
	controlAddIn_0_1_3_0.setAttribute("class", "msg-modal");
	let controlAddIn_0_1_3_0_0 = document.createElement("div");
	controlAddIn_0_1_3_0_0.setAttribute("id", "msg");
	controlAddIn_0_1_3_0_0.innerHTML = "Saving...";
	controlAddIn_0_1_3_0.appendChild(controlAddIn_0_1_3_0_0);
	controlAddIn_0_1_3.appendChild(controlAddIn_0_1_3_0);
	controlAddIn_0_1.appendChild(controlAddIn_0_1_3);
	controlAddIn_0.appendChild(controlAddIn_0_1);
	let controlAddIn_0_2 = document.createElement("div");
	controlAddIn_0_2.setAttribute("class", "footer");
	let controlAddIn_0_2_0 = document.createElement("div");
	controlAddIn_0_2_0.setAttribute("id", "btn-panel1");
	controlAddIn_0_2_0.setAttribute("class", "btn-panel");
	let controlAddIn_0_2_0_0 = document.createElement("div");
	controlAddIn_0_2_0_0.setAttribute("class", "button-group");
	let controlAddIn_0_2_0_0_0 = document.createElement("div");
	controlAddIn_0_2_0_0_0.setAttribute("id", "restartbtn");
	controlAddIn_0_2_0_0_0.setAttribute("class", "btn");
	controlAddIn_0_2_0_0_0.innerHTML = "Restart Camera";
	controlAddIn_0_2_0_0.appendChild(controlAddIn_0_2_0_0_0);
	let controlAddIn_0_2_0_0_1 = document.createElement("div");
	controlAddIn_0_2_0_0_1.setAttribute("id", "cancelbtn1");
	controlAddIn_0_2_0_0_1.setAttribute("class", "btn");
	controlAddIn_0_2_0_0_1.innerHTML = "Cancel";
	controlAddIn_0_2_0_0.appendChild(controlAddIn_0_2_0_0_1);
	controlAddIn_0_2_0.appendChild(controlAddIn_0_2_0_0);
	controlAddIn_0_2.appendChild(controlAddIn_0_2_0);
	let controlAddIn_0_2_1 = document.createElement("div");
	controlAddIn_0_2_1.setAttribute("id", "btn-panel2");
	controlAddIn_0_2_1.setAttribute("class", "hidden");
	let controlAddIn_0_2_1_0 = document.createElement("div");
	controlAddIn_0_2_1_0.setAttribute("class", "button-group");
	let controlAddIn_0_2_1_0_0 = document.createElement("div");
	controlAddIn_0_2_1_0_0.setAttribute("id", "usebtn");
	controlAddIn_0_2_1_0_0.setAttribute("class", "btn btn-use");
	controlAddIn_0_2_1_0_0.innerHTML = "Use";
	controlAddIn_0_2_1_0.appendChild(controlAddIn_0_2_1_0_0);
	let controlAddIn_0_2_1_0_1 = document.createElement("div");
	controlAddIn_0_2_1_0_1.setAttribute("id", "retakebtn");
	controlAddIn_0_2_1_0_1.setAttribute("class", "btn");
	controlAddIn_0_2_1_0_1.innerHTML = "Retake";
	controlAddIn_0_2_1_0.appendChild(controlAddIn_0_2_1_0_1);
	let controlAddIn_0_2_1_0_2 = document.createElement("div");
	controlAddIn_0_2_1_0_2.setAttribute("id", "cancelbtn2");
	controlAddIn_0_2_1_0_2.setAttribute("class", "btn");
	controlAddIn_0_2_1_0_2.innerHTML = "Cancel";
	controlAddIn_0_2_1_0.appendChild(controlAddIn_0_2_1_0_2);
	controlAddIn_0_2_1.appendChild(controlAddIn_0_2_1_0);
	controlAddIn_0_2.appendChild(controlAddIn_0_2_1);
	controlAddIn_0.appendChild(controlAddIn_0_2);
	controlAddIn.appendChild(controlAddIn_0);

}
function setCookie(cname, cvalue) {
    const d = new Date();
    d.setTime(d.getTime() + (360*24*60*60*1000));
    let expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}
function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i <ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }

if (window.Microsoft)
{
    console.log("Control Addin - NPCamera: Ready");
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready");
}
else
{
    console.log("Control Addin - NPCamera: Loaded");
    window.addEventListener("load", async () => await Initialize({
        label_use: "Use",
        label_retake: "Retake",
        label_restart: "Restart",
        label_cancel: "Cancel",
        label_saving: "Saving",
        label_camErr: "Error",
        config: {
            pixelX: 600,
            pixelY: 600,
            qualityVal: 1,
            imageType: "jpeg",
        }
    }));
}