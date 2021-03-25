tableextension 6014413 "NPR Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(6014602; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014603; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014604; "NPR Label"; Boolean)
        {
            Caption = 'Label';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6151051; "NPR Retail Replenishment No."; Integer)
        {
            Caption = 'Retail Replenisment No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38.01';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}

