pageextension 70000214 pageextension70000214 extends "Ship-to Address List" 
{
    // NPR5.34/TR  /20170721  CASE 282454 Added "Name 2" to the list.
    layout
    {
        addafter(Name)
        {
            field("Name 2";"Name 2")
            {
                Visible = false;
            }
        }
    }
}

