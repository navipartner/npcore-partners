table 6059787 "Ticket Access Capacity Slots"
{
    // NPR4.16/TSA/20150807/CASE 219658 - Object Touched

    Caption = 'Access Capacity';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Slot ID"; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
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
                if TicketType.Get("Ticket Type Code") then
                    Description := TicketType.Description;
            end;
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
            Editable = true;
            InitValue = 1;
        }
        field(40; "Quantity Reserved"; Decimal)
        {
            CalcFormula = Sum ("Ticket Access Reservation".Quantity WHERE("Ticket Access Capacity Slot ID" = FIELD("Slot ID")));
            Caption = 'Access Reservatation';
            FieldClass = FlowField;
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

    trigger OnInsert()
    begin
        "Slot ID" := 0;
    end;
}

