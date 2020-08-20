table 6059788 "Ticket Access Reservation"
{
    // NPR4.16/TSA/20150807/CASE 219658 - Object Touched

    Caption = 'Ticket Access Reservation';
    DataClassification = CustomerContent;
    DrillDownPageID = "Ticket Access Reservation List";
    LookupPageID = "Ticket Access Reservation List";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
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
            TableRelation = "TM Ticket Type";

            trigger OnValidate()
            var
                TicketType: Record "TM Ticket Type";
            begin
                TicketType.Get("Ticket Type Code");
                Description := TicketType.Description;
            end;
        }
        field(10; "Ticket Access Capacity Slot ID"; BigInteger)
        {
            Caption = 'Ticket Access Capacity';
            DataClassification = CustomerContent;
            Editable = true;
            TableRelation = "Ticket Access Capacity Slots";

            trigger OnValidate()
            begin
                ValidateCapacitySlotID;
            end;
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
            Editable = true;
            InitValue = 1;
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
        key(Key2; "Ticket Access Capacity Slot ID")
        {
            SumIndexFields = Quantity;
        }
        key(Key3; "Sales Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        ValidateCapacitySlotID;
    end;

    procedure ValidateCapacitySlotID()
    var
        TicketAccessCapacitySlots: Record "Ticket Access Capacity Slots";
    begin
        TicketAccessCapacitySlots.Get("Ticket Access Capacity Slot ID");
        "Ticket Type Code" := TicketAccessCapacitySlots."Ticket Type Code";
        Description := TicketAccessCapacitySlots.Description;
    end;
}

