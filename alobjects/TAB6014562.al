table 6014562 "RP Data Item Links"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0
    // NPR5.47/MMV /20181017 CASE 318084 Added field 19

    Caption = 'Data Item Links';

    fields
    {
        field(1;"Data Item Code";Code[20])
        {
            Caption = 'Data Item Code';
            TableRelation = "RP Data Items".Code;
        }
        field(2;"Parent Line No.";Integer)
        {
            Caption = 'Parent Line No.';
        }
        field(4;"Child Line No.";Integer)
        {
            Caption = 'Child Line No.';
        }
        field(11;"Parent Table ID";Integer)
        {
            Caption = 'Parent Table ID';
        }
        field(12;"Parent Field ID";Integer)
        {
            Caption = 'Parent Field ID';

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
            begin
                Field.FilterGroup(2);
                Field.SetRange(TableNo,"Parent Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Parent Field Name" := Field.FieldName;
                  "Parent Field ID"   := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo,"Parent Table ID");
                Field.SetRange("No.", "Parent Field ID");
                Field.FindFirst;
                "Parent Field Name" := Field.FieldName;
            end;
        }
        field(13;"Parent Field Name";Text[50])
        {
            Caption = 'Parent Field Name';

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
            begin
                Field.FilterGroup(2);
                Field.SetRange(TableNo,"Parent Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Parent Field Name" := Field.FieldName;
                  "Parent Field ID"   := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo,"Parent Table ID");
                Field.SetRange(FieldName, "Parent Field Name");
                if not Field.FindFirst then
                  Field.SetFilter(FieldName, '@' + "Parent Field Name" + '*');
                Field.FindFirst;

                "Parent Field Name" := Field.FieldName;
                "Parent Field ID"   := Field."No."
            end;
        }
        field(14;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(15;"Field ID";Integer)
        {
            Caption = 'Field ID';

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
            begin
                Field.FilterGroup(2);
                Field.SetRange(TableNo,"Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Field Name" := Field.FieldName;
                  "Field ID" := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table ID");
                Field.SetRange("No.", "Field ID");
                Field.FindFirst;
                "Field Name" := Field.FieldName;
            end;
        }
        field(16;"Field Name";Text[50])
        {
            Caption = 'Field Name';

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
            begin
                Field.FilterGroup(2);
                Field.SetRange(TableNo,"Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Field Name" := Field.FieldName;
                  "Field ID"   := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo,"Table ID");
                Field.SetRange(FieldName, "Field Name");
                if not Field.FindFirst then
                  Field.SetFilter(FieldName, '@' + "Field Name" + '*');
                Field.FindFirst;

                "Field Name" := Field.FieldName;
                "Field ID" := Field."No."
            end;
        }
        field(17;"Filter Type";Option)
        {
            Caption = 'Filter Type';
            OptionCaption = 'TableLink,Fixed Filter';
            OptionMembers = TableLink,"Fixed Filter";

            trigger OnValidate()
            begin
                if "Filter Type" = "Filter Type"::TableLink then
                  "Filter Value" := ''
                else begin
                  "Parent Field ID" := 0;
                  "Parent Field Name" := '';
                end;
            end;
        }
        field(18;"Filter Value";Text[250])
        {
            Caption = 'Filter Value';

            trigger OnLookup()
            var
                FieldRef: FieldRef;
                RecRef: RecordRef;
                "Field": Record "Field";
                TempRetailList: Record "Retail List" temporary;
                RetailListPage: Page "Retail List";
                StringArray: DotNet npNetArray;
                Regex: DotNet npNetRegex;
                String: Text;
            begin
                if not Field.Get("Table ID", "Field ID") then
                  exit;

                RecRef.Open("Table ID");
                FieldRef := RecRef.Field("Field ID");
                case LowerCase(Format(FieldRef.Type)) of
                  'boolean' :
                    begin
                      TempRetailList.Choice := 'True';
                      TempRetailList.Insert;

                      TempRetailList.Number += 1;
                      TempRetailList.Choice := 'False';
                      TempRetailList.Insert;
                      if PAGE.RunModal(PAGE::"Retail List", TempRetailList) = ACTION::LookupOK then
                        "Filter Value" := TempRetailList.Choice;
                    end;
                  'option'  :
                    begin
                      StringArray := Regex.Split(FieldRef.OptionCaption,',');
                      foreach String in StringArray do begin
                        TempRetailList.Number += 1;
                        if not (String in ['',' ']) then begin
                          TempRetailList.Choice := String;
                          TempRetailList.Value  := Format(TempRetailList.Number - 1);
                          TempRetailList.Insert;
                        end;
                      end;
                      RetailListPage.SetMultipleChoiceMode(true);
                      RetailListPage.LookupMode(true);
                      RetailListPage.SetRec(TempRetailList);
                      if RetailListPage.RunModal = ACTION::LookupOK then begin
                        "Filter Value" := '';
                        RetailListPage.GetRec(TempRetailList);
                        TempRetailList.SetRange(Chosen, true);
                        if TempRetailList.FindSet then repeat
                          if StrLen("Filter Value") > 0 then
                            "Filter Value" += '|';
                          "Filter Value" += TempRetailList.Value;
                        until TempRetailList.Next = 0;
                      end;
                    end;
                  else
                    exit;
                end;
            end;
        }
        field(19;"Link Type";Option)
        {
            Caption = 'Link Type';
            OptionCaption = '=,>,<,<>';
            OptionMembers = "=",">","<","<>";
        }
    }

    keys
    {
        key(Key1;"Data Item Code","Parent Line No.","Child Line No.","Parent Table ID","Table ID","Parent Field ID","Field ID")
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
        TemplateHeader: Record "RP Template Header";
    begin
        if IsTemporary then
          exit;
        if TemplateHeader.Get("Data Item Code") then
          TemplateHeader.Modify(true);
    end;
}

