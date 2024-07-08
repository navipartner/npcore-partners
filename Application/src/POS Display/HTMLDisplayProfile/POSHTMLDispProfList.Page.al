page 6150772 "NPR POS HTML Disp. Prof. List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR POS HTML Disp. Prof.";
    CardPageId = "NPR POS HTML Disp. Prof. Card";
    Extensible = false;
    Editable = false;
    Caption = 'HTML Display Profiles';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Profile Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a unique code to identify the profile.';

                }
                field(HTML; Rec."HTML Blob".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the HTML file, upload via the ''Upload File'' action';
                    Caption = 'HTML File';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Speccifies the description of the profile, to help distinguish between profiles.';
                }
            }
        }
    }
}