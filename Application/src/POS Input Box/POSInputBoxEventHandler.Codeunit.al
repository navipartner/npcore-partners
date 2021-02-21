codeunit 6060107 "NPR POS Input Box Evt Handler"
{
    var
        Text000: Label 'Ambigous input, please specify.';
        Text001: Label '"%1" not found.';

    procedure InvokeEanBox(EanBoxValue: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EanBoxSetup: Record "NPR Ean Box Setup";
        TempEanBoxSetupEvent: Record "NPR Ean Box Setup Event" temporary;
    begin
        FrontEnd.SetOption('doNotClearTextBox', false);
        if not FindEanBoxSetup(POSSession, EanBoxSetup) then begin
            Message(Text001, EanBoxValue);
            exit;
        end;

        if not FindEnabledEanBoxEvents(EanBoxSetup, EanBoxValue, TempEanBoxSetupEvent) then begin
            Message(Text001, EanBoxValue);
            exit;
        end;

        if not SelectEanBoxEvent(TempEanBoxSetupEvent) then
            exit;

        InvokePOSAction(EanBoxValue, TempEanBoxSetupEvent, POSSession, FrontEnd);

        POSSession.RequestRefreshData();
    end;

    local procedure FindEanBoxSetup(POSSession: Codeunit "NPR POS Session"; var EanBoxSetup: Record "NPR Ean Box Setup"): Boolean
    var
        SalePOS: Record "NPR Sale POS";
        POSUnit: Record "NPR POS Unit";
        EanBoxSetupMgt: Codeunit "NPR POS Input Box Setup Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        CurrView: Codeunit "NPR POS View";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") then;

        POSSession.GetCurrentView(CurrView);
        case CurrView.Type of
            CurrView.Type::Sale:
                begin
                    if POSUnit."Ean Box Sales Setup" = '' then
                        POSUnit."Ean Box Sales Setup" := EanBoxSetupMgt.DefaultSalesSetupCode();
                    if not EanBoxSetup.Get(POSUnit."Ean Box Sales Setup") then
                        exit(false);

                    exit(EanBoxSetup."POS View" = EanBoxSetup."POS View"::Sale);
                end;
        end;

        exit(false);
    end;

    local procedure FindEnabledEanBoxEvents(EanBoxSetup: Record "NPR Ean Box Setup"; EanBoxValue: Text; var TempEanBoxSetupEvent: Record "NPR Ean Box Setup Event" temporary): Boolean
    var
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
        InScope: Boolean;
    begin
        EanBoxSetupEvent.SetRange("Setup Code", EanBoxSetup.Code);
        EanBoxSetupEvent.SetRange(Enabled, true);
        if not EanBoxSetupEvent.FindSet then
            exit;

        repeat
            InScope := false;
            SetEanBoxEventInScope(EanBoxSetupEvent, EanBoxValue, InScope);
            if InScope then begin
                TempEanBoxSetupEvent.Init;
                TempEanBoxSetupEvent := EanBoxSetupEvent;
                TempEanBoxSetupEvent.Insert;
            end;
        until EanBoxSetupEvent.Next = 0;

        exit(TempEanBoxSetupEvent.FindFirst);
    end;

    [IntegrationEvent(false, false)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
    end;

    local procedure SelectEanBoxEvent(var TempEanBoxSetupEvent: Record "NPR Ean Box Setup Event" temporary): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        MenuSelected: Integer;
        MenuString: Text;
        i: Integer;
    begin
        UpdatePriority(TempEanBoxSetupEvent);
        TempEanBoxSetupEvent.SetCurrentKey(Priority);
        if not TempEanBoxSetupEvent.FindFirst then
            exit(false);
        TempEanBoxSetupEvent.SetRange(Priority, TempEanBoxSetupEvent.Priority);
        case TempEanBoxSetupEvent.Count of
            0:
                exit(false);
            1:
                exit(true);
        end;

        TempEanBoxSetupEvent.FindSet;
        repeat
            TempEanBoxSetupEvent.CalcFields("Event Description", "Module Name");
            MenuString += TempEanBoxSetupEvent."Event Description" + ' (' + TempEanBoxSetupEvent."Module Name" + '),';

            i += 1;
            TempRetailList.Init;
            TempRetailList.Number := i;
            TempRetailList.Choice := TempEanBoxSetupEvent."Setup Code";
            TempRetailList.Value := TempEanBoxSetupEvent."Event Code";
            TempRetailList.Insert;
        until TempEanBoxSetupEvent.Next = 0;
        MenuString := DelStr(MenuString, StrLen(MenuString));

        MenuSelected := StrMenu(MenuString, 1, Text000);
        if not TempRetailList.Get(MenuSelected) then
            exit(false);

        exit(TempEanBoxSetupEvent.Get(TempRetailList.Choice, TempRetailList.Value));
    end;

    local procedure UpdatePriority(var TempEanBoxSetupEvent: Record "NPR Ean Box Setup Event" temporary)
    var
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
    begin
        if not TempEanBoxSetupEvent.FindSet then
            exit;

        repeat
            if EanBoxSetupEvent.Get(TempEanBoxSetupEvent."Setup Code", TempEanBoxSetupEvent."Event Code") then begin
                TempEanBoxSetupEvent.Priority := EanBoxSetupEvent.Priority;
                TempEanBoxSetupEvent.Modify;
            end;
        until TempEanBoxSetupEvent.Next = 0;
    end;

    procedure InvokePOSAction(EanBoxValue: Text; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSAction: Record "NPR POS Action";
    begin
        if EanBoxSetupEvent."Action Code" = '' then
            exit(false);

        if not POSSession.RetrieveSessionAction(EanBoxSetupEvent."Action Code", POSAction) then
            POSAction.Get(EanBoxSetupEvent."Action Code");

        SetPOSActionParameters(EanBoxValue, EanBoxSetupEvent, POSAction, FrontEnd);
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure SetPOSActionParameters(EanBoxValue: Text; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; var POSAction: Record "NPR POS Action"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        EanBoxParameter.SetRange("Setup Code", EanBoxSetupEvent."Setup Code");
        EanBoxParameter.SetRange("Event Code", EanBoxSetupEvent."Event Code");
        if not EanBoxParameter.FindSet then
            exit;

        repeat
            SetPOSActionParameter(EanBoxValue, EanBoxParameter, POSAction, FrontEnd);
        until EanBoxParameter.Next = 0;
    end;

    local procedure SetPOSActionParameter(EanBoxValue: Text; EanBoxParameter: Record "NPR Ean Box Parameter"; var POSAction: Record "NPR POS Action"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        IntBuffer: Integer;
        DecBuffer: Decimal;
    begin
        if EanBoxParameter."Ean Box Value" then
            EanBoxParameter.Value := EanBoxValue;

        case EanBoxParameter."Data Type" of
            EanBoxParameter."Data Type"::Option:
                begin
                    POSAction.SetWorkflowInvocationParameter(EanBoxParameter.Name, EanBoxParameter.OptionValueInteger, FrontEnd);
                end;
            EanBoxParameter."Data Type"::Boolean:
                begin
                    POSAction.SetWorkflowInvocationParameter(EanBoxParameter.Name, LowerCase(EanBoxParameter.Value) in ['yes', '1', 'true'], FrontEnd);
                end;
            EanBoxParameter."Data Type"::Decimal:
                begin
                    Evaluate(DecBuffer, EanBoxParameter.Value);
                    POSAction.SetWorkflowInvocationParameter(EanBoxParameter.Name, DecBuffer, FrontEnd);
                end;
            EanBoxParameter."Data Type"::Integer:
                begin
                    Evaluate(IntBuffer, EanBoxParameter.Value);
                    POSAction.SetWorkflowInvocationParameter(EanBoxParameter.Name, IntBuffer, FrontEnd);
                end;
            else
                POSAction.SetWorkflowInvocationParameter(EanBoxParameter.Name, EanBoxParameter.Value, FrontEnd);
        end;
    end;
}
