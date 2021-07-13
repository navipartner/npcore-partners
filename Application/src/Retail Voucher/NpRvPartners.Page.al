page 6151026 "NPR NpRv Partners"
{
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Service Url"; Rec."Service Url")
                {

                    ToolTip = 'Specifies the value of the Service Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Service Username"; Rec."Service Username")
                {

                    ToolTip = 'Specifies the value of the Service Username field';
                    ApplicationArea = NPRRetail;
                }
                field("Service Password"; Rec."Service Password")
                {

                    ToolTip = 'Specifies the value of the Service Password field';
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

