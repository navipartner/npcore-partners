pageextension 6014431 "NPR Ship-to Address" extends "Ship-to Address"
{
    // NPR5.34/TR  /20170721  CASE 282454 Added "Name 2" to the list.
    layout
    {
        addafter(GLN)
        {
            field("NPR Name 2"; "Name 2")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}

