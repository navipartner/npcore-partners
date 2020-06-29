table 6014626 "Lookup Template"
{
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.
    // NPR5.22/VB/20160414 CASE 238802 Added support for sorting options.
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Caption = 'Lookup Template';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnValidate()
            begin
                SetDefaultClass();
                SetDefaultKeyFieldNo();
            end;
        }
        field(11; Class; Text[30])
        {
            Caption = 'Class';
        }
        field(12; "Value Field No."; Integer)
        {
            Caption = 'Value Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                if Field.Get("Table No.", "Value Field No.") then;
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Value Field No." := Field."No.";
            end;
        }
        field(13; "Value Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Value Field No.")));
            Caption = 'Value Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Preemptive Push"; Boolean)
        {
            Caption = 'Preemptive Push';
            Description = 'NPR5.22';
        }
        field(15; "Sort By Field No."; Integer)
        {
            Caption = 'Sort By Field No.';
            Description = 'NPR5.22';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                if Field.Get("Table No.", "Value Field No.") then;
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Sort By Field No." := Field."No.";
            end;
        }
        field(16; "Sorting Order"; Option)
        {
            Caption = 'Sorting Order';
            Description = 'NPR5.22';
            OptionCaption = 'Ascending,Descending';
            OptionMembers = "Ascending","Descending";
        }
        field(91; "Table Caption"; Text[30])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(92; "Has Lines"; Boolean)
        {
            CalcFormula = Exist ("Lookup Template Line" WHERE("Lookup Template Table No." = FIELD("Table No.")));
            Caption = 'Has Lines';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        LookupTemplateLine: Record "Lookup Template Line";
    begin
        LookupTemplateLine.SetRange("Lookup Template Table No.", "Table No.");
        LookupTemplateLine.DeleteAll;
    end;

    local procedure SetDefaultClass()
    begin
        if ("Table No." <> xRec."Table No.") and ((GetClass(xRec."Table No.") = Class) or (Class = '')) then
            Class := GetClass("Table No.");
    end;

    local procedure SetDefaultKeyFieldNo()
    begin
        if ("Table No." <> xRec."Table No.") and ((GetKeyFieldNo(xRec."Table No.") = "Value Field No.") or ("Value Field No." = 0)) then
            "Value Field No." := GetKeyFieldNo("Table No.");
    end;

    local procedure GetClass(TableNo: Integer) Result: Text
    var
        "Object": Record "Object";
        AllObj: Record AllObj;
    begin
        //-322752 [322752]
        // IF NOT Object.GET(Object.Type::Table,'',TableNo) THEN
        //  EXIT('');
        //
        // Result := CONVERTSTR(LOWERCASE(Object.Name),' .','-_');

        if not AllObj.Get(AllObj."Object Type"::Table, '', TableNo) then
            exit('');

        Result := ConvertStr(LowerCase(AllObj."Object Name"), ' .', '-_');
        //+322752 [322752]
    end;

    local procedure GetKeyFieldNo(TableNo: Integer): Integer
    var
        RecRef: RecordRef;
    begin
        if TableNo = 0 then
            exit(0);

        RecRef.Open(TableNo);
        exit(RecRef.KeyIndex(1).FieldIndex(RecRef.KeyIndex(1).FieldCount).Number);
    end;
}

