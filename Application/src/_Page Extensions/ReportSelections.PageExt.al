pageextension 6014426 "NPR Report Selections" extends "Report Selection - Sales"
{
    layout
    {
        addafter("Email Body Layout Description")
        {
            field("NPR Responsibility Center"; Rec."NPR Responsibility Center")
            {
                ToolTip = 'Specifies the value of the Responsibility Center';
                ApplicationArea = Location;
            }
        }
    }
}
