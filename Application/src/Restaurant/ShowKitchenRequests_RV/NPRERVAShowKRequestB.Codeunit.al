codeunit 6151340 "NPR NPRE RVA: Show K.Request-B"
{
    Access = Internal;

    procedure ShowKitchenRequests(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; RestaurantCode: Code[20]; FilterBy: Option Restaurant,Salesperson,Seating,Waiterpad; FilterByEntityCode: Code[20])
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link";
        Salesperson: Record "Salesperson/Purchaser";
        SalePOS: Record "NPR POS Sale";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        KitchenRequests: Page "NPR NPRE Kitchen Req.";
        SeatingNotSelectedErr: Label 'Please select a waiter pad or seating first.';
        WPadNotSelectedErr: Label 'Please select a waiter pad first.';
    begin
        if RestaurantCode = '' then
            RestaurantCode := Setup.RestaurantCode();
        case FilterBy of
            FilterBy::Salesperson:
                begin
                    if FilterByEntityCode = '' then begin
                        Setup.GetSalespersonRecord(Salesperson);
                        FilterByEntityCode := Salesperson.Code;
                    end;
                    KitchenReqSourceParam."Restaurant Code" := RestaurantCode;
                    KitchenReqSourceParam."Assigned Waiter Code" := FilterByEntityCode;
                    KitchenOrderMgt.FindKitchenRequestsForWaiterOrSeating(KitchenRequest, KitchenReqSourceParam);
                end;
            FilterBy::Seating:
                begin
                    if FilterByEntityCode = '' then begin
                        Sale.GetCurrentSale(SalePOS);
                        FilterByEntityCode := SalePOS."NPRE Pre-Set Seating Code";
                    end;
                    if FilterByEntityCode = '' then
                        Error(SeatingNotSelectedErr);
                    KitchenReqSourceParam."Restaurant Code" := RestaurantCode;
                    KitchenReqSourceParam."Seating Code" := FilterByEntityCode;
                    KitchenOrderMgt.FindKitchenRequestsForWaiterOrSeating(KitchenRequest, KitchenReqSourceParam);
                end;
            FilterBy::Waiterpad:
                begin
                    if FilterByEntityCode = '' then begin
                        Sale.GetCurrentSale(SalePOS);
                        FilterByEntityCode := SalePOS."NPRE Pre-Set Waiter Pad No.";
                    end;
                    if FilterByEntityCode = '' then
                        Error(WPadNotSelectedErr);
                    WaiterPadLine."Waiter Pad No." := FilterByEntityCode;
                    WaiterPadLine."Line No." := 0;
                    KitchenOrderMgt.InitKitchenReqSourceFromWaiterPadLine(KitchenReqSourceParam, WaiterPadLine, RestaurantCode, '', '', '', 0DT);
                    KitchenOrderMgt.FindKitchenRequestsForSourceDoc(KitchenRequest, KitchenReqSourceParam);
                end;
        end;
        KitchenRequest.SetRange("Restaurant Code", RestaurantCode);

        Clear(KitchenRequests);
        KitchenRequests.SetViewMode(0);
        KitchenRequests.SetTableView(KitchenRequest);
        KitchenRequests.Run();
    end;
}