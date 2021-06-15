#pragma warning disable AL0432
tableextension 6014450 "NPR Sales Price" extends "Sales Price"
{
    fields
    {
        field(6059800; "NPR Value ID"; Integer)
        {
            Caption = 'Value ID';
            DataClassification = CustomerContent;
            Description = 'NPR7.000.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059972; "NPR Master Record Reference"; Text[250])
        {
            Caption = 'Master Record Reference';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6060000; "NPR Price Without Vat"; Decimal)
        {
            Caption = 'Price Without Vat';
            DataClassification = CustomerContent;
            Description = 'Field needed so we can sync normal to web//NPR7.000.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}
#pragma warning restore