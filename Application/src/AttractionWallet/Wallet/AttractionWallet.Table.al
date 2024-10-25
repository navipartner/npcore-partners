table 6150937 "NPR AttractionWallet"
{
    Access = Internal;
    DataClassification = CustomerContent;
    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }

        field(10; ReferenceNumber; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference Number';
        }

        field(20; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(30; ExpirationDate; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Expiration Date';
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }

        key(Key2; ReferenceNumber)
        {
            Clustered = false;
        }

    }

    fieldgroups
    {
        fieldgroup(DropDown; Description)
        {
        }
    }
}