query 6150660 "NPRE Kitchen Request w. Source"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale


    elements
    {
        dataitem(KitchenOrder;"NPRE Kitchen Order")
        {
            column(Order_ID;"Order ID")
            {
            }
            column(Order_Status;Status)
            {
            }
            dataitem(KitchenRequest;"NPRE Kitchen Request")
            {
                DataItemLink = "Order ID"=KitchenOrder."Order ID";
                SqlJoinType = InnerJoin;
                column(Request_No;"Request No.")
                {
                }
                column(Restaurant_Code;"Restaurant Code")
                {
                }
                column(Serving_Step;"Serving Step")
                {
                }
                column(Line_Status;"Line Status")
                {
                }
                dataitem(KitchenReqSourceLink;"NPRE Kitchen Req. Source Link")
                {
                    DataItemLink = "Request No."=KitchenRequest."Request No.";
                    SqlJoinType = InnerJoin;
                    column(Source_Document_Type;"Source Document Type")
                    {
                    }
                    column(Source_Document_Subtype;"Source Document Subtype")
                    {
                    }
                    column(Source_Document_No;"Source Document No.")
                    {
                    }
                    column(Source_Document_Line_No;"Source Document Line No.")
                    {
                    }
                }
            }
        }
    }
}

