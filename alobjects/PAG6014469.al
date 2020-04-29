page 6014469 "Retail Document Header"
{
    // 
    // *NPK1.0* 100203 BC NPK
    // Menupunkt 'Dan k�bsordre' tilf�jet p� knappen 'Skr�dder'
    // 7545: Menupunkt 'Dan k�bsordre' <OnPush>
    //       Overf�rer varerne fra linierne til k�bsordre ved enten at danne ny eller tilf�je til eksisterende linie / ordre
    // 
    // //-NPK3.0m Ved Nikolai Pedersen
    //   Tilf�jet fanebladet "levering"
    //   Tilf�jet "max bel�b" under andet
    // 
    // //-NPR3.0t d.25.05.05 v. Simon Sch�bel
    //   overs�ttelser
    // 
    // NPK, MIM 01-09-2007: Rettet form til at overholde GUI retningslinjer.
    // 
    // NPK, MH 19-01-2009: Tilf�jet menuknap, der ligger under "Hj�lp"-knappen, til brug i forb. med genvejstaster.
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
    SourceTable = "Retail Document Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document Type";"Document Type")
                {
                    OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Quote';
                }
                field("No.";"No.")
                {
                }
                field("Customer Type";"Customer Type")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Name;Name)
                {
                }
                field("First Name";"First Name")
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Country Code";"Country Code")
                {
                }
                field("Document Date";"Document Date")
                {
                }
                field("Last Date Modified";"Last Date Modified")
                {
                }
                field("Time of Day";"Time of Day")
                {
                }
                field(Phone;Phone)
                {
                }
                field(Mobile;Mobile)
                {
                }
                field("E-mail";"E-mail")
                {
                }
                field(Reference;Reference)
                {
                    Caption = 'Reference';
                }
                field("Contract Status";"Contract Status")
                {
                }
                field(Cashed;Cashed)
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
            }
            group(Delivery1)
            {
                Caption = 'Delivery';
                group(Control6150648)
                {
                    ShowCaption = false;
                    field("Ship-to Name";"Ship-to Name")
                    {
                    }
                    field("Ship-to Address";"Ship-to Address")
                    {
                    }
                    field("Ship-to Address 2";"Ship-to Address 2")
                    {
                    }
                    field("Ship-to Post Code";"Ship-to Post Code")
                    {
                    }
                    field("Ship-to City";"Ship-to City")
                    {
                    }
                    field("Ship-to Attention";"Ship-to Attention")
                    {
                    }
                }
                group(Control6150655)
                {
                    ShowCaption = false;
                    field(Delivery;Delivery)
                    {
                    }
                    field("Shipping Type";"Shipping Type")
                    {
                    }
                    field("Delivery by Vendor";"Delivery by Vendor")
                    {
                    }
                    field("Resource Ship-by n Persons";"Resource Ship-by n Persons")
                    {
                        Caption = 'Persons';
                    }
                    field("Estimated Time Use";"Estimated Time Use")
                    {
                    }
                    field("Resource Ship-by Car";"Resource Ship-by Car")
                    {
                    }
                    field("Resource.Name";Resource.Name)
                    {
                        Caption = 'Resource Name';
                    }
                    field("Return Date";"Return Date")
                    {
                    }
                    field("Delivery Date";"Delivery Date")
                    {
                    }
                    field("Delivery Time 1";"Delivery Time 1")
                    {
                    }
                    field("Delivery Time 2";"Delivery Time 2")
                    {
                    }
                    field("Ship-to Resource Date";"Ship-to Resource Date")
                    {
                    }
                    field("Ship-to Resource Time";"Ship-to Resource Time")
                    {
                    }
                }
            }
            group(Establishment)
            {
                Caption = 'Establishment';
                group(Control6150671)
                {
                    ShowCaption = false;
                    field(Via;Via)
                    {
                    }
                    field("Rent Register";"Rent Register")
                    {
                    }
                    field("Rent Sales Ticket";"Rent Sales Ticket")
                    {
                    }
                    field("Rent Salesperson";"Rent Salesperson")
                    {
                    }
                }
                group(Control6150676)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                    {
                        Caption = 'Shortcut Dimension 1 Code';
                    }
                    field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                    {
                        Caption = 'Shortcut Dimension 2 Code';
                    }
                    field("ID Card";"ID Card")
                    {
                    }
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                field("Vendor Index";"Vendor Index")
                {
                }
                field("Purchase Order No.";"Purchase Order No.")
                {
                }
                field("Order No.";"Order No.")
                {
                }
                field("Notify Customer";"Notify Customer")
                {
                }
            }
            group("Customer Letter")
            {
                Caption = 'Customer Letter';
                group(Control6150696)
                {
                    ShowCaption = false;
                    field(Status;Status)
                    {
                    }
                    field("Letter Printed";"Letter Printed")
                    {
                    }
                    field("Invoice No.";"Invoice No.")
                    {
                    }
                }
            }
            group(Agreement)
            {
                Caption = 'Agreement';
                group(Control6150698)
                {
                    ShowCaption = false;
                    field(Deposit;Deposit)
                    {
                    }
                    field("Prices Including VAT";"Prices Including VAT")
                    {
                    }
                    field("Payment Method Code";"Payment Method Code")
                    {
                    }
                    field("Invoice No.1";"Invoice No.")
                    {
                        Caption = 'Invoice No.';
                    }
                    field("Req. Return Date";"Req. Return Date")
                    {
                    }
                }
            }
            part(RetailDocumentLines1;"Retail Document Lines")
            {
                SubPageLink = "Document Type"=FIELD("Document Type"),
                              "Document No."=FIELD("No.");
                SubPageView = SORTING("Document Type","Document No.","Line No.");
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

                trigger OnAction()
                begin
                    ExitCode:='';
                end;
            }
            group(Print)
            {
                Caption = '&Print';
                action("Print Order Note")
                {
                    Caption = 'Print Order Note';
                    Image = PrintDocument;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        RetailDocumentHeader.SetRange("Document Type","Document Type");
                        RetailDocumentHeader.SetRange("No.","No.");
                        if RetailDocumentHeader.Find('-') then;
                        //-NPR5.29
                        //RetailDocumentHeader."Copy no.":=RetailDocumentHeader."Copy no."+1;
                        //RetailDocumentHeader.MODIFY();
                        //+NPR5.29
                        ReportSelectionRetail.SetRange("Report Type",ReportSelectionRetail."Report Type"::Tailor);
                        ReportSelectionRetail.Find('-');
                        repeat
                          REPORT.Run(ReportSelectionRetail."Report ID",true,false,RetailDocumentHeader);
                        until ReportSelectionRetail.Next = 0;
                        //-NPR5.29
                        RetailDocumentHeader."Copy No." := RetailDocumentHeader."Copy No." + 1;
                        RetailDocumentHeader.Modify();
                        //+NPR5.29
                    end;
                }
                action(Label)
                {
                    Caption = 'Label';
                    Image = DepositSlip;

                    trigger OnAction()
                    begin
                        RetailDocumentHeader.Copy(Rec);
                        RetailDocumentHeader.SetRecFilter;
                        REPORT.RunModal(REPORT::Report50093,false,false,RetailDocumentHeader);    /*true=faLSE HVIS FILTER IKKE SKAL VISES*/

                    end;
                }
                action(Action6150643)
                {
                    Caption = 'Customer Letter';
                    Image = CustomerLedger;

                    trigger OnAction()
                    begin
                        RetailDocumentHeader.Copy(Rec);
                        RetailDocumentHeader.SetRecFilter;
                        REPORT.RunModal(REPORT::"Return Reason Code Statistics",true,false,RetailDocumentHeader);
                        /*true=faLSE HVIS FILTER IKKE SKAL VISES*/

                    end;
                }
                action("Purchase Contract")
                {
                    Caption = 'Purchase Contract';
                    Image = Documents;

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        ReportSelectionContract.SetRange("Report Type",ReportSelectionContract."Report Type"::"Purchase contract");
                        ReportSelectionContract.Find('-');
                        repeat
                          REPORT.Run(ReportSelectionContract."Report ID",true,false,Rec);
                        until ReportSelectionContract.Next = 0;
                    end;
                }
                action(Lease)
                {
                    Caption = 'Lease';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                        ThisRetailDocumentHeader: Record "Retail Document Header";
                    begin
                        ReportSelectionContract.SetRange("Report Type",ReportSelectionContract."Report Type"::"Rental contract");
                        ReportSelectionContract.Find('-');
                        ThisRetailDocumentHeader.SetFilter("Document Type",'%1',Rec."Document Type");
                        ThisRetailDocumentHeader.SetFilter("No.","No.");
                        repeat
                          REPORT.Run(ReportSelectionContract."Report ID",true,false,ThisRetailDocumentHeader);
                        until ReportSelectionContract.Next = 0;
                    end;
                }
                action("Detail Trial Bal.")
                {
                    Caption = 'Detail Trial Bal.';
                    Image = BankAccountLedger;

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
                        CustLedgerEntry.SetCurrentKey("Customer No.","Posting Date");
                        //+NPR5.30 [266874]

                        CustLedgerEntry.SetRange("Customer No.","Customer No.");
                        CustLedgerEntry.SetRange("Document Type");
                        CustLedgerEntry.SetRange("External Document No.","No.");

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
                    RunObject = Page "Retail Document List";
                    ShortCutKey = 'F5';
                    Visible = false;
                }
                action("Create Invoice")
                {
                    Caption = 'Create Invoice';
                    Image = Invoice;

                    trigger OnAction()
                    begin
                        CreateInvoice;
                        Validate("Contract Status","Contract Status"::"Transmitted to invoice");
                        Modify(true);
                    end;
                }
                action("Create purchaseorder")
                {
                    Caption = 'Create purchaseorder';
                    Image = "Order";

                    trigger OnAction()
                    begin
                        CreatePurchaseOrder;
                    end;
                }
                action("Send Status SMS")
                {
                    Caption = 'Send Status SMS';
                    Image = SendMail;

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
        RetailDocumentHeader: Record "Retail Document Header";
        RetailSetup: Record "Retail Setup";
        Resource: Record Resource;
        ExitCode: Code[10];
}

