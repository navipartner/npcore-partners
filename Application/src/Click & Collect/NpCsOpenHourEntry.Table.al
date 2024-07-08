table 6151210 "NPR NpCs Open. Hour Entry"
{
    Access = Internal;
    Caption = 'Collect Store Opening Hour Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Set Code"; Code[20])
        {
            Caption = 'Set Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpCs Open. Hour Set";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Entry Type"; Option)
        {
            Caption = 'Opening Type';
            DataClassification = CustomerContent;
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
        field(20; "Period Type"; Option)
        {
            Caption = 'Period Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Every Day,Weekly,Yearly,Date';
            OptionMembers = "Every Day",Weekly,Yearly,Date;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(25; Monday; Boolean)
        {
            Caption = 'Monday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(30; Tuesday; Boolean)
        {
            Caption = 'Tuesday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(35; Wednesday; Boolean)
        {
            Caption = 'Wednesday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(40; Thursday; Boolean)
        {
            Caption = 'Thursday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(45; Friday; Boolean)
        {
            Caption = 'Friday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(50; Saturday; Boolean)
        {
            Caption = 'Saturday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(55; Sunday; Boolean)
        {
            Caption = 'Sunday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(65; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(100; "Period Description"; Text[250])
        {
            Caption = 'Period Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Set Code", "Line No.")
        {
        }
    }

    local procedure UpdatePeriodDescription()
    begin
        "Period Description" := '';
        case "Period Type" of
            "Period Type"::"Every Day":
                begin
                    "Period Description" := Format("Period Type");
                end;
            "Period Type"::Weekly:
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
            "Period Type"::Yearly, "Period Type"::Date:
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
            "Period Description" := CopyStr("Period Description" + ',' + PeriodDescription, 1, MaxStrLen("Period Description"))
        else
            "Period Description" := CopyStr(PeriodDescription, 1, MaxStrLen("Period Description"));
    end;
}

