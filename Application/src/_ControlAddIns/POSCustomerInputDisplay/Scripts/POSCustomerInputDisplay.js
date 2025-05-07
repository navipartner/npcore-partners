function SendInputDataAndLabelV2(input, showControl, approveLbl, redoLbl, phoneLbl, noInputLbl)
{
    try{
        debugger;
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
function GetSignatureWidthAndHeight(points) {
    let topMost = null;
    let leftMost = null;
    let rightMost = null;
    let botMost = null;
    
    // Check if points is a flat array or already properly nested
    let processedPoints = points;
    
    // If this is a flat array of points (not a 2D array), convert it to the expected format
    if (points.length > 0 && !Array.isArray(points[0])) {
        // Create a single stroke containing all points
        processedPoints = [points];
    }
    
    // Now process using the nested structure
    for (let i = 0; i < processedPoints.length; i++) {
        for (let j = 0; j < processedPoints[i].length; j++) {
            let point = processedPoints[i][j];
            
            // Skip terminator point if present
            if (point.x === "FFFF" && point.y === "FFFF") {
                continue;
            }
            
            if (topMost === null || topMost.y > point.y) {
                topMost = point;
            }
            if (leftMost === null || leftMost.x > point.x) {
                leftMost = point;
            }
            if (rightMost === null || rightMost.x < point.x) {
                rightMost = point;
            }
            if (botMost === null || botMost.y < point.y) {
                botMost = point;
            }
        }
    }
    
    // Check if we have valid points
    if (topMost === null || leftMost === null || rightMost === null || botMost === null) {
        return { startPoint: { x: 0, y: 0 }, width: 0, height: 0 };
    }
    
    let w = rightMost.x - leftMost.x;
    let h = botMost.y - topMost.y;
    return { startPoint: { x: leftMost.x, y: topMost.y }, width: w, height: h };
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
    const transformedSignature = points.map((point) => {
        if (point.x !== undefined && point.y !== undefined) {
          return {
            X: point.x,
            Y: point.y,
          };
        }
        return point;
      });
 
      if (canvas.getContext) {
        const ctx = canvas.getContext("2d");
        ctx.lineWidth = 3;
 
        if (transformedSignature.length > 1) {
          let maxX = -Infinity,
            maxY = -Infinity,
            minX = Infinity,
            minY = Infinity;
 
          for (const point of transformedSignature) {
            const x = parseInt(point.X, 16);
            const y = parseInt(point.Y, 16);
            if (x !== 65535 && y !== 65535) {
              minX = Math.min(minX, x);
              maxX = Math.max(maxX, x);
              minY = Math.min(minY, y);
              maxY = Math.max(maxY, y);
            }
          }
 
          const canvasWidth = canvas.width;
          const canvasHeight = canvas.height;
 
          const scaleX = canvasWidth / (maxX - minX);
          const scaleY = canvasHeight / (maxY - minY);
          const scale = Math.min(scaleX, scaleY) * 0.9;
 
          const offsetX = (canvasWidth - (maxX - minX) * scale) / 2;
          const offsetY = (canvasHeight - (maxY - minY) * scale) / 2;
 
          ctx.beginPath();
          let firstDot = null;
 
          for (const point of transformedSignature) {
            const x = parseInt(point.X, 16);
            const y = parseInt(point.Y, 16);
 
            if (x !== 65535 && y !== 65535) {
              const scaledX = (x - minX) * scale + offsetX;
              const scaledY = (y - minY) * scale + offsetY;
 
              // eslint-disable-next-line max-depth
              if (!firstDot) {
                ctx.moveTo(scaledX, scaledY);
                firstDot = true;
              } else {
                ctx.lineTo(scaledX, scaledY);
              }
            } else {
              firstDot = null;
            }
          }
          ctx.stroke();
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