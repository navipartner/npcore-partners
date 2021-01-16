page 6151026 "NPR NpRv Partners"
{
    Caption = 'Retail Voucher Partners';
    CardPageID = "NPR NpRv Partner Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Partner";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Service Url"; "Service Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Url field';
                }
                field("Service Username"; "Service Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Username field';
                }
                field("Service Password"; "Service Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Password field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Partner Relations action';
            }
        }
    }
}

