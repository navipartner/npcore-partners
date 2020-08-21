pageextension 6014474 pageextension6014474 extends "Posted Return Shipment"
{
    // NPR4.10/TS/20150602  CASE 213397  Added field  "Buy-from Vendor Name 2", "Pay-to Name 2", "Ship-to Name 2"
    layout
    {
        addafter("Buy-from Vendor Name")
        {
            field("Buy-from Vendor Name 2"; "Buy-from Vendor Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Pay-to Name")
        {
            field("Pay-to Name 2"; "Pay-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Ship-to Name")
        {
            field("Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }
    }
}

