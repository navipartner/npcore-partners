query 6150660 "NPR NPRE Kitchen Req. w Source"
{
    Access = Internal;
    Caption = 'NPRE Kitchen Req. w Source';
    elements
    {
        dataitem(KitchenOrder; "NPR NPRE Kitchen Order")
        {
            column(Order_ID; "Order ID")
            {
            }
            column(Order_Status; Status)
            {
            }
            dataitem(KitchenRequest; "NPR NPRE Kitchen Request")
            {
                DataItemLink = "Order ID" = KitchenOrder."Order ID";
                SqlJoinType = InnerJoin;
                column(Request_No; "Request No.")
                {
                }
                column(Restaurant_Code; "Restaurant Code")
                {
                }
                column(Serving_Step; "Serving Step")
                {
                }
                column(Line_Status; "Line Status")
                {
                }
                dataitem(KitchenReqSourceLink; "NPR NPRE Kitchen Req.Src. Link")
                {
                    DataItemLink = "Request No." = KitchenRequest."Request No.";
                    SqlJoinType = InnerJoin;
                    column(Source_Document_Type; "Source Document Type")
                    {
                    }
                    column(Source_Document_Subtype; "Source Document Subtype")
                    {
                    }
                    column(Source_Document_No; "Source Document No.")
                    {
                    }
                    column(Source_Document_Line_No; "Source Document Line No.")
                    {
                    }
                }
            }
        }
    }
}
