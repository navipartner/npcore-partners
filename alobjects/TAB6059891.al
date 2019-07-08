table 6059891 "Npm View Condition"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm View Condition';

    fields
    {
        field(1;"Table No.";Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            NotBlank = true;
            TableRelation = "Npm View"."Table No." WHERE (Code=FIELD("View Code"));
        }
        field(5;"View Code";Code[20])
        {
            Caption = 'View Code';
            TableRelation = "Npm View".Code WHERE ("Table No."=FIELD("Table No."));
        }
        field(10;"Field No.";Integer)
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
                if PAGE.RunModal(PAGE::"Field List",Field) = ACTION::LookupOK then
                  "Field No." := Field."No.";

                CalcFields("Field Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(15;Value;Text[250])
        {
            Caption = 'Value';

            trigger OnLookup()
            var
                NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
            begin
                NpXmlTemplateMgt.LookupFieldValue("Table No.","Field No.",Value);
            end;
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
    }

    keys
    {
        key(Key1;"Table No.","View Code","Field No.")
        {
        }
    }

    fieldgroups
    {
    }
}

