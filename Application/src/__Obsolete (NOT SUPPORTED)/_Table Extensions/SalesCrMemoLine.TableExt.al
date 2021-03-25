tableextension 6014408 "NPR Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(6014408; "NPR Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014409; "NPR Special price"; Decimal)
        {
            Caption = 'Special price';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014602; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014603; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014604; "NPR Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. not Created';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT1.00';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT1.00';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}

