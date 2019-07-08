page 6059893 "Npm Page Subform"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm Page Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Npm Page View";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("View Code";"View Code")
                {
                }
                field("Show Mandatory Fields";"Show Mandatory Fields")
                {
                }
                field("Show Field Captions";"Show Field Captions")
                {
                }
            }
        }
    }

    actions
    {
    }
}

