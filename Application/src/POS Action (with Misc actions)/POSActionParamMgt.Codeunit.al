codeunit 6150709 "NPR POS Action Param. Mgt."
{
    var
        Text001: Label 'There are no action parameters to edit for %1, %2, and action %3 does not define any parameters to copy from.';
        Text002: Label 'There are no action parameters defined for %1, %2. Do you want to insert the default parameters and their values?';

    procedure EditParametersForField(ActionCode: Code[20]; RecordID: RecordID; FieldNo: Integer)
    var
        ParamValue: Record "NPR POS Parameter Value";
        ActionParam: Record "NPR POS Action Parameter";
        RecRef: RecordRef;
        EditParams: Page "NPR POS Parameter Values";
    begin
        if ActionCode = '' then
            exit;

        RecRef.Get(RecordID);

        ParamValue.FilterGroup(4);
        ParamValue.SetRange("Table No.", RecRef.Number);
        ParamValue.SetRange("Record ID", RecordID);
        ParamValue.SetRange(ID, FieldNo);
        ParamValue.FilterGroup(0);
        if ParamValue.IsEmpty then begin
            ActionParam.SetRange("POS Action Code", ActionCode);
            if ActionParam.IsEmpty then begin
                Message(Text001, RecRef.Caption, RecRef.Field(FieldNo).Caption, ActionCode);
                exit;
            end;
            if not Confirm(Text002, true, RecRef.Caption, RecRef.Field(FieldNo).Caption) then
                exit;
            CopyFromActionToField(ActionCode, RecordID, FieldNo);
            Commit();
        end;

        EditParams.SetTableView(ParamValue);
        EditParams.RunModal();
    end;

    procedure ClearParametersForRecord(RecordIDToClear: RecordID; FieldIDToClear: Integer)
    var
        ParamValue: Record "NPR POS Parameter Value";
        RecRef: RecordRef;
    begin
        if not RecRef.Get(RecordIDToClear) then
            exit;

        ParamValue.SetRange("Table No.", RecRef.Number);
        ParamValue.SetRange("Record ID", RecRef.RecordId);
        if FieldIDToClear > 0 then
            ParamValue.SetRange(ID, FieldIDToClear);
        ParamValue.DeleteAll();
    end;

    local procedure CopyFromAction(ActionParam: Record "NPR POS Action Parameter"; var ToRec: Record "NPR POS Parameter Value")
    begin
        ToRec.Name := ActionParam.Name;
        ToRec."Action Code" := ActionParam."POS Action Code";
        ToRec."Data Type" := ActionParam."Data Type";
        ToRec.Value := ActionParam."Default Value";
        ToRec.Insert();
    end;

    procedure CopyFromActionToMenuButton(ActionCode: Code[20]; MenuButton: Record "NPR POS Menu Button")
    var
        "Action": Record "NPR POS Action";
        ActionParam: Record "NPR POS Action Parameter";
        ParamValue: Record "NPR POS Parameter Value";
    begin
        if not Action.Get(ActionCode) then
            exit;

        ActionParam.SetRange("POS Action Code", ActionCode);
        if ActionParam.FindSet() then
            repeat
                ParamValue.InitForMenuButton(MenuButton);
                CopyFromAction(ActionParam, ParamValue);
            until ActionParam.Next() = 0;
    end;

    procedure CopyFromActionToField(ActionCode: Code[20]; RecordID: RecordID; FieldID: Integer)
    var
        "Action": Record "NPR POS Action";
        ActionParam: Record "NPR POS Action Parameter";
        ParamValue: Record "NPR POS Parameter Value";
    begin
        if not Action.Get(ActionCode) then
            exit;

        ActionParam.SetRange("POS Action Code", ActionCode);
        if ActionParam.FindSet() then
            repeat
                ParamValue.InitForField(RecordID, FieldID);
                CopyFromAction(ActionParam, ParamValue);
            until ActionParam.Next() = 0;
    end;

    procedure SplitString(Text: Text; var Parts: List of [Text])
    begin
        Parts := Text.Split(',');
    end;

    procedure RefreshParameters(RecordID: RecordID; "Code": Code[20]; FieldID: Integer; ActionCode: Code[20])
    var
        ActionParam: Record "NPR POS Action Parameter";
        ParamValue: Record "NPR POS Parameter Value";
        RecRef: RecordRef;
        Update: Boolean;
    begin
        RecRef.Get(RecordID);

        // 1st pass: insert new parameters for action and replace existing parameters where data type has changed
        ActionParam.SetRange("POS Action Code", ActionCode);
        if ActionParam.FindSet() then
            repeat
                ParamValue."Table No." := RecRef.Number;
                ParamValue.Code := Code;
                ParamValue.ID := FieldID;
                ParamValue."Record ID" := RecordID;
                ParamValue.Name := ActionParam.Name;

                Update := false;
                if not ParamValue.Find() then begin
                    ParamValue.Insert();
                    Update := true;
                end else
                    if ParamValue."Data Type" <> ActionParam."Data Type" then
                        Update := true;

                if Update then begin
                    ParamValue."Action Code" := ActionCode;
                    ParamValue."Data Type" := ActionParam."Data Type";
                    ParamValue.Value := ActionParam."Default Value";
                    ParamValue.Modify();
                end;
            until ActionParam.Next() = 0;

        // 2nd pass: remove old parameters that are not present in action parameters anymore
        ParamValue.FilterParameters(RecordID, FieldID);
        if ParamValue.FindSet(true) then
            repeat
                if not ActionParam.Get(ParamValue."Action Code", ParamValue.Name) then
                    ParamValue.Delete();
            until ParamValue.Next() = 0;
    end;

    procedure RefreshParametersRequired(RecordID: RecordID; "Code": Code[20]; FieldID: Integer; ActionCode: Code[20]): Boolean
    var
        ActionParam: Record "NPR POS Action Parameter";
        ParamValue: Record "NPR POS Parameter Value";
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        // Record defines deprecated parameters
        ParamValue.FilterParameters(RecordID, FieldID);
        if ParamValue.FindSet() then
            repeat
                if not ActionParam.Get(ParamValue."Action Code", ParamValue.Name) then
                    exit(true);
            until ParamValue.Next() = 0;

        // Record does not define actual parameters or defines a parameter with incorrect data type
        ActionParam.SetRange("POS Action Code", ActionCode);
        if ActionParam.FindSet() then
            repeat
                ParamValue."Table No." := RecRef.Number;
                ParamValue.Code := Code;
                ParamValue.ID := FieldID;
                ParamValue."Record ID" := RecordID;
                ParamValue.Name := ActionParam.Name;
                if (not ParamValue.Find()) or (ParamValue."Data Type" <> ActionParam."Data Type") then
                    exit(true);
            until ActionParam.Next() = 0;

        exit(false);
    end;

    procedure GetParametersAsJson(RecordID: RecordID; FieldID: Integer): Text
    var
        ParamValue: Record "NPR POS Parameter Value";
        JObject: JsonObject;
        JObjectTextValue: Text;
        JParamLbl: Label '{"parameters" : %1}', Locked = true;
    begin
        JObject.ReadFrom('{}');

        ParamValue.FilterParameters(RecordID, FieldID);
        if (ParamValue.FindSet()) then
            repeat
                ParamValue.AddParameterToJObject(JObject);
            until (ParamValue.Next() = 0);

        JObject.WriteTo(JObjectTextValue);
        exit(StrSubstNo(JParamLbl, JObjectTextValue));
    end;
}
