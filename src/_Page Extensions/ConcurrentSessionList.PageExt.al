pageextension 6014490 "NPR Concurrent Session List" extends "Concurrent Session List"
{
    // NPR70.00.00.00/TS/20150126 CASE 205355  Added Kill Session
    // NPR5.48/JDH /20181109 CASE 334163 Removed Space from Caption Kill session
    actions
    {
        addfirst(Processing)
        {
            action("NPR Kill Session")
            {
                Caption = 'Kill Session';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category4;
                ApplicationArea=All;
            }
        }
    }
}

