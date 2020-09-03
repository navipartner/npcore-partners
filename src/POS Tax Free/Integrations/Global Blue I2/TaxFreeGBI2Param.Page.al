page 6014647 "NPR Tax Free GB I2 Param."
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Parameters';
    PageType = Card;
    SourceTable = "NPR Tax Free GB I2 Param.";

    layout
    {
        area(content)
        {
            group(Required)
            {
                group(General)
                {
                    field("Shop ID"; "Shop ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Desk ID"; "Desk ID")
                    {
                        ApplicationArea = All;
                    }
                    field(Username; Username)
                    {
                        ApplicationArea = All;
                    }
                    field(Password; Password)
                    {
                        ApplicationArea = All;
                    }
                    field("Consolidation Allowed"; "Consolidation Allowed")
                    {
                        ApplicationArea = All;
                    }
                    field("Consolidation Separate Limits"; "Consolidation Separate Limits")
                    {
                        ApplicationArea = All;
                    }
                    field("Voucher Issue Date Limit"; "Voucher Issue Date Limit")
                    {
                        ApplicationArea = All;
                    }
                    field("Services Eligible"; "Services Eligible")
                    {
                        ApplicationArea = All;
                    }
                    field("Count Zero VAT Goods For Limit"; "Count Zero VAT Goods For Limit")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Dialog")
                {
                    field("(Dialog) Passport Number"; "(Dialog) Passport Number")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) First Name"; "(Dialog) First Name")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Last Name"; "(Dialog) Last Name")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Street"; "(Dialog) Street")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Postal Code"; "(Dialog) Postal Code")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Town"; "(Dialog) Town")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Country Code"; "(Dialog) Country Code")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Email"; "(Dialog) Email")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Mobile No."; "(Dialog) Mobile No.")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Passport Country Code"; "(Dialog) Passport Country Code")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Date Of Birth"; "(Dialog) Date Of Birth")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Departure Date"; "(Dialog) Departure Date")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Arrival Date"; "(Dialog) Arrival Date")
                    {
                        ApplicationArea = All;
                    }
                    field("(Dialog) Dest. Country Code"; "(Dialog) Dest. Country Code")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Automatic)
            {
                Editable = false;
                field("Shop Country Code"; "Shop Country Code")
                {
                    ApplicationArea = All;
                }
                field("Date Last Auto Configured"; "Date Last Auto Configured")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Tax Free GB I2 Serv. List";
                RunPageLink = "Tax Free Unit" = FIELD("Tax Free Unit");
            }
        }
    }
}

