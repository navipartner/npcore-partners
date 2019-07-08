codeunit 6060105 "Ean Box Setup Mgt."
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.34/TSA /20170724 CASE 284798 Corrected Spelling of publisher: IdentifyThisCodePublisher
    // NPR5.36/ANEN  /20170901 CASE 288703 Adding fcn. SetDispenserExitCode and GetDispenserExitCode
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Default Ean Box Sales Setup';

    [IntegrationEvent(false, false)]
    procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    begin
    end;

    local procedure "--- Init Default Setup"()
    begin
    end;

    procedure InitDefaultEanBoxSetup()
    var
        EanBoxSetup: Record "Ean Box Setup";
    begin
        if not EanBoxSetup.Get(DefaultSalesSetupCode()) then begin
          EanBoxSetup.Init;
          EanBoxSetup.Code := DefaultSalesSetupCode;
          EanBoxSetup.Description := Text000;
          EanBoxSetup."POS View" := EanBoxSetup."POS View"::Sale;
          EanBoxSetup.Insert(true);

          InitEanBoxSetupEvent(EanBoxSetup,'ITEMNO');
          InitEanBoxSetupEvent(EanBoxSetup,'ITEMCROSSREFERENCENO');
        end;
    end;

    local procedure InitEanBoxSetupEvent(EanBoxSetup: Record "Ean Box Setup";EventCode: Code[20])
    var
        EanBoxEvent: Record "Ean Box Event";
        EanBoxSetupEvent: Record "Ean Box Setup Event";
    begin
        if EanBoxSetupEvent.Get(EanBoxSetup.Code,EventCode) then
          exit;
        if not EanBoxEvent.Get(EventCode) then
          exit;

        EanBoxSetupEvent.Init;
        EanBoxSetupEvent.Validate("Setup Code",EanBoxSetup.Code);
        EanBoxSetupEvent.Validate("Event Code",EventCode);
        EanBoxSetupEvent.Enabled := true;
        EanBoxSetupEvent.Insert(true);
    end;

    local procedure "--- Init Parameters"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6060106, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEanBoxEvent(var Rec: Record "Ean Box Event";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;

        InitEanBoxEventParameters(Rec);
    end;

    procedure InitEanBoxEventParameters(EanBoxEvent: Record "Ean Box Event")
    var
        EanBoxSetupEvent: Record "Ean Box Setup Event";
        EanBoxParameter: Record "Ean Box Parameter";
        POSActionParameter: Record "POS Action Parameter";
    begin
        POSActionParameter.SetRange("POS Action Code",EanBoxEvent."Action Code");
        if POSActionParameter.IsEmpty or (EanBoxEvent."Action Code" = '') then begin
          EanBoxParameter.SetRange("Event Code",EanBoxEvent.Code);
          if EanBoxParameter.FindFirst then
            EanBoxParameter.DeleteAll;

          exit;
        end;

        EanBoxParameter.Reset;
        EanBoxParameter.SetRange("Event Code",EanBoxEvent.Code);
        if EanBoxParameter.FindSet then
          repeat
            EanBoxParameter.Mark(true);
          until EanBoxParameter.Next = 0;

        POSActionParameter.FindSet;
        repeat
          EanBoxSetupEvent."Setup Code" := '';
          EanBoxSetupEvent."Event Code" := EanBoxEvent.Code;
          InitEanBoxSetupEventParameter(EanBoxSetupEvent,POSActionParameter,EanBoxParameter);

          EanBoxSetupEvent.SetRange("Event Code",EanBoxEvent.Code);
          if EanBoxSetupEvent.FindSet then
            repeat
              InitEanBoxSetupEventParameter(EanBoxSetupEvent,POSActionParameter,EanBoxParameter);
            until EanBoxSetupEvent.Next = 0;
        until POSActionParameter.Next = 0;

        EanBoxParameter.MarkedOnly(true);
        if EanBoxParameter.FindFirst then
          EanBoxParameter.DeleteAll;

        OnInitEanBoxParameters(EanBoxEvent);
    end;

    [EventSubscriber(ObjectType::Table, 6060107, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertEanBoxSetupEvent(var Rec: Record "Ean Box Setup Event";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;

        InitEanBoxSetupEventParameters(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6060107, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyEanBoxSetupEvent(var Rec: Record "Ean Box Setup Event";var xRec: Record "Ean Box Setup Event";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;

        InitEanBoxSetupEventParameters(Rec);
    end;

    procedure InitEanBoxSetupEventParameters(EanBoxSetupEvent: Record "Ean Box Setup Event")
    var
        EanBoxEvent: Record "Ean Box Event";
        EanBoxParameter: Record "Ean Box Parameter";
        POSActionParameter: Record "POS Action Parameter";
    begin
        POSActionParameter.SetRange("POS Action Code",EanBoxSetupEvent."Action Code");
        if POSActionParameter.IsEmpty or (EanBoxSetupEvent."Action Code" = '') or not EanBoxEvent.Get(EanBoxSetupEvent."Event Code") then begin
          EanBoxParameter.SetRange("Setup Code",EanBoxSetupEvent."Setup Code");
          EanBoxParameter.SetRange("Event Code",EanBoxSetupEvent."Event Code");
          if EanBoxParameter.FindFirst then
            EanBoxParameter.DeleteAll;

          exit;
        end;

        EanBoxParameter.Reset;
        EanBoxParameter.SetRange("Setup Code",EanBoxSetupEvent."Setup Code");
        EanBoxParameter.SetRange("Event Code",EanBoxSetupEvent."Event Code");
        if EanBoxParameter.FindSet then
          repeat
            EanBoxParameter.Mark(true);
          until EanBoxParameter.Next = 0;

        POSActionParameter.FindSet;
        repeat
          InitEanBoxSetupEventParameter(EanBoxSetupEvent,POSActionParameter,EanBoxParameter);
        until POSActionParameter.Next = 0;

        EanBoxParameter.MarkedOnly(true);
        if EanBoxParameter.FindFirst then
          EanBoxParameter.DeleteAll;

        OnInitEanBoxParameters(EanBoxEvent);
    end;

    local procedure InitEanBoxSetupEventParameter(EanBoxSetupEvent: Record "Ean Box Setup Event";POSActionParameter: Record "POS Action Parameter";var EanBoxParameter: Record "Ean Box Parameter")
    var
        PrevRec: Text;
    begin
        if EanBoxParameter.Get(EanBoxSetupEvent."Setup Code",EanBoxSetupEvent."Event Code",POSActionParameter."POS Action Code",POSActionParameter.Name) then begin
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
          EanBoxParameter.Init;
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
    local procedure OnInitEanBoxParameters(EanBoxEvent: Record "Ean Box Event")
    begin
    end;

    procedure SetNonEditableParameterValues(EanBoxEvent: Record "Ean Box Event";Name: Text;EanBoxValue: Boolean;Value: Text)
    var
        EanBoxParameter: Record "Ean Box Parameter";
        PrevRec: Text;
    begin
        if StrLen(Name) > MaxStrLen(EanBoxParameter.Name) then
          exit;

        EanBoxParameter.SetRange("Event Code",EanBoxEvent.Code);
        EanBoxParameter.SetRange(Name,Name);
        if not EanBoxParameter.FindSet then
          exit;

        repeat
          PrevRec := Format(EanBoxParameter);

          EanBoxParameter."Ean Box Value" := EanBoxValue;
          EanBoxParameter."Non Editable" := true;
          EanBoxParameter.Validate(Value,CopyStr(Value,1,MaxStrLen(Value)));

          if PrevRec <> Format(EanBoxParameter) then
            EanBoxParameter.Modify(true);
        until EanBoxParameter.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnAfterActionUpdated', '', true, true)]
    local procedure OnAfterPOSActionUpdated("Action": Record "POS Action")
    var
        EanBoxEvent: Record "Ean Box Event";
    begin
        EanBoxEvent.SetRange("Action Code",Action.Code);
        if EanBoxEvent.IsEmpty then
          exit;

        EanBoxEvent.FindSet;
        repeat
          InitEanBoxEventParameters(EanBoxEvent);
        until EanBoxEvent.Next = 0;
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure DefaultSalesSetupCode(): Code[10]
    begin
        exit('SALE');
    end;
}

