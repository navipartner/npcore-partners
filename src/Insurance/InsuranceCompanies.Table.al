table 6014516 "NPR Insurance Companies"
{
    Caption = 'Insurance Companies';
    LookupPageID = "NPR Insurance Companies";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(4; "ZIP Code"; Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = "Post Code".Code;

            trigger OnValidate()
            var
                postby: Record "Post Code";
            begin
                if postby.Get("ZIP Code") then
                    City := postby.City;
            end;
        }
        field(5; City; Text[100])
        {
            Caption = 'City';
        }
        field(6; "Phone No."; Code[20])
        {
            Caption = 'Phone No.';
        }
        field(7; "FIK/Giro No."; Code[30])
        {
            Caption = 'FIK/Giro No.';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

