page 6060100 "NPR POS Input Box Setup"
{
    Extensible = False;

    UsageCategory = None;
    Caption = 'POS Input Box Setup';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/reference/input_box_profile/input_box_profile/';
    SourceTable = "NPR Ean Box Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique code of the profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = '	Specifies the short description of a profile.';
                    ApplicationArea = NPRRetail;
                }
                field("POS View"; Rec."POS View")
                {

                    ToolTip = 'Specifies the value of the POS View field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6014402; "NPR POS Input Box Setup Events")
            {
                SubPageLink = "Setup Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
    }

}

