page 6184951 "NPR APIV1 PBI POSPaymentMethod"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posPaymentMethod';
    EntitySetName = 'posPaymentMethods';
    Caption = 'PowerBI POS Payment Methods';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS Payment Method";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(allowRefund; Rec."Allow Refund")
                {
                    Caption = 'Allow Refund';
                }
                field(askForCheckNo; Rec."Ask for Check No.")
                {
                    Caption = 'Ask for Check No.';
                }
                field(autoEndSale; Rec."Auto End Sale")
                {
                    Caption = 'Auto End Sale';
                }
                field(binForVirtualCount; Rec."Bin for Virtual-Count")
                {
                    Caption = 'Bin for Virtual-Count';
                }
                field(blockPOSPayment; Rec."Block POS Payment")
                {
                    Caption = 'Block POS Payment';
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(condensedPostingDescription; Rec."Condensed Posting Description")
                {
                    Caption = 'Condensed Posting Description';
                }
                field(createdByVersion; Rec."Created by Version")
                {
                    Caption = 'Created by Version';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(eftSurchargeAccountNo; Rec."EFT Surcharge Account No.")
                {
                    Caption = 'EFT Surcharge Account No.';
                }
                field(eftTipAccountNo; Rec."EFT Tip Account No.")
                {
                    Caption = 'EFT Tip Account No.';
                }
                field(fixedRate; Rec."Fixed Rate")
                {
                    Caption = 'Fixed Rate';
                }
                field(forcedAmount; Rec."Forced Amount")
                {
                    Caption = 'Forced Amount';
                }
                field(includeInCounting; Rec."Include In Counting")
                {
                    Caption = 'Include In Counting';
                }
                field(matchSalesAmount; Rec."Match Sales Amount")
                {
                    Caption = 'Match Sales Amount';
                }
                field(maximumAmount; Rec."Maximum Amount")
                {
                    Caption = 'Max Amount';
                }
                field(minimumAmount; Rec."Minimum Amount")
                {
                    Caption = 'Min Amount';
                }
                field(nprWarningPopUpOnReturn; Rec."NPR Warning pop-up on Return")
                {
                    Caption = 'Warning pop-up on Return';
                }
                field(noMinAmountOnWebOrders; Rec."No Min Amount on Web Orders")
                {
                    Caption = 'No Min Amount on Web Orders';
                }
                field(openDrawer; Rec."Open Drawer")
                {
                    Caption = 'Open Drawer';
                }
                field(postCondensed; Rec."Post Condensed")
                {
                    Caption = 'Post Condensed';
                }
                field(processingType; Rec."Processing Type")
                {
                    Caption = 'Processing Type';
                }
                field(returnPaymentMethodCode; Rec."Return Payment Method Code")
                {
                    Caption = 'Return Payment Method Code';
                }
                field(reverseUnrealizedVAT; Rec."Reverse Unrealized VAT")
                {
                    Caption = 'Reverse Unrealized VAT';
                }
                field(roundingGainsAccount; Rec."Rounding Gains Account")
                {
                    Caption = 'Rounding Gains Account';
                }
                field(roundingLossesAccount; Rec."Rounding Losses Account")
                {
                    Caption = 'Rounding Losses Account';
                }
                field(roundingPrecision; Rec."Rounding Precision")
                {
                    Caption = 'Rounding Precision';
                }
                field(roundingType; Rec."Rounding Type")
                {
                    Caption = 'Rounding Type';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field(useStandExcRateForBal; Rec."Use Stand. Exc. Rate for Bal.")
                {
                    Caption = 'Use Standard Exchange Rate from BC';
                }
                field(vouchedBy; Rec."Vouched By")
                {
                    Caption = 'Vouched By';
                }
                field(zeroAsDefaultOnPopup; Rec."Zero as Default on Popup")
                {
                    Caption = 'Zero as Default on Popup';
                }
            }
        }
    }
}
