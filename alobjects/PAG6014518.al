page 6014518 "Sales Order Pick"
{
    // NPR4.18/JC/20151202  CASE 227142 Sales Order Pick
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to MAG2.00
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.41/TS  /20180105 CASE 300893 Chabged Post to Post Order as function Post already exist.
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // #361514/THRO/20190718 CASE 361514 Named actions "Post and Print" and "Post and Email" (for AL Conversion)

    Caption = 'Sales Order';
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type"=FILTER(Order));

    layout
    {
        area(content)
        {
            field("Sales Order No.";SalesOrderNoSearch)
            {

                trigger OnValidate()
                var
                    SalesOrderTestSearch: Record "Sales Header";
                begin
                    Clear(AlternativeNo);
                    Clear(ItemBarcode);
                    Clear(ItemVariantBarcode);
                    ItemFoundonLines := false;
                    if SalesOrderNoSearch <> '' then begin
                      SalesOrderTestSearch.Get("Document Type"::Order,  SalesOrderNoSearch);
                      Reset;
                      SetRange("Document Type", "Document Type"::Order);
                      SetRange("No.", SalesOrderNoSearch);
                      CurrPage.Update;
                    end else
                      ItemBarcodeInput := '';
                end;
            }
            field("Item Barcode";ItemBarcodeInput)
            {

                trigger OnValidate()
                var
                    SalesLinesSearch: Record "Sales Line";
                begin
                    Clear(AlternativeNo);
                    Clear(ItemBarcode);
                    Clear(ItemVariantBarcode);
                    ItemFoundonLines := false;
                    if ItemBarcodeInput <> '' then begin
                      AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                      AlternativeNo.SetRange("Alt. No.", ItemBarcodeInput);
                      AlternativeNo.FindFirst;
                      ItemBarcode.Get(AlternativeNo.Code);

                      if AlternativeNo."Variant Code" <> '' then
                        ItemVariantBarcode.Get(AlternativeNo.Code, AlternativeNo."Variant Code");

                      SalesLinesSearch.SetRange("Document Type", SalesLinesSearch."Document Type"::Order);
                      SalesLinesSearch.SetRange("Document No.", "No.");
                      SalesLinesSearch.SetRange(Type, SalesLinesSearch.Type::Item);
                      SalesLinesSearch.SetRange("No.", ItemBarcode."No.");
                      SalesLinesSearch.FindFirst;

                      ItemFoundonLines := true;

                      CurrPage.SalesLines.PAGE.UpdateQtyToShipOnLines(ItemBarcode."No.", ItemVariantBarcode.Code, 1);
                      CurrPage.Update;
                    end;
                end;
            }
            field("Item No.";ItemBarcode."No.")
            {
                Editable = false;
            }
            field("Item Found on SalesLines";ItemFoundonLines)
            {
                Editable = false;
            }
            group(General)
            {
                Caption = 'General';
                field("No.";"No.")
                {
                    Importance = Promoted;
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                          CurrPage.Update;
                    end;
                }
                field("Sell-to Customer No.";"Sell-to Customer No.")
                {
                    Importance = Promoted;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        SelltoCustomerNoOnAfterValidat;
                    end;
                }
                field("Sell-to Contact No.";"Sell-to Contact No.")
                {
                    Importance = Additional;

                    trigger OnValidate()
                    begin
                        if GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                          if "Sell-to Contact No." <> xRec."Sell-to Contact No." then
                            SetRange("Sell-to Contact No.");
                    end;
                }
                field("Sell-to Customer Name";"Sell-to Customer Name")
                {
                    QuickEntry = false;
                }
                field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
                {
                }
                field("Sell-to Address";"Sell-to Address")
                {
                    Importance = Additional;
                }
                field("Sell-to Address 2";"Sell-to Address 2")
                {
                    Importance = Additional;
                }
                field("Sell-to Post Code";"Sell-to Post Code")
                {
                    Importance = Additional;
                }
                field("Sell-to City";"Sell-to City")
                {
                    QuickEntry = false;
                }
                field("Sell-to Contact";"Sell-to Contact")
                {
                }
                field("No. of Archived Versions";"No. of Archived Versions")
                {
                    Importance = Additional;
                }
                field("Posting Date";"Posting Date")
                {
                    QuickEntry = false;
                }
                field("Order Date";"Order Date")
                {
                    Importance = Promoted;
                    QuickEntry = false;
                }
                field("Document Date";"Document Date")
                {
                    QuickEntry = false;
                }
                field("Requested Delivery Date";"Requested Delivery Date")
                {
                }
                field("Promised Delivery Date";"Promised Delivery Date")
                {
                    Importance = Additional;
                }
                field("Quote No.";"Quote No.")
                {
                    Importance = Additional;
                }
                field("External Document No.";"External Document No.")
                {
                    Importance = Promoted;
                }
                field("Your Reference";"Your Reference")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        SalespersonCodeOnAfterValidate;
                    end;
                }
                field("Campaign No.";"Campaign No.")
                {
                    Importance = Additional;
                }
                field("Opportunity No.";"Opportunity No.")
                {
                    Importance = Additional;
                }
                field("Responsibility Center";"Responsibility Center")
                {
                    Importance = Additional;
                }
                field("Assigned User ID";"Assigned User ID")
                {
                    Importance = Additional;
                }
                field("Job Queue Status";"Job Queue Status")
                {
                    Importance = Additional;
                }
                field(Status;Status)
                {
                    Importance = Promoted;
                    QuickEntry = false;
                }
            }
            part(SalesLines;"Sales Order Pick Subform")
            {
                Editable = DynamicEditable;
                SubPageLink = "Document No."=FIELD("No.");
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Bill-to Customer No.";"Bill-to Customer No.")
                {
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        BilltoCustomerNoOnAfterValidat;
                    end;
                }
                field("Bill-to Contact No.";"Bill-to Contact No.")
                {
                    Importance = Additional;
                }
                field("Bill-to Name";"Bill-to Name")
                {
                }
                field("Bill-to Name 2";"Bill-to Name 2")
                {
                }
                field("Bill-to Address";"Bill-to Address")
                {
                    Importance = Additional;
                }
                field("Bill-to Address 2";"Bill-to Address 2")
                {
                    Importance = Additional;
                }
                field("Bill-to Post Code";"Bill-to Post Code")
                {
                    Importance = Additional;
                }
                field("Bill-to City";"Bill-to City")
                {
                }
                field("Bill-to Contact";"Bill-to Contact")
                {
                    Importance = Additional;
                }
                field("Bill-to Company";"Bill-to Company")
                {
                }
                field("Bill-To Vendor No.";"Bill-To Vendor No.")
                {
                }
                field("Bill-to E-mail";"Bill-to E-mail")
                {
                }
                field("Document Processing";"Document Processing")
                {
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV;
                    end;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV;
                    end;
                }
                field("Payment Terms Code";"Payment Terms Code")
                {
                    Importance = Promoted;
                }
                field("Due Date";"Due Date")
                {
                    Importance = Promoted;
                }
                field("Payment Discount %";"Payment Discount %")
                {
                }
                field("Pmt. Discount Date";"Pmt. Discount Date")
                {
                }
                field("Payment Method Code";"Payment Method Code")
                {
                }
                field("Direct Debit Mandate ID";"Direct Debit Mandate ID")
                {
                }
                field("Prices Including VAT";"Prices Including VAT")
                {

                    trigger OnValidate()
                    begin
                        PricesIncludingVATOnAfterValid;
                    end;
                }
                field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
                {
                }
                field("Magento Payment Amount";"Magento Payment Amount")
                {
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Code";"Ship-to Code")
                {
                    Importance = Promoted;
                }
                field("Ship-to Name";"Ship-to Name")
                {
                }
                field("Ship-to Name 2";"Ship-to Name 2")
                {
                }
                field("Ship-to Address";"Ship-to Address")
                {
                    Importance = Additional;
                }
                field("Ship-to Address 2";"Ship-to Address 2")
                {
                    Importance = Additional;
                }
                field("Ship-to Post Code";"Ship-to Post Code")
                {
                    Importance = Promoted;
                }
                field("Ship-to City";"Ship-to City")
                {
                }
                field("Ship-to Contact";"Ship-to Contact")
                {
                    Importance = Additional;
                }
                field("Location Code";"Location Code")
                {
                }
                field("Outbound Whse. Handling Time";"Outbound Whse. Handling Time")
                {
                    Importance = Additional;
                }
                field("Shipment Method Code";"Shipment Method Code")
                {
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {
                    Importance = Additional;
                }
                field("Shipping Agent Service Code";"Shipping Agent Service Code")
                {
                    Importance = Additional;
                }
                field("Shipping Time";"Shipping Time")
                {
                }
                field("Late Order Shipping";"Late Order Shipping")
                {
                    Importance = Additional;
                }
                field("Package Tracking No.";"Package Tracking No.")
                {
                    Importance = Additional;
                }
                field("Shipment Date";"Shipment Date")
                {
                    Importance = Promoted;
                }
                field("Shipping Advice";"Shipping Advice")
                {
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        if "Shipping Advice" <> xRec."Shipping Advice" then
                          if not Confirm(Text001,false,FieldCaption("Shipping Advice")) then
                            Error(Text002);
                    end;
                }
                field("Delivery Location";"Delivery Location")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup21)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F9';

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.PerformManualRelease(Rec);
                    end;
                }
                action("Re&open")
                {
                    Caption = 'Re&open';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.PerformManualReopen(Rec);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Quantity to Ship 0")
                {
                    Caption = 'Quantity to Ship 0';
                    Image = Shipment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.UpdateQtyToShipOnLines(ItemBarcode."No.", ItemVariantBarcode.Code, 0);
                        CurrPage.Update(false);
                    end;
                }
                action("P&ost Order")
                {
                    Caption = 'P&ost Order';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        Post(CODEUNIT::"Sales-Post (Yes/No)");
                    end;
                }
                action(PostAndPrint)
                {
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        Post(CODEUNIT::"Sales-Post + Print");
                    end;
                }
                action(PostAndEmail)
                {
                    Caption = 'Post and Email';
                    Ellipsis = true;
                    Image = PostMail;

                    trigger OnAction()
                    var
                        SalesPostPrint: Codeunit "Sales-Post + Print";
                    begin
                        SalesPostPrint.PostAndEmail(Rec);
                    end;
                }
                action(PostAndSendPdf2Nav)
                {
                    Caption = 'Post and Pdf2Nav';
                    Image = PostSendTo;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Post and handle as set up in ''Document Processing''';
                }
                action("Test Report")
                {
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintSalesHeader(Rec);
                    end;
                }
                action("Post &Batch")
                {
                    Caption = 'Post &Batch';
                    Ellipsis = true;
                    Image = PostBatch;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Batch Post Sales Orders",true,true,Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DynamicEditable := CurrPage.Editable;
    end;

    trigger OnAfterGetRecord()
    begin
        JobQueueVisible := "Job Queue Status" = "Job Queue Status"::"Scheduled for Posting";
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord;
        exit(ConfirmDeletion);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckCreditMaxBeforeInsert;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Responsibility Center" := UserMgt.GetSalesFilter;
    end;

    trigger OnOpenPage()
    begin
        if UserMgt.GetSalesFilter <> '' then begin
          FilterGroup(2);
          SetRange("Responsibility Center",UserMgt.GetSalesFilter);
          FilterGroup(0);
        end;

        SetRange("Date Filter",0D,WorkDate - 1);

        SetDocNoVisible;
    end;

    var
        Text000: Label 'Unable to run this function while in View mode.';
        CopySalesDoc: Report "Copy Sales Document";
        MoveNegSalesLines: Report "Move Negative Sales Lines";
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        EmailDocMgt: Codeunit "E-mail Document Management";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        ChangeExchangeRate: Page "Change Exchange Rate";
        UserMgt: Codeunit "User Setup Management";
        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
        [InDataSet]
        JobQueueVisible: Boolean;
        Text001: Label 'Do you want to change %1 in all related records in the warehouse?';
        Text002: Label 'The update has been interrupted to respect the warning.';
        DynamicEditable: Boolean;
        DocNoVisible: Boolean;
        ExternalDocNoMandatory: Boolean;
        SalesOrderNoSearch: Code[20];
        ItemBarcodeInput: Code[20];
        ItemBarcode: Record Item;
        ItemVariantBarcode: Record "Item Variant";
        AlternativeNo: Record "Alternative No.";
        ItemFoundonLines: Boolean;

    local procedure Post(PostingCodeunitID: Integer)
    begin
        SendToPosting(PostingCodeunitID);
        if "Job Queue Status" = "Job Queue Status"::"Scheduled for Posting" then
          CurrPage.Close;
        CurrPage.Update(false);
    end;

    procedure UpdateAllowed(): Boolean
    begin
        if CurrPage.Editable = false then
          Error(Text000);
        exit(true);
    end;

    local procedure ApproveCalcInvDisc()
    begin
        CurrPage.SalesLines.PAGE.ApproveCalcInvDisc;
    end;

    local procedure SelltoCustomerNoOnAfterValidat()
    begin
        if GetFilter("Sell-to Customer No.") = xRec."Sell-to Customer No." then
          if "Sell-to Customer No." <> xRec."Sell-to Customer No." then
            SetRange("Sell-to Customer No.");
        CurrPage.Update;
    end;

    local procedure SalespersonCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update;
    end;

    local procedure ShortcutDimension1CodeOnAfterV()
    begin
        CurrPage.Update;
    end;

    local procedure ShortcutDimension2CodeOnAfterV()
    begin
        CurrPage.Update;
    end;

    local procedure PricesIncludingVATOnAfterValid()
    begin
        CurrPage.Update;
    end;

    local procedure AccountCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true)
    end;

    local procedure Prepayment37OnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo;
    begin
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::Order,"No.");
    end;
}

