codeunit 6150709 "POS Action Parameter Mgt."
{
    // NPR5.40/VB  /20180228 CASE 306347 This is a completely new object, replacing the old object that was dropped in this release.
    // NPR5.40/MMV /20180309 CASE 307453 String performance


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'There are no action parameters to edit for %1, %2, and action %3 does not define any parameters to copy from.';
        Text002: Label 'There are no action parameters defined for %1, %2. Do you want to insert the default parameters and their values?';

    procedure EditParametersForField(ActionCode: Code[20];RecordID: RecordID;FieldNo: Integer)
    var
        ParamValue: Record "POS Parameter Value";
        ActionParam: Record "POS Action Parameter";
        RecRef: RecordRef;
        EditParams: Page "POS Parameter Values";
    begin
        if ActionCode = '' then
          exit;

        RecRef.Get(RecordID);

        ParamValue.FilterGroup(4);
        ParamValue.SetRange("Table No.",RecRef.Number);
        ParamValue.SetRange("Record ID",RecordID);
        ParamValue.SetRange(ID,FieldNo);
        ParamValue.FilterGroup(0);
        if ParamValue.IsEmpty then begin
          ActionParam.SetRange("POS Action Code",ActionCode);
          if ActionParam.IsEmpty then begin
            Message(Text001,RecRef.Caption,RecRef.Field(FieldNo).Caption,ActionCode);
            exit;
          end;
          if not Confirm(Text002,true,RecRef.Caption,RecRef.Field(FieldNo).Caption) then
            exit;
          CopyFromActionToField(ActionCode,RecordID,FieldNo);
          Commit;
        end;

        EditParams.SetTableView(ParamValue);
        EditParams.RunModal();
    end;

    procedure ClearParametersForRecord(RecordIDToClear: RecordID;FieldIDToClear: Integer)
    var
        ParamValue: Record "POS Parameter Value";
        RecRef: RecordRef;
    begin
        if not RecRef.Get(RecordIDToClear) then
          exit;

        with ParamValue do begin
          SetRange("Table No.",RecRef.Number);
          SetRange("Record ID",RecRef.RecordId);
          if FieldIDToClear > 0 then
            SetRange(ID,FieldIDToClear);
          DeleteAll();
        end;
    end;

    local procedure CopyFromAction(ActionParam: Record "POS Action Parameter";var ToRec: Record "POS Parameter Value")
    begin
        with ToRec do begin
          Name := ActionParam.Name;
          "Action Code" := ActionParam."POS Action Code";
          "Data Type" := ActionParam."Data Type";
          Value := ActionParam."Default Value";
          Insert;
        end;
    end;

    procedure CopyFromActionToMenuButton(ActionCode: Code[20];MenuButton: Record "POS Menu Button")
    var
        "Action": Record "POS Action";
        ActionParam: Record "POS Action Parameter";
        ParamValue: Record "POS Parameter Value";
    begin
        if not Action.Get(ActionCode) then
          exit;

        ActionParam.SetRange("POS Action Code",ActionCode);
        if ActionParam.FindSet then
          repeat
            ParamValue.InitForMenuButton(MenuButton);
            CopyFromAction(ActionParam,ParamValue);
          until ActionParam.Next = 0;
    end;

    procedure CopyFromActionToField(ActionCode: Code[20];RecordID: RecordID;FieldID: Integer)
    var
        "Action": Record "POS Action";
        ActionParam: Record "POS Action Parameter";
        ParamValue: Record "POS Parameter Value";
    begin
        if not Action.Get(ActionCode) then
          exit;

        ActionParam.SetRange("POS Action Code",ActionCode);
        if ActionParam.FindSet then
          repeat
            ParamValue.InitForField(RecordID,FieldID);
            CopyFromAction(ActionParam,ParamValue);
          until ActionParam.Next = 0;
    end;

    procedure SplitString(Text: Text;var Parts: DotNet npNetArray)
    var
        String: DotNet npNetString;
        Char: DotNet npNetString;
    begin
        String := Text;
        Char := ',';
        //-NPR5.40 [307453]
        // Separators := Separators.CreateInstance(GETDOTNETTYPE(Char),1);
        // Separators.SetValue(Char,0);
        // Parts := String.Split(Separators);
        Parts := String.Split(Char.ToCharArray());
        //+NPR5.40 [307453]
    end;

    procedure RefreshParameters(RecordID: RecordID;"Code": Code[20];FieldID: Integer;ActionCode: Code[20])
    var
        ActionParam: Record "POS Action Parameter";
        ParamValue: Record "POS Parameter Value";
        RecRef: RecordRef;
        Update: Boolean;
    begin
        RecRef.Get(RecordID);

        // 1st pass: insert new parameters for action and replace existing parameters where data type has changed
        ActionParam.SetRange("POS Action Code",ActionCode);
        if ActionParam.FindSet then
          repeat
            ParamValue."Table No." := RecRef.Number;
            ParamValue.Code := Code;
            ParamValue.ID := FieldID;
            ParamValue."Record ID" := RecordID;
            ParamValue.Name := ActionParam.Name;

            Update := false;
            if not ParamValue.Find then begin
              ParamValue.Insert;
              Update := true;
            end else
              if ParamValue."Data Type" <> ActionParam."Data Type" then
                Update := true;

            if Update then begin
              ParamValue."Action Code" := ActionCode;
              ParamValue."Data Type" := ActionParam."Data Type";
              ParamValue.Value := ActionParam."Default Value";
              ParamValue.Modify;
            end;
          until ActionParam.Next = 0;

        // 2nd pass: remove old parameters that are not present in action parameters anymore
        ParamValue.FilterParameters(RecordID,FieldID);
        if ParamValue.FindSet(true) then
          repeat
            if not ActionParam.Get(ParamValue."Action Code",ParamValue.Name) then
              ParamValue.Delete;
          until ParamValue.Next = 0;
    end;

    procedure RefreshParametersRequired(RecordID: RecordID;"Code": Code[20];FieldID: Integer;ActionCode: Code[20]): Boolean
    var
        ActionParam: Record "POS Action Parameter";
        ParamValue: Record "POS Parameter Value";
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        // Record defines deprecated parameters
        ParamValue.FilterParameters(RecordID,FieldID);
        if ParamValue.FindSet then
          repeat
            if not ActionParam.Get(ParamValue."Action Code",ParamValue.Name) then
              exit(true);
          until ParamValue.Next = 0;

        // Record does not define actual parameters or defines a parameter with incorrect data type
        ActionParam.SetRange("POS Action Code",ActionCode);
        if ActionParam.FindSet then
          repeat
            ParamValue."Table No." := RecRef.Number;
            ParamValue.Code := Code;
            ParamValue.ID := FieldID;
            ParamValue."Record ID" := RecordID;
            ParamValue.Name := ActionParam.Name;
            if (not ParamValue.Find) or (ParamValue."Data Type" <> ActionParam."Data Type") then
              exit(true);
          until ActionParam.Next = 0;

        exit(false);
    end;
}

