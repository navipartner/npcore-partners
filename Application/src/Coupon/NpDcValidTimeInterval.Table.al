﻿table 6151600 "NPR NpDc Valid Time Interval"
{
    Access = Internal;
    Caption = 'Extra Coupon Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
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
        field(20; "Period Type"; Option)
        {
            Caption = 'Period Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
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
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(30; Tuesday; Boolean)
        {
            Caption = 'Tuesday';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(35; Wednesday; Boolean)
        {
            Caption = 'Wednesday';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(40; Thursday; Boolean)
        {
            Caption = 'Thursday';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(45; Friday; Boolean)
        {
            Caption = 'Friday';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(50; Saturday; Boolean)
        {
            Caption = 'Saturday';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(55; Sunday; Boolean)
        {
            Caption = 'Sunday';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';

            trigger OnValidate()
            begin
                UpdatePeriodDescription();
            end;
        }
        field(100; "Period Description"; Text[250])
        {
            Caption = 'Period Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
        }
    }

    keys
    {
        key(Key1; "Coupon Type", "Line No.")
        {
        }
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

