tableextension 6014436 "NPR Invoice Post. Buffer" extends "Invoice Post. Buffer"
{
    fields
    {
        field(6014400; "NPR Purchase / Sales lineno."; Integer)
        {
            Caption = 'Purchase / Sales lineno.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014401; "NPR Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}