page 6059789 "NPR Member App. Area Setup"
{
    Extensible = False;
    Caption = 'Membership Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Membership Setup';
    ApplicationArea = NPRRetail;


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
                field("NPR Membership Essential"; Rec."NPR Membership Essential")
                {
                    ToolTip = 'Specifies the value of the NPR Membership Essential field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Membership Advanced"; Rec."NPR Membership Advanced")
                {
                    ToolTip = 'Specifies the value of the NPR Membership Advanced field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
