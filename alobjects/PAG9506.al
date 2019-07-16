pageextension 50675 pageextension50675 extends "Session List" 
{
    // NPR70.00.00.00/TS/20150126 CASE 205355  Added Kill Session
    // NPR5.48/JDH /20181109 CASE 334163 Removed Space from Caption Kill session
    actions
    {
        addafter("Debug Next Session")
        {
            action("Kill Session")
            {
                Caption = 'Kill Session';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category4;
            }
        }
    }
}

