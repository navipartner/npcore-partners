tableextension 6014419 "NPR G/L Account" extends "G/L Account"
{
    fields
    {
        field(6014400; "NPR Retail Payment"; Boolean)
        {
            Caption = 'NPR payment';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Aux. G/L Account."';
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014404; "NPR Sales Ticket No. Filter"; Code[10])
        {
            Caption = 'Sales Ticket No. Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014405; "NPR Is Retail Payment"; Boolean)
        {
            Caption = 'Retail Payment';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Aux. G/L Account"."Retail Payment" where("No." = field("No.")));
        }
    }
}

