page 6150710 "NPR POS View List"
{
    Extensible = False;
    Caption = 'POS View List';
    ContextSensitiveHelpPage = 'retail/pos_profiles/reference/POS_view_profile.html';
    CardPageID = "NPR POS View Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS View";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code for the POS View';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the POS View ';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
