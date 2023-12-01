codeunit 6184546 "NPR POS Action: HD Input" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        HtmlReq: Codeunit "NPR POS HTML Disp. Req";
        ActionDescription: Label 'Html Display: Collect input from customer display.';
        ErrPOSEntryNotSelected: Label 'No POS Entry selected.';
        ErrPOSEntryInputExists: Label 'Input has already been collected for this POS Entry.';
        ErrPOSEntryUndefined: Label 'Undefined behavior when selecting POS Entry.';
        ErrUnknownOperation: Label 'Undefined operation.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ErrPOSEntryNotSelected', ErrPOSEntryNotSelected);
        WorkflowConfig.AddLabel('ErrPOSEntryInputExists', ErrPOSEntryInputExists);
        WorkflowConfig.AddLabel('ErrPOSEntryUndefined', ErrPOSEntryUndefined);
        WorkflowConfig.AddLabel('ErrUnknownOperation', ErrUnknownOperation);
        WorkflowConfig.AddLabel('HtmlDisplayVersion', Format(HtmlReq.HtmlDisplayVersion()));

    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        ValidationPage: Page "NPR POS HTML Validate Input";
        POSUnit: Record "NPR POS Unit";
        HtmlProfile: Record "NPR POS HTML Disp. Prof.";
        POSEntry: Record "NPR POS Entry";
        Json: JsonObject;
        Request: JsonObject;
        InputObj: JsonObject;
        HtmlDispCU: Codeunit "NPR POS HTML Disp. Prof.";
        HtmlReq: Codeunit "NPR POS Html Disp. Req";
        HtmlResp: Codeunit "NPR POS Html Disp. Resp";
        ValidationResult: Text;
        UserCanceledInput: Label 'Input was canceled.';


    begin
        case Step of
            'PrepareInputRequest':
                begin
                    if (SelectPOSEntry(POSEntry, Setup.GetPOSUnitNo())) then begin
                        if (POSEntry.CalcFields("Costumer Input") and POSEntry."Costumer Input") then begin
                            Json.Add('Result', 'INPUT_EXISTS');
                        end else begin
                            Setup.GetPOSUnit(POSUnit);
                            HtmlProfile.Get(POSUnit."POS HTML Display Profile");
                            HtmlReq.InputRequest(Request, HtmlProfile);
                            Json.Add('Result', 'GET_INPUT');
                            Context.SetContext('POSEntryNo', POSEntry."Entry No.");
                            Context.SetContext('Request', Request);
                        end;
                    end else begin
                        Json.Add('Result', 'NOT_SELECTED');
                    end;
                    FrontEnd.WorkflowResponse(Json);
                end;
            'InputCollected':
                begin
                    Context.GetJObject(Json);
                    HtmlResp.ParseGetInputResponse(Json, InputObj);
                    POSEntry.Get(Context.GetInteger('POSEntryNo'));
                    ValidationResult := ValidationPage.ValidateInput(InputObj);
                    clear(Json);
                    if (ValidationResult = 'OK') then begin
                        HtmlDispCU.EnterCustomerInput(InputObj, POSEntry);
                        Json.Add('ReCollectInput', False);
                    end;
                    if (ValidationResult = 'REDO') then
                        Json.Add('ReCollectInput', True);
                    if (ValidationResult = 'CANCEL') then begin
                        Message(UserCanceledInput);
                        Json.Add('ReCollectInput', False);
                    end;
                    Frontend.WorkflowResponse(Json);
                end;
            'UpdateReceiptView':
                begin
                    HtmlReq.UpdateReceiptRequest(Request);
                    Json.Add('Request', Request);
                    FrontEnd.WorkflowResponse(Json);
                end;
        end;

    end;

    local procedure SelectPOSEntry(var POSEntry: Record "NPR POS Entry"; UnitCodeNo: Code[10]): Boolean
    begin
        POSEntry.Reset();
        POSEntry.SetFilter("Document No.", '<>%1', '');
        POSEntry.SetFilter("POS Unit No.", '=%1', UnitCodeNo);
        POSEntry.SetCurrentKey("Entry No.");
        POSEntry.SetAscending("Entry No.", false);
        exit(page.runmodal(page::"NPR POS Entry List", POSEntry) = Action::LookupOK);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:PosActionHtmlDispInput.js### 
'let main=async({context:a,popup:e,captions:t})=>{a.HtmlDisplayVersion=Number.parseInt(t.HtmlDisplayVersion);let w=null;try{switch((await workflow.respond("PrepareInputRequest")).Result){case"GET_INPUT":break;case"NOT_SELECTED":e.error(t.ErrPOSEntryNotSelected);return;case"INPUT_EXISTS":e.error(t.ErrPOSEntryInputExists);return;default:e.error(t.ErrPOSEntryUndefined);return}let r=null,c=!1;await new Promise(async(o,u)=>{try{async function l(){r=await e.simplePayment({title:"Collect Signature",initialStatus:"awaiting customer",showStatus:!0,amountStyle:{fontSize:"0px"},abortEnabled:!0,onAbort:async()=>{c=!0,await hwc.invoke("HTMLDisplay",{Cancel:!0,Version:a.HtmlDisplayVersion})}});debugger;let s=await hwc.invoke("HTMLDisplay",a.Request);if(r.close(),!s.IsSuccessfull&&s.Error==="Cancel")return o();(await workflow.respond("InputCollected",s)).ReCollectInput?setTimeout(l,200):o()}l()}catch(l){u(l)}finally{r&&r.close()}});let i=await workflow.respond("UpdateReceiptView");i.Request&&await hwc.invoke("HTMLDisplay",i.Request)}catch(n){e.error(n)}};'
        );
    end;
}
