codeunit 6151175 "NPR POS Action: Change LineAm." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action is used to change line amount VIA EAN Box events';
        ParamNewLineAmt_CptLbl: Label 'New Line Amount';
        ParamNewLineAmt_DescLbl: Label 'Defines a new line amount';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddDecimalParameter('NewLineAmount', 0, ParamNewLineAmt_CptLbl, ParamNewLineAmt_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        BusinessLogic: Codeunit "NPR POS Action:Change LineAm B";
        LineAmount: Decimal;
    begin
        LineAmount := Context.GetDecimalParameter('NewLineAmount');
        case Step of
            'ChangeAmount':
                BusinessLogic.ChangeAmount(LineAmount, SaleLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not EanBoxEvent.Get(EanEventCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EanEventCode();
            EanBoxEvent."Module Name" := CopyStr(SaleLinePOS.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(SaleLinePOS.FieldCaption(Amount), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: Change LineAm.";
            EanBoxEvent.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if EanBoxEvent.Code = EanEventCode() then
            Sender.SetNonEditableParameterValues(EanBoxEvent, 'NewLineAmount', true, '0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Amount: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> EanEventCode() then
            exit;

        if StrPos(EanBoxValue, '+') > 1 then
            exit;

        EanBoxValue := CopyStr(EanBoxValue, 2);
        if EanBoxValue = '' then
            exit;

        InScope := Evaluate(Amount, EanBoxValue);
        Clear(Amount);
    end;

    local procedure EanEventCode(): Code[20]
    begin
        exit('saleprice');
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::CHANGE_AMOUNT));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionChangeLineAm.js###
'let main=async({})=>await workflow.respond("ChangeAmount");'
        )
    end;
}
