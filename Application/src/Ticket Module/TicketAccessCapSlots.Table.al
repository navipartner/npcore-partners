table 6059787 "NPR Ticket Access Cap. Slots"
{
    Caption = 'Access Capacity';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Slot ID"; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Ticket Type Code"; Code[10])
        {
            Caption = 'Ticket Type Code';
            DataClassification = CustomerContent;
        }
        field(10; "Access Date"; Date)
        {
            Caption = 'Access Date';
            DataClassification = CustomerContent;
        }
        field(11; "Access Start"; Time)
        {
            Caption = 'Access Time';
            DataClassification = CustomerContent;
        }
        field(12; "Access End"; Time)
        {
            Caption = 'Access End';
            DataClassification = CustomerContent;
        }
        field(13; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(31; Quantity; Decimal)
        {
            Caption = 'Point Card - Issued Cards';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Slot ID")
        {
        }
    }

    fieldgroups
    {
    }
}

