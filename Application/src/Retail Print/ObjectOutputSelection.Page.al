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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Control6150620)
            {
                ShowCaption = false;
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object ID"; Rec."Object ID")
                {

                    ToolTip = 'Specifies the value of the Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Object Name")
                {

                    ToolTip = 'Specifies the value of the Object Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template"; Rec."Print Template")
                {

                    ToolTip = 'Specifies the value of the Print Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Type"; Rec."Output Type")
                {

                    ToolTip = 'Specifies the value of the Output Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Path"; Rec."Output Path")
                {

                    ToolTip = 'Specifies the value of the Output Path field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

