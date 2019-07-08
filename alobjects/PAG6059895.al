page 6059895 "Npm Caption Subform"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm Caption Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "Npm Field Caption";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Language Id";"Language Id")
                {
                }
                field("Language Name";"Language Name")
                {
                }
                field("Language Code";"Language Code")
                {
                }
                field(Caption;Caption)
                {
                }
            }
        }
    }

    actions
    {
    }
}

