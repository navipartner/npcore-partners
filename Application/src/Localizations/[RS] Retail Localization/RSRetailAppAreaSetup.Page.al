page 6150836 "NPR RS Retail App. Area Setup"
{
    Caption = 'RS Retail Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = None;
    ObsoleteReason = 'Not used anymore.';
    ObsoleteState = Pending;
    ObsoleteTag = '2023-07-28';
    Extensible = false;

    layout
    {
        area(Content)
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
                field("NPR RS R Local"; Rec."NPR RS R Local")
                {
                    ToolTip = 'Specifies the value of the NPR RS Retail Localization field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
