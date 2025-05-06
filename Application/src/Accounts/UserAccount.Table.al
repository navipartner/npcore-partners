table 6151165 "NPR UserAccount"
{
    Access = Internal;
    Caption = 'User Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AccountNo; BigInteger)
        {
            Caption = 'Account No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; FirstName; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateDisplayName();
            end;
        }
        field(3; LastName; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateDisplayName();
            end;
        }
        field(6; DisplayName; Text[250])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
        }
        field(4; EmailAddress; Text[80])
        {
            Caption = 'E-mail Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(5; PhoneNo; Text[80])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
    }

    keys
    {
        key(PK; AccountNo)
        {
            Clustered = true;
        }
        key(ByCommunication; EmailAddress, PhoneNo)
        {
        }
    }

    local procedure UpdateDisplayName()
    begin
        Rec.DisplayName := Rec.FirstName + ' ' + Rec.LastName;
    end;
}