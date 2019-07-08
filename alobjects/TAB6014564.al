table 6014564 "RP Data Item Constraint Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 12

    Caption = 'Data Item Constraint Links';

    fields
    {
        field(1;"Data Item Code";Code[20])
        {
            Caption = 'Data Item Code';
            TableRelation = "RP Data Item Constraint"."Data Item Code";
        }
        field(2;"Constraint Line No.";Integer)
        {
            Caption = 'Constraint Line No.';
            TableRelation = "RP Data Item Constraint"."Line No.";
        }
        field(3;"Data Item Name";Text[50])
        {
            Caption = 'Data Item Name';

            trigger OnLookup()
            var
                DataItem: Record "RP Data Items";
                DataItemConstraint: Record "RP Data Item Constraint";
                tmpRetailList: Record "Retail List" temporary;
            begin
                // DataItemConstraint.SETRANGE("Data Item Code", "Data Item Code");
                // DataItemConstraint.SETRANGE("Line No.", "Constraint Line No.");
                // DataItemConstraint.FINDFIRST;
                //
                // DataItem.SETRANGE(Code, "Data Item Code");
                // DataItem.SETRANGE("Line No.", DataItemConstraint."Data Item Line No.");
                // DataItem.FINDFIRST;
                //
                // tmpRetailList.Choice := DataItem.Name;
                // tmpRetailList.Value := FORMAT(DataItem."Table ID");
                // tmpRetailList.INSERT;
                //
                // DataItem.SETRANGE("Line No.", DataItem."Parent Item Line No.");
                // IF DataItem.FINDFIRST THEN BEGIN
                //  tmpRetailList.Number += 1;
                //  tmpRetailList.Choice := DataItem.Name;
                //  tmpRetailList.Value := FORMAT(DataItem."Table ID");
                //  tmpRetailList.INSERT;
                // END;
                //
                // IF PAGE.RUNMODAL(PAGE::"Retail List", tmpRetailList) = ACTION::LookupOK THEN
                //  VALIDATE("Data Item Name",tmpRetailList.Choice);
            end;

            trigger OnValidate()
            var
                DataItem: Record "RP Data Items";
                DataItemConstraint: Record "RP Data Item Constraint";
            begin
                // DataItemConstraint.SETRANGE("Data Item Code", "Data Item Code");
                // DataItemConstraint.SETRANGE("Line No.", "Constraint Line No.");
                // DataItemConstraint.FINDFIRST;
                //
                // DataItem.SETRANGE(Code, "Data Item Code");
                // DataItem.SETRANGE("Line No.", DataItemConstraint."Data Item Line No.");
                // DataItem.SETFILTER(Name,'@' + "Data Item Name" + '*');
                // IF DataItem.FINDFIRST THEN BEGIN
                //  "Data Item Name" := DataItem.Name;
                //  "Data Item Table ID" := DataItem."Table ID";
                //  EXIT;
                // END;
                //
                // DataItem.SETRANGE(Name);
                // DataItem.FINDFIRST;
                //
                // DataItem.SETRANGE("Line No.", DataItem."Parent Item Line No.");
                // DataItem.SETFILTER(Name,'@' + "Data Item Name" + '*');
                // DataItem.FINDFIRST;
                //
                // "Data Item Name" := DataItem.Name;
                // "Data Item Table ID" := DataItem."Table ID";
            end;
        }
        field(4;"Data Item Table ID";Integer)
        {
            Caption = 'Data Item Table ID';
        }
        field(5;"Data Item Field ID";Integer)
        {
            Caption = 'Data Item Field ID';

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
                DataItemConstraint: Record "RP Data Item Constraint";
                DataItem: Record "RP Data Items";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                Field.FilterGroup(2);
                Field.SetRange(TableNo, DataItem."Table ID");
                //Field.SETRANGE(TableNo,"Data Item Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Data Item Field Name" := Field.FieldName;
                  "Data Item Field ID" := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "RP Data Item Constraint";
                DataItem: Record "RP Data Items";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                //Field.SETRANGE(TableNo,"Data Item Table ID");
                Field.SetRange(TableNo, DataItem."Table ID");
                Field.SetRange("No.", "Data Item Field ID");
                Field.FindFirst;
                "Data Item Field Name" := Field.FieldName;
            end;
        }
        field(6;"Data Item Field Name";Text[50])
        {
            Caption = 'Data Item Field Name';

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
                DataItemConstraint: Record "RP Data Item Constraint";
                DataItem: Record "RP Data Items";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                Field.FilterGroup(2);
                Field.SetRange(TableNo, DataItem."Table ID");
                //Field.SETRANGE(TableNo,"Data Item Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Data Item Field Name" := Field.FieldName;
                  "Data Item Field ID" := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "RP Data Item Constraint";
                DataItem: Record "RP Data Items";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;
                DataItem.Get("Data Item Code", DataItemConstraint."Data Item Line No.");

                //Field.SETRANGE(TableNo,"Data Item Table ID");
                Field.SetRange(TableNo, DataItem."Table ID");
                Field.SetRange(FieldName, "Data Item Field Name");
                if not Field.FindFirst then
                  Field.SetFilter(FieldName, '@' + "Data Item Field Name" + '*');
                Field.FindFirst;

                "Data Item Field Name" := Field.FieldName;
                "Data Item Field ID" := Field."No."
            end;
        }
        field(7;"Field ID";Integer)
        {
            Caption = 'Field ID';

            trigger OnLookup()
            var
                DataItemConstraint: Record "RP Data Item Constraint";
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;

                Field.FilterGroup(2);
                Field.SetRange(TableNo,DataItemConstraint."Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal = ACTION::LookupOK then begin
                  FieldLookup.GetRecord(Field);
                  "Field Name"       := Field.FieldName;
                  "Field ID" := Field."No.";
                end;
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
                DataItemConstraint: Record "RP Data Item Constraint";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;

                Field.SetRange(TableNo,DataItemConstraint."Table ID");
                Field.SetRange("No.", "Field ID");
                Field.FindFirst;
                "Field Name" := Field.FieldName;
            end;
        }
        field(8;"Field Name";Text[50])
        {
            Caption = 'Field Name';

            trigger OnLookup()
            var
                DataItemConstraint: Record "RP Data Item Constraint";
                "Field": Record "Field";
                FieldLookup: Page "Field Lookup";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;

                Field.FilterGroup(2);
                Field.SetRange(TableNo,DataItemConstraint."Table ID");
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
                DataItemConstraint: Record "RP Data Item Constraint";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;

                Field.SetRange(TableNo,DataItemConstraint."Table ID");
                Field.SetRange(FieldName, "Field Name");
                if not Field.FindFirst then
                  Field.SetFilter(FieldName, '@' + "Field Name" + '*');
                Field.FindFirst;

                "Field Name" := Field.FieldName;
                "Field ID" := Field."No.";
            end;
        }
        field(9;"Filter Type";Option)
        {
            Caption = 'Filter Type';
            OptionCaption = 'TableLink,Fixed Filter';
            OptionMembers = TableLink,"Fixed Filter";

            trigger OnValidate()
            begin
                if "Filter Type" = "Filter Type"::TableLink then
                  "Filter Value" := ''
                else begin
                  "Data Item Name" := '';
                  "Data Item Field ID" := 0;
                  "Data Item Field Name" := '';
                end;
            end;
        }
        field(10;"Filter Value";Text[250])
        {
            Caption = 'Filter Value';

            trigger OnLookup()
            var
                FieldRef: FieldRef;
                RecRef: RecordRef;
                "Field": Record "Field";
                TempRetailList: Record "Retail List" temporary;
                RetailListPage: Page "Retail List";
                StringArray: DotNet Array;
                Regex: DotNet Regex;
                String: Text;
                DataItemConstraint: Record "RP Data Item Constraint";
            begin
                DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
                DataItemConstraint.SetRange("Line No.", "Constraint Line No.");
                DataItemConstraint.FindFirst;

                if not Field.Get(DataItemConstraint."Table ID", "Field ID") then
                  exit;

                RecRef.Open(DataItemConstraint."Table ID");
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
        field(11;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(12;"Link Type";Option)
        {
            Caption = 'Link Type';
            OptionCaption = '=,>,<,<>';
            OptionMembers = "=",">","<","<>";
        }
    }

    keys
    {
        key(Key1;"Data Item Code","Constraint Line No.","Line No.")
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

