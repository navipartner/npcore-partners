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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            field(Typefilter; Typefilter)
            {

                Caption = 'Type Filter';
                OptionCaption = ' ,G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
                Visible = false;
                ToolTip = 'Specifies the value of the Type Filter field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    if Typefilter > Typefilter::" " then begin
                        Rec.SetRange(Type, Typefilter - 1);
                        boolCancelled := false;
                    end else begin
                        Rec.SetRange(Type);
                        boolCancelled := true;
                        Rec.SetFilter(Type, '<>%1', Rec.Type::Cancelled);
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(CounterNoFilter; CounterNoFilter)
            {

                Caption = 'Counter No.Filter';
                TableRelation = "NPR HC Register"."Register No.";
                Visible = false;
                ToolTip = 'Specifies the value of the Counter No.Filter field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    if CounterNoFilter <> '' then begin
                        Rec.SetCurrentKey("Register No.", "Sales Ticket No.");
                        Rec.SetRange("Register No.", CounterNoFilter)
                    end else begin
                        Rec.SetRange("Register No.");
                        Rec.SetCurrentKey("Sales Ticket No.");
                    end;

                    CurrPage.Update(false);
                end;
            }
            field(SalespersonCodeFilter; SalespersonCodeFilter)
            {

                Caption = 'Sales Person Code Filter';
                TableRelation = "Salesperson/Purchaser".Code;
                Visible = false;
                ToolTip = 'Specifies the value of the Sales Person Code Filter field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    if SalespersonCodeFilter <> '' then
                        Rec.SetRange("Salesperson Code", SalespersonCodeFilter)
                    else
                        Rec.SetRange("Salesperson Code");

                    CurrPage.Update(false);
                end;
            }
            field(CustomerNoFilter; CustomerNoFilter)
            {

                Caption = 'Customer No. Filter';
                Visible = false;
                ToolTip = 'Specifies the value of the Customer No. Filter field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin

                    if CustomerNoFilter <> '' then
                        Rec.SetRange("Customer No.", CustomerNoFilter)
                    else
                        Rec.SetRange("Customer No.");
                    CurrPage.Update(true);
                end;
            }
            field(SaleDateFilter; SaleDateFilter)
            {

                Caption = 'Sales Date Filter';
                Visible = false;
                ToolTip = 'Specifies the value of the Sales Date Filter field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    if SaleDateFilter <> 0D then begin
                        Rec.SetRange("Sale Date", SaleDateFilter);
                    end else begin
                        Rec.SetRange("Sale Date");
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(boolCancelled; boolCancelled)
            {

                Caption = 'Hide Cancelled';
                Visible = false;
                ToolTip = 'Specifies the value of the Hide Cancelled field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin

                    if boolCancelled then begin
                        Rec.SetFilter(Type, '<>%1', Rec.Type::Cancelled);
                    end else begin
                        Rec.SetRange(Type);
                    end;

                    Typefilter := Typefilter::" ";
                    CurrPage.Update(true);
                end;
            }
            field(PostedFilter; PostedFilter)
            {

                Caption = 'Posted Filter';
                OptionCaption = ' ,No,Yes';
                Visible = false;
                ToolTip = 'Specifies the value of the Posted Filter field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    if PostedFilter = PostedFilter::" " then begin
                        Rec.SetRange(Posted);
                    end else begin
                        if PostedFilter = PostedFilter::No then begin
                            Rec.SetRange(Posted, false);
                        end else begin
                            if PostedFilter = PostedFilter::Yes then begin
                                Rec.SetRange(Posted, true);
                            end;
                        end;
                    end;
                    CurrPage.Update(true);
                end;
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    Editable = false;
                    Enabled = FieldRegisterNo;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Type"; Rec."Sale Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Date"; Rec."Sale Date")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Sale Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Closing Time"; Rec."Closing Time")
                {

                    ToolTip = 'Specifies the value of the Closing Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Reference; Rec.Reference)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Reference field';
                    ApplicationArea = NPRRetail;
                }
                field(Posted; Rec.Posted)
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Posted field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Entry Posted"; Rec."Item Entry Posted")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Item Entry Posted field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT %"; Rec."VAT %")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the VAT % field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("<Item Entry Posted1>"; Rec."Item Entry Posted")
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Item Entry Posted field';
                    ApplicationArea = NPRRetail;
                }
                field(Offline; Rec.Offline)
                {

                    Editable = false;
                    StyleExpr = StyleExpr;
                    ToolTip = 'Specifies the value of the Offline field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea = NPRRetail;


                trigger AddInReady()
                begin
                end;

                trigger Pong()
                begin
                    CurrPage.PingPong.Stop();
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

                    ToolTip = 'Executes the Post Payments action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Post action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Post Sales Ticket action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PostReceipt();
                    end;
                }
                action("Posting of Range")
                {
                    Caption = 'Posting of Range';
                    Image = Post;
                    ShortCutKey = 'Ctrl+F11';

                    ToolTip = 'Executes the Posting of Range action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Show Documents action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalesTicketNo: Code[20];
                    begin

                        if Rec."Sales Ticket No." = '' then
                            Error(Text10600004);
                        SalesTicketNo := Rec."Sales Ticket No.";
                        case Rec."Document Type" of
                            Rec."Document Type"::Faktura:
                                begin
                                    SalesInvoiceHeader.FilterGroup := 2;
                                    SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesTicketNo);
                                    SalesInvoiceHeader.FilterGroup := 0;
                                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                                end;
                            Rec."Document Type"::Kreditnota:
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

                    ToolTip = 'Executes the Naviger action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Naviger: Page Navigate;
                    begin
                        Naviger.SetDoc(Rec."Sale Date", Rec."Posted Doc. No.");
                        Naviger.Run();
                    end;
                }
                action(ShowDocumentsCustom)
                {
                    Caption = 'Show Documents Custom';
                    Image = ShowList;

                    ToolTip = 'Executes the Show Documents Custom action';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150674)
                {
                }
                action(Calculate)
                {
                    Caption = 'Calculate';
                    Image = Calculate;

                    ToolTip = 'Executes the Calculate action';
                    ApplicationArea = NPRRetail;
                }
                action(Sum)
                {
                    Caption = 'Sum';
                    Image = Totals;
                    ShortCutKey = 'Ctrl+S';

                    ToolTip = 'Executes the Sum action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        HCAuditRoll: Record "NPR HC Audit Roll";
                        Sum1: Decimal;
                    begin

                        HCAuditRoll.CopyFilters(Rec);

                        if HCAuditRoll.Find('-') then
                            repeat
                                Sum1 += HCAuditRoll."Amount Including VAT";
                            until HCAuditRoll.Next() = 0;

                        Message(Format(Sum1));

                        Rec.CopyFilters(HCAuditRoll);
                    end;
                }
                action("Sales Ticket Statistics")
                {
                    Caption = 'Sales Ticket Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F9';

                    ToolTip = 'Executes the Sales Ticket Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        HCAuditRollGlobal.Reset();
                        HCAuditRollGlobal.FilterGroup := 2;

                        HCAuditRollGlobal.SetRange("Register No.", Rec."Register No.");
                        HCAuditRollGlobal.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
                        HCAuditRollGlobal.SetRange("Sale Type", Rec."Sale Type"::Sale);
                        HCAuditRollGlobal.SetRange("Sale Date", Rec."Sale Date");
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

                    ToolTip = 'Executes the Advanced Sales Statistics action';
                    ApplicationArea = NPRRetail;
                }
                action("Day Report")
                {
                    Caption = 'Day Report';
                    Enabled = false;
                    Image = "Report";
                    Visible = false;

                    ToolTip = 'Executes the Day Report action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        HCAuditRollGlobal.Reset();
                        HCAuditRollGlobal.FilterGroup := 2;
                        HCAuditRollGlobal.SetCurrentKey("Sale Date", "Sale Type");
                        HCAuditRollGlobal.SetRange("Register No.");
                        HCAuditRollGlobal.SetRange("Sales Ticket No.");
                        HCAuditRollGlobal.SetRange("Sale Type", Rec."Sale Type"::Sale);
                        HCAuditRollGlobal.SetRange("Sale Date", Today);
                        HCAuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"NPR HC Audit Roll Stats", HCAuditRollGlobal);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TempHCAuditRollArray[2] := TempHCAuditRollArray[1];
        TempHCAuditRollArray[1] := Rec;

        SelectedTicketNo := Rec."Sales Ticket No.";


        if TempHCAuditRollArray[1]."Sales Ticket No." <> TempHCAuditRollArray[2]."Sales Ticket No." then
            CurrPage.PingPong.Ping(1);
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyleExpression();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Type, '<>%1', Rec.Type::Cancelled);
        if Rec.FindFirst() then;
        SelectedTicketNo := Rec."Sales Ticket No.";
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
        HCAuditRoll4.SetRange("Register No.", Rec."Register No.");
        HCAuditRoll4.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        if Confirm(TX001, true, HCAuditRoll4.GetFilters) then begin
            HCAuditRollPosting.DeleteAll();
            HCAuditRollPosting.TransferFromRevSilent(HCAuditRoll4, HCAuditRollPosting);
            PostDocNo := HCPostTempAuditRoll.getNewPostingNo(true);
            HCPostTempAuditRoll.setPostingNo(PostDocNo);
            HCPostTempAuditRoll.RunPost(HCAuditRollPosting);
            HCAuditRollPosting.UpdateChangesSilent();

            /* ITEM LEDGER ENTRIES */
            HCAuditRollPosting.DeleteAll();
            HCAuditRollPosting.TransferFromRevSilentItemLedg(HCAuditRoll4, HCAuditRollPosting);
            HCPostTempAuditRoll.setPostingNo(PostDocNo);
            HCPostTempAuditRoll.RunPostItemLedger(HCAuditRollPosting);
            HCAuditRollPosting.UpdateChangesSilent();
        end;

    end;

    procedure ModifyAllowed(): Boolean
    begin
        exit((Rec.Type = Rec.Type::"G/L")
             and (Rec."Sale Type" = Rec."Sale Type"::"Out payment")
             and (not Rec.Posted)
             and (Filter[1] = Filter::Payment)
            or
             (Rec.Type = Rec.Type::Customer)
             and (Rec."Sale Type" = Rec."Sale Type"::Deposit)
             and (not Rec.Posted)
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
                    Rec.FilterGroup(2);
                    TempHCAuditRollArray[1].CopyFilters(Rec);
                    Rec.Reset();
                    Rec.SetRange(Type, Rec.Type::"G/L");
                    Rec.SetRange("Sale Type", Rec."Sale Type"::"Out payment");
                    Rec.SetRange(Posted, false);
                    Rec.SetRange("No.", '*');
                    Rec.FilterGroup(0);
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
                    Rec.FilterGroup(2);
                    TempHCAuditRollArray[1].CopyFilters(Rec);
                    Rec.Reset();
                    Rec.SetRange(Type, Rec.Type::Customer);
                    Rec.SetRange("Sale Type", Rec."Sale Type"::Deposit);
                    Rec.SetRange(Posted, false);
                    Rec.SetRange("No.", '*');
                    Rec.FilterGroup(0);
                    CurrPage.Update(true);
                    exit(Filter[2]);
                end;
        end;
    end;

    procedure SetStyleExpression()
    begin
        if Rec.Type = Rec.Type::"Open/Close" then
            StyleExpr := 'Strong'
        else
            if (Rec."Sales Ticket No." = SelectedTicketNo) then
                StyleExpr := 'StrongAccent'
            else
                StyleExpr := 'None'
    end;
}

