codeunit 6184547 "NPR POS Action: HD Qr" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        HtmlReq: Codeunit "NPR POS HTML Disp. Req";
        ActionDescription: Label 'Html Display: Show/Hide QR code.';
        QR_Toggle_Name: Label 'QrShow', Locked = true;
        QR_Toggle_Caption: Label 'QR Toggle: Show/Hide';
        QR_Toggle_Desc: Label 'Specify the if the QR code should be displayed (true) or not (false).';
        QR_Title_Name: Label 'QrTitle', Locked = true;
        QR_Title_Caption: Label 'QR Toggle: Title';
        QR_Title_Desc: Label 'Specify the title displayed with the ''QR Toggle'' action';
        QR_Message_Name: Label 'QrMessage', Locked = true;
        QR_Message_Caption: Label 'QR Toggle: Message';
        QR_Message_Desc: Label 'Specify the message displayed with the ''QR Toggle'' action';
        QR_Content_Name: Label 'QrContent', Locked = true;
        QR_Content_Caption: Label 'QR Toggle: Content';
        QR_Content_Desc: Label 'Specify the content the QR code should contain with the ''QR Toggle'' action';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter(QR_Toggle_Name, False, QR_Toggle_Caption, QR_Toggle_Desc);
        WorkflowConfig.AddTextParameter(QR_Title_Name, '', QR_Title_Caption, QR_Title_Desc);
        WorkflowConfig.AddTextParameter(QR_Message_Name, '', QR_Message_Caption, QR_Message_Desc);
        WorkflowConfig.AddTextParameter(QR_Content_Name, '', QR_Content_Caption, QR_Content_Desc);
        WorkflowConfig.AddLabel('HtmlDisplayVersion', Format(HtmlReq.HtmlDisplayVersion()));
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin

    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:PosActionHtmlDispQr.js### 
'let main=async({context:r,parameters:s,captions:l})=>{r.HtmlDisplayVersion=Number.parseInt(l.HtmlDisplayVersion),r.IsNestedWorkflow||(r.QrShow=s.QrShow,r.QrTitle=s.QrTitle,r.QrMessage=s.QrMessage,r.QrContent=s.QrContent,r.IsNestedWorkflow=!1),r.QrShow??=!1,r.QrTitle??="",r.QrMessage??="",r.QrContent??="";let i=null;try{let e={HtmlDisplayVersion:r.HtmlDisplayVersion,DisplayAction:"SendJs",JsParameter:JSON.stringify({JSAction:"QRPaymentScan",Provider:r.QrTitle,PaymentAmount:r.QrMessage,QrContent:r.QrContent,Command:r.QrShow?"Open":"Close"})};i=await hwc.invoke("HTMLDisplay",e)}catch(e){r.IsNestedWorkflow||popup.error({title:"Customer Display Error: QR",message:`The ${r.QrShow?"Open":"Close"} operation failed with: ${e.message}`})}return i};'
        );
    end;
}
