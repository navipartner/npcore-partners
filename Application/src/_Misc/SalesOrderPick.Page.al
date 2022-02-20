page 6014518 "NPR Sales Order Pick"
{
    Extensible = False;
    Caption = 'Sales Order';
    PageType = Card;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            field("Sales Order No."; SalesOrderNoSearch)
            {

                Caption = 'Sales Order No.';
                ToolTip = 'Specifies the value of the SalesOrderNoSearch field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                var
                    SalesOrderTestSearch: Record "Sales Header";
                begin
                    Clear(ItemBarcode);
                    Clear(ItemVariantBarcode);
                    ItemFoundonLines := false;
                    if SalesOrderNoSearch <> '' then begin
                        SalesOrderTestSearch.Get(Rec."Document Type"::Order, SalesOrderNoSearch);
                        Rec.Reset();
                        Rec.SetRange("Document Type", Rec."Document Type"::Order);
                        Rec.SetRange("No.", SalesOrderNoSearch);
                        CurrPage.Update();
                    end;
                end;
            }
            field("Item No."; ItemBarcode."No.")
            {

                Caption = 'Item No.';
                Editable = false;
                ToolTip = 'Specifies the value of the ItemBarcode.No. field';
                ApplicationArea = NPRRetail;
            }
            field("Item Found on SalesLines"; ItemFoundonLines)
            {

                Caption = 'Item Found on SalesLines';
                Editable = false;
                ToolTip = 'Specifies the value of the ItemFoundonLines field';
                ApplicationArea = NPRRetail;
            }
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {

                    Importance = Promoted;
                    Visible = DocNoVisible;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {

                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SelltoCustomerNoOnAfterValidat();
                    end;
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Contact No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec.GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                            if Rec."Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                Rec.SetRange("Sell-to Contact No.");
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
                {

                    ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to Address"; Rec."Sell-to Address")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to Address 2"; Rec."Sell-to Address 2")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to City"; Rec."Sell-to City")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Sell-to City field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {

                    ToolTip = 'Specifies the value of the Sell-to Contact field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Archived Versions"; Rec."No. of Archived Versions")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the No. of Archived Versions field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Order Date"; Rec."Order Date")
                {

                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Order Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Date"; Rec."Document Date")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Document Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {

                    ToolTip = 'Specifies the value of the Requested Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Promised Delivery Date"; Rec."Promised Delivery Date")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Promised Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Quote No."; Rec."Quote No.")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Quote No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Your Reference"; Rec."Your Reference")
                {

                    ToolTip = 'Specifies the value of the Your Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SalespersonCodeOnAfterValidate();
                    end;
                }
                field("Campaign No."; Rec."Campaign No.")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Campaign No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Opportunity No."; Rec."Opportunity No.")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Opportunity No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Responsibility Center field';
                    ApplicationArea = NPRRetail;
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Assigned User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Queue Status"; Rec."Job Queue Status")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Job Queue Status field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(SalesLines; "NPR Sales Order Pick Subform")
            {
                Editable = DynamicEditable;
                SubPageLink = "Document No." = FIELD("No.");
                ApplicationArea = NPRRetail;

            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        BilltoCustomerNoOnAfterValidat();
                    end;
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Contact No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {

                    ToolTip = 'Specifies the value of the Bill-to Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Name 2"; Rec."Bill-to Name 2")
                {

                    ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Address"; Rec."Bill-to Address")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Address 2"; Rec."Bill-to Address 2")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to City"; Rec."Bill-to City")
                {

                    ToolTip = 'Specifies the value of the Bill-to City field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Contact field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Company"; Rec."NPR Bill-to Company")
                {

                    ToolTip = 'Specifies the value of the NPR Bill-to Company field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-To Vendor No."; Rec."NPR Bill-To Vendor No.")
                {

                    ToolTip = 'Specifies the value of the NPR Bill-To Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to E-mail"; Rec."NPR Bill-to E-mail")
                {

                    ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV();
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV();
                    end;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Due Date"; Rec."Due Date")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Due Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Discount %"; Rec."Payment Discount %")
                {

                    ToolTip = 'Specifies the value of the Payment Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {

                    ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Debit Mandate ID"; Rec."Direct Debit Mandate ID")
                {

                    ToolTip = 'Specifies the value of the Direct Debit Mandate ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {

                    ToolTip = 'Specifies the value of the Prices Including VAT field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        PricesIncludingVATOnAfterValid();
                    end;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {

                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Payment Amount"; Rec."NPR Magento Payment Amount")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Payment Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Code"; Rec."Ship-to Code")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Ship-to Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {

                    ToolTip = 'Specifies the value of the Ship-to Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {

                    ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {

                    ToolTip = 'Specifies the value of the Ship-to City field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Contact field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Outbound Whse. Handling Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {

                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Time"; Rec."Shipping Time")
                {

                    ToolTip = 'Specifies the value of the Shipping Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Late Order Shipping"; Rec."Late Order Shipping")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Late Order Shipping field';
                    ApplicationArea = NPRRetail;
                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Package Tracking No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Shipping Advice field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Shipping Advice" <> xRec."Shipping Advice" then
                            if not Confirm(ChangeRecordsQst, false, Rec.FieldCaption("Shipping Advice")) then
                                Error(UpdateErr);
                    end;
                }
                field("Delivery Location"; Rec."NPR Delivery Location")
                {

                    ToolTip = 'Specifies the value of the NPR Delivery Location field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Re&lease action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Re&open action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Quantity to Ship 0 action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the P&ost Order action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Post and &Print action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Post and Email action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalesPostPrint: Codeunit "Sales-Post + Print";
                    begin
                        SalesPostPrint.PostAndEmail(Rec);
                    end;
                }
                action("Test Report")
                {
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    ToolTip = 'Executes the Test Report action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Post &Batch action';
                    ApplicationArea = NPRRetail;

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
        DynamicEditable := CurrPage.Editable();
    end;

    trigger OnAfterGetRecord()
    begin
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord();
        exit(Rec.ConfirmDeletion());
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.CheckCreditMaxBeforeInsert();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Responsibility Center" := UserMgt.GetSalesFilter();
    end;

    trigger OnOpenPage()
    begin
        if UserMgt.GetSalesFilter() <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Responsibility Center", UserMgt.GetSalesFilter());
            Rec.FilterGroup(0);
        end;

        Rec.SetRange("Date Filter", 0D, WorkDate() - 1);

        SetDocNoVisible();
    end;

    var
        ItemBarcode: Record Item;
        ItemVariantBarcode: Record "Item Variant";
        ReportPrint: Codeunit "Test Report-Print";
        UserMgt: Codeunit "User Setup Management";
        DocNoVisible: Boolean;
        DynamicEditable: Boolean;
        ItemFoundonLines: Boolean;
        SalesOrderNoSearch: Code[20];
        ChangeRecordsQst: Label 'Do you want to change %1 in all related records in the warehouse?';
        UpdateErr: Label 'The update has been interrupted to respect the warning.';
        ViewModeErr: Label 'Unable to run this function while in View mode.';

    local procedure Post(PostingCodeunitID: Integer)
    begin
        Rec.SendToPosting(PostingCodeunitID);
        if Rec."Job Queue Status" = Rec."Job Queue Status"::"Scheduled for Posting" then
            CurrPage.Close();
        CurrPage.Update(false);
    end;

    procedure UpdateAllowed(): Boolean
    begin
        if CurrPage.Editable = false then
            Error(ViewModeErr);
        exit(true);
    end;

    local procedure SelltoCustomerNoOnAfterValidat()
    begin
        if Rec.GetFilter("Sell-to Customer No.") = xRec."Sell-to Customer No." then
            if Rec."Sell-to Customer No." <> xRec."Sell-to Customer No." then
                Rec.SetRange("Sell-to Customer No.");
        CurrPage.Update();
    end;

    local procedure SalespersonCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update();
    end;

    local procedure ShortcutDimension1CodeOnAfterV()
    begin
        CurrPage.Update();
    end;

    local procedure ShortcutDimension2CodeOnAfterV()
    begin
        CurrPage.Update();
    end;

    local procedure PricesIncludingVATOnAfterValid()
    begin
        CurrPage.Update();
    end;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo;
    begin
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::Order, Rec."No.");
    end;
}
