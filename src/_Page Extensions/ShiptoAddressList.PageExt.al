pageextension 6014432 "NPR Ship-to Address List" extends "Ship-to Address List"
{
    // NPR5.34/TR  /20170721  CASE 282454 Added "Name 2" to the list.
    layout
    {
        addafter(Name)
        {
            field("NPR Name 2"; "Name 2")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
}

