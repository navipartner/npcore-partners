table 6060064 "EAN Prefix per Country"
{
    // NPR5.46/TJ  /20180913 CASE 327838 New object

    Caption = 'EAN Prefix per Country';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;Prefix;Code[10])
        {
            Caption = 'Prefix';
            Numeric = true;
        }
        field(20;"Country Code";Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "Country/Region";
        }
        field(21;"Country Name";Text[50])
        {
            CalcFormula = Lookup("Country/Region".Name WHERE (Code=FIELD("Country Code")));
            Caption = 'Country Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Country Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        EANPrefixPerCountry: Record "EAN Prefix per Country";
    begin
        "Entry No." := 1;
        if EANPrefixPerCountry.FindLast then
          "Entry No." := EANPrefixPerCountry."Entry No." + 1;
    end;
}

