function SendInputData(input, showControl)
{
    try{
        let showPhone = input.PhoneNumber != null && input.PhoneNumber != undefined;;
        let showSign = input.Signature != null && input.Signature != undefined;
        let showBtns = showControl;
        init(showPhone, showSign, showBtns);
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
            phonebox.innerHTML = "Phone No.: " + input.PhoneNumber;
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

function init(phonebox, signaturebox, btns)
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
    if (btns)
    {
        let RedoBtn = document.createElement("button");
        RedoBtn.style.height = "50px";
        RedoBtn.style.width = "100%";
        RedoBtn.style.backgroundColor = "indianred";
        RedoBtn.textContent = "Redo Input";
        RedoBtn.id = "RedoBtn";
        RedoBtn.innerHTML = "<svg style=\"height: 100%; color: #00800000;\" fill=\"none\" stroke=\"darkred\" stroke-width=\"1.5\" viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\" aria-hidden=\"true\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636\"></path></svg>";
        RedoBtn.addEventListener("click", () => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("RedoInput",[]));
        let OkBtn = document.createElement("button");
        OkBtn.style.height = "50px";
        OkBtn.style.width = "100%";
        OkBtn.style.backgroundColor = "darkseagreen";
        OkBtn.id = "OkBtn";
        OkBtn.innerHTML = "<svg style=\"height: 100%; color: #00800000;\" fill=\"none\" stroke=\"darkolivegreen\" stroke-width=\"1.5\" viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\" aria-hidden=\"true\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M4.5 12.75l6 6 9-13.5\"></path></svg>";
        OkBtn.addEventListener("click", () => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OkInput",[]));
        gridlayout.appendChild(RedoBtn);
        gridlayout.appendChild(OkBtn);
    }
    body.appendChild(gridlayout);
}