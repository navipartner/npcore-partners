page 6059793 "NPR E-mail Templ. Subform"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    AutoSplitKey = true;
    Caption = 'E-mail Template Subform';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR E-mail Templ. Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Mail Body Line"; Rec."Mail Body Line")
                {

                    ToolTip = 'Specifies the value of the Mail Body Line field';
                    ApplicationArea = NPRLegacyEmail;
                }
            }
        }
    }

}

