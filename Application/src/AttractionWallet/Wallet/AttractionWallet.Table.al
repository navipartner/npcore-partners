table 6150937 "NPR AttractionWallet"
{
    Access = Internal;
    Caption = 'Attraction Wallet';
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }

        field(10; ReferenceNumber; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference Number';
        }

        field(15; OriginatesFromItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Originates From Item No.';
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

        field(40; PrintCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Print Count';
        }

        field(45; LastPrintAt; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Print Date';
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
#if not (BC17 or BC18)
            IncludedFields = ExpirationDate;
#endif
        }

    }

    fieldgroups
    {
        fieldgroup(DropDown; Description)
        {
        }
    }
}