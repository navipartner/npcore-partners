pageextension 6014477 "NPR Resource Groups" extends "Resource Groups"
{
    // NPR5.29/TJ/20161124 CASE 248723 New field 6060150 E-Mail
    layout
    {
        addafter(Name)
        {
            field("NPR E-Mail"; "NPR E-Mail")
            {
                ApplicationArea = All;
            }
        }
    }
}

