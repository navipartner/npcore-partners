table 6059788 "NPR Ticket Access Reserv."
{
    Caption = 'Ticket Access Reservation';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(3; "Ticket Type Code"; Code[10])
        {
            Caption = 'Ticket Type Code';
            DataClassification = CustomerContent;
        }
        field(10; "Ticket Access Capacity Slot ID"; Integer)
        {
            Caption = 'Ticket Access Capacity';
            DataClassification = CustomerContent;
        }
        field(12; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(21; "Member Card Code"; Code[10])
        {
            Caption = 'Point Card - Issued Cards';
            DataClassification = CustomerContent;
        }
        field(31; Quantity; Decimal)
        {
            Caption = 'Point Card - Issued Cards';
            DataClassification = CustomerContent;
        }
        field(61; "Sales Header Type"; Option)
        {
            Caption = 'Sales Header Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(62; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            DataClassification = CustomerContent;
        }
        field(63; "Sales Ticket No."; Code[20])
        {
            Caption = 'POS Reciept No.';
            DataClassification = CustomerContent;
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

