page 6014518 "NPR Sales Order Pick"
{
    // NPR4.18/JC/20151202  CASE 227142 Sales Order Pick
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to MAG2.00
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.41/TS  /20180105 CASE 300893 Chabged Post to Post Order as function Post already exist.
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.51/THRO/20190718 CASE 361514 Named actions "Post and Print" and "Post and Email" (for AL Conversion)

    Caption = 'Sales Order';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            field("Sales Order No."; SalesOrderNoSearch)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SalesOrderNoSearch field';

                trigger OnValidate()
                var
                    SalesOrderTestSearch: Record "Sales Header";
                begin
                    Clear(AlternativeNo);
                    Clear(ItemBarcode);
                    Clear(ItemVariantBarcode);
                    ItemFoundonLines := false;
                    if SalesOrderNoSearch <> '' then begin
                        SalesOrderTestSearch.Get("Document Type"::Order, SalesOrderNoSearch);
                        Reset;
                        SetRange("Document Type", "Document Type"::Order);
                        SetRange("No.", SalesOrderNoSearch);
                        CurrPage.Update;
                    end else
                        ItemBarcodeInput := '';
                end;
            }
            field("Item Barcode"; ItemBarcodeInput)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the ItemBarcodeInput field';

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
            field("Item No."; ItemBarcode."No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the ItemBarcode.No. field';
            }
            field("Item Found on SalesLines"; ItemFoundonLines)
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the ItemFoundonLines field';
            }
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Visible = DocNoVisible;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field';

                    trigger OnValidate()
                    begin
                        SelltoCustomerNoOnAfterValidat;
                    end;
                }
                field("Sell-to Contact No."; "Sell-to Contact No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Contact No. field';

                    trigger OnValidate()
                    begin
                        if GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                            if "Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                SetRange("Sell-to Contact No.");
                    end;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                }
                field("Sell-to Customer Name 2"; "Sell-to Customer Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                }
                field("Sell-to Address"; "Sell-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Address field';
                }
                field("Sell-to Address 2"; "Sell-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Address 2 field';
                }
                field("Sell-to Post Code"; "Sell-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Post Code field';
                }
                field("Sell-to City"; "Sell-to City")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Sell-to City field';
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Contact field';
                }
                field("No. of Archived Versions"; "No. of Archived Versions")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the No. of Archived Versions field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Order Date field';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Requested Delivery Date field';
                }
                field("Promised Delivery Date"; "Promised Delivery Date")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Promised Delivery Date field';
                }
                field("Quote No."; "Quote No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Quote No. field';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("Your Reference"; "Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Your Reference field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Salesperson Code field';

                    trigger OnValidate()
                    begin
                        SalespersonCodeOnAfterValidate;
                    end;
                }
                field("Campaign No."; "Campaign No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Campaign No. field';
                }
                field("Opportunity No."; "Opportunity No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Opportunity No. field';
                }
                field("Responsibility Center"; "Responsibility Center")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Responsibility Center field';
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Assigned User ID field';
                }
                field("Job Queue Status"; "Job Queue Status")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Job Queue Status field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
            }
            part(SalesLines; "NPR Sales Order Pick Subform")
            {
                Editable = DynamicEditable;
                SubPageLink = "Document No." = FIELD("No.");
                ApplicationArea = All;
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';

                    trigger OnValidate()
                    begin
                        BilltoCustomerNoOnAfterValidat;
                    end;
                }
                field("Bill-to Contact No."; "Bill-to Contact No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Contact No. field';
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name field';
                }
                field("Bill-to Name 2"; "Bill-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Address field';
                }
                field("Bill-to Address 2"; "Bill-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Post Code field';
                }
                field("Bill-to City"; "Bill-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to City field';
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Contact field';
                }
                field("Bill-to Company"; "NPR Bill-to Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Bill-to Company field';
                }
                field("Bill-To Vendor No."; "NPR Bill-To Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Bill-To Vendor No. field';
                }
                field("Bill-to E-mail"; "NPR Bill-to E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
                }
                field("Document Processing"; "NPR Document Processing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Document Processing field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV;
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV;
                    end;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Discount % field';
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Direct Debit Mandate ID"; "Direct Debit Mandate ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Debit Mandate ID field';
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices Including VAT field';

                    trigger OnValidate()
                    begin
                        PricesIncludingVATOnAfterValid;
                    end;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("Magento Payment Amount"; "NPR Magento Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Payment Amount field';
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Ship-to Code field';
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Ship-to Name 2"; "Ship-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field';
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Contact field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Outbound Whse. Handling Time field';
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Shipping Time"; "Shipping Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Time field';
                }
                field("Late Order Shipping"; "Late Order Shipping")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Late Order Shipping field';
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Package Tracking No. field';
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Shipping Advice field';

                    trigger OnValidate()
                    begin
                        if "Shipping Advice" <> xRec."Shipping Advice" then
                            if not Confirm(Text001, false, FieldCaption("Shipping Advice")) then
                                Error(Text002);
                    end;
                }
                field("Delivery Location"; "NPR Delivery Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Delivery Location field';
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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Re&lease action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Re&open action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Quantity to Ship 0 action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the P&ost Order action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post and &Print action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post and Email action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Post and handle as set up in ''Document Processing''';
                    ApplicationArea = All;
                }
                action("Test Report")
                {
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Test Report action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post &Batch action';

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Batch Post Sales Orders", true, true, Rec);
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
            SetRange("Responsibility Center", UserMgt.GetSalesFilter);
            FilterGroup(0);
        end;

        SetRange("Date Filter", 0D, WorkDate - 1);

        SetDocNoVisible;
    end;

    var
        Text000: Label 'Unable to run this function while in View mode.';
        CopySalesDoc: Report "Copy Sales Document";
        MoveNegSalesLines: Report "Move Negative Sales Lines";
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
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
        AlternativeNo: Record "NPR Alternative No.";
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
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::Order, "No.");
    end;
}

