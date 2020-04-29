page 6014647 "Tax Free GB I2 Parameters"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Parameters';
    PageType = Card;
    SourceTable = "Tax Free GB I2 Parameter";

    layout
    {
        area(content)
        {
            group(Required)
            {
                group(General)
                {
                    field("Shop ID";"Shop ID")
                    {
                    }
                    field("Desk ID";"Desk ID")
                    {
                    }
                    field(Username;Username)
                    {
                    }
                    field(Password;Password)
                    {
                    }
                    field("Consolidation Allowed";"Consolidation Allowed")
                    {
                    }
                    field("Consolidation Separate Limits";"Consolidation Separate Limits")
                    {
                    }
                    field("Voucher Issue Date Limit";"Voucher Issue Date Limit")
                    {
                    }
                    field("Services Eligible";"Services Eligible")
                    {
                    }
                    field("Count Zero VAT Goods For Limit";"Count Zero VAT Goods For Limit")
                    {
                    }
                }
                group("Dialog ")
                {
                    field("(Dialog) Passport Number";"(Dialog) Passport Number")
                    {
                    }
                    field("(Dialog) First Name";"(Dialog) First Name")
                    {
                    }
                    field("(Dialog) Last Name";"(Dialog) Last Name")
                    {
                    }
                    field("(Dialog) Street";"(Dialog) Street")
                    {
                    }
                    field("(Dialog) Postal Code";"(Dialog) Postal Code")
                    {
                    }
                    field("(Dialog) Town";"(Dialog) Town")
                    {
                    }
                    field("(Dialog) Country Code";"(Dialog) Country Code")
                    {
                    }
                    field("(Dialog) Email";"(Dialog) Email")
                    {
                    }
                    field("(Dialog) Mobile No.";"(Dialog) Mobile No.")
                    {
                    }
                    field("(Dialog) Passport Country Code";"(Dialog) Passport Country Code")
                    {
                    }
                    field("(Dialog) Date Of Birth";"(Dialog) Date Of Birth")
                    {
                    }
                    field("(Dialog) Departure Date";"(Dialog) Departure Date")
                    {
                    }
                    field("(Dialog) Arrival Date";"(Dialog) Arrival Date")
                    {
                    }
                    field("(Dialog) Dest. Country Code";"(Dialog) Dest. Country Code")
                    {
                    }
                }
            }
            group(Automatic)
            {
                Editable = false;
                field("Shop Country Code";"Shop Country Code")
                {
                }
                field("Date Last Auto Configured";"Date Last Auto Configured")
                {
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
                RunObject = Page "Tax Free GB I2 Service List";
                RunPageLink = "Tax Free Unit"=FIELD("Tax Free Unit");
            }
        }
    }
}

