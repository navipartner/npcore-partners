pageextension 6014472 pageextension6014472 extends "Resource Groups" 
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

