table 6014643 "NPR Tax Free Consolidation"
{
    Caption = 'Tax Free Consolidation';
    LookupPageID = "NPR Tax Free Consolidation";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Header Type"; Option)
        {
            Caption = 'Sales Header Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(4; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            DataClassification = CustomerContent;
        }
        field(6; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}

