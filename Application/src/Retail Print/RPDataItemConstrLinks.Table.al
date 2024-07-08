table 6014564 "NPR RP Data Item Constr. Links"
{
    Access = Internal;
    Caption = 'Data Item Constraint Links';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Item Code"; Code[20])
        {
            Caption = 'Data Item Code';
            TableRelation = "NPR RP Data Item Constr."."Data Item Code";
            DataClassification = CustomerContent;
        }
        field(2; "Constraint Line No."; Integer)
        {
            Caption = 'Constraint Line No.';
            TableRelation = "NPR RP Data Item Constr."."Line No.";
            DataClassification = CustomerContent;
        }
        field(3; "Data Item Name"; Text[50])
        {
            Caption = 'Data Item Name';
            DataClassification = CustomerContent;
        }
        field(4; "Data Item Table ID"; Integer)
        {
            Caption = 'Data Item Table ID';
            DataClassification = CustomerContent;
        }
        field(5; "Data Item Field ID"; Integer)
        {
            Caption = 'Data Item Field ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
                DataItemConstraint: Record "NPR RP Data Item Constr.";
                DataItem: Record "NPR RP Data Items";
            begin
                TestField("Data Item Link On", "Data Item Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                Field.FilterGroup(2);
                Field.SetRange(TableNo, DataItem."Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Data Item Field Name" := Field.FieldName;
                    "Data Item Field ID" := Field."No.";
                    CheckSelectedField(Field, FieldCaption("Data Item Field ID"));
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "NPR RP Data Item Constr.";
                DataItem: Record "NPR RP Data Items";
            begin
                TestField("Data Item Link On", "Data Item Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                Field.SetRange(TableNo, DataItem."Table ID");
                Field.SetRange("No.", "Data Item Field ID");
                Field.FindFirst();
                "Data Item Field Name" := Field.FieldName;
                CheckSelectedField(Field, FieldCaption("Data Item Field ID"));
            end;
        }
        field(6; "Data Item Field Name"; Text[50])
        {
            Caption = 'Data Item Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
                DataItemConstraint: Record "NPR RP Data Item Constr.";
                DataItem: Record "NPR RP Data Items";
            begin
                TestField("Data Item Link On", "Data Item Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                Field.FilterGroup(2);
                Field.SetRange(TableNo, DataItem."Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Data Item Field Name" := Field.FieldName;
                    "Data Item Field ID" := Field."No.";
                    CheckSelectedField(Field, FieldCaption("Data Item Field Name"));
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "NPR RP Data Item Constr.";
                DataItem: Record "NPR RP Data Items";
            begin
                TestField("Data Item Link On", "Data Item Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                Field.SetRange(TableNo, DataItem."Table ID");
                Field.SetRange(FieldName, "Data Item Field Name");
                if not Field.FindFirst() then
                    Field.SetFilter(FieldName, '@' + "Data Item Field Name" + '*');
                Field.FindFirst();

                "Data Item Field Name" := Field.FieldName;
                "Data Item Field ID" := Field."No.";
                CheckSelectedField(Field, FieldCaption("Data Item Field Name"));
            end;
        }
        field(7; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                DataItemConstraint: Record "NPR RP Data Item Constr.";
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                TestField("Link On", "Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();

                Field.FilterGroup(2);
                Field.SetRange(TableNo, DataItemConstraint."Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Field Name" := Field.FieldName;
                    "Field ID" := Field."No.";
                    CheckSelectedField(Field, FieldCaption("Field ID"));
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "NPR RP Data Item Constr.";
            begin
                TestField("Link On", "Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();

                Field.SetRange(TableNo, DataItemConstraint."Table ID");
                Field.SetRange("No.", "Field ID");
                Field.FindFirst();
                "Field Name" := Field.FieldName;
                CheckSelectedField(Field, FieldCaption("Field ID"));
            end;
        }
        field(8; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                DataItemConstraint: Record "NPR RP Data Item Constr.";
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                TestField("Link On", "Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();

                Field.FilterGroup(2);
                Field.SetRange(TableNo, DataItemConstraint."Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Field Name" := Field.FieldName;
                    "Field ID" := Field."No.";
                    CheckSelectedField(Field, FieldCaption("Field Name"));
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "NPR RP Data Item Constr.";
            begin
                TestField("Link On", "Link On"::"Field");
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();

                Field.SetRange(TableNo, DataItemConstraint."Table ID");
                Field.SetRange(FieldName, "Field Name");
                if not Field.FindFirst() then
                    Field.SetFilter(FieldName, '@' + "Field Name" + '*');
                Field.FindFirst();

                "Field Name" := Field.FieldName;
                "Field ID" := Field."No.";
                CheckSelectedField(Field, FieldCaption("Field Name"));
            end;
        }
        field(9; "Filter Type"; Option)
        {
            Caption = 'Filter Type';
            OptionCaption = 'TableLink,Fixed Filter';
            OptionMembers = TableLink,"Fixed Filter";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Filter Type" = "Filter Type"::TableLink then
                    "Filter Value" := ''
                else begin
                    "Data Item Name" := '';
                    "Data Item Field ID" := 0;
                    "Data Item Field Name" := '';
                    "Data Item Link On" := "Data Item Link On"::"Field";
                    "Link On" := "Link On"::"Field";
                    "Link Type" := "Link Type"::"=";
                end;
            end;
        }
        field(10; "Filter Value"; Text[250])
        {
            Caption = 'Filter Value';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                FieldRef: FieldRef;
                RecRef: RecordRef;
                "Field": Record "Field";
                TempRetailList: Record "NPR Retail List" temporary;
                RetailListPage: Page "NPR Retail List";
                StringArray: List of [Text];
                String: Text;
                DataItemConstraint: Record "NPR RP Data Item Constr.";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst();

                if not Field.Get(DataItemConstraint."Table ID", "Field ID") then
                    exit;

                RecRef.Open(DataItemConstraint."Table ID");
                FieldRef := RecRef.Field("Field ID");
                case LowerCase(Format(FieldRef.Type)) of
                    'boolean':
                        begin
                            TempRetailList.Choice := 'True';
                            TempRetailList.Insert();

                            TempRetailList.Number += 1;
                            TempRetailList.Choice := 'False';
                            TempRetailList.Insert();
                            if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then
                                "Filter Value" := TempRetailList.Choice;
                        end;
                    'option':
                        begin
                            StringArray := FieldRef.OptionCaption.Split(',');
                            foreach String in StringArray do begin
                                TempRetailList.Number += 1;
                                if not (String in ['', ' ']) then begin
#pragma warning disable AA0139
                                    TempRetailList.Choice := String;
#pragma warning restore AA0139
                                    TempRetailList.Value := Format(TempRetailList.Number - 1);
                                    TempRetailList.Insert();
                                end;
                            end;
                            RetailListPage.SetMultipleChoiceMode(true);
                            RetailListPage.LookupMode(true);
                            RetailListPage.SetRec(TempRetailList);
                            if RetailListPage.RunModal() = ACTION::LookupOK then begin
                                "Filter Value" := '';
                                RetailListPage.GetRec(TempRetailList);
                                TempRetailList.SetRange(Chosen, true);
                                if TempRetailList.FindSet() then
                                    repeat
                                        if StrLen("Filter Value") > 0 then
                                            "Filter Value" += '|';
                                        "Filter Value" += TempRetailList.Value;
                                    until TempRetailList.Next() = 0;
                            end;
                        end;
                    else
                        exit;
                end;
            end;
        }
        field(11; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(12; "Link Type"; Enum "NPR RP Data Item Link Type")
        {
            Caption = 'Link Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Link Type" <> "Link Type"::"=" then begin
                    TestField("Filter Type", "Filter Type"::TableLink);
                    TestField("Data Item Link On", "Data Item Link On"::"Field");
                    TestField("Link On", "Link On"::"Field");
                end;
            end;
        }
        field(20; "Data Item Link On"; Enum "NPR RP Data Item Link On")
        {
            Caption = 'Data Item Link On';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Data Item Link On" <> "Data Item Link On"::"Field" then begin
                    TestField("Filter Type", "Filter Type"::TableLink);
                    "Data Item Field ID" := 0;
                    "Data Item Field Name" := '';
                    "Link On" := "Link On"::"Field";
                    "Link Type" := "Link Type"::"=";
                    if "Field ID" <> 0 then
                        Validate("Field ID");
                end;
            end;
        }
        field(21; "Link On"; Enum "NPR RP Data Item Link On")
        {
            Caption = 'Link On';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Link On" <> "Link On"::"Field" then begin
                    TestField("Filter Type", "Filter Type"::TableLink);
                    "Field ID" := 0;
                    "Field Name" := '';
                    "Data Item Link On" := "Data Item Link On"::"Field";
                    "Link Type" := "Link Type"::"=";
                    if "Data Item Field ID" <> 0 then
                        Validate("Data Item Field ID");
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Data Item Code", "Constraint Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ModifiedRec();
    end;

    trigger OnInsert()
    begin
        ModifiedRec();
        if "Link On" = "Link On"::"Field" then
            TestField("Field ID");
    end;

    trigger OnModify()
    begin
        ModifiedRec();
    end;

    trigger OnRename()
    begin
        ModifiedRec();
    end;

    local procedure ModifiedRec()
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if RPTemplateHeader.Get("Data Item Code") then
            RPTemplateHeader.Modify(true);
    end;

    local procedure CheckSelectedField("Field": Record "Field"; CalledByFieldCaption: Text)
    var
        WrontFieldTypeErr: Label 'You must select a field of type "%1" as %2.', Comment = '%1 - required field type, %2 - called by field caption.';
    begin
        if ((CalledByFieldCaption in [FieldCaption("Field ID"), FieldCaption("Field Name")]) and
            ("Data Item Link On" = "Data Item Link On"::"Record ID") and ("Field ID" <> 0)) or
           ((CalledByFieldCaption in [FieldCaption("Data Item Field ID"), FieldCaption("Data Item Field Name")]) and
            ("Link On" = "Link On"::"Record ID") and ("Data Item Field ID" <> 0))
        then
            if Field.Type <> Field.Type::RecordID then
                Error(WrontFieldTypeErr, Format(FieldType::RecordId), CalledByFieldCaption);
    end;
}
