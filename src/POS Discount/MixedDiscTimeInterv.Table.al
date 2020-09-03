table 6014420 "NPR Mixed Disc. Time Interv."
{
    // NPR5.45/MHA /20180820  CASE 323568 Object created

    Caption = 'Active Time Interval';

    fields
    {
        field(1; "Mix Code"; Code[20])
        {
            Caption = 'MixCode';
            TableRelation = "NPR Mixed Discount";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Start Time"; Time)
        {
            Caption = 'Start Time';
        }
        field(15; "End Time"; Time)
        {
            Caption = 'End Time';
        }
        field(20; "Period Type"; Option)
        {
            Caption = 'Period Type';
            OptionCaption = 'Every Day,Weekly';
            OptionMembers = "Every Day",Weekly;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(25; Monday; Boolean)
        {
            Caption = 'Monday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(30; Tuesday; Boolean)
        {
            Caption = 'Tuesday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(35; Wednesday; Boolean)
        {
            Caption = 'Wednesday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(40; Thursday; Boolean)
        {
            Caption = 'Thursday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(45; Friday; Boolean)
        {
            Caption = 'Friday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(50; Saturday; Boolean)
        {
            Caption = 'Saturday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(55; Sunday; Boolean)
        {
            Caption = 'Sunday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(100; "Period Description"; Text[250])
        {
            Caption = 'Period Description';
        }
    }

    keys
    {
        key(Key1; "Mix Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure UpdatePeriodDescription()
    begin
        "Period Description" := '';
        if "Period Type" = "Period Type"::"Every Day" then
            exit;

        if Monday then
            AppendPeriodDescription(FieldCaption(Monday));
        if Tuesday then
            AppendPeriodDescription(FieldCaption(Tuesday));
        if Wednesday then
            AppendPeriodDescription(FieldCaption(Wednesday));
        if Thursday then
            AppendPeriodDescription(FieldCaption(Thursday));
        if Friday then
            AppendPeriodDescription(FieldCaption(Friday));
        if Saturday then
            AppendPeriodDescription(FieldCaption(Saturday));
        if Sunday then
            AppendPeriodDescription(FieldCaption(Sunday));
    end;

    local procedure AppendPeriodDescription(PeriodDescription: Text)
    begin
        if PeriodDescription = '' then
            exit;

        if "Period Description" <> '' then
            "Period Description" := CopyStr("Period Description" + ',' + PeriodDescription, 1, MaxStrLen("Period Description"))
        else
            "Period Description" := CopyStr(PeriodDescription, 1, MaxStrLen("Period Description"));
    end;
}

