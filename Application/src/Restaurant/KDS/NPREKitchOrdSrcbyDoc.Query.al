query 6014446 "NPR NPRE Kitch.Ord.Src. by Doc"
{
    Access = Internal;
    Caption = 'Kitchen Order Source by Doc.';
    OrderBy = ascending(Request_No, Source_Document_No_);
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(KitchenRequest; "NPR NPRE Kitchen Request")
        {
            column(Order_ID; "Order ID") { }
            column(Request_No; "Request No.") { }
            column(Line_Status; "Line Status") { }
            dataitem(KitchenReqSourceLink; "NPR NPRE Kitchen Req.Src. Link")
            {
                DataItemLink = "Request No." = KitchenRequest."Request No.";
                SqlJoinType = InnerJoin;
                column(Source_Document_Type; "Source Document Type") { }
                column(Source_Document_Subtype; "Source Document Subtype") { }
                column(Source_Document_No_; "Source Document No.") { }
                column(QuantityBase; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
