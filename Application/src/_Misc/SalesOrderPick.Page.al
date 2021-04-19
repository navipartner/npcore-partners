page 6014518 "NPR Sales Order Pick"
{
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Visible = DocNoVisible;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field';

                    trigger OnValidate()
                    begin
                        SelltoCustomerNoOnAfterValidat();
                    end;
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Contact No. field';

                    trigger OnValidate()
                    begin
                        if Rec.GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                            if Rec."Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                Rec.SetRange("Sell-to Contact No.");
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                }
                field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                }
                field("Sell-to Address"; Rec."Sell-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Address field';
                }
                field("Sell-to Address 2"; Rec."Sell-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Address 2 field';
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Post Code field';
                }
                field("Sell-to City"; Rec."Sell-to City")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Sell-to City field';
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Contact field';
                }
                field("No. of Archived Versions"; Rec."No. of Archived Versions")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the No. of Archived Versions field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Order Date field';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Requested Delivery Date field';
                }
                field("Promised Delivery Date"; Rec."Promised Delivery Date")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Promised Delivery Date field';
                }
                field("Quote No."; Rec."Quote No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Quote No. field';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Your Reference field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Salesperson Code field';

                    trigger OnValidate()
                    begin
                        SalespersonCodeOnAfterValidate();
                    end;
                }
                field("Campaign No."; Rec."Campaign No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Campaign No. field';
                }
                field("Opportunity No."; Rec."Opportunity No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Opportunity No. field';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Responsibility Center field';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Assigned User ID field';
                }
                field("Job Queue Status"; Rec."Job Queue Status")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Job Queue Status field';
                }
                field(Status; Rec.Status)
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
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';

                    trigger OnValidate()
                    begin
                        BilltoCustomerNoOnAfterValidat();
                    end;
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Contact No. field';
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name field';
                }
                field("Bill-to Name 2"; Rec."Bill-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                }
                field("Bill-to Address"; Rec."Bill-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Address field';
                }
                field("Bill-to Address 2"; Rec."Bill-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Post Code field';
                }
                field("Bill-to City"; Rec."Bill-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to City field';
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Bill-to Contact field';
                }
                field("Bill-to Company"; Rec."NPR Bill-to Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Bill-to Company field';
                }
                field("Bill-To Vendor No."; Rec."NPR Bill-To Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Bill-To Vendor No. field';
                }
                field("Bill-to E-mail"; Rec."NPR Bill-to E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV();
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV();
                    end;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field("Payment Discount %"; Rec."Payment Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Discount % field';
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Direct Debit Mandate ID"; Rec."Direct Debit Mandate ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Debit Mandate ID field';
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices Including VAT field';

                    trigger OnValidate()
                    begin
                        PricesIncludingVATOnAfterValid();
                    end;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("Magento Payment Amount"; Rec."NPR Magento Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Payment Amount field';
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Ship-to Code field';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field';
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Ship-to Contact field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Outbound Whse. Handling Time field';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Shipping Time"; Rec."Shipping Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Time field';
                }
                field("Late Order Shipping"; Rec."Late Order Shipping")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Late Order Shipping field';
                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Package Tracking No. field';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Shipping Advice field';

                    trigger OnValidate()
                    begin
                        if Rec."Shipping Advice" <> xRec."Shipping Advice" then
                            if not Confirm(ChangeRecordsQst, false, Rec.FieldCaption("Shipping Advice")) then
                                Error(UpdateErr);
                    end;
                }
                field("Delivery Location"; Rec."NPR Delivery Location")
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
        Rec.CheckCreditMaxBeforeInsert;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Responsibility Center" := UserMgt.GetSalesFilter();
    end;

    trigger OnOpenPage()
    begin
        if UserMgt.GetSalesFilter <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Responsibility Center", UserMgt.GetSalesFilter);
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

    local procedure ApproveCalcInvDisc()
    begin
        CurrPage.SalesLines.PAGE.ApproveCalcInvDisc();
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

    local procedure AccountCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true)
    end;

    local procedure Prepayment37OnAfterValidate()
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