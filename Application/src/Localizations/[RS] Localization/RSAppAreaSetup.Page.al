page 6150837 "NPR RS App. Area Setup"
{
    Extensible = false;
    Caption = 'RS Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

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
                field("NPR RS Fiscal"; Rec."NPR RS Local")
                {
                    ToolTip = 'Specifies the value of the NPR RS Localization field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
