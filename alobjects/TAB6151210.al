table 6151210 "NpCs Open. Hour Entry"
{
    // #362443/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Entry';

    fields
    {
        field(1;"Set Code";Code[20])
        {
            Caption = 'Set Code';
            NotBlank = true;
            TableRelation = "NpCs Open. Hour Set";
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Store Open,Store Closed';
            OptionMembers = "Store Open","Store Closed";

            trigger OnValidate()
            begin
                if "Entry Type" = "Entry Type"::"Store Closed" then begin
                  "Start Time" := 0T;
                  "End Time" := 0T;
                end;
            end;
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
            OptionCaption = 'Every Day,Weekly,Yearly,Date';
            OptionMembers = "Every Day",Weekly,Yearly,Date;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(25;Monday;Boolean)
        {
            Caption = 'Monday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(30;Tuesday;Boolean)
        {
            Caption = 'Tuesday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(35;Wednesday;Boolean)
        {
            Caption = 'Wednesday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(40;Thursday;Boolean)
        {
            Caption = 'Thursday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(45;Friday;Boolean)
        {
            Caption = 'Friday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(50;Saturday;Boolean)
        {
            Caption = 'Saturday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(55;Sunday;Boolean)
        {
            Caption = 'Sunday';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(65;"Entry Date";Date)
        {
            Caption = 'Entry Date';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(100;"Period Description";Text[250])
        {
            Caption = 'Period Description';
        }
    }

    keys
    {
        key(Key1;"Set Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure UpdatePeriodDescription()
    begin
        "Period Description" := '';
        case "Period Type" of
          "Period Type"::"Every Day":
            begin
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
          "Period Type"::Yearly,"Period Type"::Date:
            begin
              AppendPeriodDescription(Format("Entry Date"));
            end;
        end;
    end;

    local procedure AppendPeriodDescription(PeriodDescription: Text)
    begin
        if PeriodDescription = '' then
          exit;

        if "Period Description" <> '' then
          "Period Description" := CopyStr("Period Description" + ',' + PeriodDescription,1,MaxStrLen("Period Description"))
        else
          "Period Description" := CopyStr(PeriodDescription,1,MaxStrLen("Period Description"));
    end;
}

