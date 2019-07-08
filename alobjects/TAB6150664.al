table 6150664 "NPRE Flow Status"
{
    // NPR5.34/ANEN  /20170717  CASE 262628 Added support for status
    // NPR5.34/NPKNAV/20170801  CASE 283328 Transport NPR5.34 - 1 August 2017
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Status';
    DrillDownPageID = "NPRE Flow Status";
    LookupPageID = "NPRE Flow Status";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;"Status Object";Option)
        {
            Caption = 'Status Object';
            OptionCaption = 'Seating,Waiter Pad,Waiter Pad Line Meal Flow,Waiter Pad Line Status';
            OptionMembers = Seating,WaiterPad,WaiterPadLineMealFlow,WaiterPadLineStatus;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(6;"Flow Order";Integer)
        {
            Caption = 'Flow Order';
        }
    }

    keys
    {
        key(Key1;"Code","Status Object")
        {
        }
        key(Key2;"Status Object","Flow Order")
        {
        }
    }

    fieldgroups
    {
    }
}

