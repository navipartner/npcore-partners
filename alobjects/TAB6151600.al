table 6151600 "NpDc Valid Time Interval"
{
    // NPR5.35/MHA /20170809  CASE 286355 Object created
    // NPR5.37/MHA /20171010  CASE 292171 Added Period Type and Weekday fields

    Caption = 'Extra Coupon Item';

    fields
    {
        field(1;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NpDc Coupon Type";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Start Time";Time)
        {
            Caption = 'Start Time';
        }
        field(15;"End Time";Time)
        {
            Caption = 'End Time';
        }
        field(20;"Period Type";Option)
        {
            Caption = 'Period Type';
            Description = 'NPR5.37';
            OptionCaption = 'Every Day,Weekly';
            OptionMembers = "Every Day",Weekly;

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(25;Monday;Boolean)
        {
            Caption = 'Monday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(30;Tuesday;Boolean)
        {
            Caption = 'Tuesday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(35;Wednesday;Boolean)
        {
            Caption = 'Wednesday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(40;Thursday;Boolean)
        {
            Caption = 'Thursday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(45;Friday;Boolean)
        {
            Caption = 'Friday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(50;Saturday;Boolean)
        {
            Caption = 'Saturday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(55;Sunday;Boolean)
        {
            Caption = 'Sunday';
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                //-NPR5.37 [292171]
                UpdatePeriodDescription();
                //+NPR5.37 [292171]
            end;
        }
        field(100;"Period Description";Text[250])
        {
            Caption = 'Period Description';
            Description = 'NPR5.37';
        }
    }

    keys
    {
        key(Key1;"Coupon Type","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure UpdatePeriodDescription()
    begin
        //-NPR5.37 [292171]
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
        //+NPR5.37 [292171]
    end;

    local procedure AppendPeriodDescription(PeriodDescription: Text)
    begin
        //-NPR5.37 [292171]
        if PeriodDescription = '' then
          exit;

        if "Period Description" <> '' then
          "Period Description" := CopyStr("Period Description" + ',' + PeriodDescription,1,MaxStrLen("Period Description"))
        else
          "Period Description" := CopyStr(PeriodDescription,1,MaxStrLen("Period Description"));
        //+NPR5.37 [292171]
    end;
}

