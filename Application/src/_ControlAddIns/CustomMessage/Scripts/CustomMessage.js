function Init(titleTxt, messageTxt)
{
    console.log("Control Addin - CustomMessage: Init");
    let container = document.getElementById("controlAddIn");
    let header = document.createElement("div");
    header.style.width = "100%";
    header.style.background = "lightgrey";
    header.style.height = "100px";
    let body = document.createElement("div");
    body.style.height = "400px";
    body.style.width = "100%";
    body.style.background = "#ededed";
    body.style.overflow = "auto";
    let footer = document.createElement("div");
    footer.style.height = "100px";
    footer.style.width = "100%";
    footer.style.textAlign = "end";

    let title = document.createElement("span");
    title.id = "title-header";
    title.style.fontSize = "60px";
    title.style.fontWeight = "bold";
    title.style.fontFamily = "\"Segoe UI\",Tahoma,Geneva,Verdana,sans-serif";
    title.innerHTML = titleTxt;

    let message = document.createElement("span");
    message.id = "message-body";
    message.style.fontSize = "30px";
    message.style.fontFamily = "\"Segoe UI\",Tahoma,Geneva,Verdana,sans-serif";
    message.innerHTML = messageTxt;
    let OkLabel = document.createElement("span");
    OkLabel.innerHTML = "OK";
    OkLabel.style.fontSize = "30px";
    
    let OkBtn = document.createElement("button");
    OkBtn.style.height = "80px";
    OkBtn.style.width = "120px";
    OkBtn.style.margin = "auto";
    OkBtn.appendChild(OkLabel);
    OkBtn.onclick = (e) => {
        let time = new Date().toLocaleString();
        console.log("Control Addin - CustomMessage: OkClicked: " + time);
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OKCliked",[]);
    };

    header.appendChild(title);
    body.appendChild(message);
    footer.appendChild(OkBtn);
    container.appendChild(header);
    container.appendChild(body);
    container.appendChild(footer);
}
console.log("Control Addin - CustomMessage: InvokeExtensibilityMethod(Ready)");
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready",[]);