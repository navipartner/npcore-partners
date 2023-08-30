page 6150757 "NPR HeyLoyalty App. Area Setup"
{
    Extensible = False;
    Caption = 'HeyLoyalty Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = None;
    AdditionalSearchTerms = 'HeyLoyalty Setup';
    ObsoleteReason = 'Replaced by page 6151094 "NPR Feature Management"';
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR24.0';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Profile ID"; Rec."Profile ID")
                {
                    ToolTip = 'Specifies the value of the Profile ID field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR HeyLoyalty"; Rec."NPR HeyLoyalty")
                {
                    ToolTip = 'Specifies the value of the NPR HeyLoyalty field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
