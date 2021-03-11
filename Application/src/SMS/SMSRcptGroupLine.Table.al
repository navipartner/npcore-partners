table 6014503 "NPR SMS Rcpt. Group Line"
{
    Caption = 'SMS Recipient Group Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Group Code"; Code[10])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; "Mobile Phone No."; Text[20])
        {
            Caption = 'Mobile Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
            trigger OnValidate()
            begin
                if (DelChr("Mobile Phone No.", '<=>', '+1234567890 ') <> '') then
                    FieldError("Mobile Phone No.", PhoneNoCannotContainLettersErr);
            end;
        }
    }
    keys
    {
        key(PK; "Group Code", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        PhoneNoCannotContainLettersErr: Label 'must not contain letters';
}
