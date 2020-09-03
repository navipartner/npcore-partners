page 6014432 "NPR Audit Roll"
{
    // //001
    // Henter den afslutningsbon der indholder afslutningsoplysningerne, dvs. den der henvises til i
    // felterne "Afsluttet på bonnr" og "På kassenummer"
    // 
    // NPR4.000.005, NPK, 07-04-09, MH - Tilf¢jet funktionen, SendAsPDF(), der sender den pågældene kvittering som vedhæftet via email.
    //                                   Der benyttes "Mail And Document Handler"-modulet.
    // NPR4.000.006, NPK, 23-04-09, MH - Tilrettet variabelNavne og sortering i SendAsPDF().
    // NPR4.000.007, NPK, 23-04-09, MH - Fjernet funktionalitet i forhold til performance i SendAsPDF().
    // NPR4.000.008, NPK, 11-06-09, MH - Tilf¢jet feltet "Lock Code" (sag 65422).
    // NPR4.000.009, NPK, 06-07-09, MH - SendAsPDF(), flyttet til tabel, audit roll.
    // PN1.04/MH/20140819  NAV-AddOn: PDF2NAV
    //   - Added Menu Items on Function-button: "E-mail Log" and "Send as PDF".
    // 
    // NPR4.14/MMV/20150720 CASE 218865 Added code for printing A4 receipts. (was commented out before)
    //                                  Changed caption on button for printing A4 receipts.
    // NPR4.14/MMV/20150807 CASE 220160 Moved code for printing register receipts to CU 6014428 since its used elsewhere as well.
    // NPR4.14/BHR/20150811 CASE 220159 Hide action Tax Free.(to remove action). property visible set to false
    // NPR4.14/TS/20150818 CASE 220780 Change captions Posting to Post.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR4.18/MMV/20160202 CASE 224257 New tax free integration
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.22/VBA/20160411 CASE 237960 Added ENU captions where missing (for actions)
    // NPR5.22/MMV/20160425 CASE 232067 Moved filter on rec to removable by user instead of hardcoded (As in classic)
    // NPR5.22/MMV/20160426 CASE 239998 Promoted action "Register Report" & "Tax Free"
    // NPR5.23/JDH /20160523 CASE 242105 Changed key to "Sale Date,Sales Ticket No.,Line No."
    // NPR5.25/TS/20160701 CASE 245839 Added Action to MobilPay Transaction List
    // NPR5.26/OSFI/20160811 CASE 246167 Added POS Info action to show POS Info lines linked to the sale
    // NPR5.28/TS/20161110  CASE 258009 Added Desciption2
    // NPR5.28/BR /20161124 CASE  259295 Added Action "Pepper Transaction Requests"
    // NPR5.30/MMV /20170127 CASE 261964 Refactored tax free
    // NPR5.32/JLK /20170502 CASE 274353 Added field "Gen. Bus. Posting Group"
    // NPR5.34/TSA /20170704 CASE 283125 Removed EFT receipt printing from sales receipt printing and promoted the EFT Receipt button
    // NPR5.35/TJ  /20170809 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entry
    // NPR5.38/TS  /20171120 CASE 290609 Promoted Action Debit Print
    // NPR5.38/BR  /20171207 CASE 299035 Changed Key to include Sale Type field
    // NPR5.38/TS  /20171213 CASE 295566 SendAsPDF has been promoted.
    // NPR5.38/BR  /20180108 CASE 301600 Show Warning if Advanced posting is on
    // NPR5.38/MHA /20180109 CASE 295549 Action "MobilePay Transaction List" removed
    // NPR5.38/TS  /20180110 CASE 301806 Removed Action Register Journal
    // NPR5.39/MHA /20180214 CASE 305139 Added field 405 "Discount Authorised by"
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module
    // NPR5.42/BHR /20180518 CASE 314987 Added functionality to Change dimension
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.44/MHA /20180705 CASE 321231 Added "Reason Code"
    // NPR5.45/TJ  /20180719 CASE 318531 New action Advanced Filter
    // NPR5.46/MMV /20181001 CASE 290734 EFT framework refactoring
    // NPR5.48/TJ  /20181129 CASE 318531 Give ability to preset different Type filter
    // NPR5.48/TS  /20181213 CASE 339569 Added field Gift Voucher REf
    // NPR5.48/TJ  /20190122 CASE 335967 Added field "Unit of Measure Code"
    // NPR5.51/TJ  /20190123 CASE 343685 Fixed double posting doc. no. generation for same ticket
    // NPR5.51/YAHA/20190718 CASE 365357 Page action moved from tab ACTION to tab HOME

    Caption = 'Audit Roll';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Prints,Posting,Test5,Test6,Test7,Test8';
    SourceTable = "NPR Audit Roll";
    SourceTableView = SORTING("Sale Date", "Sales Ticket No.", "Sale Type", "Line No.")
                      ORDER(Descending);
    UsageCategory = Lists;

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
            }
            field(ClicktoSeePOSEntries; ClicktoSeePOSEntries)
            {
                ApplicationArea = All;
                Caption = 'Click to See POS Entriies';
                LookupPageID = "NPR POS Entries";
                ShowCaption = false;
                Visible = AdvancedPosting;

                trigger OnAssistEdit()
                begin
                    //-NPR5.38 [301600]
                    PAGE.Run(PAGE::"NPR POS Entry List");
                    CurrPage.Close;
                    //+NPR5.38 [301600]
                end;
            }
            field(TypeFilter; TypeFilter)
            {
                ApplicationArea = All;
                Caption = 'Type Filter';
                Visible = false;

                trigger OnValidate()
                begin
                    // SalesColor := TRUE;
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

                trigger OnValidate()
                begin
                    /*
                   CASE Bogf¢rtfilter OF
                     Bogf¢rtfilter::" " :
                       SETRANGE(Posted);
                     Bogf¢rtfilter::No :
                       SETRANGE(Posted,FALSE);
                     Bogf¢rtfilter::Yes :
                       SETRANGE(Posted,TRUE);
                   END;
                   */
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
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = FieldRegisterNo;
                    StyleExpr = StyleExpr;
                }
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Gift voucher ref."; "Gift voucher ref.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Item Entry Posted"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("<Item Entry Posted1>"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field(Offline; Offline)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleExpr;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
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
            group(Print)
            {
                Caption = '&Print';
                action("Sales Ticket")
                {
                    Caption = 'Receipt';
                    Image = Sales;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = false;

                    trigger OnAction()
                    var
                        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
                    begin
                        //-NPR5.34 [283125]
                        // {* Print Terminal receipt *}
                        // Revisionsrulle.SETRANGE( "Cash Terminal Approved", TRUE );
                        // Dankorttransaktion.RESET;
                        // Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
                        // Dankorttransaktion.SETRANGE("Register No.","Register No.");
                        // Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                        // Dankorttransaktion.SETRANGE(Type,0);
                        // //Dankorttransaktion.SETRANGE(Dato,Ekspeditionsdato);
                        // IF Dankorttransaktion.FIND('-') THEN
                        //  Dankorttransaktion.PrintTerminalReceipt(FALSE);
                        //
                        // Revisionsrulle.SETRANGE( "Cash Terminal Approved");
                        //+NPR5.34 [283125]

                        /** Print receipt **/
                        if (Type = Type::"Open/Close") or (Type = Type::Cancelled) then
                            Error(Text10600005);
                        AuditRollGlobal.Reset;
                        //CurrPage.SETSELECTIONFILTER(Revisionsrulle);
                        AuditRollGlobal := Rec;
                        AuditRollGlobal.SetRecFilter;
                        AuditRollGlobal.MarkedOnly(false);
                        AuditRollGlobal.SetRange("Sale Type");
                        AuditRollGlobal.SetRange(Type);
                        AuditRollGlobal.SetRange("Line No.");
                        AuditRollGlobal.SetRange("No.");
                        //Revisionsrulle.IncrementCount; //MIJ. Done in std. codeunit code
                        //Revisionsrulle.UdskrivBon( FALSE );
                        StdCodeunitCode.PrintReceipt(AuditRollGlobal, true);

                    end;
                }
                action("A4 Sales Ticket")
                {
                    Caption = 'A4 Sales Ticket';
                    Image = Sales;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        AuditRoll: Record "NPR Audit Roll";
                    begin
                        //-NPR4.14
                        /*
                        IF (Type=Type::"Open/Close") OR (Type=Type::Cancelled) THEN ERROR(Text10600005);
                        CurrPage.SETSELECTIONFILTER(Revisionsrulle);
                        Revisionsrulle.MARKEDONLY( FALSE );
                        Revisionsrulle.SETRANGE( "Sale Type" );
                        Revisionsrulle.SETRANGE( Type );
                        Revisionsrulle.SETRANGE( "Line No." );
                        Revisionsrulle.SETRANGE( "No." );
                        Revisionsrulle.IncrementCount;
                        Revisionsrulle.UdskrivBonA4(FALSE);
                        */

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
                        //+NPR4.14

                    end;
                }
                action(Invoice)
                {
                    Caption = 'Invoice';
                    Image = Invoice;

                    trigger OnAction()
                    var
                        AuditRoll3: Record "NPR Audit Roll";
                    begin
                        AuditRoll3.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        AuditRoll3.Find('-');
                        AuditRoll3.TestField("Sale Type", "Sale Type"::"Debit Sale");
                        AuditRoll3.TestField("Allocated No.");
                        //TESTFIELD("Document No.");
                        //Salgsfakturahoved.GET("Document No.");
                        SalesInvoiceHeader.FilterGroup := 2;
                        SalesInvoiceHeader.SetRange("Pre-Assigned No.", "Sales Ticket No.");
                        SalesInvoiceHeader.Find('-');
                        SalesInvoiceHeader.FilterGroup := 0;
                        //Salgsfakturahoved.SETRANGE("No.","Document No.");

                        SalesInvoiceHeader.PrintRecords(true);
                    end;
                }
                action("Debit Receipt")
                {
                    Caption = 'Debit Receipt';
                    Image = Receipt;
                    Promoted = true;
                    PromotedCategory = "Report";

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

                    trigger OnAction()
                    begin
                        RetailContractMgt.PrintInsurance("Register No.", "Sales Ticket No.", true);
                    end;
                }
                action("Retail Order")
                {
                    Caption = 'Retail order';
                    Image = "Action";

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
                    PromotedCategory = "Report";
                    PromotedIsBig = false;

                    trigger OnAction()
                    var
                        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
                    begin
                        //-NPR4.14
                        //IF Type <> Type::"Open/Close" THEN
                        //  ERROR(t001);

                        //PrintType := STRMENU(Text10600008);

                        //NPconfig.GET();
                        //CLEAR(Revisionsrulle);

                        //IF (NPconfig."Balancing Posting Type" = NPconfig."Balancing Posting Type"::"PER KASSE") OR (Revisionsrulle."Balanced on Sales Ticket No."='')THEN BEGIN
                        //  Revisionsrulle.SETRANGE("Register No.","Register No.");
                        //  Revisionsrulle.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                        //END;

                        //IF (NPconfig."Balancing Posting Type" = NPconfig."Balancing Posting Type"::SAMLET) AND (Revisionsrulle."Balanced on Sales Ticket No."<>'') THEN BEGIN
                        //  Revisionsrulle.SETRANGE("Register No.","On Register No.");
                        //  Revisionsrulle.SETRANGE("Sales Ticket No.","Balanced on Sales Ticket No.");
                        //  Revisionsrulle.SETRANGE("Sale Type","Sale Type"::Bemærkning);
                        //  Revisionsrulle.SETRANGE("Line No.","Line No.");
                        //  Revisionsrulle.SETRANGE("No.","On Register No.");
                        //  Revisionsrulle.SETRANGE("Sale Date","Sale Date");
                        //END;

                        //IF (Revisionsrulle.COUNT <> 0) THEN BEGIN
                        //  CASE PrintType OF
                        //    PrintType::"To Printer" :
                        //      BEGIN
                        //        rapportvalg.SETRANGE("Report Type",rapportvalg."Report Type"::Kasseafslut);
                        //        rapportvalg.SETFILTER("Report ID",'<>0');
                        //        rapportvalg.SETRANGE( "Register No.", "Register No." );
                        //        IF NOT rapportvalg.FIND('-') THEN
                        //          rapportvalg.SETRANGE( "Register No.", '' );
                        //        IF rapportvalg.FIND('-') THEN
                        //        REPEAT
                        //          REPORT.RUNMODAL(rapportvalg."Report ID",TRUE,FALSE,Revisionsrulle);
                        //        UNTIL rapportvalg.NEXT = 0;

                        //        // Test For Codeunit
                        //        rapportvalg.SETRANGE("Report ID");
                        //        rapportvalg.SETFILTER("Codeunit ID",'<>0');
                        //        IF NOT rapportvalg.FIND('-') THEN
                        //          rapportvalg.SETRANGE("Register No.", '');
                        //
                        //        IF rapportvalg.FIND('-') THEN REPEAT
                        //          Table := Revisionsrulle;
                        //          LinePrintBuffer.ProcessPrint(rapportvalg."Codeunit ID", Table);
                        //        UNTIL rapportvalg.NEXT = 0;
                        //      END;
                        //    PrintType::"To Screen" :
                        //      BEGIN
                        //        REPORT.RUNMODAL(REPORT::"Balancing Ticket IV",TRUE,FALSE,Revisionsrulle);
                        //      END;
                        //  END;
                        //END;

                        StdCodeunitCode.PrintRegisterReceipt(Rec);
                        //+NPR4.14
                    end;
                }
                action("Tax Free")
                {
                    Caption = 'Tax Free';
                    Image = TaxDetail;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = false;
                    Visible = true;

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
                        //-NPR5.40 [293106]
                        // IF TaxFreeMgt.TryGetVoucherFromReceiptNo(AuditRollGlobal."Sales Ticket No.",TaxFreeVoucher) THEN
                        //  TaxFreeMgt.VoucherPrint(TaxFreeVoucher)
                        // ELSE IF CONFIRM(TaxFree_Create,FALSE) THEN
                        //+NPR5.40 [293106]
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
                }
                action("EFT Receipt")
                {
                    Caption = 'EFT Receipt';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        //-NPR5.46 [290734]
                        // CreditCardTransaction.RESET;
                        // CreditCardTransaction.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
                        // CreditCardTransaction.FILTERGROUP := 2;
                        // CreditCardTransaction.SETRANGE("Register No.","Register No.");
                        // CreditCardTransaction.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                        // CreditCardTransaction.SETRANGE(Type,0);
                        //
                        // CreditCardTransaction.FILTERGROUP := 0;
                        // IF CreditCardTransaction.FIND('-') THEN
                        //  CreditCardTransaction.PrintTerminalReceipt(FALSE)
                        // ELSE
                        //  MESSAGE(Text10600006,"Sales Ticket No.","Register No.");
                        EFTTransactionRequest.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        EFTTransactionRequest.SetRange("Register No.", "Register No.");
                        if EFTTransactionRequest.FindSet then
                            repeat
                                EFTTransactionRequest.PrintReceipts(true);
                            until EFTTransactionRequest.Next = 0;
                        //+NPR5.46 [290734]
                    end;
                }
                action("Show credit Card Transaction")
                {
                    Caption = 'Show Credit Card Transaction';
                    Image = "Action";

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
                            //FORM.RUNMODAL(FORM::"Credit card transaction ticket",Dankorttransaktion)
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
                        PostAuditRoll: Codeunit "NPR Post audit roll";
                    begin
                        Clear(AuditRollGlobal);
                        PostAuditRoll.ShowProgress(true);
                        PostAuditRoll.RunCode(AuditRollGlobal);
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
                        PostAuditRoll: Codeunit "NPR Post audit roll";
                    begin
                        PostAuditRoll.ShowProgress(true);
                        PostAuditRoll.RunCode(Rec);
                    end;
                }
                action("Move Sales Ticket to Warranty")
                {
                    Caption = 'Move Sales Ticket to Warranty';
                    Image = MovementWorksheet;

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
                                    //FORM.RUNMODAL(FORM::"Posted Sales Invoice",Salgsfakturahoved);
                                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                                end;
                            "Document Type"::Order:
                                begin
                                    SalesShipmentHeader.FilterGroup := 2;
                                    SalesShipmentHeader.SetRange("NPR Sales Ticket No.", SalesTicketNo);
                                    SalesShipmentHeader.FilterGroup := 0;
                                    //FORM.RUNMODAL(FORM::"Posted Sales Shipment", SalgsLevHoved);
                                    PAGE.RunModal(PAGE::"Posted Sales Shipment", SalesShipmentHeader);
                                end;
                            "Document Type"::"Credit Memo":
                                begin
                                    SalesCrMemoHeader.FilterGroup := 2;
                                    SalesCrMemoHeader.SetRange("Pre-Assigned No.", SalesTicketNo);
                                    SalesCrMemoHeader.FilterGroup := 0;
                                    //FORM.RUNMODAL(FORM::"Posted Sales Credit Memo", SalgsKreditnotaHoved);
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
                }
                action("&Navigate")
                {
                    Caption = 'Naviger';
                    Image = Navigate;

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

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
                action(ChangeDimensions)
                {
                    Caption = 'Change Dimensions';
                    Image = ChangeDimensions;

                    trigger OnAction()
                    begin
                        //-NPR5.42 [314987]
                        SetDimensions;
                        //+NPR5.42 [314987]
                    end;
                }
                action(Comment)
                {
                    Caption = 'Comments';
                    Image = Comment;

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
                }
                action("POS Entry")
                {
                    Caption = 'POS Entry';
                    Image = Entries;

                    trigger OnAction()
                    var
                        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        //-NPR5.38 [295255]
                        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", "Clustered Key");
                        if AuditRolltoPOSEntryLink.FindFirst then begin
                            POSEntry.SetRange("Entry No.", AuditRolltoPOSEntryLink."POS Entry No.");
                            Clear(POSEntryList);
                            POSEntryList.SetTableView(POSEntry);
                            POSEntryList.Run;
                        end;
                        //+NPR5.38 [295255]
                    end;
                }
                action(AdvancedFilter)
                {
                    Caption = 'Advanced Filter';
                    Image = "Filter";
                }
                separator(Separator6150674)
                {
                }
                action(Calculate)
                {
                    Caption = 'Calculate';
                    Image = Calculate;
                }
                action(Sum)
                {
                    Caption = 'Sum';
                    Image = Totals;
                    ShortCutKey = 'Ctrl+S';

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

                    trigger OnAction()
                    begin
                        AuditRollGlobal.Reset;
                        AuditRollGlobal.FilterGroup := 2;

                        AuditRollGlobal.SetRange("Register No.", "Register No.");
                        AuditRollGlobal.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        AuditRollGlobal.SetRange("Sale Type", "Sale Type"::Sale);
                        AuditRollGlobal.SetRange("Sale Date", "Sale Date");
                        AuditRollGlobal.FilterGroup := 0;
                        //FORM.RUNMODAL(FORM::"Revisionsrulle Statistik",Revisionsrulle);
                        PAGE.RunModal(PAGE::"NPR Audit Roll Statistics", AuditRollGlobal);
                    end;
                }
                action("Advanced Sales Statistics")
                {
                    Caption = 'Advanced Sales Statistics';
                    Image = Statistics;
                    RunObject = Page "NPR Advanced Sales Stats";
                }
                action("Day Report")
                {
                    Caption = 'Day Report';
                    Image = "Report";

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
                        //FORM.RUNMODAL(FORM::"Revisionsrulle Statistik",Revisionsrulle);
                        PAGE.RunModal(PAGE::"NPR Audit Roll Statistics", AuditRollGlobal);
                    end;
                }
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    Promoted = true;
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

        //IF "No." = '80203' THEN SalesColor := TRUE
    end;

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        //-NPR5.48 [318531]
        if GetFilter(Type) = '' then
            //+NPR5.48 [318531]
            //-NPR5.22
            SetFilter(Type, '<>%1', Type::Cancelled);
        //+NPR5.22

        //-NPR5.23 [242105]
        //IF FIND('+') THEN;
        if FindFirst then;
        //+NPR5.23 [242105]

        SelectedTicketNo := "Sales Ticket No.";

        /*IF NOT extFilters THEN BEGIN
          CASE Filter[2] OF
            Filter::Hængende : BEGIN
              Filter[2] := Filter::" ";
              Rec.COPYFILTERS(tRec[1]);
              //CurrForm."Register No.".ACTIVATE;
              FieldRegisterNo:=TRUE;
              //CurrForm.UPDATE(TRUE);
              CurrPage.UPDATE(TRUE);
            END;
            Filter::Hængende2 : BEGIN
              Filter[2] := Filter::" ";
              Rec.COPYFILTERS(tRec[1]);
              //CurrForm."Register No.".ACTIVATE;
              //CurrForm.UPDATE(TRUE);
              CurrPage.UPDATE(TRUE);
            END;
          END;
        END;*/

        //-NPR5.38 [301600]
        if NPRetailSetup.Get then
            AdvancedPosting := NPRetailSetup."Advanced Posting Activated";
        //+NPR5.38 [301600]

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

    procedure PostReceipt()
    var
        AuditRoll4: Record "NPR Audit Roll";
        PostTempAuditRoll: Codeunit "NPR Post Temp Audit Roll";
        AuditRollPosting: Record "NPR Audit Roll Posting";
        TX001: Label 'Posted ?';
        PostDocNo: Code[20];
    begin
        //PostReceipt

        AuditRoll4 := Rec;
        AuditRoll4.SetCurrentKey("Register No.", "Sales Ticket No.");
        AuditRoll4.SetRange("Register No.", "Register No.");
        AuditRoll4.SetRange("Sales Ticket No.", "Sales Ticket No.");
        if Confirm(TX001, true, AuditRoll4.GetFilters) then begin
            /* FINANCES */
            AuditRollPosting.DeleteAll;
            AuditRollPosting.TransferFromRevSilent(AuditRoll4, AuditRollPosting);
            //-NPR5.51 [343685]
            //PostTempAuditRoll.SetPostingNo(PostTempAuditRoll.GetNewPostingNo(TRUE));
            PostDocNo := PostTempAuditRoll.GetNewPostingNo(true);
            PostTempAuditRoll.SetPostingNo(PostDocNo);
            //+NPR5.51 [343685]
            PostTempAuditRoll.RunPost(AuditRollPosting);
            AuditRollPosting.UpdateChangesSilent;

            /* ITEM LEDGER ENTRIES */
            AuditRollPosting.DeleteAll;
            AuditRollPosting.TransferFromRevSilentItemLedg(AuditRoll4, AuditRollPosting);
            //-NPR5.51 [343685]
            //PostTempAuditRoll.SetPostingNo(PostTempAuditRoll.GetNewPostingNo(TRUE));
            PostTempAuditRoll.SetPostingNo(PostDocNo);
            //+NPR5.51 [343685]
            PostTempAuditRoll.RunPostItemLedger(AuditRollPosting);
            AuditRollPosting.UpdateChangesSilent;
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
    var
        NPRetail: Record "NPR Retail Setup";
    begin
        //CurrForm.Funktion.VISIBLE(Filter[2] = Filter::Hængende);
        //CurrForm.Udskriv.VISIBLE(Filter[2] = Filter::Hængende);
        //CurrForm.Dankort.VISIBLE(Filter[2] = Filter::Hængende);
        //CurrForm."Funktion - Udbetaling".VISIBLE(Filter[2] = Filter::" ");

        case Filter[2] of
            Filter::Payment:
                begin
                    Filter[2] := Filter::" ";
                    Rec.CopyFilters(TempAuditRollArray[1]);
                    //CurrForm."Register No.".ACTIVATE;
                    //CurrForm.UPDATE(TRUE);
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
                    //CurrForm.UPDATE(TRUE);
                    //CurrForm."No.".ACTIVATE;
                    exit(Filter[2]);
                end;
        end;
    end;

    procedure DepositEntries(): Integer
    var
        NPRetail: Record "NPR Retail Setup";
    begin
        //CurrForm.Funktion.VISIBLE(Filter[2] = Filter::Hængende2);
        //CurrForm.Udskriv.VISIBLE(Filter[2] = Filter::Hængende2);
        //CurrForm.Dankort.VISIBLE(Filter[2] = Filter::Hængende2);
        //CurrForm."Funktion - Udbetaling".VISIBLE(Filter[2] = Filter::" ");

        case Filter[2] of
            Filter::Deposit:
                begin
                    Filter[2] := Filter::" ";
                    Rec.CopyFilters(TempAuditRollArray[1]);
                    //CurrForm."Register No.".ACTIVATE;
                    //CurrForm.UPDATE(TRUE);
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
                    //CurrForm.UPDATE(TRUE);
                    CurrPage.Update(true);
                    //CurrForm."No.".ACTIVATE;
                    exit(Filter[2]);
                end;
        end;
    end;

    procedure SetExtFilters(ExtFilters1: Boolean)
    begin
        //usingTS(isTouch1 : Boolean)
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

