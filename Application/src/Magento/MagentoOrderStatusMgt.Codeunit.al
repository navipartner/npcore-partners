codeunit 6151405 "NPR Magento Order Status Mgt."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesDoc(SalesInvHdrNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        MagentoOrderStatus: Record "NPR Magento Order Status";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if (SalesInvHdrNo = '') or not SalesInvHeader.Get(SalesInvHdrNo) then
            exit;
        if not (MagentoSetup.Get() and MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        if SalesInvHeader."Order No." = '' then
            exit;
        if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesInvHeader."Order No.") then
            exit;
        if not MagentoOrderStatus.Get(SalesInvHeader."Order No.") then
            exit;
        if MagentoOrderStatus."External Order No." <> SalesInvHeader."NPR External Order No." then
            exit;

        if MagentoOrderStatus.Status <> MagentoOrderStatus.Status::Complete then begin
            MagentoOrderStatus.Status := MagentoOrderStatus.Status::Complete;
            MagentoOrderStatus.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure SalesHeaderOnInsert(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        MagentoOrderStatus: Record "NPR Magento Order Status";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;

        if Rec."NPR External Order No." = '' then
            exit;
        if not (MagentoSetup.Get() and MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        if MagentoOrderStatus.Get(Rec."No.") then
            exit;

        MagentoOrderStatus.Init();
        MagentoOrderStatus."Order No." := Rec."No.";
        MagentoOrderStatus.Status := MagentoOrderStatus.Status::Processing;
        MagentoOrderStatus."External Order No." := Rec."NPR External Order No.";
        MagentoOrderStatus.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, true)]
    local procedure SalesHeaderOnDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        MagentoOrderStatus: Record "NPR Magento Order Status";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;
        if not (MagentoSetup.Get() and MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        if not MagentoOrderStatus.Get(Rec."No.") then
            exit;
        if MagentoOrderStatus."External Order No." <> Rec."NPR External Order No." then
            exit;

        if MagentoOrderStatus.Status <> MagentoOrderStatus.Status::Cancelled then begin
            MagentoOrderStatus.Status := MagentoOrderStatus.Status::Cancelled;
            MagentoOrderStatus.Modify(true);
        end;
    end;

    local procedure IsTemporary(VariantRec: Variant): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(VariantRec);
        exit(RecRef.IsTemporary);
    end;
}
