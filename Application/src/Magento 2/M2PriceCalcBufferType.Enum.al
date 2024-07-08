enum 6014439 "NPR M2 Price Calc. Buffer Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "Unit Price")
    {
        Caption = 'Unit Price';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; "Customer Price Group")
    {
        Caption = 'Customer Price Group';
    }
    value(3; "All Customers")
    {
        Caption = 'All Customers';
    }
    value(4; Campaign)
    {
        Caption = 'Campaign';
    }
    value(5; "Item Discount")
    {
        Caption = 'Item Discount';
    }
    value(6; "Item Discount Group")
    {
        Caption = 'Item Discount Group';
    }
    value(7; "Customer Discount Group")
    {
        Caption = 'Customer Discount Group';
    }
}
