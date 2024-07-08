codeunit 6151311 "NPR POS Action Calc DiscountsB"
{
    Access = Internal;
    internal procedure GetTotalDiscountBenefitItems(SalePOS: Record "NPR POS Sale";
                                                    NPRBenefitItemsCollection: Enum "NPR Benefit Items Collection";
                                                    var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary) Found: Boolean
    var
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        Found := NPRTotalDiscountManagement.GetTotalDiscountBenefitItemsForSale(SalePOS,
                                                                                NPRBenefitItemsCollection,
                                                                                TempNPRTotalDiscBenItemBuffer)
    end;

    internal procedure CheckIfBenefitItemsAddedToPOSSale(SalePOS: Record "NPR POS Sale") Found: Boolean
    var
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        Found := NPRTotalDiscountManagement.CheckIfBenefitItemsAddedToPOSSale(SalePOS);
    end;

    internal procedure AddBenefitItems(SalePOS: Record "NPR POS Sale";
                                       var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
                                       FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRPOSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
    begin
        NPRPOSActionInsertItemB.AddBenefitItems(SalePOS,
                                                TempNPRTotalDiscBenItemBuffer,
                                                FrontEnd);
    end;

    internal procedure CreateBenefitListBufferFromDiscountBenefitItemBuffer(var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
                                                                            var TempNPRItemBenefitListHeader: Record "NPR Item Benefit List Header" temporary)
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRItemBenefitListHeader: Record "NPR Item Benefit List Header";
        LineDescription: Text[100];
        TemporaryRecordErrorLbl: Label 'The record that you have provided is not temporary.';
        TotalDiscountLbl: Label 'Total discount';
    begin
        if not TempNPRItemBenefitListHeader.IsTemporary then
            Error(TemporaryRecordErrorLbl);

        TempNPRItemBenefitListHeader.Reset();
        if not TempNPRItemBenefitListHeader.IsEmpty then
            TempNPRItemBenefitListHeader.DeleteAll(true);

        TempNPRTotalDiscBenItemBuffer.SetCurrentKey("Benefit List Code");
        if not TempNPRTotalDiscBenItemBuffer.FindSet(false) then
            exit;

        repeat
            TempNPRTotalDiscBenItemBuffer.SetRange("Benefit List Code", TempNPRTotalDiscBenItemBuffer."Benefit List Code");
            TempNPRTotalDiscBenItemBuffer.FindLast();

            if not TempNPRItemBenefitListHeader.Get(TempNPRTotalDiscBenItemBuffer."Benefit List Code") then begin

                TempNPRItemBenefitListHeader.Code := TempNPRTotalDiscBenItemBuffer."Benefit List Code";

                if not NPRItemBenefitListHeader.Get(TempNPRTotalDiscBenItemBuffer."Benefit List Code") then
                    Clear(NPRItemBenefitListHeader);

                if not NPRTotalDiscountHeader.Get(TempNPRTotalDiscBenItemBuffer."Total Discount Code") then
                    Clear(NPRTotalDiscountHeader);

                LineDescription := NPRItemBenefitListHeader.Description;
                if LineDescription = '' then
                    LineDescription := NPRTotalDiscountHeader.Description;

                if LineDescription = '' then
                    LineDescription := TotalDiscountLbl;

                TempNPRItemBenefitListHeader.Description := LineDescription;

                TempNPRItemBenefitListHeader.Insert();
            end;

            TempNPRTotalDiscBenItemBuffer.SetRange("Benefit List Code");
        until TempNPRTotalDiscBenItemBuffer.Next() = 0;


    end;
}