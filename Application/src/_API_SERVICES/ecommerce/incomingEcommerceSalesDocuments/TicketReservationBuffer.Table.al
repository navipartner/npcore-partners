#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6151264 "NPR Ticket Reservation Buffer"
{
    Access = Internal;
    Caption = 'Ticket Reservation Remap Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Document Entry No."; BigInteger)
        {
            Caption = 'Document Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[150])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "Ticket Reservation Line Id"; Guid)
        {
            Caption = 'Ticket Reservation Line Id';
            DataClassification = CustomerContent;
        }
        field(10; "Session Token ID"; Text[100])
        {
            Caption = 'Session Token ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(DocumentLine; "Document Entry No.", "Sales Line No.")
        {
        }
    }
}
#endif
