table 6059773 "NPR Member Card Trx Log"
{

    Caption = 'Point Card - Transaction Log';
    DataClassification = CustomerContent;
    ObsoleteReason = 'Not used.';
    ObsoleteState = Removed;
    fields
    {
        field(1; "Transaction No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(2; "Card Code"; Code[20])
        {
            Caption = 'Card Code';
            DataClassification = CustomerContent;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(4; Points; Decimal)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(5; "Remaining Points"; Decimal)
        {
            Caption = 'Remaining points';
            DataClassification = CustomerContent;
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(10; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(15; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'For debit trace puposes';
            DataClassification = CustomerContent;
        }
        field(16; "Balancing Sales Ticket"; Code[20])
        {
            Caption = 'Balancing Sales Ticket';
            DataClassification = CustomerContent;
        }
        field(20; "Value Entry No."; Integer)
        {
            Caption = 'Value Entry No.';
            DataClassification = CustomerContent;
        }
        field(25; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(50; Company; Text[50])
        {
            Caption = 'Company';
            DataClassification = CustomerContent;
        }
        field(6059800; "Sent To Web"; Boolean)
        {
            Caption = 'Sent To Web';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
        key(Key2; "Card Code", "Posting Date")
        {
            SumIndexFields = Points, "Remaining Points";
        }
        key(Key3; "Card Code", "Posting Date", "Remaining Points")
        {
        }
        key(Key4; "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

}

