page 6060037 "NPR APIV1 PBIPurchase Header"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'purchaseHeader';
    EntitySetName = 'purchaseHeaders';
    Caption = 'PowerBI Purchase Header';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Purchase Header";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(paytoVendorNo; Rec."Pay-to Vendor No.")
                {
                    Caption = 'Pay-to Vendor No.', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(status; Rec."Status")
                {
                    Caption = 'Status', Locked = true;
                }
                field(buyFromVendorNo; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Buy-from Vendor No.', Locked = true;
                }
                field(dimensionSetId; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date', Locked = true;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type', Locked = true;
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date', Locked = true;
                }
                field(expectedReceiptDate; Rec."Expected Receipt Date")
                {
                    Caption = 'Expected Receipt Date', Locked = true;
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                }
                field(invoice; Rec."Invoice")
                {
                    Caption = 'Invoice', Locked = true;
                }
                field(orderDate; Rec."Order Date")
                {
                    Caption = 'Order Date', Locked = true;
                }
                field(paymentDiscountPct; Rec."Payment Discount %")
                {
                    Caption = 'Payment Discount %', Locked = true;
                }
                field(pmtDiscountDate; Rec."Pmt. Discount Date")
                {
                    Caption = 'Pmt. Discount Date', Locked = true;
                }
                field(postingNo; Rec."Posting No.")
                {
                    Caption = 'Posting No.', Locked = true;
                }
                field(receive; Rec."Receive")
                {
                    Caption = 'Receive', Locked = true;
                }
                field(receivingNo; Rec."Receiving No.")
                {
                    Caption = 'Receiving No.', Locked = true;
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code', Locked = true;
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code', Locked = true;
                }
                field(transactionType; Rec."Transaction Type")
                {
                    Caption = 'Transaction Type', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Transaction Type', Locked = true;
                }
                field(quoteNo; Rec."Quote No.")
                {
                    Caption = 'Quote No.', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                field(invoiceReceivedDate; Rec."Invoice Received Date")
                {
                    Caption = 'Invoice Received Date', Locked = true;
                }
#ENDIF
                field(yourReference; Rec."Your Reference")
                {
                    Caption = 'Your Reference', Locked = true;
                }
            }
        }
    }

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";

}