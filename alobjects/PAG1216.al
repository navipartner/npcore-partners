pageextension 50003 pageextension50003 extends "Data Exch Col Def Part" 
{
    // NPR5.27/BR  /20160928  CASE 252817 Added fields 6060073 Split File and 6060074 Split Value
    layout
    {
        addafter("Pad Character")
        {
            field("Split File";"Split File")
            {
            }
            field("Split Value";"Split Value")
            {
                Editable = "Split File"="Split File"::NewFileOnSplitVAlue;
            }
        }
    }
}

