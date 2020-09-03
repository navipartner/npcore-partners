table 6014643 "NPR Tax Free Consolidation"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Consolidation';
    LookupPageID = "NPR Tax Free Consolidation";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(3; "Sales Header Type"; Option)
        {
            Caption = 'Sales Header Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(4; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
        }
        field(6; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

