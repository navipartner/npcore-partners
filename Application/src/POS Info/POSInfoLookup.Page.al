page 6150646 "NPR POS Info Lookup"
{
    Extensible = False;
    Caption = 'POS Info Lookup';
    PageType = List;
    UsageCategory = None;
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
                    CaptionClass = ColumnCaption[1];
                    Visible = Column1Visible;
                    ToolTip = 'Specifies the value of the Field 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 2"; Rec."Field 2")
                {
                    CaptionClass = ColumnCaption[2];
                    Visible = Column2Visible;
                    ToolTip = 'Specifies the value of the Field 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 3"; Rec."Field 3")
                {
                    CaptionClass = ColumnCaption[3];
                    Visible = Column3Visible;
                    ToolTip = 'Specifies the value of the Field 3 field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 4"; Rec."Field 4")
                {
                    CaptionClass = ColumnCaption[4];
                    Visible = Column4Visible;
                    ToolTip = 'Specifies the value of the Field 4 field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 5"; Rec."Field 5")
                {
                    CaptionClass = ColumnCaption[5];
                    Visible = Column5Visible;
                    ToolTip = 'Specifies the value of the Field 5 field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 6"; Rec."Field 6")
                {
                    CaptionClass = ColumnCaption[6];
                    Visible = Column6Visible;
                    ToolTip = 'Specifies the value of the Field 6 field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
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
        ColumnCaption: array[6] of Text;
        Column1Visible: Boolean;
        Column2Visible: Boolean;
        Column3Visible: Boolean;
        Column4Visible: Boolean;
        Column5Visible: Boolean;
        Column6Visible: Boolean;
        FieldMappingARR: array[6] of Integer;

    procedure SetPOSInfo(pPOSInfo: Record "NPR POS Info")
    begin
        POSInfo := pPOSInfo;
    end;

    local procedure LoadTable()
    var
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
        RecRef: RecordRef;
        FieldMappingNotDefinedErr: Label 'You must define field mapping for POS Info Code %1';
    begin
        Clear(FieldMappingARR);
        POSInfoLookupSetup.SetRange("POS Info Code", POSInfo.Code);
        POSInfo.TestField("Table No.");

        if POSInfoLookupSetup.IsEmpty then
            Error(FieldMappingNotDefinedErr, POSInfo.Code);
        POSInfoLookupSetup.FindSet();
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
        SetColumnCaptions(RecRef);

        Rec."Entry No." := 0;
        if RecRef.FindSet() then
            repeat
                Rec.Init();
                Rec."Entry No." += 1;
                Rec."Table No." := 0; //Function to create a combined key

                if FieldMappingARR[1] <> 0 then
                    Rec."Field 1" := Format(RecRef.Field(FieldMappingARR[1]).Value);
                if FieldMappingARR[2] <> 0 then
                    Rec."Field 2" := Format(RecRef.Field(FieldMappingARR[2]).Value);
                if FieldMappingARR[3] <> 0 then
                    Rec."Field 3" := Format(RecRef.Field(FieldMappingARR[3]).Value);
                if FieldMappingARR[4] <> 0 then
                    Rec."Field 4" := Format(RecRef.Field(FieldMappingARR[4]).Value);
                if FieldMappingARR[5] <> 0 then
                    Rec."Field 5" := Format(RecRef.Field(FieldMappingARR[5]).Value);
                if FieldMappingARR[6] <> 0 then
                    Rec."Field 6" := Format(RecRef.Field(FieldMappingARR[6]).Value);

                Rec.RecID := RecRef.RecordId;
                Rec.Insert();
            until RecRef.Next() = 0;
    end;

    local procedure LoadSubcodes()
    var
        POSInfoSubcode: Record "NPR POS Info Subcode";
        EntryNo: Integer;
        SubcodesNotDefinedErr: Label 'You must define subcodes in POS Info %1';
    begin
        EntryNo := 1;
        POSInfoSubcode.Reset();
        POSInfoSubcode.SetRange(Code, POSInfo.Code);
        if not POSInfoSubcode.FindSet() then
            Error(SubcodesNotDefinedErr, POSInfo.Code);
        repeat
            Rec.Init();
            Rec."Entry No." := EntryNo;
            EntryNo := EntryNo + 1;
            Rec."Field 1" := POSInfoSubcode.Subcode;
            ColumnCaption[1] := POSInfoSubcode.Subcode;
            Column1Visible := true;
            Rec."Field 2" := POSInfoSubcode.Description;
            ColumnCaption[2] := POSInfoSubcode.Description;
            Column2Visible := true;
            Rec.Insert();

        until POSInfoSubcode.Next() = 0;
    end;

    local procedure SetColumnCaptions(RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to ArrayLen(FieldMappingARR) do
            if FieldMappingARR[ColumnNo] <> 0 then begin
                FieldRef := RecRef.Field(FieldMappingARR[ColumnNo]);
                ColumnCaption[ColumnNo] := FieldRef.Caption;
            end;

        Column1Visible := FieldMappingARR[1] <> 0;
        Column2Visible := FieldMappingARR[2] <> 0;
        Column3Visible := FieldMappingARR[3] <> 0;
        Column4Visible := FieldMappingARR[4] <> 0;
        Column5Visible := FieldMappingARR[5] <> 0;
        Column6Visible := FieldMappingARR[6] <> 0;
    end;
}
