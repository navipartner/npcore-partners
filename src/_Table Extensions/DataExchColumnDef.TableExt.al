tableextension 6014412 "NPR Data Exch. Column Def" extends "Data Exch. Column Def"
{
    // NPR5.27/BR  /20160928  CASE 252817 Added fields 6060073 Split File and 6060074 Split Value
    // NPR5.48/JDH /20181109 CASE 334163 Added caption to field Split File
    fields
    {
        field(6060073; "NPR Split File"; Option)
        {
            Caption = 'Split File';
            DataClassification = CustomerContent;
            Description = 'NPR5.27';
            OptionCaption = ' ,One File per Value,New file on Split Value';
            OptionMembers = " ",OneFileperValue,NewFileOnSplitValue;
        }
        field(6060074; "NPR Split Value"; Text[30])
        {
            Caption = 'Split Value';
            DataClassification = CustomerContent;
            Description = 'NPR5.27';
        }
    }
}

