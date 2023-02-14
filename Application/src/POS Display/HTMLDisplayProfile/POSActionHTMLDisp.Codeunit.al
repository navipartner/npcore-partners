codeunit 6059903 "NPR POS Action: HTML Disp." implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        //Internal
        ActionDescription: Label 'HTML Display Actions for manual operations';
        NameCaption: Label 'Customer Display Operation';
        OptionCaption: Label 'Open,Close,Get Input';
        ErrPOSEntryNotSelected: Label 'No POS Entry selected.';
        ErrPOSEntryInputExists: Label 'Input has already been collected for this POS Entry.';
        ErrPOSEntryUndefined: Label 'Undefined behavior when selecting POS Entry.';
        ErrUnknownOperation: Label 'Undefined operation.';

        ActionName: Label 'CustomerDisplayOp', Locked = true;
        ActionOptions: Label 'OPEN,CLOSE,GET_INPUT', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(ActionName, ActionOptions, '', NameCaption, ActionDescription, OptionCaption);
        WorkflowConfig.AddLabel('ErrPOSEntryNotSelected', ErrPOSEntryNotSelected);
        WorkflowConfig.AddLabel('ErrPOSEntryInputExists', ErrPOSEntryInputExists);
        WorkflowConfig.AddLabel('ErrPOSEntryUndefined', ErrPOSEntryUndefined);
        WorkflowConfig.AddLabel('ErrUnknownOperation', ErrUnknownOperation);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        ValidationPage: Page "NPR POS HTML Validate Input";
        POSEntry: Record "NPR POS Entry";
        InputObj: JsonObject;
        HtmlDispCU: Codeunit "NPR POS HTML Disp. Prof.";
        ValidationResult: Text;
        UserCanceledInput: Label 'Input was canceled.';
    begin
        case Step of
            'POSEntryNo':
                begin
                    SelectPOSEntry(POSEntry, Setup.GetPOSUnitNo());
                    Context.SetContext('POSEntryNo', POSEntry."Entry No.");
                    FrontEnd.WorkflowResponse(ShouldGetInput(POSEntry));
                end;
            'InputCollected':
                begin
                    Context.GetJObject(InputObj);
                    POSEntry.Get(Context.GetInteger('POSEntryNo'));
                    ValidationResult := ValidationPage.ValidateInput(InputObj);
                    if (ValidationResult = 'OK') then begin
                        HtmlDispCU.EnterCustomerInput(InputObj, POSEntry);
                        FrontEnd.WorkflowResponse(True);
                    end;
                    if (ValidationResult = 'REDO') then
                        FrontEnd.WorkflowResponse(False);
                    if (ValidationResult = 'CANCEL') then begin
                        Message(UserCanceledInput);
                        FrontEnd.WorkflowResponse(True);
                    end;

                end;
        end;
    end;

    local procedure SelectPOSEntry(var POSEntry: Record "NPR POS Entry"; UnitCodeNo: Code[10])
    var
        prec: Page "NPR POS Entry List";
        tmpLookupMode: Boolean;
    begin
        POSEntry.Reset();
        POSEntry.SetFilter("Document No.", '<>%1', '');
        POSEntry.SetFilter("POS Unit No.", '=%1', UnitCodeNo);
        POSEntry.SetCurrentKey("Entry No.");
        POSEntry.SetAscending("Entry No.", false);
        prec.SetTableView(POSEntry);
        tmpLookupMode := prec.LookupMode;
        prec.LookupMode(true);
        if (prec.RunModal() = Action::LookupOK) then
            prec.GetRecord(POSEntry);
        prec.LookupMode(tmpLookupMode);
    end;

    local procedure ShouldGetInput(var POSEntry: Record "NPR POS Entry"): Text
    begin
        if (POSEntry."Entry No." = 0) then
            exit('NOT_SELECTED');
        if (POSEntry.CalcFields("Costumer Input") and POSEntry."Costumer Input") then
            exit('INPUT_EXISTS');
        exit('GET_INPUT');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHTMLDisp.Codeunit.js### 
'let main=async e=>{try{const{popup:r,captions:a,parameters:t}=e;switch(t.CustomerDisplayOp.toString()){case"OPEN":OpenCloseDisplay(!0);break;case"CLOSE":OpenCloseDisplay(!1);break;case"GET_INPUT":await CollectInput(e);break;default:r.error(a.ErrUnknownOperation+": ''"+t.CustomerDisplayOp.toString()+"''");break}}catch(r){popup.error(r)}};async function CollectInput(e){const{hwc:r,workflow:a,popup:t,captions:n}=e;switch(objParam={JSAction:"GetInput",InputType:"Phone & Signature"},await a.respond("POSEntryNo")){case"GET_INPUT":break;case"NOT_SELECTED":t.error(n.ErrPOSEntryNotSelected);return;case"INPUT_EXISTS":t.error(n.ErrPOSEntryInputExists);return;default:t.error(n.ErrPOSEntryUndefined);return}let o=!1;for(;!o;){let s=await r.invoke("HTMLDisplay",{DisplayAction:"SendJS",JSParameter:JSON.stringify(objParam)});o=await a.respond("InputCollected",s.JSON.Input)}}async function OpenCloseDisplay(e){await hwc.invoke("HTMLDisplay",{DisplayAction:e?"Open":"Close"})}'
        );
    end;
}
