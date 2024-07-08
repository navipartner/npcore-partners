table 6059876 "NPR Total Disc. Time Interv."
{
    Access = Internal;
    Caption = 'Active Time Interval';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            TableRelation = "NPR Total Discount Header";
            DataClassification = CustomerContent;
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
        field(20; "Period Type"; Enum "NPR Discount Period Type")
        {
            Caption = 'Period Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(25; Monday; Boolean)
        {
            Caption = 'Monday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(30; Tuesday; Boolean)
        {
            Caption = 'Tuesday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(35; Wednesday; Boolean)
        {
            Caption = 'Wednesday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(40; Thursday; Boolean)
        {
            Caption = 'Thursday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(45; Friday; Boolean)
        {
            Caption = 'Friday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(50; Saturday; Boolean)
        {
            Caption = 'Saturday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
            end;
        }
        field(55; Sunday; Boolean)
        {
            Caption = 'Sunday';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
            begin
                NPRTotDiscTimeIntervUtils.UpdatePeriodDescription(Rec);
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
        key(Key1; "Total Discount Code", "Line No.")
        {
        }

#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key3; SystemRowVersion)
        {
        }
#ENDIF
    }

    trigger OnInsert()
    var
        NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
    begin
        NPRTotDiscTimeIntervUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnModify()
    var
        NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
    begin
        NPRTotDiscTimeIntervUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnDelete()
    var
        NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
    begin
        NPRTotDiscTimeIntervUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnRename()
    var
        NPRTotDiscTimeIntervUtils: Codeunit "NPR Tot Disc Time Interv Utils";
    begin
        NPRTotDiscTimeIntervUtils.CheckIfTotalDiscountEditable(Rec);
    end;

}

