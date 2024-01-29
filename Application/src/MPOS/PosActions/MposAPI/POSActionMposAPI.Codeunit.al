codeunit 6060073 "NPR POS Action: Mpos API" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        LblActionDesc: Label 'Mpos API, simplifies calls to the mPOS device.';
        LblInvokeTypeError: Label 'No Such InvokeType for Mpos. This is a programming Error.';
        LblNotMposDevice: Label 'This device does not support Mpos calls. Make sure you are on a Mpos device.';
    begin
        WorkflowConfig.AddActionDescription(LblActionDesc);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('LblInvokeTypeError', LblInvokeTypeError);
        WorkflowConfig.AddLabel('LblNotMposDevice', LblNotMposDevice);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMposAPI.js### 
'let main=async({context:n,captions:d,popup:o})=>{let t=n.InvokeType??null,r=n.FunctionName??null,s=n.FunctionArgument??null;try{debugger;var a=navigator.userAgent||navigator.vendor||window.opera;let e=null;if(/android/i.test(a)?e="ANDROID":/iPad|iPhone|iPod|Macintosh/i.test(a)&&!window.MSStream&&(e="IOS"),!e)throw new Error(d.LblNotMposDevice);switch(t){case"FUNCTION":let w={FunctionName:r,FunctionParameter:s};switch(e){case"ANDROID":if(!window.top.jsBridge||!window.top.jsBridge.invokeFunction)throw new Error;return JSON.parse(await window.top.jsBridge.invokeFunction(JSON.stringify(w)));case"IOS":if(!window.top.webkit||!window.top.webkit.messageHandlers||!window.top.webkit.messageHandlers.invokeFunction)throw new Error;return JSON.parse(await window.top.webkit.messageHandlers.invokeFunction.postMessage(w))}break;case"ACTION":let i={RequestMethod:r};switch(i=Object.assign(i,s),e){case"ANDROID":if(!window.top.jsBridge||!window.top.jsBridge.invokeAction)throw new Error;if(window.top.jsBridge)await window.top.jsBridge.invokeAction(JSON.stringify(i));else try{await window.top.mpos.invokeAction(JSON.stringify(i))}catch{await window.top.mpos.handleBackendMessage(jsonObject)}break;case"IOS":if(!window.top.webkit||!window.top.webkit.messageHandlers||!window.top.webkit.messageHandlers.invokeAction)throw new Error;await window.top.webkit.messageHandlers.invokeAction.postMessage(i);break}break;default:o.error("The MPOS Api has been called with invalid InvokeOptions. This is a programming error, please contact your vendor.","Programming Error");break}}catch(e){if(t==="FUNCTION")return{IsSuccessful:!1,ErrorMessage:e.message,Result:null};o.error(e.message,"mPOS Error")}};'
        )
    end;
}

