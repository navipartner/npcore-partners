table 6059831 "NPR Chart Data Update Tracker"
{
    Access = Internal;
    Caption = 'Chart Data Update Tracker';
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Chart Page ID"; Integer)
        {
            Caption = 'Chart Page ID';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Replaced by field Chart Codeunit ID';
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
        }
        field(3; "Last Computed"; DateTime)
        {
            Caption = 'Last Computed';
            DataClassification = SystemMetadata;
        }
        field(4; Period; Option)
        {
            Caption = 'Period';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Next,Previous';
            OptionMembers = " ",Next,Previous;
        }
        field(5; "Period Type"; Option)
        {
            Caption = 'Period Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period,Period';
            OptionMembers = Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        }
        field(6; Dimension; Option)
        {
            Caption = 'Dimension';
            DataClassification = SystemMetadata;
            OptionCaption = 'Dimension 1,Dimension 2';
            OptionMembers = "Dimension 1","Dimension 2";
        }
        field(7; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = SystemMetadata;
        }
        field(8; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = SystemMetadata;
        }
        field(9; "Chart Codeunit ID"; Integer)
        {
            Caption = 'Chart Codeunit ID"';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}