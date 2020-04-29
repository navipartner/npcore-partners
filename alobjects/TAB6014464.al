table 6014464 "E-mail Template Filter"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains Field Filters for defining detailed Link with Table Records.
    // PN1.07/TTH/20151001  CASE 222376 PDF2NAV Changes. Added the field "Field Name".
    // PN1.08/MHA/20151214  CASE 228859 Changed Field 10 "Field Name" to Flowfield and removed retail reference

    Caption = 'E-mail Template Filter';

    fields
    {
        field(1;"E-mail Template Code";Code[20])
        {
            Caption = 'E-mail Template Code';
            TableRelation = "E-mail Template Header";
        }
        field(3;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(8;"Field No.";Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                //-PN1.08
                //"Field No." := "FieldRef Library".LookupFieldNum("Table No.");
                ////-PN1.07
                //"Field Name" := "FieldRef Library".GetFieldName("Table No.", "Field No.");
                ////-PN1.07
                Field.FilterGroup(2);
                Field.SetRange(TableNo,"Table No.");
                Field.FilterGroup(0);
                if PAGE.RunModal(PAGE::"Field List",Field) = ACTION::LookupOK then
                  "Field No." := Field."No.";
                //+PN1.08
            end;
        }
        field(9;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(10;"Field Name";Text[30])
        {
            CalcFormula = Lookup(Field.FieldName WHERE (TableNo=FIELD("Table No."),
                                                        "No."=FIELD("Field No.")));
            Caption = 'Field Name';
            Description = 'PN1.07,PN1.08';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"E-mail Template Code","Table No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

