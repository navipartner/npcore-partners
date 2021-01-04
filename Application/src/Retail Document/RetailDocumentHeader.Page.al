page 6014469 "NPR Retail Document Header"
{
    // 
    // *NPK1.0* 100203 BC NPK
    // Menupunkt 'Dan k¢bsordre' tilf¢jet på knappen 'Skrædder'
    // 7545: Menupunkt 'Dan k¢bsordre' <OnPush>
    //       Overf¢rer varerne fra linierne til k¢bsordre ved enten at danne ny eller tilf¢je til eksisterende linie / ordre
    // 
    // //-NPK3.0m Ved Nikolai Pedersen
    //   Tilf¢jet fanebladet "levering"
    //   Tilf¢jet "max bel¢b" under andet
    // 
    // //-NPR3.0t d.25.05.05 v. Simon Sch¢bel
    //   oversættelser
    // 
    // NPK, MIM 01-09-2007: Rettet form til at overholde GUI retningslinjer.
    // 
    // NPK, MH 19-01-2009: Tilf¢jet menuknap, der ligger under "Hjælp"-knappen, til brug i forb. med genvejstaster.
    // 
    // NPRx.xx/JDH/20150703 CASE 217876 Caption changed
    // 
    // NPR5.29/TS  /20160926  CASE 253262 Added Document Type and removed function place cursor
    // NPR5.29/TS  /20161018  CASE 255320 Added Field Customer Type
    // NPR5.29/JLK /20161028  CASE 256691 Corrected Issue when Printing Retail Document Report
    //                                    Changed Variable from Hoved to RetailDocumentHeader for better understanding
    // NPR5.29/JC  /20161107  CASE 257563 Disabled action selection list (Contract)
    // NPR5.29/TS  /20161110  CASE 257587 Added Location Code
    // NPR5.30/TJ  /20170222  CASE 266874 Changed key used in action Detail Trial Bal.
    // NPR5.36/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables/functions
    // NPR5.40/TS  /20180308  CASE 307589 Removed Find Card, its Variable and Function.
    // NPR5.40/LS  /20180307  CASE 307431 Added field "POS Entry No." on General tab
    // NPR5.40/TS  /20180315  CASE 307590 Removed Danish Captions
    // NPR5.40/TS  /20180321  CASE 308711 Corrected Enu captions Persons
    // NPR5.41/TS  /20180105  CASE 300893 Removed Caption on Name on Action

    Caption = 'Retail Document';
    SourceTable = "NPR Retail Document Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Quote';
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Customer Type"; "Customer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Type field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Created field';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                }
                field("Time of Day"; "Time of Day")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field(Phone; Phone)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone field';
                }
                field(Mobile; Mobile)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cell No. field';
                }
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail field';
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    Caption = 'Reference';
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("Contract Status"; "Contract Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract Status field';
                }
                field(Cashed; Cashed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed field';
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
            }
            group(Delivery1)
            {
                Caption = 'Delivery';
                group(Control6150648)
                {
                    ShowCaption = false;
                    field("Ship-to Name"; "Ship-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name field';
                    }
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address field';
                    }
                    field("Ship-to Address 2"; "Ship-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Post Code field';
                    }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to City field';
                    }
                    field("Ship-to Attention"; "Ship-to Attention")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Attention field';
                    }
                }
                group(Control6150655)
                {
                    ShowCaption = false;
                    field(Delivery; Delivery)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivery field';
                    }
                    field("Shipping Type"; "Shipping Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shipping Method field';
                    }
                    field("Delivery by Vendor"; "Delivery by Vendor")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivery by Vendor field';
                    }
                    field("Resource Ship-by n Persons"; "Resource Ship-by n Persons")
                    {
                        ApplicationArea = All;
                        Caption = 'Persons';
                        ToolTip = 'Specifies the value of the Persons field';
                    }
                    field("Estimated Time Use"; "Estimated Time Use")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Estimated Time Use field';
                    }
                    field("Resource Ship-by Car"; "Resource Ship-by Car")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Resource Ship-by Car field';
                    }
                    field("Resource.Name"; Resource.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Resource Name';
                        ToolTip = 'Specifies the value of the Resource Name field';
                    }
                    field("Return Date"; "Return Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Return Date field';
                    }
                    field("Delivery Date"; "Delivery Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivery Date field';
                    }
                    field("Delivery Time 1"; "Delivery Time 1")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivery Time 1 field';
                    }
                    field("Delivery Time 2"; "Delivery Time 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivery Time 2 field';
                    }
                    field("Ship-to Resource Date"; "Ship-to Resource Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Resource Date field';
                    }
                    field("Ship-to Resource Time"; "Ship-to Resource Time")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Resource Time field';
                    }
                }
            }
            group(Establishment)
            {
                Caption = 'Establishment';
                group(Control6150671)
                {
                    ShowCaption = false;
                    field(Via; Via)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Via field';
                    }
                    field("Rent Register"; "Rent Register")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rent Cash Register No. field';
                    }
                    field("Rent Sales Ticket"; "Rent Sales Ticket")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rent Sales Ticket field';
                    }
                    field("Rent Salesperson"; "Rent Salesperson")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rent Salesperson field';
                    }
                }
                group(Control6150676)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Shortcut Dimension 1 Code';
                        ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    }
                    field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Shortcut Dimension 2 Code';
                        ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    }
                    field("ID Card"; "ID Card")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ID card field';
                    }
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                field("Vendor Index"; "Vendor Index")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Index field';
                }
                field("Purchase Order No."; "Purchase Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Quote field';
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No. field';
                }
                field("Notify Customer"; "Notify Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer field';
                }
            }
            group("Customer Letter")
            {
                Caption = 'Customer Letter';
                group(Control6150696)
                {
                    ShowCaption = false;
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field';
                    }
                    field("Letter Printed"; "Letter Printed")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Letter Printed field';
                    }
                    field("Invoice No."; "Invoice No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Invoice No. field';
                    }
                }
            }
            group(Agreement)
            {
                Caption = 'Agreement';
                group(Control6150698)
                {
                    ShowCaption = false;
                    field(Deposit; Deposit)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Deposit field';
                    }
                    field("Prices Including VAT"; "Prices Including VAT")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Prices Including VAT field';
                    }
                    field("Payment Method Code"; "Payment Method Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Method Code field';
                    }
                    field("Invoice No.1"; "Invoice No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Invoice No.';
                        ToolTip = 'Specifies the value of the Invoice No. field';
                    }
                    field("Req. Return Date"; "Req. Return Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Req. Return Date field';
                    }
                }
            }
            part(RetailDocumentLines1; "NPR Retail Document Lines")
            {
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No.");
                SubPageView = SORTING("Document Type", "Document No.", "Line No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                Caption = 'OK';
                Image = Confirm;
                ApplicationArea = All;
                ToolTip = 'Executes the OK action';

                trigger OnAction()
                begin
                    ExitCode := 'OK';
                end;
            }
            separator(Separator6150638)
            {
            }
            action(Cancel)
            {
                Caption = ' Cancel';
                Image = Cancel;
                ApplicationArea = All;
                ToolTip = 'Executes the  Cancel action';

                trigger OnAction()
                begin
                    ExitCode := '';
                end;
            }
            group(Print)
            {
                Caption = '&Print';
                action("Print Order Note")
                {
                    Caption = 'Print Order Note';
                    Image = PrintDocument;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Order Note action';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        RetailDocumentHeader.SetRange("Document Type", "Document Type");
                        RetailDocumentHeader.SetRange("No.", "No.");
                        if RetailDocumentHeader.Find('-') then;
                        //-NPR5.29
                        //RetailDocumentHeader."Copy no.":=RetailDocumentHeader."Copy no."+1;
                        //RetailDocumentHeader.MODIFY();
                        //+NPR5.29
                        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::Tailor);
                        ReportSelectionRetail.Find('-');
                        repeat
                            REPORT.Run(ReportSelectionRetail."Report ID", true, false, RetailDocumentHeader);
                        until ReportSelectionRetail.Next = 0;
                        //-NPR5.29
                        RetailDocumentHeader."Copy No." := RetailDocumentHeader."Copy No." + 1;
                        RetailDocumentHeader.Modify();
                        //+NPR5.29
                    end;
                }
                action("Label")
                {
                    Caption = 'Label';
                    Image = DepositSlip;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Label action';

                    trigger OnAction()
                    begin
                        RetailDocumentHeader.Copy(Rec);
                        RetailDocumentHeader.SetRecFilter;
                        //REPORT.RunModal(REPORT::Report50093,false,false,RetailDocumentHeader);    /*true=faLSE HVIS FILTER IKKE SKAL VISES*/

                    end;
                }
                action(Action6150643)
                {
                    Caption = 'Customer Letter';
                    Image = CustomerLedger;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer Letter action';

                    trigger OnAction()
                    begin
                        RetailDocumentHeader.Copy(Rec);
                        RetailDocumentHeader.SetRecFilter;
                        REPORT.RunModal(REPORT::"NPR Return Reason Code Stat.", true, false, RetailDocumentHeader);
                        /*true=faLSE HVIS FILTER IKKE SKAL VISES*/

                    end;
                }
                action("Purchase Contract")
                {
                    Caption = 'Purchase Contract';
                    Image = Documents;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Contract action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Purchase contract");
                        ReportSelectionContract.Find('-');
                        repeat
                            REPORT.Run(ReportSelectionContract."Report ID", true, false, Rec);
                        until ReportSelectionContract.Next = 0;
                    end;
                }
                action(Lease)
                {
                    Caption = 'Lease';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Lease action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                        ThisRetailDocumentHeader: Record "NPR Retail Document Header";
                    begin
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Rental contract");
                        ReportSelectionContract.Find('-');
                        ThisRetailDocumentHeader.SetFilter("Document Type", '%1', Rec."Document Type");
                        ThisRetailDocumentHeader.SetFilter("No.", "No.");
                        repeat
                            REPORT.Run(ReportSelectionContract."Report ID", true, false, ThisRetailDocumentHeader);
                        until ReportSelectionContract.Next = 0;
                    end;
                }
                action("Detail Trial Bal.")
                {
                    Caption = 'Detail Trial Bal.';
                    Image = BankAccountLedger;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Detail Trial Bal. action';

                    trigger OnAction()
                    var
                        CustomerDetailTrialBal: Report "Customer - Detail Trial Bal.";
                        Customer: Record Customer;
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                    begin
                        Clear(CustomerDetailTrialBal);
                        CustomerDetailTrialBal.UseRequestPage(true);

                        Customer.Get("Customer No.");
                        Customer.SetRecFilter;

                        CustLedgerEntry.Reset;

                        //-NPR5.30 [266874]
                        //cle.SETCURRENTKEY("Document Type","External Document No.","Customer No.");
                        CustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date");
                        //+NPR5.30 [266874]

                        CustLedgerEntry.SetRange("Customer No.", "Customer No.");
                        CustLedgerEntry.SetRange("Document Type");
                        CustLedgerEntry.SetRange("External Document No.", "No.");

                        CustomerDetailTrialBal.SetTableView(Customer);
                        CustomerDetailTrialBal.SetTableView(CustLedgerEntry);
                        CustomerDetailTrialBal.Run;
                    end;
                }
            }
            group(Contract)
            {
                Caption = '&Contract';
                action("Selection List")
                {
                    Caption = 'Selection List';
                    Enabled = false;
                    Image = List;
                    RunObject = Page "NPR Retail Document List";
                    ShortCutKey = 'F5';
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Selection List action';
                }
                action("Create Invoice")
                {
                    Caption = 'Create Invoice';
                    Image = Invoice;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Invoice action';

                    trigger OnAction()
                    begin
                        CreateInvoice;
                        Validate("Contract Status", "Contract Status"::"Transmitted to invoice");
                        Modify(true);
                    end;
                }
                action("Create purchaseorder")
                {
                    Caption = 'Create purchaseorder';
                    Image = "Order";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create purchaseorder action';

                    trigger OnAction()
                    begin
                        CreatePurchaseOrder;
                    end;
                }
                action("Send Status SMS")
                {
                    Caption = 'Send Status SMS';
                    Image = SendMail;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Status SMS action';

                    trigger OnAction()
                    begin
                        SendStatusSMS;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcAnualRent();
        //-NPR5.40
        //Rates();
        //#+307589
        //-NPR5.29 [253262]
        //CurrForm.underForm.FORM.setRetailDocType("Document Type");
        //IF "Document Type" <> "Document Type"::" " THEN
        //  CurrPage.RetailDocumentLines1.PAGE.setRetailDocType("Document Type");
        //+NPR5.29 [253262]
    end;

    trigger OnClosePage()
    begin
        Reset;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        RetailSetup.Get;
        //-NPR5.29 [253262]
        //"Document Type" := "Document Type"::"Selection Contract";
        //+NPR5.29 [253262]
        "Customer Type" := RetailSetup."Default Rental";
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.29 [253262]
        //PlaceCursor;
        //+NPR5.29 [253262]
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Txt001: Label 'You have not chosen a customer. Continue?';
        ErrNoCustDeposit: Label 'Error. You must assign a customer when deposit is greater than zero.';
    begin
        if (("Customer No." = '') or ("Customer Type" = "Customer Type"::Kontant))
          and (Deposit > 0) then
            Error(ErrNoCustDeposit);

        if ("Customer No." = '') and (ExitCode = 'OK') then
            if not Confirm(Txt001, false) then
                exit(false);
    end;

    var
        RetailDocumentHeader: Record "NPR Retail Document Header";
        RetailSetup: Record "NPR Retail Setup";
        Resource: Record Resource;
        ExitCode: Code[10];
}

