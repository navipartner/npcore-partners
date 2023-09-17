codeunit 6060073 "NPR POS Action: Mpos API" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        FunctionOptions: Text;
        FunctionOptionsName: Text;
        FunctionOptionsDesc: Text;
    begin
        WorkflowConfig.AddActionDescription(ActionDescription());
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetActionCode(ActionCode());
        FunctionOptions := 'Mock';
        FunctionOptionsName := 'Functionality';
        FunctionOptionsDesc := 'Defines which functionality to call on MPOS.';
        WorkflowConfig.AddOptionParameter(
            CopyStr(FunctionOptionsName, 1, 30), CopyStr(FunctionOptions, 1, 250), '', FunctionOptionsName, FunctionOptionsDesc, FunctionOptions);
        WorkflowConfig.AddTextParameter('Parameters', '', 'Mpos function Parameter', 'Specifies the parameter to the functionality called');
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

    end;

    local procedure ActionDescription(): Text
    begin
        exit('MPOS API, this workflow simplifies the calls to the MPOS and paramerters define what is requested on MPOS');
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::MPOS_API));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMposAPI.js### 
'let main=async({workflow:n,parameters:e,context:o,popup:l})=>{let s=null,t=o.IsFromWorkflow===!0;var u=navigator.userAgent||navigator.vendor||window.opera;try{if(/android/i.test(u))s="ANDROID";else if(/iPad|iPhone|iPod|Macintosh/i.test(u)&&!window.MSStream)s="IOS";else throw new Error("This action does not work on non-MPOS Devices");let i=["Mock"],r=null,w=t?o.FunctionName:i[Number(e.Functionality)],d=t?o.FunctionParameter:e.Parameters,a={FunctionName:w,FunctionParameter:d};if(a=JSON.stringify(a),r=await SendToApp(s,a),t)return r;n.respond(w,{mposResponse:r})}catch(i){if(t)return{IsSuccessful:!1,ErrorMessage:i.message,Result:null};l.error(i.message,"mPOS Error")}};async function SendToApp(n,e){let o=''<div style="text-align: left;"><p>This device does not support this feature.<br/>Known reasons:<br/>-If you are running iOS version < 14.0.<br/>-The app is not updated.</p></div>'';if(n==="ANDROID"){if(window.top.jsBridge&&window.top.jsBridge.invokeFunction)return JSON.parse(await window.top.jsBridge.invokeFunction(e));throw Error(o)}else if(n==="IOS"){if(window.top.webkit&&window.top.webkit.messageHandlers&&window.top.webkit.messageHandlers.invokeFunction&&window.top.webkit.messageHandlers.invokeFunction.postMessage)return JSON.parse(await window.top.webkit.messageHandlers.invokeFunction.postMessage(e));throw Error(o)}}function Debug(n,e){try{n==="ANDROID"?window.top.jsBridge.debug(e):n==="IOS"&&window.webkit.messageHandlers.debug.postMessage(e)}catch{}}'
        )
    end;
}

