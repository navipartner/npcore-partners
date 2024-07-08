page 6014647 "NPR Tax Free GB I2 Param."
{
    Extensible = False;
    Caption = 'Tax Free GB I2 Parameters';
    PageType = Card;
    SourceTable = "NPR Tax Free GB I2 Param.";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(Required)
            {
                group(General)
                {
                    field("Shop ID"; Rec."Shop ID")
                    {

                        ToolTip = 'Specifies the value of the Shop ID field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Desk ID"; Rec."Desk ID")
                    {

                        ToolTip = 'Specifies the value of the Desk ID field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Username; Rec.Username)
                    {

                        ToolTip = 'Specifies the value of the Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Password; Rec.Password)
                    {

                        ToolTip = 'Specifies the value of the Password field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Consolidation Allowed"; Rec."Consolidation Allowed")
                    {

                        ToolTip = 'Specifies the value of the Consolidation Allowed field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Consolidation Separate Limits"; Rec."Consolidation Separate Limits")
                    {

                        ToolTip = 'Specifies the value of the Consolidation Separate Limits field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Issue Date Limit"; Rec."Voucher Issue Date Limit")
                    {

                        ToolTip = 'Specifies the value of the Voucher Issue Date Limit field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Services Eligible"; Rec."Services Eligible")
                    {

                        ToolTip = 'Specifies the value of the Services Eligible field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Count Zero VAT Goods For Limit"; Rec."Count Zero VAT Goods For Limit")
                    {

                        ToolTip = 'Specifies the value of the Count Zero VAT Goods For Limit field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Dialog")
                {
                    field("(Dialog) Passport Number"; Rec."(Dialog) Passport Number")
                    {

                        ToolTip = 'Specifies the value of the Passport Number field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) First Name"; Rec."(Dialog) First Name")
                    {

                        ToolTip = 'Specifies the value of the First Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Last Name"; Rec."(Dialog) Last Name")
                    {

                        ToolTip = 'Specifies the value of the Last Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Street"; Rec."(Dialog) Street")
                    {

                        ToolTip = 'Specifies the value of the Street field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Postal Code"; Rec."(Dialog) Postal Code")
                    {

                        ToolTip = 'Specifies the value of the Postal Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Town"; Rec."(Dialog) Town")
                    {

                        ToolTip = 'Specifies the value of the Town field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Country Code"; Rec."(Dialog) Country Code")
                    {

                        ToolTip = 'Specifies the value of the Country Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Email"; Rec."(Dialog) Email")
                    {

                        ToolTip = 'Specifies the value of the Email field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Mobile No."; Rec."(Dialog) Mobile No.")
                    {

                        ToolTip = 'Specifies the value of the Mobile No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Passport Country Code"; Rec."(Dialog) Passport Country Code")
                    {

                        ToolTip = 'Specifies the value of the Passport Country Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Date Of Birth"; Rec."(Dialog) Date Of Birth")
                    {

                        ToolTip = 'Specifies the value of the Date Of Birth field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Departure Date"; Rec."(Dialog) Departure Date")
                    {

                        ToolTip = 'Specifies the value of the Departure Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Arrival Date"; Rec."(Dialog) Arrival Date")
                    {

                        ToolTip = 'Specifies the value of the Arrival Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("(Dialog) Dest. Country Code"; Rec."(Dialog) Dest. Country Code")
                    {

                        ToolTip = 'Specifies the value of the Dest. Country Code field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Automatic)
            {
                Editable = false;
                field("Shop Country Code"; Rec."Shop Country Code")
                {

                    ToolTip = 'Specifies the value of the Shop Country Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Last Auto Configured"; Rec."Date Last Auto Configured")
                {

                    ToolTip = 'Specifies the value of the Date Last Auto Configured field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Services)
            {
                Caption = 'Services';
                Image = ServiceLedger;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Tax Free GB I2 Serv. List";
                RunPageLink = "Tax Free Unit" = FIELD("Tax Free Unit");

                ToolTip = 'Executes the Services action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

