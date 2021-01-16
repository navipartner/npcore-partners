page 6014580 "NPR Object Output Selection"
{
    // NPR4.15/MMV/20151002 CASE 223893 Added field 12
    // NPR5.22/MMV/20160414 CASE 228382 Added action "Google Cloud Print Setup"
    // NPR5.26/MMV /20160826 CASE 246209 Removed all actions.
    // NPR5.32/MMV /20170324 CASE 253590 Removed field 12.

    Caption = 'Object Output Selection';
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Google Cloud Print';
    SourceTable = "NPR Object Output Selection";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150620)
            {
                ShowCaption = false;
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object ID field';
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
                field("Print Template"; "Print Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Template field';
                }
                field("Output Type"; "Output Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Type field';
                }
                field("Output Path"; "Output Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Path field';
                }
            }
        }
    }

    actions
    {
    }
}

