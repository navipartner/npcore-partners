codeunit 6059889 "Npm Validation Mgt."
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterGetDatabaseTableTriggerSetup', '', false, false)]
    local procedure OnAfterGetDatabaseTableTriggerSetup(TableId: Integer;var OnDatabaseInsert: Boolean;var OnDatabaseModify: Boolean;var OnDatabaseDelete: Boolean;var OnDatabaseRename: Boolean)
    var
        NpmTable: Record "Npm View";
        DataLogSetupTable: Record "Data Log Setup (Table)";
    begin
        NpmTable.SetRange("Table No.",TableId);
        NpmTable.SetFilter("Mandatory Field Qty.",'>%1',0);
        if NpmTable.IsEmpty then
          exit;

        OnDatabaseModify := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseModify', '', false, false)]
    local procedure OnDatabaseModify(RecRef: RecordRef)
    begin
        ValidatePageViews(RecRef);
    end;

    local procedure ValidatePageViews(RecRef: RecordRef)
    var
        NpmView: Record "Npm View";
    begin
        NpmView.SetRange("Table No.",RecRef.Number);
        if NpmView.IsEmpty then
          exit;

        NpmView.FindSet;
        repeat
          ValidatePageView(NpmView,RecRef);
        until NpmView.Next = 0;
    end;

    local procedure ValidatePageView(NpmView: Record "Npm View";RecRef: RecordRef)
    begin
        if not RecInPageView(NpmView,RecRef) then
          exit;

        ValidateMandatoryFields(NpmView,RecRef);
    end;

    local procedure RecInPageView(NpmView: Record "Npm View";RecRef: RecordRef): Boolean
    var
        "Field": Record "Field";
        NpmViewCondition: Record "Npm View Condition";
        TempRecRef: RecordRef;
        FieldRef: FieldRef;
        TempFieldRef: FieldRef;
    begin
        if NpmView."Table No." <> RecRef.Number then
          exit(false);

        NpmViewCondition.SetRange("Table No.",NpmView."Table No.");
        NpmViewCondition.SetRange("View Code",NpmView.Code);
        if NpmViewCondition.IsEmpty then
          exit(false);

        Clear(TempRecRef);
        TempRecRef.Open(RecRef.Number,true);
        TempRecRef.SetPosition(RecRef.GetPosition);
        NpmViewCondition.FindSet;
        repeat
          if Field.Get(NpmViewCondition."Table No.",NpmViewCondition."Field No.") then begin
            FieldRef := RecRef.Field(NpmViewCondition."Field No.");
            TempFieldRef := TempRecRef.Field(NpmViewCondition."Field No.");
            TempFieldRef.Value := FieldRef.Value;
            TempFieldRef.SetFilter(NpmViewCondition.Value);
          end;
        until NpmViewCondition.Next = 0;

        TempRecRef.Insert;
        exit(TempRecRef.FindFirst);
    end;

    local procedure ValidateMandatoryFields(NpmView: Record "Npm View";RecRef: RecordRef)
    var
        NpmField: Record "Npm Field";
        "Field": Record "Field";
        FieldRef: FieldRef;
    begin
        NpmField.SetRange(Type,NpmField.Type::Mandatory);
        NpmField.SetRange("Table No.",NpmView."Table No.");
        NpmField.SetRange("View Code",NpmView.Code);
        if NpmField.IsEmpty then
          exit;

        NpmField.FindSet;
        repeat
          if Field.Get(NpmField."Table No.",NpmField."Field No.") then begin
            FieldRef := RecRef.Field(Field."No.");
            FieldRef.TestField;
          end;
        until NpmField.Next = 0;
    end;
}

