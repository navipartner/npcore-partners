pageextension 6014474 "NPR Posted Return Shipment" extends "Posted Return Shipment"
{
    // NPR4.10/TS/20150602  CASE 213397  Added field  "Buy-from Vendor Name 2", "Pay-to Name 2", "Ship-to Name 2"
    layout
    {
        addafter("Buy-from Vendor Name")
        {
            field("NPR Buy-from Vendor Name 2"; "Buy-from Vendor Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Pay-to Name")
        {
            field("NPR Pay-to Name 2"; "Pay-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }
    }
}

