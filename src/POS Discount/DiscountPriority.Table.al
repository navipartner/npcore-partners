table 6014417 "NPR Discount Priority"
{
    // NPR5.31/MHA /20170210  CASE 262904 Added fields: 10 Disabled, 15 "Discount Calc. Codeunit ID", 20 "Discount Calc. Codeunit Name"
    // NPR5.44/MMV /20180627  CASE 312154 Added field 30
    // NPR5.44/JDH /20180726 CASE 323366  changed flowfields to correct length 50 -> 30
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Caption = 'Discount Priority';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempObject: Record AllObj temporary;
            begin
                Clear(TempObject);
                RetailSalesLineCode.SetupObjectNoList(TempObject);
                //-NPR5.46 [322752]
                //IF PAGE.RUNMODAL(PAGE::Objects,TempObject) = ACTION::LookupOK THEN BEGIN
                //  "Table ID" := TempObject.ID;
                if PAGE.RunModal(PAGE::"Table Objects", TempObject) = ACTION::LookupOK then begin
                    "Table ID" := TempObject."Object ID";
                    //+NPR5.46 [322752]
                    Validate("Table ID");
                end;
            end;

            trigger OnValidate()
            var
                TempObject: Record AllObj temporary;
            begin
                CalcFields("Table Name");
                RetailSalesLineCode.SetupObjectNoList(TempObject);
                //-NPR5.46 [322752]
                //TempObject.Type := TempObject.Type::Table;
                //TempObject.ID := "Table ID";
                TempObject."Object Type" := TempObject."Object Type"::Table;
                TempObject."Object ID" := "Table ID";
                //+NPR5.46 [322752]
                if not TempObject.Find then
                    FieldError("Table ID");
            end;
        }
        field(2; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(3; "Table Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; Disabled; Boolean)
        {
            Caption = 'Disabled';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(15; "Discount Calc. Codeunit ID"; Integer)
        {
            Caption = 'Discount Calc. Codeunit ID';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(20; "Discount Calc. Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Discount Calc. Codeunit ID")));
            Caption = 'Discount Calc. Codeunit Name';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Cross Line Calculation"; Boolean)
        {
            Caption = 'Cross Line Calculation';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
        }
        key(Key2; Priority)
        {
        }
    }

    fieldgroups
    {
    }

    var
        RetailSalesLineCode: Codeunit "NPR Retail Sales Line Code";
}

