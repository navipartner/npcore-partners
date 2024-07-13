#if not BC17
codeunit 6184803 "NPR Spfy Assigned ID Mgt Impl."
{
    Access = Internal;

    procedure GetAssignedShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"): Text[30]
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
    begin
        FilterRecordset(BCRecID, ShopifyIDType, ShopifyAssignedID);
        if not ShopifyAssignedID.FindFirst() then
            exit('');
        exit(ShopifyAssignedID."Shopify ID");
    end;

    procedure AssignShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"; NewShopifyID: Text[30]; WithCheck: Boolean)
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
    begin
        if NewShopifyID = '' then begin
            RemoveAssignedShopifyID(BCRecID, ShopifyIDType);
            exit;
        end;

        if WithCheck then
            CheckForDuplicates(BCRecID, ShopifyIDType, NewShopifyID);

        FilterRecordset(BCRecID, ShopifyIDType, ShopifyAssignedID);
        if not ShopifyAssignedID.FindFirst() then begin
            ShopifyAssignedID.Init();
            ShopifyAssignedID."Table No." := BCRecID.TableNo();
            ShopifyAssignedID."Shopify ID Type" := ShopifyIDType;
            ShopifyAssignedID."BC Record ID" := BCRecID;
            ShopifyAssignedID."Entry No." := 0;
            ShopifyAssignedID.Insert();
        end;

        if ShopifyAssignedID."Shopify ID" <> NewShopifyID then begin
            ShopifyAssignedID."Shopify ID" := NewShopifyID;
            ShopifyAssignedID.Modify(true);
        end;
    end;

    procedure RemoveAssignedShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type")
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
    begin
        FilterRecordset(BCRecID, ShopifyIDType, ShopifyAssignedID);
        if not ShopifyAssignedID.IsEmpty() then
            ShopifyAssignedID.DeleteAll();
    end;

    procedure CopyAssignedShopifyID(FromBCRecID: RecordId; ToBCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type")
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
    begin
        FilterRecordset(FromBCRecID, ShopifyIDType, ShopifyAssignedID);
        if ShopifyAssignedID.FindFirst() then
            AssignShopifyID(ToBCRecID, ShopifyIDType, ShopifyAssignedID."Shopify ID", false);
    end;

    procedure FilterWhereUsed(ShopifyIDType: Enum "NPR Spfy ID Type"; ShopifyID: Text[30]; ForUpdate: Boolean; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        ShopifyAssignedID.Reset();
        if ForUpdate then
            ShopifyAssignedID.LockTable();
        ShopifyAssignedID.SetCurrentKey("Shopify ID Type", "Shopify ID");
        ShopifyAssignedID.SetRange("Shopify ID Type", ShopifyIDType);
        ShopifyAssignedID.SetRange("Shopify ID", ShopifyID);
    end;

    procedure FilterWhereUsedInTable(TableNo: Integer; ShopifyIDType: Enum "NPR Spfy ID Type"; ShopifyID: Text[30]; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        ShopifyAssignedID.Reset();
        ShopifyAssignedID.SetCurrentKey("Table No.", "Shopify ID Type", "Shopify ID");
        ShopifyAssignedID.SetRange("Table No.", TableNo);
        ShopifyAssignedID.SetRange("Shopify ID Type", ShopifyIDType);
        ShopifyAssignedID.SetRange("Shopify ID", ShopifyID);
    end;

    local procedure FilterRecordset(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        ShopifyAssignedID.Reset();
        ShopifyAssignedID.SetCurrentKey("Table No.", "Shopify ID Type", "BC Record ID");
        ShopifyAssignedID.SetRange("Table No.", BCRecID.TableNo());
        ShopifyAssignedID.SetRange("Shopify ID Type", ShopifyIDType);
        ShopifyAssignedID.SetRange("BC Record ID", BCRecID);
    end;

    local procedure CheckForDuplicates(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"; NewShopifyID: Text[30])
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        IDAlreadyAssigned: Label 'Provided Shopify %1 ''%2'' is already assigned to another record (%3)';
    begin
        if NewShopifyID = '' then
            exit;

        FilterWhereUsedInTable(BCRecID.TableNo(), ShopifyIDType, NewShopifyID, ShopifyAssignedID);
        ShopifyAssignedID.SetFilter("BC Record ID", '<>%1', BCRecID);
        if ShopifyAssignedID.FindFirst() then
            Error(IDAlreadyAssigned, Format(ShopifyIDType), NewShopifyID, ShopifyAssignedID."BC Record ID");
    end;

    //#region Subscribers
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure Customer_RemoveAssignedShopifyID(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterRenameEvent', '', false, false)]
    local procedure Customer_MoveAssignedShopifyID(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Type", 'OnAfterDeleteEvent', '', false, false)]
    local procedure VoucherType_RemoveAssignedShopifyStore(var Rec: Record "NPR NpRv Voucher Type"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Type", 'OnAfterRenameEvent', '', false, false)]
    local procedure VoucherType_MoveAssignedShopifyStore(var Rec: Record "NPR NpRv Voucher Type"; var xRec: Record "NPR NpRv Voucher Type"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Store Code");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnAfterDeleteEvent', '', false, false)]
    local procedure Voucher_RemoveAssignedShopifyID(var Rec: Record "NPR NpRv Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnAfterRenameEvent', '', false, false)]
    local procedure Voucher_MoveAssignedShopifyStore(var Rec: Record "NPR NpRv Voucher"; var xRec: Record "NPR NpRv Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ArchVoucher_RemoveAssignedShopifyID(var Rec: Record "NPR NpRv Arch. Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", 'OnAfterRenameEvent', '', false, false)]
    local procedure ArchVoucher_MoveAssignedShopifyStore(var Rec: Record "NPR NpRv Arch. Voucher"; var xRec: Record "NPR NpRv Arch. Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", 'OnAfterArchiveVoucher', '', false, false)]
    local procedure OnAfterArchiveVoucher_MoveAssignedShopifyID(Voucher: Record "NPR NpRv Voucher"; ArchVoucher: Record "NPR NpRv Arch. Voucher")
    begin
        CopyAssignedShopifyID(Voucher.RecordId(), ArchVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", 'OnAfterUnArchiveVoucher', '', false, false)]
    local procedure OnAfterUnArchiveVoucher_MoveAssignedShopifyID(ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher")
    begin
        CopyAssignedShopifyID(ArchVoucher.RecordId(), Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(ArchVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesHeader_RemoveAssignedShopifyID(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesLine_RemoveAssignedShopifyID(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure MagPmtLine_RemoveAssignedShopifyID(var Rec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptHeaderInsert', '', false, false)]
    local procedure SalesShptHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesShipmentHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesShipmentHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptHeaderInsert', '', false, false)]
    local procedure ReturnRcptHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure SalesInvHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoHeaderInsert', '', false, false)]
    local procedure SalesCrMemoHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptLineInsert', '', false, false)]
    local procedure SalesShptLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var SalesShipmentLine: Record "Sales Shipment Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), SalesShipmentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptLineInsert', '', false, false)]
    local procedure ReturnRcptLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var ReturnRcptLine: Record "Return Receipt Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), ReturnRcptLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure SalesInvLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var SalesInvLine: Record "Sales Invoice Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), SalesInvLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoLineInsert', '', false, false)]
    local procedure SalesCrMemoLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;
    //#endregion
}
#endif