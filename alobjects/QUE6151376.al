query 6151376 "CS Refill Items"
{
    // NPR5.50/JAKUBV/20190603  CASE 247747-01 Transport NPR5.50 - 3 June 2019
    // NPR5.51/CLVA  /20190902  CASE 365659 Added captions
    // NPR5.52/CLVA  /20190926  CASE 370277 Added filter on dataitem "CS Refill Data"
    // NPR5.53/CLVA  /20191107  CASE 375918 Added filter on dataitem "CS Refill Data": Qty. in Store=FILTER(=0)

    Caption = 'CS Refill Items';
    OrderBy = Ascending(Item_No),Descending(Variant_Code);

    elements
    {
        dataitem(CS_Refill_Data;"CS Refill Data")
        {
            DataItemTableFilter = "Qty. in Stock"=FILTER(>0),"Qty. in Store"=FILTER(=0);
            filter(Stock_Take_Id;"Stock-Take Id")
            {
            }
            column(Combined_key;"Combined key")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Item_Description;"Item Description")
            {
            }
            column(Variant_Code;"Variant Code")
            {
            }
            column(Variant_Description;"Variant Description")
            {
            }
            column(Item_Group_Code;"Item Group Code")
            {
            }
            column(Image_Url;"Image Url")
            {
            }
            column(Qty_in_Stock;"Qty. in Stock")
            {
            }
            column(Qty_in_Store;"Qty. in Store")
            {
            }
            column(Refilled;Refilled)
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

