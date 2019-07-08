page 6151094 "Nc RapidConnect Trigger Fields"
{
    // NC2.14/MHA /20180716  CASE 322308 Object created - Partial Trigger functionality

    Caption = 'RapidConnect Trigger Fields';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Nc RapidConnect Trigger Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

