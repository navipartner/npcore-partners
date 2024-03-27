codeunit 6059875 "NPR POS Action: Imp. PstdInv B"
{
    Access = Internal;

    procedure PostedInvToPOS(var POSSession: Codeunit "NPR POS Session"; var SalesInvHeader: Record "Sales Invoice Header"; NegativeValues: Boolean; ShowSuccessMessage: Boolean; AppliesToInvoice: Boolean; TransferDim: Boolean; PostedSalesLineFilter: Text)
    var
        SalesInvLine: Record "Sales Invoice Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        DOCUMENT_IMPORTED: Label 'Invoice %1 was imported in POS.';
        Item: Record Item;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.", SalesInvHeader."Bill-to Customer No.");

        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::" ");
        if PostedSalesLineFilter <> '' then
            SalesInvLine.SetFilter("Line No.", PostedSalesLineFilter);
        if not SalesInvLine.FindSet() then
            exit;

        repeat
            case SalesInvLine.Type of
                SalesInvLine.Type::Item:
                    begin
                        Item.get(SalesInvLine."No.");
                        if SpecificItemTrackingExist(SalesInvLine."No.") then
                            InsertItemWithTrackingLine(SalesInvLine, POSSaleLine, TransferDim, NegativeValues, AppliesToInvoice)
                        else
                            InsertLine(SalesInvLine, POSSaleLine, NegativeValues, AppliesToInvoice, TransferDim);
                    end;
                else
                    InsertLine(SalesInvLine, POSSaleLine, NegativeValues, AppliesToInvoice, TransferDim);
            end;
        until SalesInvLine.Next() = 0;

        Commit();

        if ShowSuccessMessage then
            Message(StrSubstNo(DOCUMENT_IMPORTED, SalesInvHeader."No."));
    end;

    local procedure SpecificItemTrackingExist(ItemNo: Code[20]): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit(false);
        if Item."Item Tracking Code" = '' then
            exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);
        if ItemTrackingCode."SN Specific Tracking" then
            exit(true);
        if ItemTrackingCode."SN Sales Outbound Tracking" then
            exit(true);
        if ItemTrackingCode."Lot Specific Tracking" then
            exit(true);
        if ItemTrackingCode."Lot Sales Outbound Tracking" then
            exit(true);
        exit(false);
    end;

    local procedure InsertLine(SalesInvLine: Record "Sales Invoice Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; NegativeValues: Boolean; AppliesToInvoice: Boolean; TransferDim: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        InitNewLine(POSSaleLine, SaleLinePOS);

        case SalesInvLine.Type of
            SalesInvLine.Type::Item:
                begin
                    SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                    SaleLinePOS.Validate("No.", SalesInvLine."No.");
                    SaleLinePOS.Validate("Unit of Measure Code", SalesInvLine."Unit of Measure Code");
                end;
            SalesInvLine.Type::" ":
                SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
            SalesInvLine.Type::"G/L Account":
                begin
                    SaleLinePOS."Line Type" := "NPR POS Sale Line Type"::"GL Payment";
                    SaleLinePOS.Validate("No.", SalesInvLine."No.");
                end;
        end;

        if NegativeValues then begin
            SaleLinePOS.Validate(Quantity, -SalesInvLine.Quantity);
            if AppliesToInvoice then
                SaleLinePOS."Imported from Invoice No." := SalesInvLine."Document No.";
        end else
            SaleLinePOS.Validate(Quantity, SalesInvLine.Quantity);


        CopySaleInvLineToSaleLinePOS(SalesInvLine, SaleLinePOS, TransferDim);

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        SaleLinePOS.SetSkipCalcDiscount(false);
    end;

    local procedure InsertItemWithTrackingLine(SalesInvLine: Record "Sales Invoice Line"; var POSSaleLine: Codeunit "NPR POS Sale Line"; TransferDim: Boolean; NegativeValues: Boolean; AppliesToInvoice: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        if TempItemLedgerEntry.IsTemporary then
            TempItemLedgerEntry.DeleteAll();

        ItemTrackingDocMgt.RetrieveEntriesFromPostedInvoice(TempItemLedgerEntry, SalesInvLine.RowID1());

        if TempItemLedgerEntry.FindSet() then
            repeat
                InitNewLine(POSSaleLine, SaleLinePOS);
                SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                SaleLinePOS.Validate("No.", SalesInvLine."No.");
                SaleLinePOS.Validate("Unit of Measure Code", SalesInvLine."Unit of Measure Code");

                if NegativeValues then begin
                    SaleLinePOS.Validate(Quantity, -TempItemLedgerEntry.Quantity);
                    if AppliesToInvoice then
                        SaleLinePOS."Imported from Invoice No." := SalesInvLine."Document No.";
                end else
                    SaleLinePOS.Validate(Quantity, TempItemLedgerEntry.Quantity);

                CopySaleInvLineToSaleLinePOS(SalesInvLine, SaleLinePOS, TransferDim);

                SaleLinePOS."Serial No." := TempItemLedgerEntry."Serial No.";
                SaleLinePOS."Lot No." := TempItemLedgerEntry."Lot No.";
                POSSaleLine.InsertLineRaw(SaleLinePOS, false);
                SaleLinePOS.SetSkipCalcDiscount(false);
            until TempItemLedgerEntry.Next() = 0;
    end;

    local procedure InitNewLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        SaleLinePOS.SetSkipCalcDiscount(true); //Prevent overwrite of any discounts from sales document, until lines are added,deleted,removed.            
        SaleLinePOS.SetSkipUpdateDependantQuantity(true);
    end;

    local procedure CopySaleInvLineToSaleLinePOS(SalesInvLine: Record "Sales Invoice Line"; var SaleLinePOS: Record "NPR POS Sale Line"; TransferDim: Boolean)
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        SaleLinePOS.SetSkipUpdateDependantQuantity(false);
        SaleLinePOS.Description := SalesInvLine.Description;
        SaleLinePOS."Description 2" := SalesInvLine."Description 2";
        SaleLinePOS."Variant Code" := SalesInvLine."Variant Code";

        SaleLinePOS.Validate("Unit Price", SalesInvLine."Unit Price");
        SaleLinePOS."Bin Code" := SalesInvLine."Bin Code";
        SaleLinePOS.Validate("Allow Line Discount", SalesInvLine."Allow Line Disc.");
        SaleLinePOS.Validate("Discount %", SalesInvLine."Line Discount %");
        SaleLinePOS.Validate("Discount Amount", SalesInvLine."Line Discount Amount");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if TransferDim then begin
            SaleLinePOS."Shortcut Dimension 1 Code" := SalesInvLine."Shortcut Dimension 1 Code";
            SaleLinePOS."Shortcut Dimension 2 Code" := SalesInvLine."Shortcut Dimension 2 Code";
            SaleLinePOS."Dimension Set ID" := SalesInvLine."Dimension Set ID";
        end;

        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
        POSEntrySalesDocLink.SetRange("Sales Document No", SalesInvLine."Document No.");
        if POSEntrySalesDocLink.FindFirst() then
            if POSEntrySalesLine.Get(POSEntrySalesDocLink."POS Entry No.", SaleLinePOS."Line No.") then
                SaleLinePOS."Orig.POS Entry S.Line SystemId" := POSEntrySalesLine.SystemId;
    end;

    procedure SetPosSaleDimension(POSSale: Codeunit "NPR POS Sale"; SalesInvHeader: Record "Sales Invoice Header")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Dimension Set ID" := SalesInvHeader."Dimension Set ID";
        SalePOS."Shortcut Dimension 1 Code" := SalesInvHeader."Shortcut Dimension 1 Code";
        SalePOS."Shortcut Dimension 2 Code" := SalesInvHeader."Shortcut Dimension 2 Code";

        SalePOS.Modify(true);
    end;

    procedure SetPosSaleCustomer(POSSale: Codeunit "NPR POS Sale"; CustomerNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit;
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.Modify(true);
    end;


    procedure UpdateSalesPerson(POSSale: Codeunit "NPR POS Sale"; SalesInvHeader: Record "Sales Invoice Header")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Salesperson Code", SalesInvHeader."Salesperson Code");
        SalePOS.Modify();
    end;
}