page 6151542 "NPR APIV1 PBISales Inv. Hdr"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'salesInvoiceHeader';
    EntitySetName = 'salesInvoiceHeaders';
    Caption = 'PowerBI Sales Inv. Header';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Sales Invoice Header";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Disc.', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(amountIncludingVAT; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT', Locked = true;
                }
                field(appliesToDocNo; Rec."Applies-to Doc. No.")
                {
                    Caption = 'Applies-to Doc. No.', Locked = true;
                }
                field(appliesToDocType; Rec."Applies-to Doc. Type")
                {
                    Caption = 'Applies-to Doc. Type', Locked = true;
                }
                field("area"; Rec."Area")
                {
                    Caption = 'Area', Locked = true;
                }
                field(balAccountNo; Rec."Bal. Account No.")
                {
                    Caption = 'Bal. Account No.', Locked = true;
                }
                field(balAccountType; Rec."Bal. Account Type")
                {
                    Caption = 'Bal. Account Type', Locked = true;
                }
                field(billToAddress; Rec."Bill-to Address")
                {
                    Caption = 'Bill-to Address', Locked = true;
                }
                field(billToAddress2; Rec."Bill-to Address 2")
                {
                    Caption = 'Bill-to Address 2', Locked = true;
                }
                field(billToCity; Rec."Bill-to City")
                {
                    Caption = 'Bill-to City', Locked = true;
                }
                field(billToContact; Rec."Bill-to Contact")
                {
                    Caption = 'Bill-to Contact', Locked = true;
                }
                field(billToContactNo; Rec."Bill-to Contact No.")
                {
                    Caption = 'Bill-to Contact No.', Locked = true;
                }
                field(billToCountryRegionCode; Rec."Bill-to Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code', Locked = true;
                }
                field(billToCounty; Rec."Bill-to County")
                {
                    Caption = 'Bill-to County', Locked = true;
                }
                field(billToPostCode; Rec."Bill-to Post Code")
                {
                    Caption = 'Bill-to Post Code', Locked = true;
                }
                field(campaignNo; Rec."Campaign No.")
                {
                    Caption = 'Campaign No.', Locked = true;
                }
                field(cancelled; Rec.Cancelled)
                {
                    Caption = 'Cancelled', Locked = true;
                }
                field(closed; Rec.Closed)
                {
                    Caption = 'Closed', Locked = true;
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'Comment', Locked = true;
                }
                field(correction; Rec.Correction)
                {
                    Caption = 'Correction', Locked = true;
                }
                field(corrective; Rec.Corrective)
                {
                    Caption = 'Corrective', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(currencyFactor; Rec."Currency Factor")
                {
                    Caption = 'Currency Factor', Locked = true;
                }
                field(custLedgerEntryNo; Rec."Cust. Ledger Entry No.")
                {
                    Caption = 'Cust. Ledger Entry No.', Locked = true;
                }
                field(customerDiscGroup; Rec."Customer Disc. Group")
                {
                    Caption = 'Customer Disc. Group', Locked = true;
                }
                field(customerPostingGroup; Rec."Customer Posting Group")
                {
                    Caption = 'Customer Posting Group', Locked = true;
                }
                field(customerPriceGroup; Rec."Customer Price Group")
                {
                    Caption = 'Customer Price Group', Locked = true;
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(directDebitMandateID; Rec."Direct Debit Mandate ID")
                {
                    Caption = 'Direct Debit Mandate ID', Locked = true;
                }
                field(docExchOriginalIdentifier; Rec."Doc. Exch. Original Identifier")
                {
                    Caption = 'Doc. Exch. Original Identifier', Locked = true;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date', Locked = true;
                }
                field(documentExchangeIdentifier; Rec."Document Exchange Identifier")
                {
                    Caption = 'Document Exchange Identifier', Locked = true;
                }
                field(documentExchangeStatus; Rec."Document Exchange Status")
                {
                    Caption = 'Document Exchange Status', Locked = true;
                }
                field(draftInvoiceSystemId; Rec."Draft Invoice SystemId")
                {
                    Caption = 'Draft Invoice SystemId', Locked = true;
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date', Locked = true;
                }
                field(eu3PartyTrade; Rec."EU 3-Party Trade")
                {
                    Caption = 'EU 3-Party Trade', Locked = true;
                }
                field(exitPoint; Rec."Exit Point")
                {
                    Caption = 'Exit Point', Locked = true;
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.', Locked = true;
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                }
                field(getShipmentUsed; Rec."Get Shipment Used")
                {
                    Caption = 'Get Shipment Used', Locked = true;
                }
                field(invoiceDiscCode; Rec."Invoice Disc. Code")
                {
                    Caption = 'Invoice Disc. Code', Locked = true;
                }
                field(invoiceDiscountAmount; Rec."Invoice Discount Amount")
                {
                    Caption = 'Invoice Discount Amount', Locked = true;
                }
                field(invoiceDiscountCalculation; Rec."Invoice Discount Calculation")
                {
                    Caption = 'Invoice Discount Calculation', Locked = true;
                }
                field(invoiceDiscountValue; Rec."Invoice Discount Value")
                {
                    Caption = 'Invoice Discount Value', Locked = true;
                }
                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
                field(nprExchangeLabelBarcode; Rec."NPR Exchange Label Barcode")
                {
                    Caption = 'Exchange Label Barcode', Locked = true;
                }
                field(nprExternalOrderNo; Rec."NPR External Order No.")
                {
                    Caption = 'External Order No.', Locked = true;
                }
                field(nprGroupCode; Rec."NPR Group Code")
                {
                    Caption = 'Group Code', Locked = true;
                }
                field(nprMagentoCoupon; Rec."NPR Magento Coupon")
                {
                    Caption = 'Magento Coupon', Locked = true;
                }
                field(nprMagentoPaymentAmount; Rec."NPR Magento Payment Amount")
                {
                    Caption = 'Payment Amount', Locked = true;
                }
                field(nprSalesChannel; Rec."NPR Sales Channel")
                {
                    Caption = 'Sales Channel', Locked = true;
                }
                field(noPrinted; Rec."No. Printed")
                {
                    Caption = 'No. Printed', Locked = true;
                }
                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series', Locked = true;
                }
                field(onHold; Rec."On Hold")
                {
                    Caption = 'On Hold', Locked = true;
                }
                field(opportunityNo; Rec."Opportunity No.")
                {
                    Caption = 'Opportunity No.', Locked = true;
                }
                field(orderDate; Rec."Order Date")
                {
                    Caption = 'Order Date', Locked = true;
                }
                field(orderNo; Rec."Order No.")
                {
                    Caption = 'Order No.', Locked = true;
                }
                field(orderNoSeries; Rec."Order No. Series")
                {
                    Caption = 'Order No. Series', Locked = true;
                }
                field(packageTrackingNo; Rec."Package Tracking No.")
                {
                    Caption = 'Package Tracking No.', Locked = true;
                }
                field(paymentDiscount; Rec."Payment Discount %")
                {
                    Caption = 'Payment Discount %', Locked = true;
                }
                field(paymentMethodCode; Rec."Payment Method Code")
                {
                    Caption = 'Payment Method Code', Locked = true;
                }
                field(paymentReference; Rec."Payment Reference")
                {
                    Caption = 'Payment Reference', Locked = true;
                }
                field(paymentServiceSetID; Rec."Payment Service Set ID")
                {
                    Caption = 'Payment Service Set ID', Locked = true;
                }
                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms Code', Locked = true;
                }
                field(pmtDiscountDate; Rec."Pmt. Discount Date")
                {
                    Caption = 'Pmt. Discount Date', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(postingDescription; Rec."Posting Description")
                {
                    Caption = 'Posting Description', Locked = true;
                }
                field(preAssignedNo; Rec."Pre-Assigned No.")
                {
                    Caption = 'Pre-Assigned No.', Locked = true;
                }
                field(preAssignedNoSeries; Rec."Pre-Assigned No. Series")
                {
                    Caption = 'Pre-Assigned No. Series', Locked = true;
                }
                field(prepaymentInvoice; Rec."Prepayment Invoice")
                {
                    Caption = 'Prepayment Invoice', Locked = true;
                }
                field(prepaymentNoSeries; Rec."Prepayment No. Series")
                {
                    Caption = 'Prepayment No. Series', Locked = true;
                }
                field(prepaymentOrderNo; Rec."Prepayment Order No.")
                {
                    Caption = 'Prepayment Order No.', Locked = true;
                }
                field(priceCalculationMethod; Rec."Price Calculation Method")
                {
                    Caption = 'Price Calculation Method', Locked = true;
                }
                field(pricesIncludingVAT; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT', Locked = true;
                }
                field(quoteNo; Rec."Quote No.")
                {
                    Caption = 'Quote No.', Locked = true;
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code', Locked = true;
                }
                field(remainingAmount; Rec."Remaining Amount")
                {
                    Caption = 'Remaining Amount', Locked = true;
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center', Locked = true;
                }
                field(reversed; Rec.Reversed)
                {
                    Caption = 'Reversed', Locked = true;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(sellToAddress; Rec."Sell-to Address")
                {
                    Caption = 'Sell-to Address', Locked = true;
                }
                field(sellToAddress2; Rec."Sell-to Address 2")
                {
                    Caption = 'Sell-to Address 2', Locked = true;
                }
                field(sellToCity; Rec."Sell-to City")
                {
                    Caption = 'Sell-to City', Locked = true;
                }
                field(sellToContact; Rec."Sell-to Contact")
                {
                    Caption = 'Sell-to Contact', Locked = true;
                }
                field(sellToContactNo; Rec."Sell-to Contact No.")
                {
                    Caption = 'Sell-to Contact No.', Locked = true;
                }
                field(sellToCountryRegionCode; Rec."Sell-to Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code', Locked = true;
                }
                field(sellToCounty; Rec."Sell-to County")
                {
                    Caption = 'Sell-to County', Locked = true;
                }
                field(sellToCustomerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'Sell-to Customer Name', Locked = true;
                }
                field(sellToCustomerName2; Rec."Sell-to Customer Name 2")
                {
                    Caption = 'Sell-to Customer Name 2', Locked = true;
                }
                field(sellToEMail; Rec."Sell-to E-Mail")
                {
                    Caption = 'Email', Locked = true;
                }
                field(sellToPhoneNo; Rec."Sell-to Phone No.")
                {
                    Caption = 'Sell-to Phone No.', Locked = true;
                }
                field(sellToPostCode; Rec."Sell-to Post Code")
                {
                    Caption = 'Sell-to Post Code', Locked = true;
                }
                field(shipToAddress; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address', Locked = true;
                }
                field(shipToAddress2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address 2', Locked = true;
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City', Locked = true;
                }
                field(shipToCode; Rec."Ship-to Code")
                {
                    Caption = 'Ship-to Code', Locked = true;
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    Caption = 'Ship-to Contact', Locked = true;
                }
                field(shipToCountryRegionCode; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code', Locked = true;
                }
                field(shipToCounty; Rec."Ship-to County")
                {
                    Caption = 'Ship-to County', Locked = true;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-to Name', Locked = true;
                }
                field(shipToName2; Rec."Ship-to Name 2")
                {
                    Caption = 'Ship-to Name 2', Locked = true;
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code', Locked = true;
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    Caption = 'Shipment Date', Locked = true;
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code', Locked = true;
                }
                field(shippingAgentCode; Rec."Shipping Agent Code")
                {
                    Caption = 'Shipping Agent Code', Locked = true;
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code', Locked = true;
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code', Locked = true;
                }
                field(sourceCode; Rec."Source Code")
                {
                    Caption = 'Source Code', Locked = true;
                }
                field(taxAreaCode; Rec."Tax Area Code")
                {
                    Caption = 'Tax Area Code', Locked = true;
                }
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'Tax Liable', Locked = true;
                }
                field(transactionSpecification; Rec."Transaction Specification")
                {
                    Caption = 'Transaction Specification', Locked = true;
                }
                field(transactionType; Rec."Transaction Type")
                {
                    Caption = 'Transaction Type', Locked = true;
                }
                field(transportMethod; Rec."Transport Method")
                {
                    Caption = 'Transport Method', Locked = true;
                }
                field("userID"; Rec."User ID")
                {
                    Caption = 'User ID', Locked = true;
                }
                field(vatBaseDiscount; Rec."VAT Base Discount %")
                {
                    Caption = 'VAT Base Discount %', Locked = true;
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group', Locked = true;
                }
                field(vatCountryRegionCode; Rec."VAT Country/Region Code")
                {
                    Caption = 'VAT Country/Region Code', Locked = true;
                }
                field(vatRegistrationNo; Rec."VAT Registration No.")
                {
                    Caption = 'VAT Registration No.', Locked = true;
                }
                field(workDescription; Rec."Work Description")
                {
                    Caption = 'Work Description', Locked = true;
                }
                field(yourReference; Rec."Your Reference")
                {
                    Caption = 'Your Reference', Locked = true;
                }
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(selltoCustomerNo; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(billToCustomerNo; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.', Locked = true;
                }
                field(billtoName; Rec."Bill-to Name")
                {
                    Caption = 'Bill-to Name', Locked = true;
                }
                field(billtoName2; Rec."Bill-to Name 2")
                {
                    Caption = 'Bill-to Name 2', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
                }
            }
        }
    }
}