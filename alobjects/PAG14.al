pageextension 6014413 pageextension6014413 extends "Salespersons/Purchasers" 
{
    // NPR5.55/ALPO/20200525 CASE 405661 New column "Supervisor POS"
    layout
    {
        addafter("Privacy Blocked")
        {
            field("Supervisor POS";"Supervisor POS")
            {
            }
        }
    }
}

