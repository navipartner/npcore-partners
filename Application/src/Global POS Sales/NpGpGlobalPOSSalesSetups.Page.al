page 6151171 "NPR NpGp Global POSSalesSetups"
{
    Caption = 'Global POS Sales Setups';
    CardPageID = "NPR NpGp POS Sales Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Setup";
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                    ;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                    ;
                }
                field("Service Url"; Rec."Service Url")
                {

                    ToolTip = 'Specifies the value of the Service Url field';
                    ApplicationArea = NPRRetail;
                    ;
                }
            }
        }
    }

    actions
    {
    }
}

