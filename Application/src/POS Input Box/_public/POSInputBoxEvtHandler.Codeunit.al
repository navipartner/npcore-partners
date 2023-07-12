codeunit 6060107 "NPR POS Input Box Evt Handler"
{
    var
        Text000: Label 'Ambigous input, please specify.';
        Text001: Label '"%1" not found.';
        OverMaxLenTextLbl: Label 'Text "%1" has more then max allowed %2 characters.', Comment = '%1-text, %2-max character no.';
        StartTime: DateTime;
        SelectEanStartTime: DateTime;
        SelectEanEndTime: DateTime;

    [Obsolete('Only necessary to for v1/v2 workflow. Remove when everything is migrated to v3.', 'NPR23.0')]
    internal procedure InvokeEanBox(EanBoxValue: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management")
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
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        EanBoxSetupMgt: Codeunit "NPR POS Input Box Setup Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        CurrView: Codeunit "NPR POS View";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") then;

        POSSession.GetCurrentView(CurrView);
        case CurrView.GetType() of
            CurrView.GetType() ::Sale:
                begin
                    if POSUnit."Ean Box Sales Setup" = '' then
                        POSUnit."Ean Box Sales Setup" := EanBoxSetupMgt.DefaultSalesSetupCode();
                    if not EanBoxSetup.Get(POSUnit."Ean Box Sales Setup") then
                        exit(false);

                    exit(EanBoxSetup."POS View" = EanBoxSetup."POS View"::Sale);
                end;
            CurrView.GetType() ::Payment:
                begin
                    if POSUnit."Ean Box Payment Setup" = '' then
                        exit(false);
                    if not EanBoxSetup.Get(POSUnit."Ean Box Payment Setup") then
                        exit(false);

                    exit(EanBoxSetup."POS View" = EanBoxSetup."POS View"::Payment);
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
        if not EanBoxSetupEvent.FindSet() then
            exit;

        repeat
            InScope := false;
            SetEanBoxEventInScope(EanBoxSetupEvent, EanBoxValue, InScope);
            if InScope then begin
                TempEanBoxSetupEvent.Init();
                TempEanBoxSetupEvent := EanBoxSetupEvent;
                TempEanBoxSetupEvent.Insert();
            end;
        until EanBoxSetupEvent.Next() = 0;

        exit(TempEanBoxSetupEvent.FindFirst());
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
        if not TempEanBoxSetupEvent.FindFirst() then
            exit(false);
        TempEanBoxSetupEvent.SetRange(Priority, TempEanBoxSetupEvent.Priority);
        case TempEanBoxSetupEvent.Count() of
            0:
                exit(false);
            1:
                exit(true);
        end;

        TempEanBoxSetupEvent.FindSet();
        repeat
            TempEanBoxSetupEvent.CalcFields("Event Description", "Module Name");
            MenuString += TempEanBoxSetupEvent."Event Description" + ' (' + TempEanBoxSetupEvent."Module Name" + '),';

            i += 1;
            TempRetailList.Init();
            TempRetailList.Number := i;
            TempRetailList.Choice := TempEanBoxSetupEvent."Setup Code";
            TempRetailList.Value := TempEanBoxSetupEvent."Event Code";
            TempRetailList.Insert();
        until TempEanBoxSetupEvent.Next() = 0;
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
        if not TempEanBoxSetupEvent.FindSet() then
            exit;

        repeat
            if EanBoxSetupEvent.Get(TempEanBoxSetupEvent."Setup Code", TempEanBoxSetupEvent."Event Code") then begin
                TempEanBoxSetupEvent.Priority := EanBoxSetupEvent.Priority;
                TempEanBoxSetupEvent.Modify();
            end;
        until TempEanBoxSetupEvent.Next() = 0;
    end;


    [Obsolete('Only necessary to for v1/v2 workflow. Remove when everything is migrated to v3.', 'NPR23.0')]
    internal procedure InvokePOSAction(EanBoxValue: Text; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSAction: Record "NPR POS Action";
    begin
        if EanBoxSetupEvent."Action Code" = '' then
            exit(false);

        if not POSSession.RetrieveSessionAction(EanBoxSetupEvent."Action Code", POSAction) then
            POSAction.Get(EanBoxSetupEvent."Action Code");

        if (POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY) then
            SetPOSActionParameters(EanBoxValue, EanBoxSetupEvent, POSAction, FrontEnd)
        else
            SetPOSActionParametersV3(EanBoxValue, EanBoxSetupEvent, POSAction);

        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure SetPOSActionParametersV3(EanBoxValue: Text; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; var POSAction: Record "NPR POS Action")
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        EanBoxParameter.SetRange("Setup Code", EanBoxSetupEvent."Setup Code");
        EanBoxParameter.SetRange("Event Code", EanBoxSetupEvent."Event Code");
        if not EanBoxParameter.FindSet() then
            exit;

        repeat
            SetPOSActionParameterV3(EanBoxValue, EanBoxParameter, POSAction);
        until EanBoxParameter.Next() = 0;
    end;

    local procedure SetPOSActionParameters(EanBoxValue: Text; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; var POSAction: Record "NPR POS Action"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        EanBoxParameter.SetRange("Setup Code", EanBoxSetupEvent."Setup Code");
        EanBoxParameter.SetRange("Event Code", EanBoxSetupEvent."Event Code");
        if not EanBoxParameter.FindSet() then
            exit;

        repeat
            SetPOSActionParameter(EanBoxValue, EanBoxParameter, POSAction, FrontEnd);
        until EanBoxParameter.Next() = 0;
    end;

    local procedure SetPOSActionParameterV3(EanBoxValue: Text; EanBoxParameter: Record "NPR Ean Box Parameter"; var POSAction: Record "NPR POS Action")
    var
        IntBuffer: Integer;
        DecBuffer: Decimal;
        Value: Text;
    begin
        Value := EanBoxParameter.Value;
        if EanBoxParameter."Ean Box Value" then
            Value := EanBoxValue;

        case EanBoxParameter."Data Type" of
            EanBoxParameter."Data Type"::Option:
                begin
                    POSAction.SetWorkflowInvocationParameterUnsafe(EanBoxParameter.Name, EanBoxParameter.OptionValueInteger);
                end;
            EanBoxParameter."Data Type"::Boolean:
                begin
                    POSAction.SetWorkflowInvocationParameterUnsafe(EanBoxParameter.Name, LowerCase(Value) in ['yes', '1', 'true']);
                end;
            EanBoxParameter."Data Type"::Decimal:
                begin
                    Evaluate(DecBuffer, Value);
                    POSAction.SetWorkflowInvocationParameterUnsafe(EanBoxParameter.Name, DecBuffer);
                end;
            EanBoxParameter."Data Type"::Integer:
                begin
                    Evaluate(IntBuffer, Value);
                    POSAction.SetWorkflowInvocationParameterUnsafe(EanBoxParameter.Name, IntBuffer);
                end;
            else
                POSAction.SetWorkflowInvocationParameterUnsafe(EanBoxParameter.Name, Value);
        end;
    end;

    local procedure SetPOSActionParameter(EanBoxValue: Text; EanBoxParameter: Record "NPR Ean Box Parameter"; var POSAction: Record "NPR POS Action"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        IntBuffer: Integer;
        DecBuffer: Decimal;
    begin
        if EanBoxParameter."Ean Box Value" then begin
            if StrLen(EanBoxValue) > MaxStrLen(EanBoxParameter.Value) then
                Error(OverMaxLenTextLbl, EanBoxValue, MaxStrLen(EanBoxParameter.Value));
            EanBoxParameter.Value := CopyStr(EanBoxValue, 1, MaxStrLen(EanBoxParameter.Value));
        end;

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

    internal procedure GetEanBox(EanBoxValue: Text; var POSAction: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management"; var SetupCode: Code[20]; var EventCode: Code[20])
    var
        EanBoxSetup: Record "NPR Ean Box Setup";
        TempEanBoxSetupEvent: Record "NPR Ean Box Setup Event" temporary;
        ActionCodeMissingErr: label 'For Ean Box Event %1 %2 Action Code is missing.';
    begin
        LogStartTelem(); //log Ean Scanned

        FrontEnd.SetOption('doNotClearTextBox', false);
        if not FindEanBoxSetup(POSSession, EanBoxSetup) then
            Error(Text001, EanBoxValue);

        if not FindEnabledEanBoxEvents(EanBoxSetup, EanBoxValue, TempEanBoxSetupEvent) then
            Error(Text001, EanBoxValue);

        LogStartSelectEanTelem(); //log time before select Ean

        if not SelectEanBoxEvent(TempEanBoxSetupEvent) then
            Error(Text001, EanBoxValue);

        LogEndSelectEanTelem(); //log time after select Ean

        if TempEanBoxSetupEvent."Action Code" = '' then
            Error(ActionCodeMissingErr, TempEanBoxSetupEvent."Setup Code", TempEanBoxSetupEvent."Event Code");

        if not POSSession.RetrieveSessionAction(TempEanBoxSetupEvent."Action Code", POSAction) then
            POSAction.Get(TempEanBoxSetupEvent."Action Code");

        SetupCode := TempEanBoxSetupEvent."Setup Code";
        EventCode := TempEanBoxSetupEvent."Event Code";

        LogFinishTelem(EanBoxValue, POSAction.Code); //log time after POS Action is found

    end;

    internal procedure ResolveEanBoxActionForValue(EanBoxValue: Text; POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management"; var POSAction: Record "NPR POS Action")
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

        SetParameterValuesForAction(EanBoxValue, TempEanBoxSetupEvent, POSSession, FrontEnd, POSAction);
    end;

    internal procedure SetParameterValuesForAction(EanBoxValue: Text; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var POSAction: Record "NPR POS Action"): Boolean
    begin
        if EanBoxSetupEvent."Action Code" = '' then
            exit(false);

        if not POSSession.RetrieveSessionAction(EanBoxSetupEvent."Action Code", POSAction) then
            POSAction.Get(EanBoxSetupEvent."Action Code");

        if (POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY) then
            SetPOSActionParameters(EanBoxValue, EanBoxSetupEvent, POSAction, FrontEnd)
        else
            SetPOSActionParametersV3(EanBoxValue, EanBoxSetupEvent, POSAction);
    end;

    internal procedure SetEanParametersToPOSAction(EanBoxValue: Text; var POSAction: Record "NPR POS Action"; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"): Boolean
    begin
        SetPOSActionParametersV3(EanBoxValue, EanBoxSetupEvent, POSAction);
    end;

    local procedure LogStartSelectEanTelem()
    begin
        SelectEanStartTime := CurrentDateTime();
    end;

    local procedure LogEndSelectEanTelem()
    begin
        SelectEanEndTime := CurrentDateTime();
    end;

    local procedure LogStartTelem()
    begin
        StartTime := CurrentDateTime();
    end;

    local procedure LogFinishTelem(ScannedValue: Text; POSActionCode: Code[20])
    var
        FinishEventIdTok: Label 'NPR_EanBoxValuePOSAction', Locked = true;
        LogDict: Dictionary of [Text, Text];
        MsgTok: Label 'Company:%1, Tenant: %2, Instance: %3, Server: %4, POSAction:%5, Duration: %6';
        Msg: Text;
        ActiveSession: Record "Active Session";
        SelectEanDuration: Duration;
        POSActionDiscovered: Duration;
        DurationMs: Integer;
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        POSActionDiscovered := CurrentDateTime() - StartTime;
        SelectEanDuration := SelectEanEndTime - SelectEanStartTime;
        if SelectEanDuration <> 0 then
            POSActionDiscovered := POSActionDiscovered - SelectEanDuration;
        DurationMs := POSActionDiscovered;

        LogDict.Add('NPR_Server', ActiveSession."Server Computer Name");
        LogDict.Add('NPR_Instance', ActiveSession."Server Instance Name");
        LogDict.Add('NPR_TenantId', Database.TenantId());
        LogDict.Add('NPR_CompanyName', CompanyName());
        LogDict.Add('NPR_UserID', ActiveSession."User ID");
        LogDict.Add('NPR_ScannedValue', ScannedValue);
        LogDict.Add('NPR_DurationMs', Format(DurationMs, 0, 9));
        LogDict.Add('NPR_SelectEanDurationMs', Format(SelectEanDuration));
        LogDict.add('NPR_ActionCode', POSActionCode);
        Msg := StrSubstNo(MsgTok, CompanyName(), Database.TenantId(), ActiveSession."Server Instance Name", ActiveSession."Server Computer Name", POSActionCode, Format(DurationMs, 0, 9));

        Session.LogMessage(FinishEventIdTok, 'EanBoxScanned: ' + Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LogDict);
    end;


}
