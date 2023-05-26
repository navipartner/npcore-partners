codeunit 6059875 "NPR POS Action: Imp. PstdInv B"
{
    Access = Internal;

    procedure PostedInvToPOS(var POSSession: Codeunit "NPR POS Session"; var SalesInvHeader: Record "Sales Invoice Header"; NegativeValues: Boolean; ShowSuccessMessage: Boolean; AppliesToInvoice: Boolean; TransferDim: Boolean; PostedSalesLineFilter: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesInvLine: Record "Sales Invoice Line";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        DOCUMENT_IMPORTED: Label 'Invoice %1 was imported in POS.';
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.", SalesInvHeader."Bill-to Customer No.");

        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::" ");
        if PostedSalesLineFilter <> '' then
            SalesInvLine.SetFilter("Line No.", PostedSalesLineFilter);
        SalesInvLine.FindSet();

        repeat
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            SaleLinePOS.SetSkipCalcDiscount(true); //Prevent overwrite of any discounts from sales document, until lines are added,deleted,removed.            
            SaleLinePOS.SetSkipUpdateDependantQuantity(true);

            case SalesInvLine.Type of
                SalesInvLine.Type::Item:
                    begin
                        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                        SaleLinePOS.Validate("No.", SalesInvLine."No.");
                        SaleLinePOS.Validate("Unit of Measure Code", SalesInvLine."Unit of Measure Code");
                    end;
                SalesInvLine.Type::" ":
                    begin
                        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
                        SaleLinePOS.Description := SalesInvLine.Description;
                    end;
            end;

            SaleLinePOS.SetSkipUpdateDependantQuantity(false);

            SaleLinePOS.Description := SalesInvLine.Description;
            SaleLinePOS."Description 2" := SalesInvLine."Description 2";
            SaleLinePOS."Variant Code" := SalesInvLine."Variant Code";

            SaleLinePOS.Validate("Unit Price", SalesInvLine."Unit Price");
            SaleLinePOS.Validate("Allow Line Discount", SalesInvLine."Allow Line Disc.");
            SaleLinePOS.Validate("Discount %", SalesInvLine."Line Discount %");
            SaleLinePOS.Validate("Discount Amount", SalesInvLine."Line Discount Amount");

            if NegativeValues then begin
                SaleLinePOS.Validate(Quantity, -SalesInvLine.Quantity);
                if AppliesToInvoice then
                    SaleLinePOS."Imported from Invoice No." := SalesInvLine."Document No.";
            end else
                SaleLinePOS.Validate(Quantity, SalesInvLine.Quantity);

            SaleLinePOS."Bin Code" := SalesInvLine."Bin Code";
            //SaleLinePOS."Location Code" := SalesInvLine."Location Code";

            if TransferDim then begin
                SaleLinePOS."Dimension Set ID" := SalesInvLine."Dimension Set ID";
                SaleLinePOS."Shortcut Dimension 1 Code" := SalesInvLine."Shortcut Dimension 1 Code";
                SaleLinePOS."Shortcut Dimension 2 Code" := SalesInvLine."Shortcut Dimension 2 Code";
            end;

            POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
            POSEntrySalesDocLink.SetRange("Sales Document No", SalesInvLine."Document No.");
            if POSEntrySalesDocLink.FindFirst() then
                if POSEntrySalesLine.Get(POSEntrySalesDocLink."POS Entry No.", SaleLinePOS."Line No.") then
                    SaleLinePOS."Orig.POS Entry S.Line SystemId" := POSEntrySalesLine.SystemId;

            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            POSSaleLine.InsertLineRaw(SaleLinePOS, false);
            SaleLinePOS.SetSkipCalcDiscount(false);
        until SalesInvLine.Next() = 0;

        Commit();

        if ShowSuccessMessage then
            Message(StrSubstNo(DOCUMENT_IMPORTED, SalesInvHeader."No."));
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