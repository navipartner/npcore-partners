table 6150931 "NPR WalletAssetLine"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; TransactionId; Guid)
        {
            Caption = 'Transaction Id';
            DataClassification = CustomerContent;
        }
        field(20; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(40; Type; Enum "NPR WalletLineType")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }

        field(41; LineTypeSystemId; Guid)
        {
            Caption = 'Line Type System Id';
            DataClassification = CustomerContent;
        }
        field(45; LineTypeReference; Text[100])
        {
            Caption = 'Line Type Reference';
            DataClassification = CustomerContent;
        }
        field(50; DocumentNumber; Code[20])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }

        field(100; TransferControlledBy; Enum "NPR WalletRole")
        {
            Caption = 'Transfer Controlled By';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; TransactionId, Type)
        {
            Clustered = false;
        }
        key(Key3; Type, LineTypeSystemId)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }


}