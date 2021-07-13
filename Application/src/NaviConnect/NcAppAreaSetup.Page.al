page 6151230 "NPR Nc App. Area Setup"
{
    Caption = 'NaviConnect Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'NaviConnect Setup';
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
                field("NPR NaviConnect"; Rec."NPR NaviConnect")
                {
                    ToolTip = 'Specifies the value of the NPR NaviConnect field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
