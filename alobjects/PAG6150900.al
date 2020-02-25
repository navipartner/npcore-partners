page 6150900 "HC Audit Roll"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object based on Page 6014432
    // NPR5.38/JDH /20180119 CASE 302570 Changed option String "filter" to english
    // NPR5.39/TJ  /20180207 CASE 302634 Deleted unused variables and translated variables/functions to english
    // NPR5.48/MHA /20182111 CASE 326055 Added field 5022 "Reference"
    // NPR5.48/TJ  /20181115 CASE 331992 Added dimension fields
    // NPR5.48/TJ  /20190129 CASE 340446 Changes for version 2018 - removed actions POS Info and Show Period
    // NPR5.51/TJ  /20190123 CASE 343685 Fixed double posting doc. no. generation for same ticket
    // NPR5.53/TJ  /20191114 CASE 377556 Actions "Show Documents" and Navigate are now hidden
    //                                   New action "Show Documents Custom"

    Caption = 'HC Audit Roll';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Prints,Posting,Test5,Test6,Test7,Test8';
    SourceTable = "HC Audit Roll";
    SourceTableView = SORTING("Sale Date","Sales Ticket No.","Line No.")
                      ORDER(Descending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            field(Typefilter;Typefilter)
            {
                Caption = 'Type Filter';
                Visible = false;

                trigger OnValidate()
                begin
                    // SalesColor := TRUE;
                    if Typefilter > Typefilter::" " then begin
                      SetRange(Type,Typefilter - 1);
                      boolCancelled := false;
                    end else begin
                      SetRange(Type);
                      boolCancelled := true;
                      SetFilter(Type, '<>%1', Type::Cancelled);
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(CounterNoFilter;CounterNoFilter)
            {
                Caption = 'Counter No.Filter';
                TableRelation = "HC Register"."Register No.";
                Visible = false;

                trigger OnValidate()
                begin
                    if CounterNoFilter <> '' then begin
                      SetCurrentKey("Register No.","Sales Ticket No.");
                      SetRange("Register No.",CounterNoFilter)
                    end else begin
                      SetRange("Register No.");
                      SetCurrentKey("Sales Ticket No.");
                    end;

                    CurrPage.Update(false);
                end;
            }
            field(SalespersonCodeFilter;SalespersonCodeFilter)
            {
                Caption = 'Sales Person Code Filter';
                TableRelation = "Salesperson/Purchaser".Code;
                Visible = false;

                trigger OnValidate()
                begin
                    if SalespersonCodeFilter <> '' then
                      SetRange("Salesperson Code",SalespersonCodeFilter)
                    else
                      SetRange("Salesperson Code");

                    CurrPage.Update(false);
                end;
            }
            field(CustomerNoFilter;CustomerNoFilter)
            {
                Caption = 'Customer No. Filter';
                Visible = false;

                trigger OnValidate()
                begin

                    if CustomerNoFilter <> '' then
                      SetRange( "Customer No.", CustomerNoFilter )
                    else
                      SetRange( "Customer No." );
                     CurrPage.Update(true);
                end;
            }
            field(SaleDateFilter;SaleDateFilter)
            {
                Caption = 'Sales Date Filter';
                Visible = false;

                trigger OnValidate()
                begin
                    if SaleDateFilter <> 0D then begin
                      SetRange("Sale Date",SaleDateFilter);
                    end else begin
                      SetRange("Sale Date");
                    end;

                    CurrPage.Update(true);
                end;
            }
            field(boolCancelled;boolCancelled)
            {
                Caption = 'Hide Cancelled';
                Visible = false;

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
            field(PostedFilter;PostedFilter)
            {
                Caption = 'Posted Filter';
                OptionCaption = ' ,No,Yes';
                Visible = false;

                trigger OnValidate()
                begin
                     /*
                    CASE Bogf�rtfilter OF
                      Bogf�rtfilter::" " :
                        SETRANGE(Posted);
                      Bogf�rtfilter::No :
                        SETRANGE(Posted,FALSE);
                      Bogf�rtfilter::Yes :
                        SETRANGE(Posted,TRUE);
                    END;
                    */
                    if PostedFilter=PostedFilter::" " then begin
                      SetRange(Posted);
                      end else begin
                        if PostedFilter=PostedFilter::No then begin
                        SetRange(Posted,false);
                        end else begin
                          if PostedFilter=PostedFilter::Yes then begin
                          SetRange(Posted,true);
                          end;
                        end;
                    end;
                    
                    CurrPage.Update(true);

                end;
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                    StyleExpr = StyleExpr;
                }
                field("Register No.";"Register No.")
                {
                    Editable = false;
                    Enabled = FieldRegisterNo;
                    StyleExpr = StyleExpr;
                }
                field("Sale Type";"Sale Type")
                {
                    Visible = false;
                }
                field(Type;Type)
                {
                    Visible = false;
                }
                field("No.";"No.")
                {
                }
                field("Sale Date";"Sale Date")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Starting Time";"Starting Time")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Closing Time";"Closing Time")
                {
                }
                field(Amount;Amount)
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                    Visible = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Description 2";"Description 2")
                {
                }
                field("Customer No.";"Customer No.")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field(Reference;Reference)
                {
                    Visible = false;
                }
                field(Posted;Posted)
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Item Entry Posted";"Item Entry Posted")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field(Quantity;Quantity)
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Line Discount %";"Line Discount %")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Line Discount Amount";"Line Discount Amount")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("VAT %";"VAT %")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Salesperson Code";"Salesperson Code")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("<Item Entry Posted1>";"Item Entry Posted")
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field(Offline;Offline)
                {
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                }
            }
            usercontrol(PingPong;"Microsoft.Dynamics.Nav.Client.PingPong")
            {

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

                    trigger OnAction()
                    var
                        BogfRevrulle: Codeunit "HC Post audit roll";
                    begin

                        Clear(HCAuditRollGlobal);
                        BogfRevrulle.ShowProgress( true );
                        BogfRevrulle.RunCode( HCAuditRollGlobal );
                    end;
                }
                action("Post Sales Ticket")
                {
                    Caption = 'Post Sales Ticket';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Shift+F11';

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

                    trigger OnAction()
                    var
                        HCPostAuditRoll: Codeunit "HC Post audit roll";
                    begin
                        HCPostAuditRoll.ShowProgress( true );
                        HCPostAuditRoll.RunCode( Rec );
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
                              SalesInvoiceHeader.SetRange("Pre-Assigned No.",SalesTicketNo);
                              SalesInvoiceHeader.FilterGroup := 0;
                              //FORM.RUNMODAL(FORM::"Posted Sales Invoice",Salgsfakturahoved);
                              PAGE.RunModal(PAGE::"Posted Sales Invoice",SalesInvoiceHeader);
                            end;
                        //  "Document Type"::Ordre:
                        //    BEGIN
                        //      SalgsLevHoved.FILTERGROUP := 2;
                        //      SalgsLevHoved.SETRANGE("Sales Ticket No.",SalesTicketNo);
                        //      SalgsLevHoved.FILTERGROUP := 0;
                        //      //FORM.RUNMODAL(FORM::"Posted Sales Shipment", SalgsLevHoved);
                        //      PAGE.RUNMODAL(PAGE::"Posted Sales Shipment", SalgsLevHoved);
                        //    END;
                          "Document Type"::Kreditnota:
                            begin
                              SalesCrMemoHeader.FilterGroup := 2;
                              SalesCrMemoHeader.SetRange("Pre-Assigned No.",SalesTicketNo);
                              SalesCrMemoHeader.FilterGroup := 0;
                              //FORM.RUNMODAL(FORM::"Posted Sales Credit Memo", SalgsKreditnotaHoved);
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

                    trigger OnAction()
                    var
                        Naviger: Page Navigate;
                    begin
                        Naviger.SetDoc("Sale Date","Posted Doc. No.");
                        Naviger.Run;
                    end;
                }
                action(ShowDocumentsCustom)
                {
                    Caption = 'Show Documents Custom';
                    Image = ShowList;
                }
                separator(Separator6150674)
                {
                }
                action(Calculate)
                {
                    Caption = 'Calculate';
                    Image = Calculate;
                }
                action("Sum")
                {
                    Caption = 'Sum';
                    Image = Totals;
                    ShortCutKey = 'Ctrl+S';

                    trigger OnAction()
                    var
                        crev: Record "HC Audit Roll";
                        sum1: Decimal;
                    begin

                        crev.CopyFilters(Rec);

                        if crev.Find('-') then repeat
                          sum1 += crev."Amount Including VAT";
                        until crev.Next = 0;

                        Message(Format(sum1));

                        Rec.CopyFilters(crev);
                    end;
                }
                action("Sales Ticket Statistics")
                {
                    Caption = 'Sales Ticket Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin

                        HCAuditRollGlobal.Reset;
                        HCAuditRollGlobal.FilterGroup := 2;

                        HCAuditRollGlobal.SetRange("Register No.","Register No.");
                        HCAuditRollGlobal.SetRange("Sales Ticket No.","Sales Ticket No.");
                        HCAuditRollGlobal.SetRange("Sale Type","Sale Type"::Sale);
                        HCAuditRollGlobal.SetRange("Sale Date","Sale Date");
                        HCAuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"HC Audit Roll Statistics",HCAuditRollGlobal);
                    end;
                }
                action("Advanced Sales Statistics")
                {
                    Caption = 'Advanced Sales Statistics';
                    Enabled = false;
                    Image = Statistics;
                    RunObject = Page "Advanced Sales Statistics";
                    Visible = false;
                }
                action("Day Report")
                {
                    Caption = 'Day Report';
                    Enabled = false;
                    Image = "Report";
                    Visible = false;

                    trigger OnAction()
                    begin

                        HCAuditRollGlobal.Reset;
                        HCAuditRollGlobal.FilterGroup := 2;
                        HCAuditRollGlobal.SetCurrentKey("Sale Date","Sale Type");
                        HCAuditRollGlobal.SetRange("Register No.");
                        HCAuditRollGlobal.SetRange("Sales Ticket No.");
                        HCAuditRollGlobal.SetRange("Sale Type", "Sale Type"::Sale);
                        HCAuditRollGlobal.SetRange("Sale Date", Today);
                        HCAuditRollGlobal.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"HC Audit Roll Statistics",HCAuditRollGlobal);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        AuditRoll2: Record "HC Audit Roll";
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
        SetFilter(Type,'<>%1',Type::Cancelled);
        if FindFirst then;
        SelectedTicketNo := "Sales Ticket No.";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if Filter[2] = Filter::Payment then begin
           Filter[1] := PaymentEntries();
           CurrPage.Update(false);
           //CurrForm.UPDATE(FALSE);
           exit(false);
        end;
        if Filter[2] = Filter::Deposit then begin
           Filter[1] := DepositEntries();
           //CurrForm.UPDATE(FALSE);
           CurrPage.Update(true);
           exit(false);
        end;
    end;

    var
        HCAuditRollGlobal: Record "HC Audit Roll";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempHCAuditRollArray: array [2] of Record "HC Audit Roll" temporary;
        CounterNoFilter: Code[10];
        SalespersonCodeFilter: Code[10];
        CustomerNoFilter: Code[20];
        "Filter": array [2] of Option " ",Payment,Deposit;
        Typefilter: Option " ","G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        PostedFilter: Option " ",No,Yes;
        FindLast: Option " ",No,Yes;
        extFilters: Boolean;
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
        HCAuditRoll4: Record "HC Audit Roll";
        HCPostTempAuditRoll: Codeunit "HC Post Temp Audit Roll";
        HCAuditRollPosting: Record "HC Audit Roll Posting";
        TX001: Label 'Posted ?';
        PostDocNo: Code[20];
    begin
        //Bogf�rBon
        
        HCAuditRoll4 := Rec;
        HCAuditRoll4.SetCurrentKey( "Register No.", "Sales Ticket No." );
        HCAuditRoll4.SetRange( "Register No.", "Register No." );
        HCAuditRoll4.SetRange( "Sales Ticket No.", "Sales Ticket No." );
        if Confirm(TX001,true,HCAuditRoll4.GetFilters) then begin
          /* FINANCES */
          HCAuditRollPosting.DeleteAll;
          HCAuditRollPosting.TransferFromRevSilent( HCAuditRoll4, HCAuditRollPosting );
          //-NPR5.51 [343685]
          //HCPostTempAuditRoll.setPostingNo(HCPostTempAuditRoll.getNewPostingNo(TRUE));
          PostDocNo := HCPostTempAuditRoll.getNewPostingNo(true);
          HCPostTempAuditRoll.setPostingNo(PostDocNo);
          //+NPR5.51 [343685]
          HCPostTempAuditRoll.RunPost( HCAuditRollPosting );
          HCAuditRollPosting.UpdateChangesSilent;
        
          /* ITEM LEDGER ENTRIES */
          HCAuditRollPosting.DeleteAll;
          HCAuditRollPosting.TransferFromRevSilentItemLedg( HCAuditRoll4, HCAuditRollPosting );
          //-NPR5.51 [343685]
          //HCPostTempAuditRoll.setPostingNo(HCPostTempAuditRoll.getNewPostingNo(TRUE));
          HCPostTempAuditRoll.setPostingNo(PostDocNo);
          //+NPR5.51 [343685]
          HCPostTempAuditRoll.RunPostItemLedger( HCAuditRollPosting );
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
        //CurrForm.Funktion.VISIBLE(Filter[2] = Filter::Payment);
        //CurrForm.Udskriv.VISIBLE(Filter[2] = Filter::Payment);
        //CurrForm.Dankort.VISIBLE(Filter[2] = Filter::Payment);
        //CurrForm."Funktion - Udbetaling".VISIBLE(Filter[2] = Filter::" ");

        case Filter[2] of
          Filter::Payment : begin
            Filter[2] := Filter::" ";
            Rec.CopyFilters(TempHCAuditRollArray[1]);
            //CurrForm."Register No.".ACTIVATE;
            //CurrForm.UPDATE(TRUE);
            exit(Filter[2]);
          end;
          Filter::" " : begin
            Filter[2] := Filter::Payment;
            FilterGroup(2);
            TempHCAuditRollArray[1].CopyFilters(Rec);
            Reset;
            SetRange(Type,Type::"G/L");
            SetRange("Sale Type","Sale Type"::"Out payment");
            SetRange(Posted,false);
            SetRange("No.",'*');
            FilterGroup(0);
            //CurrForm.UPDATE(TRUE);
            //CurrForm."No.".ACTIVATE;
            exit(Filter[2]);
          end;
        end;
    end;

    procedure DepositEntries(): Integer
    begin
        //CurrForm.Funktion.VISIBLE(Filter[2] = Filter::Deposit);
        //CurrForm.Udskriv.VISIBLE(Filter[2] = Filter::Deposit);
        //CurrForm.Dankort.VISIBLE(Filter[2] = Filter::Deposit);
        //CurrForm."Funktion - Udbetaling".VISIBLE(Filter[2] = Filter::" ");

        case Filter[2] of
          Filter::Deposit : begin
            Filter[2] := Filter::" ";
            Rec.CopyFilters(TempHCAuditRollArray[1]);
            //CurrForm."Register No.".ACTIVATE;
            //CurrForm.UPDATE(TRUE);
            exit(Filter[2]);
          end;
          Filter::" " : begin
            Filter[2] := Filter::Deposit;
            FilterGroup(2);
            TempHCAuditRollArray[1].CopyFilters(Rec);
            Reset;
            SetRange(Type,Type::Customer);
            SetRange("Sale Type","Sale Type"::Deposit);
            SetRange(Posted,false);
            SetRange("No.",'*');
            FilterGroup(0);
            //CurrForm.UPDATE(TRUE);
            CurrPage.Update(true);
            //CurrForm."No.".ACTIVATE;
            exit(Filter[2]);
          end;
        end;
    end;

    procedure PrintAuditRoll()
    begin
        //PrintAuditRoll
    end;

    procedure setExtFilters(extFilters1: Boolean)
    begin
        //usingTS(isTouch1 : Boolean)
        extFilters := extFilters1;
    end;

    procedure SetStyleExpression()
    begin
        if Type = Type::"Open/Close" then
          StyleExpr := 'Strong'
        else if ("Sales Ticket No." = SelectedTicketNo) then
          StyleExpr := 'StrongAccent'
        else
          StyleExpr := 'None'
    end;
}

