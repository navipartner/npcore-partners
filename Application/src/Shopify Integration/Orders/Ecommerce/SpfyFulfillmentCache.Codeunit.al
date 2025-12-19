#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248593 "NPR Spfy Fulfillment Cache"
{
    Access = Internal;
    SingleInstance = true;
    internal procedure GetVocherReferenceNo(OrderLineId: Text; var ReferenceNo: Code[50]; var GiftCardId: Text[30])
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        Clear(ReferenceNo);
        Clear(GiftCardId);
        PrepareTempBuffer(TempBuffer);
        TempBuffer.SetRange("Order Line ID", OrderLineId);
        TempBuffer.SetRange("Gift Card", true);
        if not TempBuffer.FindFirst() then
            exit;
        Temp_SpfyFulfillmEntryDetailBuffer.Reset();
        Temp_SpfyFulfillmEntryDetailBuffer.SetCurrentKey("Parent Entry No.", Claimed);
        Temp_SpfyFulfillmEntryDetailBuffer.SetRange("Parent Entry No.", TempBuffer."Entry No.");
        Temp_SpfyFulfillmEntryDetailBuffer.SetRange(Claimed, false);
        if Temp_SpfyFulfillmEntryDetailBuffer.FindFirst() then begin
            Temp_SpfyFulfillmEntryDetailBuffer.Claimed := true;
            Temp_SpfyFulfillmEntryDetailBuffer.Modify();
            Evaluate(ReferenceNo, Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No.");
            GiftCardId := Temp_SpfyFulfillmEntryDetailBuffer."Gift Card ID";
        end;
    end;

    internal procedure RemoveLineFromCache(OrderLineId: Text)
    var
        OrderLineErr: Label 'Shopify Order Line Id filter is blank,this is a programming issue.', Locked = true;
    begin
        if OrderLineId = '' then
            Error(OrderLineErr);

        Temp_SpfyFulfillmentBuffer.Reset();
        Temp_SpfyFulfillmentBuffer.SetRange("Order Line ID", OrderLineId);
        if Temp_SpfyFulfillmentBuffer.FindFirst() then
            Temp_SpfyFulfillmentBuffer.Delete();
    end;

    internal procedure GetExpectedGiftCardCount(GCLineId: Text[100]): Integer
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        Count: Integer;
    begin
        Count := 0;
        PrepareTempBuffer(TempBuffer);
        TempBuffer.SetLoadFields("Fulfilled Quantity");
        TempBuffer.SetCurrentKey("Gift Card", "Order Line ID");
        TempBuffer.SetRange("Gift Card", true);
        TempBuffer.SetRange("Order Line ID", GCLineId);
        if TempBuffer.FindFirst() then
            Count := TempBuffer."Fulfilled Quantity";
        exit(Count);
    end;

    internal procedure AllFulfilled(): Boolean
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        PrepareTempBuffer(TempBuffer);
        TempBuffer.SetRange("Gift Card", true);
        if not TempBuffer.FindSet() then
            exit;
        repeat
            if TempBuffer."Updated At" = 0DT then
                exit;
        until TempBuffer.Next() = 0;
        exit(true);
    end;

    internal procedure IsShopifyGiftCard(): Boolean
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        PrepareTempBuffer(TempBuffer);
        TempBuffer.SetRange("Gift Card", true);
        exit(not TempBuffer.IsEmpty());
    end;

    internal procedure GetLineFromCache(OrderLineId: Text[30]; var SpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary): Boolean
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        Clear(SpfyFulfillmentBuffer);

        PrepareTempBuffer(TempBuffer);
        if OrderLineId <> '' then
            TempBuffer.SetRange("Order Line ID", OrderLineId);

        if not TempBuffer.FindFirst() then
            exit(false);

        SpfyFulfillmentBuffer.Copy(TempBuffer, true);

        exit(true);
    end;

    internal procedure GetOrderLines(var SpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; GiftCard: Boolean): Boolean
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        PrepareTempBuffer(TempBuffer);
        if GiftCard then
            TempBuffer.SetRange("Gift Card", true);
        if not TempBuffer.FindSet() then
            exit;

        SpfyFulfillmentBuffer.DeleteAll();
        SpfyFulfillmentBuffer.Copy(TempBuffer, true);
        exit(true);
    end;

    internal procedure AddGiftCardDetails(GCOrderLineId: Text[100]; GiftCardGID: Text[100]; LastCharacters: Text)
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        GiftCardId: Text[30];
    begin
        GiftCardId := SpfyAPIOrderHelper.GetNumericId(GiftCardGID);
        PrepareTempBuffer(TempBuffer);
        TempBuffer.SetRange("Order Line ID", GCOrderLineId);
        if TempBuffer.FindFirst() then begin
            Temp_SpfyFulfillmEntryDetailBuffer.SetRange("Parent Entry No.", TempBuffer."Entry No.");
            Temp_SpfyFulfillmEntryDetailBuffer.SetRange("Gift Card ID", GiftCardId);
            if not Temp_SpfyFulfillmEntryDetailBuffer.FindFirst() then begin
                Temp_SpfyFulfillmEntryDetailBuffer.Init();
                Temp_SpfyFulfillmEntryDetailBuffer."Entry No." := GetLastEntryNo() + 1;
                Temp_SpfyFulfillmEntryDetailBuffer."Parent Entry No." := TempBuffer."Entry No.";
#pragma warning disable AA0139
                Temp_SpfyFulfillmEntryDetailBuffer."Gift Card ID" := CopyStr(GiftCardId, 1, MaxStrLen(Temp_SpfyFulfillmEntryDetailBuffer."Gift Card ID"));
                Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No." := CopyStr(LastCharacters, 1, MaxStrLen(Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No."));
                if StrLen(Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No.") > 4 then
                    Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No." := CopyStr(Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No.", StrLen(Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No.") - 3);
                Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No." := StrSubstNo('%1/%2', Temp_SpfyFulfillmEntryDetailBuffer."Gift Card ID", Temp_SpfyFulfillmEntryDetailBuffer."Gift Card Reference No.");
#pragma warning restore AA0139
                Temp_SpfyFulfillmEntryDetailBuffer.Insert();
            end;
        end;
    end;

    local procedure GetLastEntryNo(): Integer
    var
        TempBufferDetails: Record "NPR Spfy Fulfillm. Buf. Detail" temporary;
    begin
        Temp_SpfyFulfillmEntryDetailBuffer.Reset();
        TempBufferDetails.Copy(Temp_SpfyFulfillmEntryDetailBuffer, true);
        if TempBufferDetails.FindLast() then
            exit(TempBufferDetails."Entry No.");
    end;

    internal procedure GetLastFulfillmentEntryNo(): integer
    var
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        Temp_SpfyFulfillmentBuffer.Reset();
        TempBuffer.Copy(Temp_SpfyFulfillmentBuffer, true);
        if TempBuffer.FindLast() then
            exit(TempBuffer."Entry No.");
    end;

    internal procedure ClearCache()
    begin
        Clear(Temp_SpfyFulfillmentBuffer);
        Clear(Temp_SpfyFulfillmEntryDetailBuffer);
        Temp_SpfyFulfillmentBuffer.Reset();
        Temp_SpfyFulfillmEntryDetailBuffer.Reset();

        Temp_SpfyFulfillmentBuffer.DeleteAll();
        Temp_SpfyFulfillmEntryDetailBuffer.DeleteAll();
    end;

    local procedure PrepareTempBuffer(var TempBuffer: record "NPR Spfy Fulfillment Buffer" temporary)
    begin
        Temp_SpfyFulfillmentBuffer.Reset();
        TempBuffer.DeleteAll();
        TempBuffer.Copy(Temp_SpfyFulfillmentBuffer, true);
    end;

    internal procedure CacheLine(SourceLine: Record "NPR Spfy Fulfillment Buffer" temporary)
    begin
        Temp_SpfyFulfillmentBuffer.Reset();
        if Temp_SpfyFulfillmentBuffer.Get(SourceLine."Entry No.") then begin
            Temp_SpfyFulfillmentBuffer.TransferFields(SourceLine, false);
            Temp_SpfyFulfillmentBuffer.Modify();
        end else begin
            Temp_SpfyFulfillmentBuffer.Init();
            Temp_SpfyFulfillmentBuffer := SourceLine;
            Temp_SpfyFulfillmentBuffer.Insert();
        end;
    end;

    var
        Temp_SpfyFulfillmEntryDetailBuffer: Record "NPR Spfy Fulfillm. Buf. Detail" temporary;
        Temp_SpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
}
#endif