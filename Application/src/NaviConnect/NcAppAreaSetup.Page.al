﻿page 6151230 "NPR Nc App. Area Setup"
{
    Extensible = False;
    Caption = 'NaviConnect Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = None;
    AdditionalSearchTerms = 'NaviConnect Setup';
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
                field("NPR NaviConnect"; Rec."NPR NaviConnect")
                {
                    ToolTip = 'Specifies the value of the NPR NaviConnect field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
