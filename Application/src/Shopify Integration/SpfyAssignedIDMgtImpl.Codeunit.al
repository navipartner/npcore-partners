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

    procedure TempStoreAssignedShopifyIDs(FromBCRecID: RecordId; ToBCRecID: RecordId; ToTemp: Boolean)
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        TempShopifyAssignedID: Record "NPR Spfy Assigned ID" temporary;
        SpfyAssignedIDTemp: Codeunit "NPR Spfy Assigned ID Temp";
    begin
        SpfyAssignedIDTemp.GetTempRecordSet(TempShopifyAssignedID);
        if ToTemp then begin
            //To temp
            FilterRecordset(FromBCRecID, ShopifyAssignedID);
            if not ShopifyAssignedID.FindSet() then
                exit;
            repeat
                TempShopifyAssignedID := ShopifyAssignedID;
                TempShopifyAssignedID."Table No." := ToBCRecID.TableNo();
                TempShopifyAssignedID."BC Record ID" := ToBCRecID;
                if not TempShopifyAssignedID.Insert() then
                    TempShopifyAssignedID.Modify();
            until ShopifyAssignedID.Next() = 0;
        end else begin
            //From temp
            FilterRecordset(FromBCRecID, TempShopifyAssignedID);
            if not TempShopifyAssignedID.FindSet() then
                exit;
            repeat
                AssignShopifyID(ToBCRecID, TempShopifyAssignedID."Shopify ID Type", TempShopifyAssignedID."Shopify ID", false);
            until ShopifyAssignedID.Next() = 0;
            TempShopifyAssignedID.DeleteAll();
            TempShopifyAssignedID.Reset();
        end;
        SpfyAssignedIDTemp.SetTempRecordSet(TempShopifyAssignedID);
    end;

    procedure FilterWhereUsed(ShopifyIDType: Enum "NPR Spfy ID Type"; ShopifyID: Text[30]; ForUpdate: Boolean; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        ShopifyAssignedID.Reset();
        if ForUpdate then
#if not (BC18 or BC19 or BC20 or BC21)
            ShopifyAssignedID.ReadIsolation := IsolationLevel::UpdLock;
#else
            ShopifyAssignedID.LockTable();
#endif
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
        ShopifyAssignedID.SetCurrentKey("Table No.", "BC Record ID", "Shopify ID Type");
        ShopifyAssignedID.SetRange("Table No.", BCRecID.TableNo());
        ShopifyAssignedID.SetRange("Shopify ID Type", ShopifyIDType);
        ShopifyAssignedID.SetRange("BC Record ID", BCRecID);
    end;

    local procedure FilterRecordset(BCRecID: RecordId; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        ShopifyAssignedID.Reset();
        ShopifyAssignedID.SetCurrentKey("Table No.", "BC Record ID", "Shopify ID Type");
        ShopifyAssignedID.SetRange("Table No.", BCRecID.TableNo());
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
#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure Customer_RemoveAssignedShopifyID(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterRenameEvent, '', false, false)]
#endif
    local procedure Customer_MoveAssignedShopifyID(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Type", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Type", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure VoucherType_RemoveAssignedShopifyStore(var Rec: Record "NPR NpRv Voucher Type"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Type", 'OnAfterRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Type", OnAfterRenameEvent, '', false, false)]
#endif
    local procedure VoucherType_MoveAssignedShopifyStore(var Rec: Record "NPR NpRv Voucher Type"; var xRec: Record "NPR NpRv Voucher Type"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Store Code");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure Voucher_RemoveAssignedShopifyID(var Rec: Record "NPR NpRv Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnAfterRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnAfterRenameEvent, '', false, false)]
#endif
    local procedure Voucher_MoveAssignedShopifyStore(var Rec: Record "NPR NpRv Voucher"; var xRec: Record "NPR NpRv Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure ArchVoucher_RemoveAssignedShopifyID(var Rec: Record "NPR NpRv Arch. Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", 'OnAfterRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", OnAfterRenameEvent, '', false, false)]
#endif
    local procedure ArchVoucher_MoveAssignedShopifyStore(var Rec: Record "NPR NpRv Arch. Voucher"; var xRec: Record "NPR NpRv Arch. Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CopyAssignedShopifyID(xRec.RecordId(), Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(xRec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", 'OnAfterArchiveVoucher', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterArchiveVoucher, '', false, false)]
#endif
    local procedure OnAfterArchiveVoucher_MoveAssignedShopifyID(Voucher: Record "NPR NpRv Voucher"; ArchVoucher: Record "NPR NpRv Arch. Voucher")
    begin
        CopyAssignedShopifyID(Voucher.RecordId(), ArchVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", 'OnAfterUnArchiveVoucher', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterUnArchiveVoucher, '', false, false)]
#endif
    local procedure OnAfterUnArchiveVoucher_MoveAssignedShopifyID(ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher")
    begin
        CopyAssignedShopifyID(ArchVoucher.RecordId(), Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(ArchVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure SalesHeader_RemoveAssignedShopifyID(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure SalesLine_RemoveAssignedShopifyID(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure MagPmtLine_RemoveAssignedShopifyID(var Rec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptHeaderInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesShptHeaderInsert, '', false, false)]
#endif
    local procedure SalesShptHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesShipmentHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesShipmentHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptHeaderInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterReturnRcptHeaderInsert, '', false, false)]
#endif
    local procedure ReturnRcptHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesInvHeaderInsert, '', false, false)]
#endif
    local procedure SalesInvHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoHeaderInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesCrMemoHeaderInsert, '', false, false)]
#endif
    local procedure SalesCrMemoHdrCopyAssignedShopifyID(SalesHeader: Record "Sales Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        CopyAssignedShopifyID(SalesHeader.RecordId(), SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptLineInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesShptLineInsert, '', false, false)]
#endif
    local procedure SalesShptLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var SalesShipmentLine: Record "Sales Shipment Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), SalesShipmentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptLineInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterReturnRcptLineInsert, '', false, false)]
#endif
    local procedure ReturnRcptLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var ReturnRcptLine: Record "Return Receipt Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), ReturnRcptLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesInvLineInsert, '', false, false)]
#endif
    local procedure SalesInvLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var SalesInvLine: Record "Sales Invoice Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), SalesInvLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoLineInsert', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesCrMemoLineInsert, '', false, false)]
#endif
    local procedure SalesCrMemoLineCopyAssignedShopifyID(SalesLine: Record "Sales Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        CopyAssignedShopifyID(SalesLine.RecordId(), SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInsertTempSalesLine', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertTempSalesLine, '', false, false)]
#endif
    local procedure RecreateSalesLine_StoreAssignedIDsToTemp(SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        TempStoreAssignedShopifyIDs(SalesLine.RecordId(), TempSalesLine.RecordId(), true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCreateSalesLine', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterCreateSalesLine, '', false, false)]
#endif
    local procedure RecreateSalesLine_RestoreAssignedIDsFromTemp(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        TempStoreAssignedShopifyIDs(TempSalesLine.RecordId(), SalesLine.RecordId(), false);
    end;
    //#endregion
}
#endif