#pragma warning disable AL0432
tableextension 6014451 "NPR Purchase Price" extends "Purchase Price"

{
    fields
    {
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
    }
}
#pragma warning restore