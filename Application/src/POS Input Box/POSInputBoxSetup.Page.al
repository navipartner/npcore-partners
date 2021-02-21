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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View field';
                }
            }
            part(Control6014402; "NPR POS Input Box Setup Events")
            {
                SubPageLink = "Setup Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    var
        ShowDeleteFields: Boolean;
        ShowRenameFields: Boolean;
}

