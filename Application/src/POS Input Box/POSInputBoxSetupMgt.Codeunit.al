codeunit 6060105 "NPR POS Input Box Setup Mgt."
{
    Access = Internal;


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Default POS Input Box Sales Setup';

    [IntegrationEvent(false, false)]
    internal procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    begin
    end;

    procedure InitDefaultEanBoxSetup()
    var
        EanBoxSetup: Record "NPR Ean Box Setup";
    begin
        if not EanBoxSetup.Get(DefaultSalesSetupCode()) then begin
            EanBoxSetup.Init();
            EanBoxSetup.Code := DefaultSalesSetupCode();
            EanBoxSetup.Description := Text000;
            EanBoxSetup."POS View" := EanBoxSetup."POS View"::Sale;
            EanBoxSetup.Insert(true);

            InitEanBoxSetupEvent(EanBoxSetup, 'ITEMNO');
            InitEanBoxSetupEvent(EanBoxSetup, 'ITEMCROSSREFERENCENO');
        end;
    end;

    local procedure InitEanBoxSetupEvent(EanBoxSetup: Record "NPR Ean Box Setup"; EventCode: Code[20])
    var
        EanBoxEvent: Record "NPR Ean Box Event";
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
    begin
        if EanBoxSetupEvent.Get(EanBoxSetup.Code, EventCode) then
            exit;
        if not EanBoxEvent.Get(EventCode) then
            exit;

        EanBoxSetupEvent.Init();
        EanBoxSetupEvent.Validate("Setup Code", EanBoxSetup.Code);
        EanBoxSetupEvent.Validate("Event Code", EventCode);
        EanBoxSetupEvent.Enabled := true;
        EanBoxSetupEvent.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Ean Box Event", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEanBoxEvent(var Rec: Record "NPR Ean Box Event"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitEanBoxEventParameters(Rec);
    end;

    procedure InitEanBoxEventParameters(EanBoxEvent: Record "NPR Ean Box Event")
    var
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
        EanBoxParameter: Record "NPR Ean Box Parameter";
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        POSActionParameter.SetRange("POS Action Code", EanBoxEvent."Action Code");
        if POSActionParameter.IsEmpty or (EanBoxEvent."Action Code" = '') then begin
            EanBoxParameter.SetRange("Event Code", EanBoxEvent.Code);
            if EanBoxParameter.FindFirst() then
                EanBoxParameter.DeleteAll();

            exit;
        end;

        EanBoxParameter.Reset();
        EanBoxParameter.SetRange("Event Code", EanBoxEvent.Code);
        if EanBoxParameter.FindSet() then
            repeat
                EanBoxParameter.Mark(true);
            until EanBoxParameter.Next() = 0;

        POSActionParameter.FindSet();
        repeat
            EanBoxSetupEvent."Setup Code" := '';
            EanBoxSetupEvent."Event Code" := EanBoxEvent.Code;
            InitEanBoxSetupEventParameter(EanBoxSetupEvent, POSActionParameter, EanBoxParameter);

            EanBoxSetupEvent.SetRange("Event Code", EanBoxEvent.Code);
            if EanBoxSetupEvent.FindSet() then
                repeat
                    InitEanBoxSetupEventParameter(EanBoxSetupEvent, POSActionParameter, EanBoxParameter);
                until EanBoxSetupEvent.Next() = 0;
        until POSActionParameter.Next() = 0;

        EanBoxParameter.MarkedOnly(true);
        if EanBoxParameter.FindFirst() then
            EanBoxParameter.DeleteAll();

        OnInitEanBoxParameters(EanBoxEvent);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Ean Box Setup Event", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertEanBoxSetupEvent(var Rec: Record "NPR Ean Box Setup Event"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitEanBoxSetupEventParameters(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Ean Box Setup Event", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyEanBoxSetupEvent(var Rec: Record "NPR Ean Box Setup Event"; var xRec: Record "NPR Ean Box Setup Event"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitEanBoxSetupEventParameters(Rec);
    end;

    procedure InitEanBoxSetupEventParameters(EanBoxSetupEvent: Record "NPR Ean Box Setup Event")
    var
        EanBoxEvent: Record "NPR Ean Box Event";
        EanBoxParameter: Record "NPR Ean Box Parameter";
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        POSActionParameter.SetRange("POS Action Code", EanBoxSetupEvent."Action Code");
        if POSActionParameter.IsEmpty or (EanBoxSetupEvent."Action Code" = '') or not EanBoxEvent.Get(EanBoxSetupEvent."Event Code") then begin
            EanBoxParameter.SetRange("Setup Code", EanBoxSetupEvent."Setup Code");
            EanBoxParameter.SetRange("Event Code", EanBoxSetupEvent."Event Code");
            if EanBoxParameter.FindFirst() then
                EanBoxParameter.DeleteAll();

            exit;
        end;

        EanBoxParameter.Reset();
        EanBoxParameter.SetRange("Setup Code", EanBoxSetupEvent."Setup Code");
        EanBoxParameter.SetRange("Event Code", EanBoxSetupEvent."Event Code");
        if EanBoxParameter.FindSet() then
            repeat
                EanBoxParameter.Mark(true);
            until EanBoxParameter.Next() = 0;

        POSActionParameter.FindSet();
        repeat
            InitEanBoxSetupEventParameter(EanBoxSetupEvent, POSActionParameter, EanBoxParameter);
        until POSActionParameter.Next() = 0;

        EanBoxParameter.MarkedOnly(true);
        if EanBoxParameter.FindFirst() then
            EanBoxParameter.DeleteAll();

        OnInitEanBoxParameters(EanBoxEvent);
    end;

    local procedure InitEanBoxSetupEventParameter(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; POSActionParameter: Record "NPR POS Action Parameter"; var EanBoxParameter: Record "NPR Ean Box Parameter")
    var
        PrevRec: Text;
    begin
        if EanBoxParameter.Get(EanBoxSetupEvent."Setup Code", EanBoxSetupEvent."Event Code", POSActionParameter."POS Action Code", POSActionParameter.Name) then begin
            EanBoxParameter.Mark(false);
            PrevRec := Format(EanBoxParameter);

            EanBoxParameter."Data Type" := POSActionParameter."Data Type";
            EanBoxParameter."Default Value" := POSActionParameter."Default Value";
            EanBoxParameter.Options := POSActionParameter.Options;

            if PrevRec <> Format(EanBoxParameter) then begin
                EanBoxParameter.Value := EanBoxParameter."Default Value";
                EanBoxParameter.OptionValueInteger := -1;
                EanBoxParameter.Modify(true);
            end;
        end else begin
            EanBoxParameter.Init();
            EanBoxParameter."Setup Code" := EanBoxSetupEvent."Setup Code";
            EanBoxParameter."Event Code" := EanBoxSetupEvent."Event Code";
            EanBoxParameter."Action Code" := POSActionParameter."POS Action Code";
            EanBoxParameter.Name := POSActionParameter.Name;
            EanBoxParameter."Data Type" := POSActionParameter."Data Type";
            EanBoxParameter."Default Value" := POSActionParameter."Default Value";
            EanBoxParameter.Options := POSActionParameter.Options;
            EanBoxParameter.Value := POSActionParameter."Default Value";
            EanBoxParameter.OptionValueInteger := -1;
            EanBoxParameter.Insert(true);
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnInitEanBoxParameters(EanBoxEvent: Record "NPR Ean Box Event")
    begin
    end;

    procedure SetNonEditableParameterValues(EanBoxEvent: Record "NPR Ean Box Event"; Name: Text; EanBoxValue: Boolean; Value: Text)
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
        PrevRec: Text;
    begin
        if StrLen(Name) > MaxStrLen(EanBoxParameter.Name) then
            exit;

        EanBoxParameter.SetRange("Event Code", EanBoxEvent.Code);
        EanBoxParameter.SetRange(Name, Name);
        if not EanBoxParameter.FindSet() then
            exit;

        repeat
            PrevRec := Format(EanBoxParameter);

            EanBoxParameter."Ean Box Value" := EanBoxValue;
            EanBoxParameter."Non Editable" := true;
            EanBoxParameter.Validate(Value, CopyStr(Value, 1, MaxStrLen(Value)));

            if PrevRec <> Format(EanBoxParameter) then
                EanBoxParameter.Modify(true);
        until EanBoxParameter.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnAfterActionUpdated', '', true, true)]
    local procedure OnAfterPOSActionUpdated("Action": Record "NPR POS Action")
    var
        EanBoxEvent: Record "NPR Ean Box Event";
    begin
        EanBoxEvent.SetRange("Action Code", Action.Code);
        if EanBoxEvent.IsEmpty then
            exit;

        EanBoxEvent.FindSet();
        repeat
            InitEanBoxEventParameters(EanBoxEvent);
        until EanBoxEvent.Next() = 0;
    end;

    procedure DefaultSalesSetupCode(): Code[10]
    begin
        exit('SALE');
    end;
}

