table 6014561 "NPR RP Data Items"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0
    // NPR5.34/MMV /20170724 CASE 284505 TESTFIELD on critical fields.
    // NPR5.40/MMV /20180208 CASE 304639 Added new fields 30,31 for more overall template control
    // NPR5.50/MMV /20190502 CASE 353588 Added support for distinct iteration.
    // NPR5.51/MMV /20190712 CASE 354694 Added type in field 13

    Caption = 'Data Items';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Parent Line No."; Integer)
        {
            Caption = 'Parent Item Line No.';
            DataClassification = CustomerContent;
        }
        field(6; "Parent Table ID"; Integer)
        {
            Caption = 'Parent Table ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
            end;
        }
        field(10; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(11; "Data Source"; Text[50])
        {
            Caption = 'Data Source';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                AllObj: Record AllObj;
                AllObjects: Page "All Objects";
            begin
                AllObj.FilterGroup(2);
                AllObj.SetRange("Object Type", AllObj."Object Type");
                AllObjects.SetTableView(AllObj);
                AllObjects.LookupMode(true);
                if AllObjects.RunModal() = ACTION::LookupOK then begin
                    AllObjects.GetRecord(AllObj);
                    "Data Source" := AllObj."Object Name";
                    "Table ID" := AllObj."Object ID";
                    Name := "Data Source";
                    //Name := STRSUBSTNO('<%1>',"Data Source");
                end;
                FindParentItem();
            end;

            trigger OnValidate()
            var
                AllObj: Record AllObj;
            begin
                AllObj.SetFilter("Object Name", '@' + "Data Source");
                if not AllObj.FindFirst() then
                    AllObj.SetFilter("Object Name", '@' + "Data Source" + '*');
                AllObj.FindFirst();

                "Data Source" := AllObj."Object Name";
                "Table ID" := AllObj."Object ID";
                Name := "Data Source";
                //Name    := STRSUBSTNO('<%1>',"Data Source");

                if "Data Source" <> xRec."Data Source" then
                    CheckLinks();
            end;
        }
        field(12; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DataItem: Record "NPR RP Data Items";
                DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
            begin
                DataItem.SetRange(Code, Code);
                DataItem.SetRange(Name, Name);
                DataItem.SetFilter("Line No.", '<>%1', "Line No.");
                if not DataItem.IsEmpty then
                    Error(Error_ExistingDataItem, Name);

                DataItemConstraintLinks.SetRange("Data Item Code", Code);
                DataItemConstraintLinks.SetRange("Data Item Name", xRec.Name);
                DataItemConstraintLinks.ModifyAll("Data Item Name", Name, true);
            end;
        }
        field(13; "Iteration Type"; Option)
        {
            Caption = 'Iteration Type';
            OptionCaption = ' ,First,Last,Total,Distinct Values,Field Value';
            OptionMembers = " ",First,Last,Total,"Distinct Values","Field Value";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Iteration Type" <> "Iteration Type"::Total then
                    Clear("Total Fields");

                //-NPR5.50 [353588]
                if "Iteration Type" <> "Iteration Type"::"Distinct Values" then
                    Clear("Field ID");
                //+NPR5.50 [353588]
            end;
        }
        field(14; "Key ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Key ID';
            TableRelation = Key."No." WHERE(TableNo = FIELD("Table ID"));
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Key": Record "Key";
                TempRetailList: Record "NPR Retail List" temporary;
                IntegerBuffer: Integer;
            begin
                Key.SetRange(TableNo, "Table ID");
                Key.SetRange(Enabled, true);
                if Key.FindSet() then
                    repeat
                        TempRetailList.Number += 1;
                        TempRetailList.Choice := Key.Key;
                        TempRetailList.Value := Format(Key."No.");
                        TempRetailList.Insert();
                    until Key.Next() = 0;

                if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
                    Evaluate(IntegerBuffer, TempRetailList.Value);
                    Validate("Key ID", IntegerBuffer);
                end;
            end;

            trigger OnValidate()
            var
                "Key": Record "Key";
            begin
                if "Key ID" > 0 then begin
                    Key.SetRange(TableNo, "Table ID");
                    Key.SetRange(Enabled, true);
                    Key.SetRange("No.", "Key ID");
                    Key.FindFirst();
                end;
            end;
        }
        field(15; "Sort Order"; Option)
        {
            Caption = 'Sort Order';
            OptionCaption = ' ,Ascending,Descending';
            OptionMembers = " ","Ascending","Descending";
            DataClassification = CustomerContent;
        }
        field(16; "Total Fields"; Text[250])
        {
            Caption = 'Total Fields';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempRetailList: Record "NPR Retail List" temporary;
                "Field": Record "Field";
                RetailListPage: Page "NPR Retail List";
                FieldString: Text;
            begin
                if "Iteration Type" <> "Iteration Type"::Total then
                    exit;

                Field.SetRange(TableNo, "Table ID");
                Field.SetRange(Enabled, true);
                Field.SetFilter(Type, '%1|%2|%3|%4', Field.Type::Decimal, Field.Type::Integer, Field.Type::BigInteger, Field.Type::Duration);

                if Field.FindSet() then
                    repeat
                        TempRetailList.Number += 1;
                        TempRetailList.Choice := Field.FieldName;
                        TempRetailList.Value := Format(Field."No.");
                        TempRetailList.Insert();
                    until Field.Next() = 0;

                RetailListPage.LookupMode(true);
                RetailListPage.SetMultipleChoiceMode(true);
                RetailListPage.SetRec(TempRetailList);
                if RetailListPage.RunModal() = ACTION::LookupOK then begin
                    RetailListPage.GetRec(TempRetailList);
                    FieldString := '';
                    TempRetailList.SetRange(Chosen, true);
                    if TempRetailList.FindSet() then
                        repeat
                            if StrLen(FieldString) > 0 then
                                FieldString += ',';
                            FieldString += TempRetailList.Value;
                        until TempRetailList.Next() = 0;

                    "Total Fields" := FieldString;
                end;
            end;
        }
        field(17; "Field ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Field ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldLookup: Page "NPR Field Lookup";
            begin
                //-NPR5.50 [353588]
                Field.FilterGroup(2);
                Field.SetRange(TableNo, "Table ID");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);

                if FieldLookup.RunModal() = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    "Field ID" := Field."No.";
                end;
                //+NPR5.50 [353588]
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                //-NPR5.50 [353588]
                Field.Get("Table ID", "Field ID");
                //+NPR5.50 [353588]
            end;
        }
        field(20; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Level <> xRec.Level then
                    CheckLinks();
            end;
        }
        field(30; "Skip Template If Empty"; Boolean)
        {
            Caption = 'Skip Template If Empty';
            DataClassification = CustomerContent;
        }
        field(31; "Skip Template If Not Empty"; Boolean)
        {
            Caption = 'Skip Template If Not Empty';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Line No.")
        {
        }
        key(Key2; "Code", Level, "Parent Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItem: Record "NPR RP Data Items";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
    begin
        ModifiedRec();

        DataItem.SetRange(Code, Code);
        DataItem.SetRange("Parent Line No.", "Line No.");
        DataItem.SetRange("Parent Table ID", "Table ID");
        DataItem.DeleteAll();

        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemLinks.SetRange("Parent Line No.", "Line No.");
        ;
        DataItemLinks.DeleteAll();

        DataItemLinks.Reset();
        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemLinks.SetRange("Child Line No.", "Line No.");
        DataItemLinks.DeleteAll();

        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraint.SetRange("Data Item Line No.", "Line No.");
        if DataItemConstraint.FindSet(true) then
            repeat
                DataItemConstraintLinks.SetRange("Data Item Code", DataItemConstraint."Data Item Code");
                DataItemConstraintLinks.SetRange("Constraint Line No.", DataItemConstraint."Line No.");
                DataItemConstraintLinks.DeleteAll();
            until DataItemConstraint.Next() = 0;
        DataItemConstraint.DeleteAll();
    end;

    trigger OnInsert()
    begin
        //-NPR5.34 [284505]
        TestField("Data Source");
        TestField(Name);
        //+NPR5.34 [284505]

        ModifiedRec();
        FindParentItem();
    end;

    trigger OnModify()
    begin
        ModifiedRec();
        FindParentItem();
    end;

    trigger OnRename()
    begin
        ModifiedRec();
    end;

    var
        Error_ExistingDataItem: Label 'Data item %1 already exists';
        Error_DeleteLinks: Label 'This operation will remove data item links/constraints.\Continue?';

    procedure FindParentItem()
    var
        DataItem: Record "NPR RP Data Items";
    begin
        DataItem.SetRange(Code, Code);
        DataItem.SetFilter("Line No.", '<%1', "Line No.");
        DataItem.SetFilter(Level, '<%1', Level);
        if DataItem.FindLast() then begin
            "Parent Line No." := DataItem."Line No.";
            "Parent Table ID" := DataItem."Table ID";
        end;
    end;

    local procedure ModifiedRec()
    var
        TemplateHeader: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if TemplateHeader.Get(Code) then
            TemplateHeader.Modify(true);
    end;

    local procedure CheckLinks()
    var
        DataItemLinks: Record "NPR RP Data Item Links";
        Prompt: Boolean;
        DataItemConstraint: Record "NPR RP Data Item Constr.";
    begin
        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemLinks.SetRange("Parent Line No.", "Line No.");
        Prompt := not DataItemLinks.IsEmpty();

        DataItemLinks.SetRange("Parent Line No.");
        DataItemLinks.SetRange("Child Line No.", "Line No.");
        Prompt := Prompt or not DataItemLinks.IsEmpty();

        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraint.SetRange("Data Item Line No.", "Line No.");
        Prompt := Prompt or not DataItemConstraint.IsEmpty();

        if not Prompt then
            exit;

        if not Confirm(Error_DeleteLinks) then
            Error('');

        DataItemLinks.Reset();
        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemLinks.SetRange("Parent Line No.", "Line No.");
        DataItemLinks.DeleteAll(true);
        DataItemLinks.SetRange("Parent Line No.");
        DataItemLinks.SetRange("Child Line No.", "Line No.");
        DataItemLinks.DeleteAll(true);
        DataItemConstraint.DeleteAll(true);
    end;
}

