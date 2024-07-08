page 6059911 "NPR RS Fiscal App. Area Setup"
{
    Caption = 'RS Fiscal Application Area Setup';
    Extensible = false;
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = None;
    ObsoleteReason = 'Not used anymore.';
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR24.0';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Profile ID"; Rec."Profile ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Profile ID field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("NPR RS Fiscal"; Rec."NPR RS Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the NPR RS Fiscalization field.';
                }
            }
        }
    }
}
