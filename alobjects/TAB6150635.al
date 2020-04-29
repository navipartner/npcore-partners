table 6150635 "POS Posting Log"
{
    // NPR5.36/BR  /20170718  CASE 279551 Object Created
    // NPR5.36/BR  /20170814  CASE 277096 Added LookupPageID and DrillDownPageID
    // NPR5.38/BR  /20180119  CASE 302791 Added field Posting Duration

    Caption = 'POS Posting Log';
    DrillDownPageID = "POS Posting Log";
    LookupPageID = "POS Posting Log";

    fields
    {
        field(10;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(20;"Posting Timestamp";DateTime)
        {
            Caption = 'Posting Timestamp';
        }
        field(21;"Posting Duration";Duration)
        {
            Caption = 'Posting Duration';
            Description = 'NPR5.38';
        }
        field(30;"User ID";Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
        }
        field(40;"With Error";Boolean)
        {
            Caption = 'With Error';
        }
        field(50;"Error Description";Text[250])
        {
            Caption = 'Error Description';
        }
        field(60;"POS Entry View";Text[250])
        {
            Caption = 'POS Entry View';
        }
        field(61;"Last POS Entry No. at Posting";Integer)
        {
            Caption = 'Last POS Entry No. at Posting';
            TableRelation = "POS Entry";
        }
        field(90;"No. of POS Entries";Integer)
        {
            CalcFormula = Count("POS Entry" WHERE ("POS Posting Log Entry No."=FIELD("Entry No.")));
            Caption = 'No. of POS Entries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200;"Parameter Posting Date";Date)
        {
            Caption = 'Parameter Posting Date';
        }
        field(201;"Parameter Replace Posting Date";Boolean)
        {
            Caption = 'Parameter Replace Posting Date';
        }
        field(202;"Parameter Replace Doc. Date";Boolean)
        {
            Caption = 'Parameter Replace Doc. Date';
        }
        field(205;"Parameter Post Item Entries";Boolean)
        {
            Caption = 'Parameter Post Item Entries';
        }
        field(206;"Parameter Post POS Entries";Boolean)
        {
            Caption = 'Parameter Post POS Entries';
        }
        field(207;"Parameter Post Compressed";Boolean)
        {
            Caption = 'Parameter Post Compressed';
        }
        field(208;"Parameter Stop On Error";Boolean)
        {
            Caption = 'Parameter Stop On Error';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

