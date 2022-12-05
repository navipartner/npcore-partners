page 6151231 "NPR App. Area Setup"
{
    Extensible = False;
    Caption = 'NPR Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'NaviPartner Setup';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name.';
                    ApplicationArea = NPRRetail;
                }
                field("Profile ID"; Rec."Profile ID")
                {
                    ToolTip = 'Specifies the value of the Profile ID.';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Retail"; Rec."NPR Retail")
                {
                    ToolTip = 'Specifies the value of the NPR Retail.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
