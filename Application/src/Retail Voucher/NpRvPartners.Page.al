page 6151026 "NPR NpRv Partners"
{
    Extensible = False;
    Caption = 'Retail Voucher Partners';
    CardPageID = "NPR NpRv Partner Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Partner";
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
                    ToolTip = 'Specifies the code of the partner';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the partner';
                    ApplicationArea = NPRRetail;
                }
                field("Service Url"; Rec."Service Url")
                {
                    ToolTip = 'Specifies the service URL of the partner.';
                    ApplicationArea = NPRRetail;
                }
                field(AuthType; Rec.AuthType)
                {
                    ToolTip = 'Specifies the authorization type that the partner will use';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Partner Code" = FIELD(Code);

                ToolTip = 'Executes the Partner Relations action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

