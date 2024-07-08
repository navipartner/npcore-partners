page 6150678 "NPR SS Profiles"
{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR SS Profile";
    Caption = 'POS Self Service Profiles';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/ss_profile/ss_profile/';
    Editable = false;
    CardPAgeID = "NPR SS Profile Card";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies unique identifier or product code for the item being purchased. Enter the code to quickly add the item to the transaction.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a brief description of the product or service. This helps both customers and staff identify the item during the checkout process.';
                    ApplicationArea = NPRRetail;
                }
                field("Kiosk Mode Unlock PIN"; Rec."Kiosk Mode Unlock PIN")
                {
                    ToolTip = 'Specifies secure PIN to unlock settings and permissions. This is necessary for authorized personnel to access and manage the self-service kiosk functionality.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
