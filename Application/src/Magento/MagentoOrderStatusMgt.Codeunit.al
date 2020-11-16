codeunit 6151405 "NPR Magento Order Status Mgt."
{
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.08/MHA /20171003  CASE 292333 Status Complete should only be set, if Order has been fully invoiced


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    procedure Cu80OnAfterPostSalesDoc(SalesInvHdrNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        MagentoPmtMgt: Codeunit "NPR Magento Nc Task Card Mgt.";
        MagentoOrderStatus: Record "NPR Magento Order Status";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if (SalesInvHdrNo = '') or not SalesInvHeader.Get(SalesInvHdrNo) then
            exit;
        if not (MagentoSetup.Get and MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;
        if SalesInvHeader."Order No." = '' then
            exit;
        //-MAG2.08 [292333]
        if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesInvHeader."Order No.") then
            exit;
        //+MAG2.08 [292333]
        if not MagentoOrderStatus.Get(SalesInvHeader."Order No.") then
            exit;
        if MagentoOrderStatus."External Order No." <> SalesInvHeader."NPR External Order No." then
            exit;

        if MagentoOrderStatus.Status <> MagentoOrderStatus.Status::Complete then begin
            MagentoOrderStatus.Status := MagentoOrderStatus.Status::Complete;
            MagentoOrderStatus.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', true, true)]
    procedure SalesHeaderOnInsert(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        MagentoOrderStatus: Record "NPR Magento Order Status";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG2.00
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;
        //+MAG2.00

        if Rec."NPR External Order No." = '' then
            exit;
        if not (MagentoSetup.Get and MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        if MagentoOrderStatus.Get(Rec."No.") then
            exit;

        MagentoOrderStatus.Init;
        MagentoOrderStatus."Order No." := Rec."No.";
        MagentoOrderStatus.Status := MagentoOrderStatus.Status::Processing;
        MagentoOrderStatus."External Order No." := Rec."NPR External Order No.";
        MagentoOrderStatus.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterDeleteEvent', '', true, true)]
    procedure SalesHeaderOnDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        MagentoOrderStatus: Record "NPR Magento Order Status";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        //-MAG2.00
        if IsTemporary(Rec) then
            exit;
        //+MAG2.00
        if not (MagentoSetup.Get and MagentoSetup.Get and MagentoSetup."Magento Enabled") then
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

    local procedure "--- Aux"()
    begin
    end;

    local procedure IsTemporary(VariantRec: Variant): Boolean
    var
        RecRef: RecordRef;
    begin
        //-MAG2.00
        RecRef.GetTable(VariantRec);
        exit(RecRef.IsTemporary);
        //+MAG2.00
    end;
}

