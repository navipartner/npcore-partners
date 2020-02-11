table 6151134 "TM Seating Reservation Entry"
{
    // TM1.43/TSA /20190903 CASE 357359 Initial Version
    // TM1.45/TSA /20191112 CASE 322432 Added index

    Caption = 'Seating Reservation Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(3;"External Schedule Entry No.";Integer)
        {
            Caption = 'External Schedule Entry No.';
        }
        field(10;ElementId;Integer)
        {
            Caption = 'ElementId';
        }
        field(20;"Reservation Status";Option)
        {
            Caption = 'Reservation Status';
            OptionCaption = 'Free,Free Special Need,Blocked,Reserved';
            OptionMembers = FREE,FREE_SPECIAL_NEED,BLOCKED,RESERVED;
        }
        field(30;"Ticket Token";Text[100])
        {
            Caption = 'Ticket Token';
        }
        field(40;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(50;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
        }
        field(51;"Schedule Code";Code[20])
        {
            Caption = 'Schedule Code';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"External Schedule Entry No.")
        {
        }
        key(Key3;"Ticket Token")
        {
        }
    }

    fieldgroups
    {
    }
}

