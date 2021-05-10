page 6150646 "NPR POS Info Lookup"
{
    Caption = 'POS Info Lookup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Info Lookup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Field 1"; Rec."Field 1")
                {
                    ApplicationArea = All;
                    CaptionClass = Field1Caption;
                    ToolTip = 'Specifies the value of the Field 1 field';
                }
                field("Field 2"; Rec."Field 2")
                {
                    ApplicationArea = All;
                    CaptionClass = Field2Caption;
                    ToolTip = 'Specifies the value of the Field 2 field';
                }
                field("Field 3"; Rec."Field 3")
                {
                    ApplicationArea = All;
                    CaptionClass = Field3Caption;
                    ToolTip = 'Specifies the value of the Field 3 field';
                }
                field("Field 4"; Rec."Field 4")
                {
                    ApplicationArea = All;
                    CaptionClass = Field4Caption;
                    ToolTip = 'Specifies the value of the Field 4 field';
                }
                field("Field 5"; Rec."Field 5")
                {
                    ApplicationArea = All;
                    CaptionClass = Field5Caption;
                    ToolTip = 'Specifies the value of the Field 5 field';
                }
                field("Field 6"; Rec."Field 6")
                {
                    ApplicationArea = All;
                    CaptionClass = Field6Caption;
                    ToolTip = 'Specifies the value of the Field 6 field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if POSInfo."Input Type" = POSInfo."Input Type"::Table then
            LoadTable();
        if POSInfo."Input Type" = POSInfo."Input Type"::SubCode then
            LoadSubcodes();

        CurrPage.Update();
    end;

    var
        POSInfo: Record "NPR POS Info";
        Field1Caption: Text;
        Field2Caption: Text;
        Field3Caption: Text;
        Field4Caption: Text;
        Field5Caption: Text;
        Field6Caption: Text;
        ErrText001: Label 'You must define subcodes in POS Info %1';

    procedure SetPOSInfo(pPOSInfo: Record "NPR POS Info")
    begin
        POSInfo := pPOSInfo;
    end;

    local procedure LoadTable()
    var
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        EntryNo: Integer;
        FieldMappingARR: array[6] of Integer;
    begin
        EntryNo := 1;
        Clear(FieldMappingARR);
        POSInfoLookupSetup.SetRange("POS Info Code", POSInfo.Code);
        if POSInfo."Table No." = 0 then
            Error('error');

        if not POSInfoLookupSetup.FindFirst() then
            Error('Error');
        repeat
            case POSInfoLookupSetup."Map To" of
                POSInfoLookupSetup."Map To"::"Field 1":
                    begin
                        FieldMappingARR[1] := POSInfoLookupSetup."Field No.";
                    end;
                POSInfoLookupSetup."Map To"::"Field 2":
                    begin
                        FieldMappingARR[2] := POSInfoLookupSetup."Field No.";
                    end;
                POSInfoLookupSetup."Map To"::"Field 3":
                    begin
                        FieldMappingARR[3] := POSInfoLookupSetup."Field No.";
                    end;
                POSInfoLookupSetup."Map To"::"Field 4":
                    begin
                        FieldMappingARR[4] := POSInfoLookupSetup."Field No.";
                    end;
                POSInfoLookupSetup."Map To"::"Field 5":
                    begin
                        FieldMappingARR[5] := POSInfoLookupSetup."Field No.";
                    end;
                POSInfoLookupSetup."Map To"::"Field 6":
                    begin
                        FieldMappingARR[6] := POSInfoLookupSetup."Field No.";
                    end;
            end;
        until POSInfoLookupSetup.Next() = 0;

        RecRef.Open(POSInfo."Table No.");
        if RecRef.FindFirst() then
            repeat
                Rec.Init();
                Rec."Entry No." := EntryNo;
                EntryNo := EntryNo + 1;
                Rec."Table No." := 0; //Function to create a combined key
                if FieldMappingARR[1] <> 0 then begin
                    Rec."Field 1" := Format(RecRef.Field(FieldMappingARR[1]).Value);
                    FieldRef := RecRef.Field(FieldMappingARR[1]);
                    Field1Caption := FieldRef.Caption;
                end;
                if FieldMappingARR[2] <> 0 then begin
                    Rec."Field 2" := Format(RecRef.Field(FieldMappingARR[2]).Value);
                    FieldRef := RecRef.Field(FieldMappingARR[2]);
                    Field2Caption := FieldRef.Caption;
                end;
                if FieldMappingARR[3] <> 0 then begin
                    Rec."Field 3" := Format(RecRef.Field(FieldMappingARR[3]).Value);
                    FieldRef := RecRef.Field(FieldMappingARR[3]);
                    Field3Caption := FieldRef.Caption;
                end;
                if FieldMappingARR[4] <> 0 then begin
                    Rec."Field 4" := Format(RecRef.Field(FieldMappingARR[4]).Value);
                    FieldRef := RecRef.Field(FieldMappingARR[4]);
                    Field4Caption := FieldRef.Caption;
                end;
                if FieldMappingARR[5] <> 0 then begin
                    Rec."Field 5" := Format(RecRef.Field(FieldMappingARR[5]).Value);
                    FieldRef := RecRef.Field(FieldMappingARR[5]);
                    Field5Caption := FieldRef.Caption;
                end;
                if FieldMappingARR[6] <> 0 then begin
                    Rec."Field 6" := Format(RecRef.Field(FieldMappingARR[6]).Value);
                    FieldRef := RecRef.Field(FieldMappingARR[6]);
                    Field6Caption := FieldRef.Caption;
                end;
                Rec.RecID := RecRef.RecordId;
                Rec.Insert();
            until RecRef.Next() = 0;
    end;

    local procedure LoadSubcodes()
    var
        POSInfoSubcode: Record "NPR POS Info Subcode";
        EntryNo: Integer;
    begin
        EntryNo := 1;
        POSInfoSubcode.Reset();
        POSInfoSubcode.SetRange(Code, POSInfo.Code);
        if not POSInfoSubcode.FindFirst() then
            Error(ErrText001, POSInfo.Code);
        repeat
            Rec.Init();
            Rec."Entry No." := EntryNo;
            EntryNo := EntryNo + 1;
            Rec."Field 1" := POSInfoSubcode.Subcode;
            Field1Caption := POSInfoSubcode.Subcode;
            Rec."Field 2" := POSInfoSubcode.Description;
            Field2Caption := POSInfoSubcode.Description;
            Rec.Insert();

        until POSInfoSubcode.Next() = 0;
    end;
}

