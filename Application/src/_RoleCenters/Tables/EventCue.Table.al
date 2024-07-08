table 6060158 "NPR Event Cue"
{
    Access = Internal;
    Caption = 'Event Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(50; "Event List"; Integer)
        {
            CalcFormula = Count(Job WHERE("NPR Event" = CONST(true)));

            Caption = 'Event List';
            FieldClass = FlowField;
        }

        field(10; "Upcoming Events"; Integer)
        {
            CalcFormula = Count(Job WHERE("NPR Event" = CONST(true),
                                           "Starting Date" = FIELD("Date Filter")));
            Caption = 'Upcoming Events';
            FieldClass = FlowField;
        }
        field(20; "Completed Events"; Integer)
        {
            CalcFormula = Count(Job WHERE("NPR Event" = CONST(true),
                                           "NPR Event Status" = CONST(Completed)));
            Caption = 'Completed Events';
            FieldClass = FlowField;
        }
        field(30; "Cancelled Events"; Integer)
        {
            CalcFormula = Count(Job WHERE("NPR Event" = CONST(true),
                                           "NPR Event Status" = CONST(Cancelled)));
            Caption = 'Cancelled Events';
            FieldClass = FlowField;
        }
        field(40; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

