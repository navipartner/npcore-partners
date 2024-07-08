table 6014562 "NPR RP Data Item Links"
{
    Access = Internal;
    Caption = 'Data Item Links';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Item Code"; Code[20])
        {
            Caption = 'Data Item Code';
            TableRelation = "NPR RP Data Items".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Child Line No."; Integer)
        {
            Caption = 'Child Line No.';
            DataClassification = CustomerContent;
        }
        field(11; "Parent Table ID"; Integer)
        {
            Caption = 'Parent Table ID';
            DataClassification = CustomerContent;
        }
        field(12; "Parent Field ID"; Integer)
        {
            Caption = 'Parent Field ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                TestField("Parent Link On", "Parent Link On"::"Field");
                Field.FilterGroup(2);
                Field.SetRange(TableNo, "Parent Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Parent Field Name" := Field.FieldName;
                    "Parent Field ID" := Field."No.";
                    CheckSelectedField(Field, FieldCaption("Parent Field ID"));
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                TestField("Parent Link On", "Parent Link On"::"Field");
                Field.SetRange(TableNo, "Parent Table ID");
                Field.SetRange("No.", "Parent Field ID");
                Field.FindFirst();
                "Parent Field Name" := Field.FieldName;
                CheckSelectedField(Field, FieldCaption("Parent Field ID"));
            end;
        }
        field(13; "Parent Field Name"; Text[50])
        {
            Caption = 'Parent Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                TestField("Parent Link On", "Parent Link On"::"Field");
                Field.FilterGroup(2);
                Field.SetRange(TableNo, "Parent Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Parent Field Name" := Field.FieldName;
                    "Parent Field ID" := Field."No.";
                    CheckSelectedField(Field, FieldCaption("Parent Field Name"));
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                TestField("Parent Link On", "Parent Link On"::"Field");
                Field.SetRange(TableNo, "Parent Table ID");
                Field.SetRange(FieldName, "Parent Field Name");
                if not Field.FindFirst() then
                    Field.SetFilter(FieldName, '@' + "Parent Field Name" + '*');
                Field.FindFirst();

                "Parent Field Name" := Field.FieldName;
                "Parent Field ID" := Field."No.";
                CheckSelectedField(Field, FieldCaption("Parent Field Name"));
            end;
        }
        field(14; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(15; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                TestField("Link On", "Link On"::"Field");
                Field.FilterGroup(2);
                Field.SetRange(TableNo, "Table ID");
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
            begin
                TestField("Link On", "Link On"::"Field");
                Field.SetRange(TableNo, "Table ID");
                Field.SetRange("No.", "Field ID");
                Field.FindFirst();
                "Field Name" := Field.FieldName;
                CheckSelectedField(Field, FieldCaption("Field ID"));
            end;
        }
        field(16; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                TestField("Link On", "Link On"::"Field");
                Field.FilterGroup(2);
                Field.SetRange(TableNo, "Table ID");
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
            begin
                TestField("Link On", "Link On"::"Field");
                Field.SetRange(TableNo, "Table ID");
                Field.SetRange(FieldName, "Field Name");
                if not Field.FindFirst() then
                    Field.SetFilter(FieldName, '@' + "Field Name" + '*');
                Field.FindFirst();

                "Field Name" := Field.FieldName;
                "Field ID" := Field."No.";
                CheckSelectedField(Field, FieldCaption("Field Name"));
            end;
        }
        field(17; "Filter Type"; Option)
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
                    "Parent Field ID" := 0;
                    "Parent Field Name" := '';
                    "Parent Link On" := "Parent Link On"::"Field";
                    "Link On" := "Link On"::"Field";
                    "Link Type" := "Link Type"::"=";
                end;
            end;
        }
        field(18; "Filter Value"; Text[250])
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
            begin
                if not Field.Get("Table ID", "Field ID") then
                    exit;

                RecRef.Open("Table ID");
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
        field(19; "Link Type"; Enum "NPR RP Data Item Link Type")
        {
            Caption = 'Link Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Link Type" <> "Link Type"::"=" then begin
                    TestField("Filter Type", "Filter Type"::TableLink);
                    TestField("Parent Link On", "Parent Link On"::"Field");
                    TestField("Link On", "Link On"::"Field");
                end;
            end;
        }
        field(20; "Parent Link On"; Enum "NPR RP Data Item Link On")
        {
            Caption = 'Parent Link On';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Parent Link On" <> "Parent Link On"::"Field" then begin
                    TestField("Filter Type", "Filter Type"::TableLink);
                    "Parent Field ID" := 0;
                    "Parent Field Name" := '';
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
                    "Parent Link On" := "Parent Link On"::"Field";
                    "Link Type" := "Link Type"::"=";
                    if "Parent Field ID" <> 0 then
                        Validate("Parent Field ID");
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Data Item Code", "Parent Line No.", "Child Line No.", "Parent Table ID", "Table ID", "Parent Field ID", "Field ID")
        {
        }
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
        if IsTemporary() then
            exit;
        if RPTemplateHeader.Get("Data Item Code") then
            RPTemplateHeader.Modify(true);
    end;

    local procedure CheckSelectedField("Field": Record "Field"; CalledByFieldCaption: Text)
    var
        WrontFieldTypeErr: Label 'You must select a field of type "%1" as %2.', Comment = '%1 - required field type, %2 - called by field caption.';
    begin
        if ((CalledByFieldCaption in [FieldCaption("Field ID"), FieldCaption("Field Name")]) and
            ("Parent Link On" = "Parent Link On"::"Record ID") and ("Field ID" <> 0)) or
           ((CalledByFieldCaption in [FieldCaption("Parent Field ID"), FieldCaption("Parent Field Name")]) and
            ("Link On" = "Link On"::"Record ID") and ("Parent Field ID" <> 0))
        then
            if Field.Type <> Field.Type::RecordID then
                Error(WrontFieldTypeErr, Format(FieldType::RecordId), CalledByFieldCaption);
    end;
}
