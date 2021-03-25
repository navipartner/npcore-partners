tableextension 6014412 "NPR Data Exch. Column Def" extends "Data Exch. Column Def"
{
    fields
    {
        field(6060073; "NPR Split File"; Option)
        {
            Caption = 'Split File';
            DataClassification = CustomerContent;
            Description = 'NPR5.27';
            OptionCaption = ' ,One File per Value,New file on Split Value';
            OptionMembers = " ",OneFileperValue,NewFileOnSplitValue;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6060074; "NPR Split Value"; Text[30])
        {
            Caption = 'Split Value';
            DataClassification = CustomerContent;
            Description = 'NPR5.27';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
    }
}

