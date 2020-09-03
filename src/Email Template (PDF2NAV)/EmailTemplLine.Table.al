table 6014463 "NPR E-mail Templ. Line"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains the e-mail body lines connected to the PDF2NAV E-mail Template.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'E-mail Template Line';

    fields
    {
        field(1; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            TableRelation = "NPR E-mail Template Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Mail Body Line"; Text[250])
        {
            Caption = 'Mail Body Line';
        }
    }

    keys
    {
        key(Key1; "E-mail Template Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

