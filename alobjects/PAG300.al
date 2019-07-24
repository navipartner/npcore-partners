pageextension 50028 pageextension50028 extends "Ship-to Address" 
{
    // NPR5.34/TR  /20170721  CASE 282454 Added "Name 2" to the list.
    layout
    {
        addafter(GLN)
        {
            field("Name 2";"Name 2")
            {
                Importance = Additional;
            }
        }
    }
}

