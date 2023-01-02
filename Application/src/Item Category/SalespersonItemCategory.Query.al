query 6014425 "NPR Salesperson/Item Category"
{
    Access = Internal;
    Caption = 'Salesperson/Item Category';
    QueryType = Normal;

    elements
    {
        dataitem(POSSaleLine; "NPR POS Entry Sales Line")
        {
            DataItemTableFilter = "Amount Excl. VAT" = filter(> 0), Type = const(Item);

            column(Salesperson_Code; "Salesperson Code")
            {
            }
            column(Item_Category_Code; "Item Category Code")
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            column(Unit_Cost; "Unit Cost")
            {
                Method = Sum;
            }
            column(Amount_Excl_VAT; "Amount Excl. VAT")
            {
                Method = Sum;
            }
            filter(Entry_Date; "Entry Date")
            {
            }
        }
    }
}
