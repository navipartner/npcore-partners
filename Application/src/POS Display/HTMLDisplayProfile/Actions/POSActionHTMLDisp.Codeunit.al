codeunit 6059903 "NPR POS Action: HTML Disp." implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        HtmlReq: Codeunit "NPR POS HTML Disp. Req";
        ActionDescription: Label 'HTML Display Actions for manual operations';
        OperationOptName: Label 'CustomerDisplayOp', Locked = true;
        OperationOptions: Label 'OPEN,UPDATE,CLOSE', Locked = true;
        OperationOptLabel: Label 'Customer Display Operation';
        OperationOptDescLabel: Label 'The operation to be used.';
        OperationsOptionsLabel: Label 'Open,Update,Close';
        DownloadMediaName: Label 'DownloadMedia', Locked = true;
        DownloadMediaLabel: Label 'Download Media';
        DownloadMediaDesc: Label 'Specify if the Media should be downloaded when opening the display';
        ScreenNoName: Label 'ScreenNo', Locked = true;
        ScreenNoLabel: Label 'Screen Number';
        ScreenNoDescLabel: Label 'Specify which screen the Customer Display should be displayed on when opening the display';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(OperationOptName, OperationOptions, '', OperationOptLabel, OperationOptDescLabel, OperationsOptionsLabel);
        WorkflowConfig.AddBooleanParameter(DownloadMediaName, False, DownloadMediaLabel, DownloadMediaDesc);
        WorkflowConfig.AddIntegerParameter(ScreenNoName, 1, ScreenNoLabel, ScreenNoDescLabel);
        WorkflowConfig.AddLabel('HtmlDisplayVersion', Format(HtmlReq.HtmlDisplayVersion()));
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup")
    var
        Json: JsonObject;
        Request: JsonObject;
        HtmlReq: Codeunit "NPR POS HTML Disp. Req";
    begin
        case Step of
            'UpdateRequest':
                begin
                    HtmlReq.UpdateReceiptRequest(Request);
                    Json.Add('Request', Request);
                    FrontEnd.WorkflowResponse(Json);

                end;
            'LocalMediaObject':
                begin
                    Request := HtmlReq.LocalMediaObject();
                    Json.Add('LocalMediaObject', Request);
                    FrontEnd.WorkflowResponse(Json);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHTMLDisp.Codeunit.js### 
'let main=async i=>{const{context:a,popup:s,captions:t,parameters:o}=i;try{a.HtmlDisplayVersion=Number.parseInt(t.HtmlDisplayVersion);let e=null;switch(String(o.CustomerDisplayOp)){case"OPEN":if(e={Version:a.HtmlDisplayVersion,DisplayAction:"Open",WindowScreenNo:o.ScreenNo},o.DownloadMedia){let l=await workflow.respond("LocalMediaObject");e.LocalMediaInfo=l.LocalMediaObject}break;case"UPDATE":e=(await workflow.respond("UpdateRequest")).Request;break;case"CLOSE":e={Version:a.HtmlDisplayVersion,DisplayAction:"Close"};break}await hwc.invoke("HTMLDisplay",e)}catch(e){s.error(e)}};'
        );
    end;
}
