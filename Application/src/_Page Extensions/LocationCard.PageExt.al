pageextension 6014460 "NPR Location Card" extends "Location Card"
{
    // NPR5.26/JLK /20160905  CASE 251231 Added field Store Group Code
    layout
    {
        addafter("Use As In-Transit")
        {
            field("NPR Store Group Code"; "NPR Store Group Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Store Group Code field';
            }
        }
    }
}

