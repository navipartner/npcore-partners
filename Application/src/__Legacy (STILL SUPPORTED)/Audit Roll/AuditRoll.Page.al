page 6014432 "NPR Audit Roll"
{
    Caption = 'Audit Roll';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Prints,Posting,Test5,Test6,Test7,Test8';
    SourceTable = "NPR Audit Roll";
    SourceTableView = SORTING("Sale Date", "Sales Ticket No.", "Sale Type", "Line No.")
                      ORDER(Descending);
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(AdvancedPostingWarning; TextAdvancedPosting)
            {
                ApplicationArea = All;
                Caption = 'Advanced Posting Warning';
                Editable = false;
                MultiLine = false;
                ShowCaption = false;
                Style = Unfavorable;
                StyleExpr = TRUE;
                Visible = AdvancedPosting;
                ToolTip = 'Specifies the value of the Advanced Posting Warning field';
            }
            field(ClicktoSeePOSEntries; ClicktoSeePOSEntries)
            {
                ApplicationArea = All;
                Caption = 'Click to See POS Entriies';
                LookupPageID = "NPR POS Entries";
                ShowCaption = false;
                Visible = AdvancedPosting;
                ToolTip = 'Specifies the value of the Click to See POS Entriies field';

                trigger OnAssistEdit()
                begin
                    PAGE.Run(PAGE::"NPR POS Entry List");
                    CurrPage.Close;
                end;
            }
            field(TypeFilter; TypeFilter)
            {
                ApplicationArea = All;
                Caption = 'Type Filter';
                Visible = false;
                ToolTip = 'Specifies the value of the Type Filter field';

                trigger OnValidate()
                begin
                    if TypeFilter > TypeFilter::" " then begin
                        SetRange(Type, TypeFilter - 1);
                        HideCancelled := false;
                    end else begin
                        SetRange(Type);
                        HideCancelled := true;
                        SetFilter(Type, '<>%1', Type::Cancelled);
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(CounterNoFilter; CounterNoFilter)
            {
                ApplicationArea = All;
                Caption = 'Counter No.Filter';
                TableRelation = "NPR Register"."Register No.";
                Visible = false;
                ToolTip = 'Specifies the value of the Counter No.Filter field';

                trigger OnValidate()
                begin
                    if CounterNoFilter <> '' then begin
                        SetCurrentKey("Register No.", "Sales Ticket No.");
                        SetRange("Register No.", CounterNoFilter)
                    end else begin
                        SetRange("Register No.");
                        SetCurrentKey("Sales Ticket No.");
                    end;

                    CurrPage.Update(false);
                end;
            }
            field(SalespersonCodeFilter; SalespersonCodeFilter)
            {
                ApplicationArea = All;
                Caption = 'Sales Person Code Filter';
                TableRelation = "Salesperson/Purchaser".Code;
                Visible = false;
                ToolTip = 'Specifies the value of the Sales Person Code Filter field';

                trigger OnValidate()
                begin
                    if SalespersonCodeFilter <> '' then
                        SetRange("Salesperson Code", SalespersonCodeFilter)
                    else
                        SetRange("Salesperson Code");

                    CurrPage.Update(false);
                end;
            }
            field(CustomerNoFilter; CustomerNoFilter)
            {
                ApplicationArea = All;
                Caption = 'Customer No. Filter';
                Visible = false;
                ToolTip = 'Specifies the value of the Customer No. Filter field';

                trigger OnValidate()
                begin
                    if CustomerNoFilter <> '' then
                        SetRange("Customer No.", CustomerNoFilter)
                    else
                        SetRange("Customer No.");
                    CurrPage.Update(true);
                end;
            }
            field(SaleDateFilter; SaleDateFilter)
            {
                ApplicationArea = All;
                Caption = 'Sales Date Filter';
                Visible = false;
                ToolTip = 'Specifies the value of the Sales Date Filter field';

                trigger OnValidate()
                begin
                    if SaleDateFilter <> 0D then begin
                        SetRange("Sale Date", SaleDateFilter);
                    end else begin
                        SetRange("Sale Date");
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(HideCancelled; HideCancelled)
            {
                ApplicationArea = All;
                Caption = 'Hide Cancelled';
                Visible = false;
                ToolTip = 'Specifies the value of the Hide Cancelled field';

                trigger OnValidate()
                begin
                    if HideCancelled then begin
                        SetFilter(Type, '<>%1', Type::Cancelled);
                    end else begin
                        SetRange(Type);
                    end;

                    TypeFilter := TypeFilter::" ";
                    CurrPage.Update(true);
                end;
            }
            field(PostedFilter; PostedFilter)
            {
                ApplicationArea = All;
                Caption = 'Posted Filter';
                OptionCaption = ' ,No,Yes';
                Visible = false;
                ToolTip = 'Specifies the value of the Posted Filter field';

                trigger OnValidate()
                begin
                    if PostedFilter = PostedFilter::" " then begin
                        SetRange(Posted);
                    end else begin
                        if PostedFilter = PostedFilter::No then begin
                            SetRange(Posted, false);
                        end else begin
                            if PostedFilter = PostedFilter::Yes then begin
                                SetRange(Posted, true);
                            end;
                        end;
                    end;

                    CurrPage.Update(true);

                end;
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = FieldRegisterNo;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Type field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Closing Time field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Gift voucher ref."; "Gift voucher ref.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Gift voucher ref. field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Posted field';
                }
                field("Item Entry Posted"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Item Entry Posted field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the VAT % field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("<Item Entry Posted1>"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Item Entry Posted field';
                }
                field(Offline; Offline)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Offline field';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
            }
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                end;

                trigger Pong()
                begin
                    CurrPage.PingPong.Stop;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                Caption = '&Print';
                action("Sales Ticket")
                {
                    Caption = 'Receipt';
                    Image = Sales;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Receipt action';

                    trigger OnAction()
                    var
                        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
                    begin
                        if (Type = Type::"Open/Close") or (Type = Type::Cancelled) then
                            Error(Text10600005);
                        AuditRollGlobal.Reset;
                        AuditRollGlobal := Rec;
                        AuditRollGlobal.SetRecFilter;
                        AuditRollGlobal.MarkedOnly(false);
                        AuditRollGlobal.SetRange("Sale Type");
                        AuditRollGlobal.SetRange(Type);
                        AuditRollGlobal.SetRange("Line No.");
                        AuditRollGlobal.SetRange("No.");
                        StdCodeunitCode.PrintReceipt(AuditRollGlobal, true);

                    end;
                }
                action("A4 Sales Ticket")
                {
                    Caption = 'A4 Sales Ticket';
                    Image = Sales;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the A4 Sales Ticket action';

                    trigger OnAction()
                    var
                        AuditRoll: Record "NPR Audit Roll";
                    begin
                        if (Type = Type::"Open/Close") or (Type = Type::Cancelled) then
                            Error(Text10600005);
                        AuditRoll.Reset;
                        AuditRoll := Rec;
                        AuditRoll.SetRecFilter;
                        AuditRoll.MarkedOnly(false);
                        AuditRoll.SetRange("Sale Type");
                        AuditRoll.SetRange(Type);
                        AuditRoll.SetRange("Line No.");
                        AuditRoll.SetRange("No.");
                        AuditRoll.PrintReceiptA4(true);
                    end;
                }
                action(Invoice)
                {
                    Caption = 'Invoice';
                    Image = Invoice;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Invoice action';

                    trigger OnAction()
                    var
                        AuditRoll3: Record "NPR Audit Roll";
                    begin
                        AuditRoll3.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        AuditRoll3.Find('-');
                        AuditRoll3.TestField("Sale Type", "Sale Type"::"Debit Sale");
                        AuditRoll3.TestField("Allocated No.");
                        SalesInvoiceHeader.FilterGroup := 2;
                        SalesInvoiceHeader.SetRange("Pre-Assigned No.", "Sales Ticket No.");
                        SalesInvoiceHeader.Find('-');
                        SalesInvoiceHeader.FilterGroup := 0;

                        SalesInvoiceHeader.PrintRecords(true);
                    end;
                }
                action("Debit Receipt")
                {
                    Caption = 'Debit Receipt';
                    Image = Receipt;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Debit Receipt action';

                    trigger OnAction()
                    var
                        RetailSalesCode: Codeunit "NPR Retail Sales Code";
                    begin
                        AuditRollGlobal.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        AuditRollGlobal.SetRange("Register No.", "Register No.");
                        AuditRollGlobal.SetRange("Sale Date", "Sale Date");

                        if (AuditRollGlobal.Count <> 0) then begin
                            if AuditRollGlobal.FindFirst() then;
                            AuditRollGlobal.SetRecFilter();
                            RetailSalesCode.Run(AuditRollGlobal);
                        end else
                            Message(Text10600007);
                    end;
                }
                action("Insurance Offer")
                {
                    Caption = 'Insurranceoffer';
                    Image = Insurance;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Insurranceoffer action';

                    trigger OnAction()
                    begin
                        RetailContractMgt.PrintInsurance("Register No.", "Sales Ticket No.", true);
                    end;
                }
                action("Retail Order")
                {
                    Caption = 'Retail order';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail order action';

                    trigger OnAction()
                    var
                        RetailDocumentHeader: Record "NPR Retail Document Header";
                    begin
                        RetailDocumentHeader.Reset;
                        RetailDocumentHeader.SetRange("Document Type", RetailDocumentHeader."Document Type"::"Retail Order");
                        RetailDocumentHeader.SetRange("No.", "Retail Document No.");
                        RetailDocumentHeader.Find('-');
                        RetailDocumentHeader.PrintRetailDocument(false);
                    end;
                }
                separator(Separator6150653)
                {
                }
                action("Register Report")
                {
                    Caption = 'Register Report';
                    Image = Report2;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Register Report action';

                    trigger OnAction()
                    var
                        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
                    begin
                        StdCodeunitCode.PrintRegisterReceipt(Rec);
                    end;
                }
                action("Tax Free")
                {
                    Caption = 'Tax Free';
                    Image = TaxDetail;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = false;
                    Visible = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Tax Free action';

                    trigger OnAction()
                    var
                        TaxFreeVoucher: Record "NPR Tax Free Voucher";
                        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
                    begin
                        if (Type = Type::"Open/Close") or (Type = Type::Cancelled) then
                            Error(Text10600005);
                        AuditRollGlobal.Reset;
                        CurrPage.SetSelectionFilter(AuditRollGlobal);
                        AuditRollGlobal.MarkedOnly(false);
                        AuditRollGlobal.SetRange("Sale Type");
                        AuditRollGlobal.SetRange(Type);
                        AuditRollGlobal.SetRange("Line No.");
                        AuditRollGlobal.SetRange("No.");

                        AuditRollGlobal.FindSet;
                        TaxFreeMgt.VoucherIssueFromPOSSale(AuditRollGlobal."Sales Ticket No.");
                    end;
                }
            }
            group("Credit Card")
            {
                Caption = '&Credit Card';
                action("Credit Transaction List")
                {
                    Caption = 'Credit Card Transaction List';
                    Image = "Action";
                    RunObject = Page "NPR Credit card Trx List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Credit Card Transaction List action';
                }
                action("EFT Receipt")
                {
                    Caption = 'EFT Receipt';
                    Image = Print;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT Receipt action';

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        EFTTransactionRequest.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        EFTTransactionRequest.SetRange("Register No.", "Register No.");
                        if EFTTransactionRequest.FindSet then
                            repeat
                                EFTTransactionRequest.PrintReceipts(true);
                            until EFTTransactionRequest.Next = 0;
                    end;
                }
                action("Show credit Card Transaction")
                {
                    Caption = 'Show Credit Card Transaction';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Credit Card Transaction action';

                    trigger OnAction()
                    begin
                        CreditCardTransaction.Reset;
                        CreditCardTransaction.FilterGroup := 2;
                        CreditCardTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", Date);
                        CreditCardTransaction.SetRange("Register No.", "Register No.");
                        CreditCardTransaction.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        CreditCardTransaction.SetRange(Date, "Sale Date");
                        CreditCardTransaction.FilterGroup := 0;
                        if CreditCardTransaction.Find('-') then
                            PAGE.RunModal(PAGE::"NPR Credit Card Trx Receipt", CreditCardTransaction)
                        else
                            Message(Text10600006, "Sales Ticket No.", "Register No.");
                    end;
                }
                action("EFT Transaction Requests")
                {
                    Caption = 'EFT Transaction Requests';
                    Image = CreditCardLog;
                    RunObject = Page "NPR EFT Transaction Requests";
                    RunPageLink = "Sales Ticket No." = FIELD("Sales Ticket No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT Transaction Requests action';
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action("Post Payments")
                {
                    Caption = 'Post Payments';
                    Image = Post;
                    ShortCutKey = 'F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post Payments action';

                    trigger OnAction()
                    begin
                        Filter[1] := PaymentEntries();
                    end;
                }
                action("Move Sales Ticket to Warranty")
                {
                    Caption = 'Move Sales Ticket to Warranty';
                    Image = MovementWorksheet;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Move Sales Ticket to Warranty action';

                    trigger OnAction()
                    var
                        WarrantyDirectory: Record "NPR Warranty Directory";
                    begin
                        WarrantyDirectory.TransferFromAuditRoll(Rec);
                    end;
                }
                separator(Separator6150668)
                {
                }
                action("Show Documents")
                {
                    Caption = 'Show Documents';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Documents action';

                    trigger OnAction()
                    var
                        SalesTicketNo: Code[20];
                    begin
                        if "Sales Ticket No." = '' then
                            Error(Text10600004);
                        SalesTicketNo := "Sales Ticket No.";
                        case "Document Type" of
                            "Document Type"::Invoice:
                                begin
                                    SalesInvoiceHeader.FilterGroup := 2;
                                    SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesTicketNo);
                                    SalesInvoiceHeader.FilterGroup := 0;
                                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                                end;
                            "Document Type"::Order:
                                begin
                                    SalesShipmentHeader.FilterGroup := 2;
                                    SalesShipmentHeader.SetRange("NPR Sales Ticket No.", SalesTicketNo);
                                    SalesShipmentHeader.FilterGroup := 0;
                                    PAGE.RunModal(PAGE::"Posted Sales Shipment", SalesShipmentHeader);
                                end;
                            "Document Type"::"Credit Memo":
                                begin
                                    SalesCrMemoHeader.FilterGroup := 2;
                                    SalesCrMemoHeader.SetRange("Pre-Assigned No.", SalesTicketNo);
                                    SalesCrMemoHeader.FilterGroup := 0;
                                    PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                                end;
                        end;
                    end;
                }
                action("Show Period")
                {
                    Caption = 'Show Period';
                    Image = Period;
                    RunObject = Page "NPR Periods";
                    RunPageLink = "Sales Ticket No." = FIELD("Sales Ticket No."),
                                  "Register No." = FIELD("Register No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Period action';
                }
                action("&Navigate")
                {
                    Caption = 'Naviger';
                    Image = Navigate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Naviger action';

                    trigger OnAction()
                    var
                        Navigate: Page Navigate;
                    begin
                        Navigate.SetDoc("Sale Date", "Posted Doc. No.");
                        Navigate.Run;
                    end;
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
                action(ChangeDimensions)
                {
                    Caption = 'Change Dimensions';
                    Image = ChangeDimensions;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Change Dimensions action';

                    trigger OnAction()
                    begin
                        SetDimensions;
                    end;
                }
                action(Comment)
                {
                    Caption = 'Comments';
                    Image = Comment;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Comments action';

                    trigger OnAction()
                    var
                        RetailComment: Record "NPR Retail Comment";
                        RetailComments: Page "NPR Retail Comments";
                    begin
                        RetailComment.SetRange("Table ID", DATABASE::"NPR Audit Roll");
                        RetailComment.SetRange("No.", "Register No.");
                        RetailComment.SetRange("No. 2", "Sales Ticket No.");
                        RetailComments.SetTableView(RetailComment);
                        RetailComments.Editable(false);
                        RetailComments.RunModal;
                    end;
                }
                action("POS Info")
                {
                    Caption = 'POS Info';
                    Image = Info;
                    RunObject = Page "NPR POS Info Audit Roll";
                    RunPageLink = "Register No." = FIELD("Register No."),
                                  "Sales Ticket No." = FIELD("Sales Ticket No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Info action';
                }
                action("POS Entry")
                {
                    Caption = 'POS Entry';
                    Image = Entries;
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Entry action';

                    trigger OnAction()
                    var
                        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", "Clustered Key");
                        if AuditRolltoPOSEntryLink.FindFirst then begin
                            POSEntry.SetRange("Entry No.", AuditRolltoPOSEntryLink."POS Entry No.");
                            Clear(POSEntryList);
                            POSEntryList.SetTableView(POSEntry);
                            POSEntryList.Run;
                        end;
                    end;
                }
                action(AdvancedFilter)
                {
                    Caption = 'Advanced Filter';
                    Image = "Filter";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Advanced Filter action';
                }
                separator(Separator6150674)
                {
                }
                action(Calculate)
                {
                    Caption = 'Calculate';
                    Image = Calculate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Calculate action';
                }
                action(Sum)
                {
                    Caption = 'Sum';
                    Image = Totals;
                    ShortCutKey = 'Ctrl+S';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sum action';

                    trigger OnAction()
                    var
                        AuditRoll: Record "NPR Audit Roll";
                        "Sum": Decimal;
                    begin
                        AuditRoll.CopyFilters(Rec);

                        if AuditRoll.Find('-') then
                            repeat
                                Sum += AuditRoll."Amount Including VAT";
                            until AuditRoll.Next = 0;

                        Message(Format(Sum));

                        Rec.CopyFilters(AuditRoll);
                    end;
                }
                action("Sales Ticket Statistics")
                {
                    Caption = 'Sales Ticket Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Ticket Statistics action';

                    trigger OnAction()
                    begin
                        AuditRollGlobal.Reset;
                        AuditRollGlobal.FilterGroup := 2;

                        AuditRollGlobal.SetRange("Register No.", "Register No.");
                        AuditRollGlobal.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        AuditRollGlobal.SetRange("Sale Type", "Sale Type"::Sale);
                        AuditRollGlobal.SetRange("Sale Date", "Sale Date");
                        AuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"NPR Audit Roll Statistics", AuditRollGlobal);
                    end;
                }
                action("Advanced Sales Statistics")
                {
                    Caption = 'Advanced Sales Statistics';
                    Image = Statistics;
                    RunObject = Page "NPR Advanced Sales Stats";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Advanced Sales Statistics action';
                }
                action("Day Report")
                {
                    Caption = 'Day Report';
                    Image = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Day Report action';

                    trigger OnAction()
                    begin
                        AuditRollGlobal.Reset;
                        AuditRollGlobal.FilterGroup := 2;
                        AuditRollGlobal.SetCurrentKey("Sale Date", "Sale Type");
                        AuditRollGlobal.SetRange("Register No.");
                        AuditRollGlobal.SetRange("Sales Ticket No.");
                        AuditRollGlobal.SetRange("Sale Type", "Sale Type"::Sale);
                        AuditRollGlobal.SetRange("Sale Date", Today);
                        AuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"NPR Audit Roll Statistics", AuditRollGlobal);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TempAuditRollArray[2] := TempAuditRollArray[1];
        TempAuditRollArray[1] := Rec;

        SelectedTicketNo := Rec."Sales Ticket No.";

        DoUpdate := true;

        if TempAuditRollArray[1]."Sales Ticket No." <> TempAuditRollArray[2]."Sales Ticket No." then
            CurrPage.PingPong.Ping(1);
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyleExpression;
    end;

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if GetFilter(Type) = '' then
            SetFilter(Type, '<>%1', Type::Cancelled);
        if FindFirst then;

        SelectedTicketNo := "Sales Ticket No.";

        if NPRetailSetup.Get then
            AdvancedPosting := NPRetailSetup."Advanced Posting Activated";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Filter[2] = Filter::Payment then begin
            Filter[1] := PaymentEntries();
            CurrPage.Update(false);
            exit(false);
        end;
        if Filter[2] = Filter::Deposit then begin
            Filter[1] := DepositEntries();
            CurrPage.Update(true);
            exit(false);
        end;
    end;

    var
        AuditRollGlobal: Record "NPR Audit Roll";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CreditCardTransaction: Record "NPR EFT Receipt";
        TempAuditRollArray: array[2] of Record "NPR Audit Roll" temporary;
        RetailContractMgt: Codeunit "NPR Retail Contract Mgt.";
        CounterNoFilter: Code[10];
        SalespersonCodeFilter: Code[10];
        CustomerNoFilter: Code[20];
        "Filter": array[2] of Option " ",Payment,Deposit;
        TypeFilter: Option " ","G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        PostedFilter: Option " ",No,Yes;
        FindLast: Option " ",No,Yes;
        ExtFilters: Boolean;
        HideCancelled: Boolean;
        Text10600004: Label 'Wrong sales ticket line, document no. is missing!';
        Text10600005: Label 'Nothing to print';
        Text10600006: Label 'There are no credit card transactions attached to sales ticket no. %1/Register %2';
        Text10600007: Label 'This is not a customer sale.';
        [InDataSet]
        FieldRegisterNo: Boolean;
        SaleDateFilter: Date;
        SelectedTicketNo: Text;
        DoUpdate: Boolean;
        StyleExpr: Text;
        TaxFree_Create: Label 'Cannot find any existing tax free vouchers associated with sale. Do you want to issue a new voucher for this sale?';
        AdvancedPosting: Boolean;
        TextAdvancedPosting: Label 'WARNING: Advanced Posting is active. Audit Roll is not used for posting.';
        ClicktoSeePOSEntries: Label 'Click here to see POS Entries.';

    // procedure PostReceipt()
    // var
    //     AuditRoll4: Record "NPR Audit Roll";
    //     PostTempAuditRoll: Codeunit "NPR Post Temp Audit Roll";
    //     AuditRollPosting: Record "NPR Audit Roll Posting";
    //     TX001: Label 'Posted ?';
    //     PostDocNo: Code[20];
    // begin
    //     AuditRoll4 := Rec;
    //     AuditRoll4.SetCurrentKey("Register No.", "Sales Ticket No.");
    //     AuditRoll4.SetRange("Register No.", "Register No.");
    //     AuditRoll4.SetRange("Sales Ticket No.", "Sales Ticket No.");
    //     if Confirm(TX001, true, AuditRoll4.GetFilters) then begin
    //         AuditRollPosting.DeleteAll;
    //         AuditRollPosting.TransferFromRevSilent(AuditRoll4, AuditRollPosting);
    //         PostDocNo := PostTempAuditRoll.GetNewPostingNo(true);
    //         PostTempAuditRoll.SetPostingNo(PostDocNo);

    //         PostTempAuditRoll.RunPost(AuditRollPosting);
    //         AuditRollPosting.UpdateChangesSilent;

    //         AuditRollPosting.DeleteAll;
    //         AuditRollPosting.TransferFromRevSilentItemLedg(AuditRoll4, AuditRollPosting);
    //         PostTempAuditRoll.SetPostingNo(PostDocNo);

    //         PostTempAuditRoll.RunPostItemLedger(AuditRollPosting);
    //         AuditRollPosting.UpdateChangesSilent;
    //     end;

    // end;

    procedure ModifyAllowed(): Boolean
    begin
        exit((Type = Type::"G/L")
             and ("Sale Type" = "Sale Type"::"Out payment")
             and (not Posted)
             and (Filter[1] = Filter::Payment)
            or
             (Type = Type::Customer)
             and ("Sale Type" = "Sale Type"::Deposit)
             and (not Posted)
             and (Filter[2] = Filter::Deposit)
            );
    end;

    procedure PaymentEntries(): Integer
    var
        NPRetail: Record "NPR Retail Setup";
    begin
        case Filter[2] of
            Filter::Payment:
                begin
                    Filter[2] := Filter::" ";
                    Rec.CopyFilters(TempAuditRollArray[1]);
                    exit(Filter[2]);
                end;
            Filter::" ":
                begin
                    Filter[2] := Filter::Payment;
                    NPRetail.Get;
                    FilterGroup(2);
                    TempAuditRollArray[1].CopyFilters(Rec);
                    Reset;
                    SetRange(Type, Type::"G/L");
                    SetRange("Sale Type", "Sale Type"::"Out payment");
                    SetRange(Posted, false);
                    SetRange("No.", '*');
                    FilterGroup(0);
                    exit(Filter[2]);
                end;
        end;
    end;

    procedure DepositEntries(): Integer
    var
        NPRetail: Record "NPR Retail Setup";
    begin
        case Filter[2] of
            Filter::Deposit:
                begin
                    Filter[2] := Filter::" ";
                    Rec.CopyFilters(TempAuditRollArray[1]);
                    exit(Filter[2]);
                end;
            Filter::" ":
                begin
                    Filter[2] := Filter::Deposit;
                    NPRetail.Get;
                    FilterGroup(2);
                    TempAuditRollArray[1].CopyFilters(Rec);
                    Reset;
                    SetRange(Type, Type::Customer);
                    SetRange("Sale Type", "Sale Type"::Deposit);
                    SetRange(Posted, false);
                    SetRange("No.", '*');
                    FilterGroup(0);
                    CurrPage.Update(true);

                    exit(Filter[2]);
                end;
        end;
    end;

    procedure SetExtFilters(ExtFilters1: Boolean)
    begin
        ExtFilters := ExtFilters1;
    end;

    procedure SetStyleExpression()
    begin
        if Type = Type::"Open/Close" then
            StyleExpr := 'Strong'
        else
            if ("Sales Ticket No." = SelectedTicketNo) then
                StyleExpr := 'StrongAccent'
            else
                StyleExpr := 'None'
    end;
}

