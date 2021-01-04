pageextension 6014413 "NPR Salespersons/Purchasers" extends "Salespersons/Purchasers"
{
    // NPR5.55/ALPO/20200525 CASE 405661 New column "Supervisor POS"
    layout
    {
        addafter("Privacy Blocked")
        {
            field("NPR Supervisor POS"; "NPR Supervisor POS")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Supervisor POS field';
            }
        }
    }
}

