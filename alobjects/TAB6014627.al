table 6014627 "Lookup Template Line"
{
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.

    Caption = 'Lookup Template Line';

    fields
    {
        field(1; "Lookup Template Table No."; Integer)
        {
            Caption = 'Lookup Template Table No.';
            TableRelation = "Lookup Template"."Table No.";
        }
        field(2; "Row No."; Integer)
        {
            Caption = 'Row No.';
        }
        field(3; "Col No."; Integer)
        {
            Caption = 'Col No.';
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Lookup Template Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                if Field.Get("Lookup Template Table No.", "Field No.") then;
                Field.SetRange(TableNo, "Lookup Template Table No.");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";
            end;
        }
        field(5; "Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Lookup Template Table No."),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Class; Text[30])
        {
            Caption = 'Class';
        }
        field(12; "Caption Type"; Option)
        {
            Caption = 'Caption Type';
            OptionCaption = 'Text,Field Caption,Table Caption';
            OptionMembers = Text,"Field","Table";

            trigger OnValidate()
            begin
                if ("Caption Type" <> xRec."Caption Type") and ("Caption Type" <> "Caption Type"::Text) then
                    "Caption Text" := '';
            end;
        }
        field(13; "Caption Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Caption Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnValidate()
            begin
                if ("Caption Table No." <> xRec."Caption Table No.") then
                    "Caption Field No." := 0;
            end;
        }
        field(14; "Caption Field No."; Integer)
        {
            BlankZero = true;
            Caption = 'Caption Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Lookup Template Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                if Field.Get("Lookup Template Table No.", "Caption Field No.") then;
                Field.SetRange(TableNo, "Lookup Template Table No.");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Caption Field No." := Field."No.";
            end;
        }
        field(15; "Caption Text"; Text[30])
        {
            Caption = 'Caption Text';
        }
        field(16; "Caption Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Lookup Template Table No."),
                                                        "No." = FIELD("Related Field No.")));
            Caption = 'Caption Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Text Align"; Option)
        {
            Caption = 'Text Align';
            OptionCaption = 'None,Left,Right,Center,Justify';
            OptionMembers = "None",Left,Right,Center,Justify;
        }
        field(18; "Font Size (pt)"; Integer)
        {
            Caption = 'Font Size (pt)';
        }
        field(19; "Width (CSS)"; Text[30])
        {
            Caption = 'Width (CSS)';
        }
        field(20; "Number Format"; Option)
        {
            Caption = 'Number Format';
            OptionCaption = 'None,Number,Percentage,Integer,IntegerThousand';
            OptionMembers = "None",Number,Percentage,"Integer",IntegerThousand;
        }
        field(21; Searchable; Boolean)
        {
            Caption = 'Searchable';
        }
        field(22; "Related Table No."; Integer)
        {
            Caption = 'Related Table No.';
            Editable = false;
        }
        field(23; "Related Table Name"; Text[30])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Related Table No.")));
            Caption = 'Related Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Related Field No."; Integer)
        {
            Caption = 'Related Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Related Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                if Field.Get("Lookup Template Table No.", "Caption Field No.") then;
                Field.SetRange(TableNo, "Lookup Template Table No.");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Caption Field No." := Field."No.";
            end;
        }
        field(25; "Related Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Lookup Template Table No."),
                                                        "No." = FIELD("Caption Field No.")));
            Caption = 'Related Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Caption Table Name"; Text[30])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Caption Table No.")));
            Caption = 'Caption Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Lookup Template Table No.", "Row No.", "Col No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Caption Table No." = 0 then
            "Caption Table No." := "Lookup Template Table No.";

        GetRelatedTableInfo();
    end;

    trigger OnModify()
    begin
        GetRelatedTableInfo();
    end;

    local procedure GetRelatedTableInfo()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if ("Lookup Template Table No." = 0) or ("Field No." = 0) or
          ((xRec."Lookup Template Table No." = "Lookup Template Table No.") and (xRec."Field No." = "Field No.")) then
            exit;

        RecRef.Open("Lookup Template Table No.");
        FieldRef := RecRef.Field("Field No.");
        if FieldRef.Relation = 0 then
            exit;
        RecRef.Close();

        RecRef.Open(FieldRef.Relation);
        "Related Table No." := RecRef.Number;
    end;
}

