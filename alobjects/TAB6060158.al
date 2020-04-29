table 6060158 "Event Cue"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

    Caption = 'Event Cue';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Upcoming Events";Integer)
        {
            CalcFormula = Count(Job WHERE (Event=CONST(true),
                                           "Starting Date"=FIELD("Date Filter")));
            Caption = 'Upcoming Events';
            FieldClass = FlowField;
        }
        field(20;"Completed Events";Integer)
        {
            CalcFormula = Count(Job WHERE (Event=CONST(true),
                                           "Event Status"=CONST(Completed)));
            Caption = 'Completed Events';
            FieldClass = FlowField;
        }
        field(30;"Cancelled Events";Integer)
        {
            CalcFormula = Count(Job WHERE (Event=CONST(true),
                                           "Event Status"=CONST(Completed)));
            Caption = 'Cancelled Events';
            FieldClass = FlowField;
        }
        field(40;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

