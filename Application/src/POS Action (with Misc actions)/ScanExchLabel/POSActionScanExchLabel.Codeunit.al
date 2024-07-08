codeunit 6150830 "NPR POS Action: ScanExchLabel" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        InpTitle: Label 'Exchange Label';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a build in function to handle exchange labels.';
        ParamPromptForBarCode_CptLbl: Label 'Prompt for Barcode';
        ParamPromptForBarCode_DescLbl: Label 'Defines if Prompt Barcode will show On action.';
        ParamExchLabelBarCode_CptLbl: Label 'Exchange Label Barcode';
        ParamExchLabelBarCode_DescLbl: Label 'Predefined exchange label barcode.';
        InpLead: Label 'Enter Exchange Label Barcode';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('PromptForBarcode', false, ParamPromptForBarCode_CptLbl, ParamPromptForBarCode_DescLbl);
        WorkflowConfig.AddTextParameter('ExchLabelBarcode', '', ParamExchLabelBarCode_CptLbl, ParamExchLabelBarCode_DescLbl);
        WorkflowConfig.AddLabel('InpTitle', InpTitle);
        WorkflowConfig.AddLabel('InpLead', InpLead);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'ExchangeLabelBarCode':
                ExchangeLabelBarCode(Context, Sale, SaleLine);
        end;
    end;

    local procedure ExchangeLabelBarCode(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        ExchLabelBarcode: Text;
        InputExchLabelBarcode: Text;
        PromptForBarcode: Boolean;
        POSActionScanExchLabelB: Codeunit "NPR POS Action:ScanExchLabel B";
    begin
        PromptForBarcode := Context.GetBooleanParameter('PromptForBarcode');

        if not PromptForBarcode then begin
            ExchLabelBarcode := Context.GetStringParameter('ExchLabelBarcode');
            if ExchLabelBarcode = '' then
                exit
        end else begin
            InputExchLabelBarcode := Context.GetString('ExchBarCode');
            ExchLabelBarcode := InputExchLabelBarcode;
        end;

        POSActionScanExchLabelB.HandleExchangeLabelBarcode(ExchLabelBarcode, Sale, SaleLine);
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::EXCHANGELABEL));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        if not EanBoxEvent.Get(EventCodeExchLabel()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeExchLabel();
            EanBoxEvent."Module Name" := InpTitle;
            EanBoxEvent.Description := CopyStr(ExchangeLabel.FieldCaption(Barcode), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeExchLabel():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ExchLabelBarcode', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'PromptForBarcode', false, 'false');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeExchLabel(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ExchangeLabel: Record "NPR Exchange Label";
        POSActionScanExchLabelB: Codeunit "NPR POS Action:ScanExchLabel B";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeExchLabel() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(ExchangeLabel.Barcode) then
            exit;

        if POSActionScanExchLabelB.BarCodeIsExchangeLabel(EanBoxValue) then
            InScope := true;
    end;

    local procedure EventCodeExchLabel(): Code[20]
    begin
        exit('EXCHLABEL');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: ScanExchLabel");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionScanExchLabel.js###
'let main=async({workflow:e,popup:n,captions:a,parameters:r})=>{if(r.PromptForBarcode){let t=await n.input({title:a.InpTitle,caption:a.InpLead});if(t===null)return" ";await e.respond("ExchangeLabelBarCode",{ExchBarCode:t})}else await e.respond("ExchangeLabelBarCode")};'
  );
    end;
}
