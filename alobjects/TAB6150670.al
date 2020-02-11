table 6150670 "NPRE Flow Status Pr.Category"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Flow Status Print Category';
    DrillDownPageID = "NPRE Flow Status Pr.Categories";
    LookupPageID = "NPRE Flow Status Pr.Categories";

    fields
    {
        field(1;"Flow Status Object";Option)
        {
            Caption = 'Flow Status Object';
            OptionCaption = 'Seating,Waiter Pad,Waiter Pad Line Meal Flow,Waiter Pad Line Status';
            OptionMembers = Seating,WaiterPad,WaiterPadLineMealFlow,WaiterPadLineStatus;
        }
        field(2;"Flow Status Code";Code[10])
        {
            Caption = 'Flow Status Code';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=FIELD("Flow Status Object"));
        }
        field(3;"Print Category Code";Code[20])
        {
            Caption = 'Print Category Code';
            NotBlank = true;
            TableRelation = "NPRE Print Category";
        }
    }

    keys
    {
        key(Key1;"Flow Status Object","Flow Status Code","Print Category Code")
        {
        }
    }

    fieldgroups
    {
    }
}

