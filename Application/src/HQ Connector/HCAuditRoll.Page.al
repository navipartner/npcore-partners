page 6150900 "NPR HC Audit Roll"
{
    Caption = 'HC Audit Roll';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Prints,Posting,Test5,Test6,Test7,Test8';
    SourceTable = "NPR HC Audit Roll";
    SourceTableView = SORTING("Sale Date", "Sales Ticket No.", "Line No.")
                      ORDER(Descending);
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(Typefilter; Typefilter)
            {
                ApplicationArea = All;
                Caption = 'Type Filter';
                Visible = false;
                ToolTip = 'Specifies the value of the Type Filter field';

                trigger OnValidate()
                begin
                    if Typefilter > Typefilter::" " then begin
                        SetRange(Type, Typefilter - 1);
                        boolCancelled := false;
                    end else begin
                        SetRange(Type);
                        boolCancelled := true;
                        SetFilter(Type, '<>%1', Type::Cancelled);
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(CounterNoFilter; CounterNoFilter)
            {
                ApplicationArea = All;
                Caption = 'Counter No.Filter';
                TableRelation = "NPR HC Register"."Register No.";
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
            field(boolCancelled; boolCancelled)
            {
                ApplicationArea = All;
                Caption = 'Hide Cancelled';
                Visible = false;
                ToolTip = 'Specifies the value of the Hide Cancelled field';

                trigger OnValidate()
                begin

                    if boolCancelled then begin
                        SetFilter(Type, '<>%1', Type::Cancelled);
                    end else begin
                        SetRange(Type);
                    end;

                    Typefilter := Typefilter::" ";
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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
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
                    ToolTip = 'Specifies the value of the Closing Time field';
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
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reference field';
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
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
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
            group(Functions)
            {
                Caption = 'Functions';
                action("Post Payments")
                {
                    Caption = 'Post Payments';
                    Enabled = false;
                    Image = Post;
                    ShortCutKey = 'F5';
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post Payments action';

                    trigger OnAction()
                    begin
                        Filter[1] := PaymentEntries();
                    end;
                }
                action(Post)
                {
                    Caption = 'Post';
                    Image = Post;
                    ShortCutKey = 'F11';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post action';

                    trigger OnAction()
                    var
                        BogfRevrulle: Codeunit "NPR HC Post Audit Roll";
                    begin
                        Clear(HCAuditRollGlobal);
                        BogfRevrulle.ShowProgress(true);
                        BogfRevrulle.RunCode(HCAuditRollGlobal);
                    end;
                }
                action("Post Sales Ticket")
                {
                    Caption = 'Post Sales Ticket';
                    Image = Post;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Shift+F11';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post Sales Ticket action';

                    trigger OnAction()
                    begin
                        PostReceipt;
                    end;
                }
                action("Posting of Range")
                {
                    Caption = 'Posting of Range';
                    Image = Post;
                    ShortCutKey = 'Ctrl+F11';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posting of Range action';

                    trigger OnAction()
                    var
                        HCPostAuditRoll: Codeunit "NPR HC Post Audit Roll";
                    begin
                        HCPostAuditRoll.ShowProgress(true);
                        HCPostAuditRoll.RunCode(Rec);
                    end;
                }
                separator(Separator6150668)
                {
                }
                action("Show Documents")
                {
                    Caption = 'Show Documents';
                    Image = "Action";
                    Visible = false;
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
                            "Document Type"::Faktura:
                                begin
                                    SalesInvoiceHeader.FilterGroup := 2;
                                    SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesTicketNo);
                                    SalesInvoiceHeader.FilterGroup := 0;
                                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                                end;
                            "Document Type"::Kreditnota:
                                begin
                                    SalesCrMemoHeader.FilterGroup := 2;
                                    SalesCrMemoHeader.SetRange("Pre-Assigned No.", SalesTicketNo);
                                    SalesCrMemoHeader.FilterGroup := 0;
                                    PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                                end;
                        end;
                    end;
                }
                action("&Navigate")
                {
                    Caption = 'Naviger';
                    Image = Navigate;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Naviger action';

                    trigger OnAction()
                    var
                        Naviger: Page Navigate;
                    begin
                        Naviger.SetDoc("Sale Date", "Posted Doc. No.");
                        Naviger.Run;
                    end;
                }
                action(ShowDocumentsCustom)
                {
                    Caption = 'Show Documents Custom';
                    Image = ShowList;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Documents Custom action';
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
                        HCAuditRoll: Record "NPR HC Audit Roll";
                        Sum1: Decimal;
                    begin

                        HCAuditRoll.CopyFilters(Rec);

                        if HCAuditRoll.Find('-') then
                            repeat
                                Sum1 += HCAuditRoll."Amount Including VAT";
                            until HCAuditRoll.Next = 0;

                        Message(Format(Sum1));

                        Rec.CopyFilters(HCAuditRoll);
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
                        HCAuditRollGlobal.Reset;
                        HCAuditRollGlobal.FilterGroup := 2;

                        HCAuditRollGlobal.SetRange("Register No.", "Register No.");
                        HCAuditRollGlobal.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        HCAuditRollGlobal.SetRange("Sale Type", "Sale Type"::Sale);
                        HCAuditRollGlobal.SetRange("Sale Date", "Sale Date");
                        HCAuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"NPR HC Audit Roll Stats", HCAuditRollGlobal);
                    end;
                }
                action("Advanced Sales Statistics")
                {
                    Caption = 'Advanced Sales Statistics';
                    Enabled = false;
                    Image = Statistics;
                    RunObject = Page "NPR Advanced Sales Stats";
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Advanced Sales Statistics action';
                }
                action("Day Report")
                {
                    Caption = 'Day Report';
                    Enabled = false;
                    Image = "Report";
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Day Report action';

                    trigger OnAction()
                    begin
                        HCAuditRollGlobal.Reset;
                        HCAuditRollGlobal.FilterGroup := 2;
                        HCAuditRollGlobal.SetCurrentKey("Sale Date", "Sale Type");
                        HCAuditRollGlobal.SetRange("Register No.");
                        HCAuditRollGlobal.SetRange("Sales Ticket No.");
                        HCAuditRollGlobal.SetRange("Sale Type", "Sale Type"::Sale);
                        HCAuditRollGlobal.SetRange("Sale Date", Today);
                        HCAuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"NPR HC Audit Roll Stats", HCAuditRollGlobal);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        AuditRoll2: Record "NPR HC Audit Roll";
    begin
        TempHCAuditRollArray[2] := TempHCAuditRollArray[1];
        TempHCAuditRollArray[1] := Rec;

        SelectedTicketNo := Rec."Sales Ticket No.";

        DoUpdate := true;

        if TempHCAuditRollArray[1]."Sales Ticket No." <> TempHCAuditRollArray[2]."Sales Ticket No." then
            CurrPage.PingPong.Ping(1);
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyleExpression;
    end;

    trigger OnOpenPage()
    begin
        SetFilter(Type, '<>%1', Type::Cancelled);
        if FindFirst then;
        SelectedTicketNo := "Sales Ticket No.";
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
        HCAuditRollGlobal: Record "NPR HC Audit Roll";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempHCAuditRollArray: array[2] of Record "NPR HC Audit Roll" temporary;
        CounterNoFilter: Code[10];
        SalespersonCodeFilter: Code[10];
        CustomerNoFilter: Code[20];
        "Filter": array[2] of Option " ",Payment,Deposit;
        Typefilter: Option " ","G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        PostedFilter: Option " ",No,Yes;
        boolCancelled: Boolean;
        Text10600004: Label 'Wrong sales ticket line, document no. is missing!';
        [InDataSet]
        FieldRegisterNo: Boolean;
        SaleDateFilter: Date;
        SelectedTicketNo: Text;
        DoUpdate: Boolean;
        StyleExpr: Text;

    procedure PostReceipt()
    var
        HCAuditRoll4: Record "NPR HC Audit Roll";
        HCPostTempAuditRoll: Codeunit "NPR HC Post Temp Audit Roll";
        HCAuditRollPosting: Record "NPR HC Audit Roll Posting";
        TX001: Label 'Posted ?';
        PostDocNo: Code[20];
    begin
        HCAuditRoll4 := Rec;
        HCAuditRoll4.SetCurrentKey("Register No.", "Sales Ticket No.");
        HCAuditRoll4.SetRange("Register No.", "Register No.");
        HCAuditRoll4.SetRange("Sales Ticket No.", "Sales Ticket No.");
        if Confirm(TX001, true, HCAuditRoll4.GetFilters) then begin
            HCAuditRollPosting.DeleteAll;
            HCAuditRollPosting.TransferFromRevSilent(HCAuditRoll4, HCAuditRollPosting);
            PostDocNo := HCPostTempAuditRoll.getNewPostingNo(true);
            HCPostTempAuditRoll.setPostingNo(PostDocNo);
            HCPostTempAuditRoll.RunPost(HCAuditRollPosting);
            HCAuditRollPosting.UpdateChangesSilent;

            /* ITEM LEDGER ENTRIES */
            HCAuditRollPosting.DeleteAll;
            HCAuditRollPosting.TransferFromRevSilentItemLedg(HCAuditRoll4, HCAuditRollPosting);
            HCPostTempAuditRoll.setPostingNo(PostDocNo);
            HCPostTempAuditRoll.RunPostItemLedger(HCAuditRollPosting);
            HCAuditRollPosting.UpdateChangesSilent;
        end;

    end;

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
    begin
        case Filter[2] of
            Filter::Payment:
                begin
                    Filter[2] := Filter::" ";
                    Rec.CopyFilters(TempHCAuditRollArray[1]);
                    exit(Filter[2]);
                end;
            Filter::" ":
                begin
                    Filter[2] := Filter::Payment;
                    FilterGroup(2);
                    TempHCAuditRollArray[1].CopyFilters(Rec);
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
    begin
        case Filter[2] of
            Filter::Deposit:
                begin
                    Filter[2] := Filter::" ";
                    Rec.CopyFilters(TempHCAuditRollArray[1]);
                    exit(Filter[2]);
                end;
            Filter::" ":
                begin
                    Filter[2] := Filter::Deposit;
                    FilterGroup(2);
                    TempHCAuditRollArray[1].CopyFilters(Rec);
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

