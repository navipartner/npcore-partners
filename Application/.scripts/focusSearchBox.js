Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('SearchDimensions','');

function SetFocusOnField(FieldNo)
{
    window.parent.document.querySelector(`[controlname^='${FieldNo}'] input`).focus()
}


function SetFocusOnFieldPhone(FieldNo)
{
    var anchors = window.parent.document.getElementsByTagName('a');
    for (var i=0;i<anchors.length;i++) {
        if (anchors[i].innerHTML == FieldNo) {
            window.parent.document.querySelector(`#${anchors[i].parentNode.id} input`).focus(); 
        }
    }
}