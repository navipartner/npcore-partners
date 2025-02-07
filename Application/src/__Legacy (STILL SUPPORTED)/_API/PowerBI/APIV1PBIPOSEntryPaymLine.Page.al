page 6184941 "NPR APIV1PBIPOSEntryPaymLine"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posEntryPaymentLine';
    EntitySetName = 'posEntryPaymentLines';
    Caption = 'PowerBI POS Entry Payment Lines';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS Entry Payment Line";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(amountLCY; Rec."Amount (LCY)")
                {
                    Caption = 'Amount (LCY)', Locked = true;
                }
                field(amountSalesCurrency; Rec."Amount (Sales Currency)")
                {
                    Caption = 'Amount (Sales Currency)', Locked = true;
                }
                field(appliesToDocNo; Rec."Applies-to Doc. No.")
                {
                    Caption = 'Applies-to Doc. No.', Locked = true;
                }
                field(appliesToDocType; Rec."Applies-to Doc. Type")
                {
                    Caption = 'Applies-to Doc. Type', Locked = true;
                }
                field(createdByReconPostingNo; Rec."Created by Recon. Posting No.")
                {
                    Caption = 'Created by Reconciliation Posting No.', Locked = true;
                }
                field(createdByReconciliation; Rec."Created by Reconciliation")
                {
                    Caption = 'Created by Reconciliation', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Paid Currency Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(eft; Rec.EFT)
                {
                    Caption = 'EFT', Locked = true;
                }
                field(eftRefundable; Rec."EFT Refundable")
                {
                    Caption = 'EFT Refundable', Locked = true;
                }
                field(endingTime; Rec."Ending Time")
                {
                    Caption = 'Ending Time', Locked = true;
                }
                field(entryDate; Rec."Entry Date")
                {
                    Caption = 'Entry Date', Locked = true;
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.', Locked = true;
                }
                field(genPostingType; Rec."Gen. Posting Type")
                {
                    Caption = 'Gen. Posting Type', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(posEntryNo; Rec."POS Entry No.")
                {
                    Caption = 'POS Entry No.', Locked = true;
                }
                field(posPaymentBinCode; Rec."POS Payment Bin Code")
                {
                    Caption = 'POS Payment Bin Code', Locked = true;
                }
                field(posPaymentLineCreatedAt; Rec."POS Payment Line Created At")
                {
                    Caption = 'POS Payment Line Created At', Locked = true;
                }
                field(posPaymentMethodCode; Rec."POS Payment Method Code")
                {
                    Caption = 'POS Payment Method Code', Locked = true;
                }
                field(posPeriodRegisterNo; Rec."POS Period Register No.")
                {
                    Caption = 'POS Period Register No.', Locked = true;
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code', Locked = true;
                }
                field(posUnitNo; Rec."POS Unit No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }
                field(paymentAmount; Rec."Payment Amount")
                {
                    Caption = 'Payment Amount', Locked = true;
                }
                field(paymentFee; Rec."Payment Fee %")
                {
                    Caption = 'Payment Fee %', Locked = true;
                }
                field(paymentFeeNonInvoiced; Rec."Payment Fee % (Non-invoiced)")
                {
                    Caption = 'Payment Fee % (Non-invoiced)', Locked = true;
                }
                field(paymentFeeAmount; Rec."Payment Fee Amount")
                {
                    Caption = 'Payment Fee Amount', Locked = true;
                }
                field(paymentFeeAmountNonInv; Rec."Payment Fee Amount (Non-inv.)")
                {
                    Caption = 'Payment Fee Amount (Non-inv.)', Locked = true;
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center', Locked = true;
                }
                field(roundingAmount; Rec."Rounding Amount")
                {
                    Caption = 'Rounding Amount', Locked = true;
                }
                field(roundingAmountLCY; Rec."Rounding Amount (LCY)")
                {
                    Caption = 'Rounding Amount (LCY)', Locked = true;
                }
                field(roundingAmountSalesCurr; Rec."Rounding Amount (Sales Curr.)")
                {
                    Caption = 'Rounding Amount (Sales Curr.)', Locked = true;
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code', Locked = true;
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code', Locked = true;
                }
                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'Starting Time', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt', Locked = true;
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy', Locked = true;
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt', Locked = true;
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy', Locked = true;
                }
                field(taxAreaCode; Rec."Tax Area Code")
                {
                    Caption = 'Tax Area Code', Locked = true;
                }
                field(taxGroupCode; Rec."Tax Group Code")
                {
                    Caption = 'Tax Group Code', Locked = true;
                }
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'Tax Liable', Locked = true;
                }
                field(token; Rec.Token)
                {
                    Caption = 'Token', Locked = true;
                }
                field(useTax; Rec."Use Tax")
                {
                    Caption = 'Use Tax', Locked = true;
                }
                field(vatAmountLCY; Rec."VAT Amount (LCY)")
                {
                    Caption = 'VAT Amount (LCY)', Locked = true;
                }
                field(vatBaseAmountLCY; Rec."VAT Base Amount (LCY)")
                {
                    Caption = 'VAT Base Amount', Locked = true;
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group', Locked = true;
                }
                field(vatCalculationType; Rec."VAT Calculation Type")
                {
                    Caption = 'VAT Calculation Type', Locked = true;
                }
                field(vatIdentifier; Rec."VAT Identifier")
                {
                    Caption = 'VAT Identifier', Locked = true;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group', Locked = true;
                }
                field(voucherCategory; Rec."Voucher Category")
                {
                    Caption = 'Voucher Category', Locked = true;
                }
            }
        }
    }
}
