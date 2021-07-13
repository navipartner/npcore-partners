page 6060100 "NPR POS Input Box Setup"
{

    UsageCategory = None;
    Caption = 'POS Input Box Setup';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
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

