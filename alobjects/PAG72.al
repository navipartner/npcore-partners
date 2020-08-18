pageextension 6014477 pageextension6014477 extends "Resource Groups" 
{
    // NPR5.29/TJ/20161124 CASE 248723 New field 6060150 E-Mail
    layout
    {
        addafter(Name)
        {
            field("E-Mail";"E-Mail")
            {
            }
        }
    }
}

