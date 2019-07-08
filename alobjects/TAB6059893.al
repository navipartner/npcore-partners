table 6059893 "Npm Field Caption"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm View Condition';
    DataPerCompany = false;
    DrillDownPageID = "Npm Fields";
    LookupPageID = "Npm Fields";

    fields
    {
        field(5;"Table No.";Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            NotBlank = true;
            TableRelation = "Npm View"."Table No." WHERE (Code=FIELD("View Code"));
        }
        field(10;"View Code";Code[20])
        {
            Caption = 'View Code';
            TableRelation = "Npm View".Code WHERE ("Table No."=FIELD("Table No."));
        }
        field(15;"Field No.";Integer)
        {
            BlankZero = true;
            Caption = 'Field No.';
            NotBlank = true;
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo,"Table No.");
                if PAGE.RunModal(PAGE::"Npm Nav Field List",Field) = ACTION::LookupOK then
                  "Field No." := Field."No.";

                CalcFields("Field Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(20;"Language Id";Integer)
        {
            Caption = 'Language Id';
            NotBlank = true;
            TableRelation = "Windows Language";
        }
        field(25;Caption;Text[100])
        {
            Caption = 'Caption';
        }
        field(100;"Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Field Name";Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE (TableNo=FIELD("Table No."),
                                                        "No."=FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
        field(120;"Language Name";Text[80])
        {
            CalcFormula = Lookup("Windows Language".Name WHERE ("Language ID"=FIELD("Language Id")));
            Caption = 'Language Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(125;"Language Code";Text[30])
        {
            CalcFormula = Lookup("Windows Language"."Abbreviated Name" WHERE ("Language ID"=FIELD("Language Id")));
            Caption = 'Language Code';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Table No.","View Code","Field No.","Language Id")
        {
        }
    }

    fieldgroups
    {
    }
}

