page 6014580 "Object Output Selection"
{
    // NPR4.15/MMV/20151002 CASE 223893 Added field 12
    // NPR5.22/MMV/20160414 CASE 228382 Added action "Google Cloud Print Setup"
    // NPR5.26/MMV /20160826 CASE 246209 Removed all actions.
    // NPR5.32/MMV /20170324 CASE 253590 Removed field 12.

    Caption = 'Object Output Selection';
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Google Cloud Print';
    SourceTable = "Object Output Selection";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150620)
            {
                ShowCaption = false;
                field("User ID";"User ID")
                {
                }
                field("Object Type";"Object Type")
                {
                }
                field("Object ID";"Object ID")
                {
                }
                field("Object Name";"Object Name")
                {
                }
                field("Print Template";"Print Template")
                {
                }
                field("Output Type";"Output Type")
                {
                }
                field("Output Path";"Output Path")
                {
                }
            }
        }
    }

    actions
    {
    }
}

