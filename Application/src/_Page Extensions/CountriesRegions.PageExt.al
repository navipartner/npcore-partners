pageextension 6014429 "NPR Countries/Regions" extends "Countries/Regions"
{
    layout
    {
        addafter("ISO Numeric Code")
        {
            field("NPR HL Country ID"; Rec."NPR HL Country ID")
            {
                ToolTip = 'Specifies the id used for the country at HeyLoyalty.';
                ApplicationArea = NPRHeyLoyalty;
            }
        }
    }
}