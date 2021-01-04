pageextension 6014402 "NPR Data Exch Col Def Part" extends "Data Exch Col Def Part"
{
    // NPR5.27/BR  /20160928  CASE 252817 Added fields 6060073 Split File and 6060074 Split Value
    layout
    {
        addafter("Pad Character")
        {
            field("NPR Split File"; "NPR Split File")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Split File field';
            }
            field("NPR Split Value"; "NPR Split Value")
            {
                ApplicationArea = All;
                Editable = "NPR Split File" = "NPR Split File"::NewFileOnSplitVAlue;
                ToolTip = 'Specifies the value of the NPR Split Value field';
            }
        }
    }
}

