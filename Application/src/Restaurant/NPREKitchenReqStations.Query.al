query 6014472 "NPR NPRE Kitchen Req. Stations"
{
    Access = Internal;
    Caption = 'NPRE Kitchen Req. Stations';
    OrderBy = ascending(Order_ID);
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(KitchenOrder; "NPR NPRE Kitchen Order")
        {
            column(Order_ID; "Order ID") { }
            column(Order_Status; "Order Status") { }
            column(Created_DateTime; "Created Date-Time") { }
            column(Expected_Dine_DateTime; "Expected Dine Date-Time") { }
            column(Order_Priority; Priority) { }
            dataitem(KitchenRequest; "NPR NPRE Kitchen Request")
            {
                DataItemLink = "Order ID" = KitchenOrder."Order ID";
                SqlJoinType = InnerJoin;
                column(Request_No; "Request No.") { }
                column(Restaurant_Code; "Restaurant Code") { }
                column(Serving_Step; "Serving Step") { }
                column(Line_Status; "Line Status") { }
                column(Production_Status; "Production Status")
                {
                    Caption = 'Request Production Status';
                }
                column(Line_Type; "Line Type") { }
                column(Item_No; "No.") { }
                column(Variant_Code; "Variant Code") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_of_Measure_Code; "Unit of Measure Code") { }
                dataitem(KitchenReqStation; "NPR NPRE Kitchen Req. Station")
                {
                    DataItemLink = "Request No." = KitchenRequest."Request No.";
                    SqlJoinType = LeftOuterJoin;
                    column(KitchenReqStation_SystemId; SystemId)
                    {
                        Caption = 'Kitchen Req. Station SystemId';
                    }
                    column(Line_No_; "Line No.") { }
                    column(Production_Restaurant_Code; "Production Restaurant Code") { }
                    column(Kitchen_Station; "Kitchen Station") { }
                    column(Production_Step; "Production Step") { }
                    column(Station_Production_Status; "Production Status")
                    {
                        Caption = 'Station Production Status';
                    }
                }
            }
        }
    }
}
