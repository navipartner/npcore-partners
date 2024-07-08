function SendInputDataAndLabelV2(input, showControl, approveLbl, redoLbl, phoneLbl, noInputLbl)
{
    try{
        let showPhone = input.PhoneNumber != null && input.PhoneNumber != undefined;;
        let showSign = input.Signature != null && input.Signature != undefined &&  input.Signature !== "[]";
        let showBtns = showControl;
        init(showPhone, showSign, showBtns, approveLbl, redoLbl, phoneLbl, noInputLbl);
        if (showSign)
        {
            let signature = JSON.parse(input.Signature);
            let canvas = document.getElementById("signaturebox");
            canvas.height = canvas.getBoundingClientRect().height;
            canvas.width = canvas.getBoundingClientRect().width;
            DrawCanvas(canvas, signature);
        }
        if (showPhone)
        {
            let phonebox = document.getElementById("phonebox");
            phonebox.innerHTML = phoneLbl + ": " + input.PhoneNumber;
        }
    } catch (e)
    {
        console.error(e);
    }
}
function GetSignatureWidthAndHeight(points)
{
    let topMost = null;
    let leftMost = null;
    let rightMost = null;
    let botMost = null;
    for(let i = 0; i< points.length; i++)
    {
        for(let j = 0; j < points[i].length; j++)
        {
            let point = points[i][j];
            if (topMost === null || topMost.y > point.y)
            {
                topMost = point;
            }
            if (leftMost === null || leftMost.x > point.x)
            {
                leftMost = point;
            }
            if (rightMost === null || rightMost.x < point.x)
            {
                rightMost = point;
            }
            if (botMost === null || botMost.y < point.y)
            {
                botMost = point;
            }
        }
    }
    let w = rightMost.x - leftMost.x;
    let h = botMost.y - topMost.y;
    return {startPoint: {x: leftMost.x, y: topMost.y}, width: w, height: h};
}
function GetScale(actualHeight, actualWidth, signHeight, signWidth)
{
    let scaleY = 1;
    let scaleX = 1;
    if (actualHeight < signHeight)
        scaleY = actualHeight / signHeight;
    if (actualWidth < signWidth)
        scaleX = actualWidth / signWidth;
    return Math.min(scaleY, scaleX);
}

/**
 * Takes a canvas HTML Element and a 2d array of points of form {x: number, y: number}.
 * The 1st dimension seperates lines drawn.
 * The 2nd dimenstion contains the collection of ordered points to draw the line.
 */
function DrawCanvas(canvas, points)
{
    let ctx = canvas.getContext('2d');
    let prev = null;
    let penSize = 2;
    let actualWidth = canvas.getBoundingClientRect().width - 10;
    let actualHeight = canvas.getBoundingClientRect().height - 10;
    let pointBox = GetSignatureWidthAndHeight(points);
    let scale = GetScale(actualHeight, actualWidth, pointBox.height, pointBox.width);
    ctx.scale(scale, scale);
    ctx.translate(-(pointBox.startPoint.x -5), -(pointBox.startPoint.y -5));
    for(let i = 0; i < points.length; i++)
    {
        prev = null;
        for(let j = 0; j < points[i].length; j++)
        {
            let point = points[i][j];
            ctx.beginPath();
            ctx.arc(point.x, point.y, penSize, 0, 2 * Math.PI, false);
            ctx.fill();
            ctx.closePath();
            if (prev !== null)
            {
                ctx.beginPath();
                ctx.lineWidth = penSize*2;
                ctx.moveTo(prev.x, prev.y);
                ctx.lineTo(point.x, point.y);
                ctx.stroke();
                ctx.closePath();
            }
            prev = point;
        }
    }
}

function init(phonebox, signaturebox, btns, approveLbl, redoLbl, phoneLbl, noInputLbl)
{
    let body = window.document.getElementById("controlAddIn");
    let gridlayout = document.createElement("div");
    gridlayout.style.display = "grid";
    gridlayout.style.height = "100%";
    gridlayout.style.width = "100%";
    gridlayout.style.gridTemplateColumns = "repeat(2, 1fr)";
    gridlayout.style.gridTemplateRows = "repeat(3, max-content)";
    if (phonebox)
    {
        let phone = document.createElement("div");
        phone.style.backgroundColor = "whitesmoke";
        phone.style.gridColumn = "1 / span 2";
        phone.style.height = "50px";
        phone.style.fontSize = "50px"
        phone.style.width = "100%";
        phone.id = "phonebox";
        phone.innerHTML = phoneLbl;
        gridlayout.appendChild(phone);
    }
    if (signaturebox)
    {
        let canvas = document.createElement("canvas");
        canvas.style.height = "150px";
        canvas.style.width = "100%";
        canvas.style.backgroundColor = "lightyellow";
        canvas.style.gridColumn = "1 / span 2";
        canvas.id = "signaturebox";
        gridlayout.appendChild(canvas);
    }
    if (!phonebox && !signaturebox)
    {
        let noInput = document.createElement("div");
        noInput.style.backgroundColor = "whitesmoke";
        noInput.style.gridColumn = "1 / span 2";
        noInput.style.height = "50px";
        noInput.style.fontSize = "50px"
        noInput.style.width = "100%";
        noInput.id = "noInput";
        noInput.innerHTML = noInputLbl;
        gridlayout.appendChild(noInput);
    }
    if (btns)
    {
        let RedoBtn = document.createElement("button");
        RedoBtn.style.width = "100%";
        RedoBtn.style.backgroundColor = "indianred";
        RedoBtn.textContent = "Redo Input";
        RedoBtn.id = "RedoBtn";
        RedoBtn.innerHTML = "<p style=\"font-size: 40px; font-weight: bold;\">"+ redoLbl +"<p/>"
        RedoBtn.addEventListener("click", () => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("RedoInput",[]));
        let OkBtn = document.createElement("button");
        OkBtn.style.width = "100%";
        OkBtn.style.backgroundColor = "darkseagreen";
        OkBtn.id = "OkBtn";
        OkBtn.innerHTML = "<p style=\"font-size: 40px; font-weight: bold;\">"+ approveLbl +"<p/>"
        OkBtn.addEventListener("click", () => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OkInput",[]));
        gridlayout.appendChild(RedoBtn);
        gridlayout.appendChild(OkBtn);
    }
    body.appendChild(gridlayout);
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready",[]);