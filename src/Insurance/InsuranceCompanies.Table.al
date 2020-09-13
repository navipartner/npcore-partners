table 6014516 "NPR Insurance Companies"
{
    Caption = 'Insurance Companies';
    LookupPageID = "NPR Insurance Companies";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(4; "ZIP Code"; Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = "Post Code".Code;
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
        }
        field(6; "Phone No."; Code[20])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(7; "FIK/Giro No."; Code[30])
        {
            Caption = 'FIK/Giro No.';
            DataClassification = CustomerContent;
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

