table 6059987 "Discount Cue"
{
    Caption = 'Discount Cue';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Mixed Discounts Active";Integer)
        {
            CalcFormula = Count("Mixed Discount" WHERE (Status=CONST(Active),
                                                        "Starting date"=FIELD("Start Date Filter"),
                                                        "Ending date"=FIELD("End Date Filter")));
            Caption = 'Mixed Discounts Active';
            FieldClass = FlowField;
        }
        field(3;"Period Discounts Active";Integer)
        {
            CalcFormula = Count("Period Discount" WHERE ("Starting Date"=FIELD("Start Date Filter"),
                                                         "Ending Date"=FIELD("End Date Filter")));
            Caption = 'Period Discounts Active';
            FieldClass = FlowField;
        }
        field(4;"Quantity Discounts Active";Integer)
        {
            CalcFormula = Count("Quantity Discount Header" WHERE (Status=CONST(Active),
                                                                  "Starting Date"=FIELD("Start Date Filter"),
                                                                  "Closing Date"=FIELD("End Date Filter")));
            Caption = 'Quantity Discounts Active';
            FieldClass = FlowField;
        }
        field(21;"Start Date Filter";Date)
        {
            Caption = 'Start Date Filter';
            FieldClass = FlowFilter;
        }
        field(22;"End Date Filter";Date)
        {
            Caption = 'End Date Filter';
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

