table 6014613 "NPR APIV1 Store Opening Buffer"
{
    Caption = 'Collect Store Opening Hour Date';
    DataClassification = CustomerContent;
    TableType = Temporary;
    fields
    {
        field(1; Store; Code[20])
        {
            Caption = 'Collect Store';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store";
        }
        field(5; "Calendar Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(10; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(15; "End Time"; Time)
        {
            Caption = 'End Time';
            DataClassification = CustomerContent;
        }
        field(1000; Weekday; Text[31])
        {
            CalcFormula = Lookup(Date."Period Name" WHERE("Period Type" = CONST(Date),
                                                           "Period Start" = FIELD("Calendar Date")));
            Caption = 'Weekday';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Store, "Calendar Date", "Start Time", "End Time")
        {
        }
    }
}

