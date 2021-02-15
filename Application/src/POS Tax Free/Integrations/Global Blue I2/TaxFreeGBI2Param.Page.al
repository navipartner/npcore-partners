page 6014647 "NPR Tax Free GB I2 Param."
{
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shop ID field';
                    }
                    field("Desk ID"; Rec."Desk ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Desk ID field';
                    }
                    field(Username; Rec.Username)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Username field';
                    }
                    field(Password; Rec.Password)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Password field';
                    }
                    field("Consolidation Allowed"; Rec."Consolidation Allowed")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Consolidation Allowed field';
                    }
                    field("Consolidation Separate Limits"; Rec."Consolidation Separate Limits")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Consolidation Separate Limits field';
                    }
                    field("Voucher Issue Date Limit"; Rec."Voucher Issue Date Limit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Issue Date Limit field';
                    }
                    field("Services Eligible"; Rec."Services Eligible")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Services Eligible field';
                    }
                    field("Count Zero VAT Goods For Limit"; Rec."Count Zero VAT Goods For Limit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Count Zero VAT Goods For Limit field';
                    }
                }
                group("Dialog")
                {
                    field("(Dialog) Passport Number"; Rec."(Dialog) Passport Number")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Passport Number field';
                    }
                    field("(Dialog) First Name"; Rec."(Dialog) First Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the First Name field';
                    }
                    field("(Dialog) Last Name"; Rec."(Dialog) Last Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Last Name field';
                    }
                    field("(Dialog) Street"; Rec."(Dialog) Street")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Street field';
                    }
                    field("(Dialog) Postal Code"; Rec."(Dialog) Postal Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Postal Code field';
                    }
                    field("(Dialog) Town"; Rec."(Dialog) Town")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Town field';
                    }
                    field("(Dialog) Country Code"; Rec."(Dialog) Country Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Country Code field';
                    }
                    field("(Dialog) Email"; Rec."(Dialog) Email")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Email field';
                    }
                    field("(Dialog) Mobile No."; Rec."(Dialog) Mobile No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Mobile No. field';
                    }
                    field("(Dialog) Passport Country Code"; Rec."(Dialog) Passport Country Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Passport Country Code field';
                    }
                    field("(Dialog) Date Of Birth"; Rec."(Dialog) Date Of Birth")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Date Of Birth field';
                    }
                    field("(Dialog) Departure Date"; Rec."(Dialog) Departure Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Departure Date field';
                    }
                    field("(Dialog) Arrival Date"; Rec."(Dialog) Arrival Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Arrival Date field';
                    }
                    field("(Dialog) Dest. Country Code"; Rec."(Dialog) Dest. Country Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Dest. Country Code field';
                    }
                }
            }
            group(Automatic)
            {
                Editable = false;
                field("Shop Country Code"; Rec."Shop Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop Country Code field';
                }
                field("Date Last Auto Configured"; Rec."Date Last Auto Configured")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Last Auto Configured field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Services action';
            }
        }
    }
}

