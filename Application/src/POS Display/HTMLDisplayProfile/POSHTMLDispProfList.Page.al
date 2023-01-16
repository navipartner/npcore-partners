page 6150772 "NPR POS HTML Disp. Prof. List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR POS HTML Disp. Prof.";
    CardPageId = "NPR POS HTML Disp. Prof. Card";
    Extensible = false;
    Editable = false;
    Caption = 'HTML Display Profiles List';
#IF NOT BC17
    AboutTitle = 'HTML Display Profile List';
    AboutText = 'This page is a list of the HTML display profiles, which each can be used for multiple POS Units.';
#ENDIF

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
#IF NOT BC17
                    AboutTitle = 'Profile Code';
                    AboutText = 'Specifies a unique code to identify the profile.';
#ENDIF

                }
                field(HTML; Rec."HTML Blob".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the HTML file, upload via the ''Upload File'' action';
                    Caption = 'HTML File';
#IF NOT BC17
                    AboutTitle = 'HTML Blob';
                    AboutText = 'Specifies the HTML file, upload via the ''Upload File'' action';
#ENDIF
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Speccifies the description of the profile, to help distinguish between profiles.';
#IF NOT BC17
                    AboutTitle = 'Description';
                    AboutText = 'Speccifies the description of the profile, to help distinguish between profiles.';
#ENDIF
                }
            }
        }
    }
}