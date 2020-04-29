codeunit 6151060 "NP GDPR Management"
{
    // NPR5.52/ZESO/20190925 CASE 358656 Object Created
    // NPR5.53/ZESO/20200115 CASE 358656 Reworked Codeunit to cater for new job parameters, check for ILES, remove customer no from email address
    // NPR5.54/ZESO/20200303 CASE 358656 Anonymize Customers where To Anomymize On is less than or equal to TODAY.
    // NPR5.54/ZESO/20200303 CASE 358656 Count of Customers which are actually being anonymized.
    // NPR5.54/ZESO/20200310 CASE 358656 Refactored Code which gives list of Customers to be anonymised.

    Permissions = TableData "Sales Shipment Header"=rm,
                  TableData "Sales Invoice Header"=rm,
                  TableData "Sales Cr.Memo Header"=rm,
                  TableData "Return Receipt Header"=rm;
    TableNo = "Task Line";

    trigger OnRun()
    var
        Customer: Record Customer;
        ReasonText: Text;
        VarNoOfCustomers: Integer;
        CustToAnonymise: Record "Customers to Anonymize";
        GDPRSetup: Record "Customer GDPR SetUp";
    begin
        VarCheckPeriod := GetParameterBool('CHECK_PERIOD');
        //-NPR5.53 [358656]


        //Customer.RESET;
        //Customer.SETRANGE(Customer.Anonymized,FALSE);
        //IF NOT VarCheckPeriod THEN
          //Customer.SETRANGE("To Anonymize",TRUE);
        //IF Customer.FINDSET THEN
          //REPEAT
            //DoAnonymization(Customer."No.",ReasonText);
          //UNTIL Customer.NEXT =0;


        VarNoOfCustomers := GetParameterInt('NO_OF_CUSTOMERS');

        if GDPRSetup.Get then;


        case VarCheckPeriod of
          false:
            begin
              Customer.Reset;
              Customer.SetRange(Customer.Anonymized,false);
              //-NPR5.54 [358656]
              //Customer.SETRANGE(Customer."To Anonymize On",TODAY);
              Customer.SetFilter(Customer."To Anonymize On",'>%1&<=%2',0D,Today);
              //+NPR5.54 [358656]
              if Customer.FindSet then
                repeat
                  DoAnonymization(Customer."No.",ReasonText);
                until Customer.Next =0;
            end;

         true:
            begin
              PopulateCustToAnonymise;
              CustToAnonymise.Reset;
              if CustToAnonymise.FindSet then
                repeat
                  DoAnonymization(CustToAnonymise."Customer No",ReasonText);
                  CustToAnonymise.Delete;
                  //-NPR5.54 [358656]
                  //VarCount += 1;
                  //+NPR5.54 [358656]
                until (CustToAnonymise.Next =0) or (VarCount = VarNoOfCustomers);
            end;
        end;


        //+NPR5.53 [358656]
    end;

    var
        Text000: Label 'You cannot anonymize Customer %1 because it has open entries/documents.';
        Text001: Label 'Customer %1  has been anonymized.';
        EntryNo: Integer;
        Text003: Label 'Customer %1 is a member. Please use Member Anonymization.';
        Text004: Label 'You do not have permission to anonymize customers. Contact your administrator to give you access.';
        VarCheckPeriod: Boolean;
        VarCount: Integer;

    procedure DoAnonymization(CustNo: Code[20];var VarReason: Text): Boolean
    var
        CLE: Record "Cust. Ledger Entry";
        GDPRSetup: Record "Customer GDPR SetUp";
        ReasonText: Text;
        SalesHdr: Record "Sales Header";
        OpenDocFound: Boolean;
        TransactionFound: Boolean;
        DateFormulaTxt: Text;
        VarPeriod: DateFormula;
        OpenTransactionFound: Boolean;
        GDPRLogEntry: Record "Customer GDPR Log Entries";
        MemberFound: Boolean;
        Membership: Record "MM Membership";
        UserSetup: Record "User Setup";
        ILE: Record "Item Ledger Entry";
    begin
        if UserSetup.Get(UserId) then
          if not UserSetup."Anonymize Customers" then
            Error(Text004);



        if GDPRLogEntry.FindLast then
          EntryNo := GDPRLogEntry."Entry No"
        else
          EntryNo := 0;


        if GDPRSetup.Get then;
        OpenDocFound := false;
        TransactionFound := false;
        OpenTransactionFound := false;
        MemberFound := false;

        SalesHdr.SetCurrentKey("Sell-to Customer No.","External Document No.");
        SalesHdr.SetRange("Sell-to Customer No.",CustNo);
        if SalesHdr.FindFirst then
          OpenDocFound := true;


        if VarCheckPeriod then begin
          DateFormulaTxt := '-' + Format(GDPRSetup."Anonymize After");
          Evaluate(VarPeriod,DateFormulaTxt);
          CLE.SetCurrentKey("Customer No.","Posting Date","Currency Code");
          CLE.SetRange("Customer No.",CustNo);
          CLE.SetFilter("Posting Date",'>%1',CalcDate(VarPeriod,Today));
          if CLE.FindFirst then
            TransactionFound := true;

          //-NPR5.53 [358656]
          if TransactionFound = false then begin
            ILE.Reset;
            ILE.SetCurrentKey("Source Type","Source No.","Item No.","Variant Code","Posting Date");
            ILE.SetRange(ILE."Source Type",ILE."Source Type"::Customer);
            ILE.SetRange(ILE."Source No.",CustNo);
            ILE.SetFilter("Posting Date",'>%1',CalcDate(VarPeriod,Today));
            if ILE.FindFirst then
              TransactionFound := true;
          end;
          //+NPR5.53 [358656]


        end;

        CLE.SetCurrentKey("Customer No.",Open,Positive,"Due Date","Currency Code");
        CLE.SetRange("Customer No.",CustNo);
        CLE.SetRange(Open,true);
        if CLE.FindFirst then
          OpenTransactionFound := true;

        //-NPR5.53 [358656]
        if not OpenTransactionFound  then begin
            ILE.Reset;
            ILE.SetCurrentKey("Source Type","Source No.","Item No.","Variant Code","Posting Date");
            ILE.SetRange(ILE."Source Type",ILE."Source Type"::Customer);
            ILE.SetRange(ILE."Source No.",CustNo);
            ILE.SetRange(Open,true);
            if ILE.FindFirst then
              OpenTransactionFound := true;
        end;
        //+NPR5.53 [358656]



        Membership.SetRange("Customer No.",CustNo);
        if Membership.FindFirst then
          MemberFound := true;



        if (OpenDocFound = false) and (TransactionFound =false) and (OpenTransactionFound = false) and (MemberFound = false) then begin
          AnonymizeCustomer(CustNo);
          //-NPR5.54 [358656]
          VarCount += 1;
          //+NPR5.54 [358656]
          InsertLogEntry(CustNo,true,OpenDocFound,OpenTransactionFound,TransactionFound,MemberFound);
          VarReason := StrSubstNo (Text001, CustNo);
          exit(true) ;
        end;

        InsertLogEntry(CustNo,false,OpenDocFound,OpenTransactionFound,TransactionFound,MemberFound);
        if (VarReason = '') and (MemberFound) then
          VarReason := StrSubstNo(Text003,CustNo);

        if (VarReason = '') and (not MemberFound) then
          VarReason := StrSubstNo(Text000,CustNo);
        exit(false);
    end;

    procedure AnonymizeCustomer(CustNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustNo);
        Customer.Name := '------';
        Customer."Search Name" := '------';
        Customer."Name 2" := '------';
        Customer.Address := '------ --';
        Customer."Address 2" := '------ --';
        Customer.City := '';
        Customer.Contact := '------';
        Customer."Phone No." := '';
        Customer."Telex No." := '';
        Customer."Fax No." := '';
        Customer."VAT Registration No." := '';
        Clear(Customer.Picture);
        Customer.GLN := '';
        Customer."Post Code" := '';
        Customer."Country/Region Code" := '';
        //-NPR5.53 [358656]
        //Customer."E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', CustNo);
        Customer."E-Mail" := '------@----';
        //+NPR5.53 [358656]
        Customer."Home Page" := 'nowhere.com';
        Customer.Anonymized := true;
        Customer."Anonymized Date" := CurrentDateTime;
        Customer."To Anonymize" := false;

        Customer.Blocked := Customer.Blocked::All;
        Customer.Modify(true);

        AnonymizePrimaryContact(CustNo);
        AnonymizeSalesInvoices(CustNo);
        AnonymizeSalesCrMemos(CustNo);
        AnonymizeSalesShipments(CustNo);
        AnonymizeReturnReceipts(CustNo);
        AnonymizeJobs(CustNo);
    end;

    local procedure AnonymizePrimaryContact(VarCustNo: Code[20])
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        ContBusRel.SetCurrentKey("Link to Table","No.");
        ContBusRel.SetRange("Link to Table",ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.",VarCustNo);
        if not ContBusRel.FindFirst then
          exit

        else if Contact.Get(ContBusRel."Contact No.") then begin
          Contact.Name := '------';
          Contact."Search Name" := '------';
          Contact."Name 2" := '------';
          Contact.Address := '------ --';
          Contact."Address 2" := '------ --';
          Contact.City := '';
          Contact."Phone No." := '';
          Contact."Fax No." := '';
          Contact."VAT Registration No." := '';;
          Clear(Contact.Picture);
          Contact."Post Code" := '';
          Contact."Country/Region Code" := '';
          //-NPR5.53 [358656]
          //Contact."E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', Contact."No.");
          Contact."E-Mail" := '------@----';
          //-NPR5.53 [358656]
          Contact."Home Page" := 'www.nowhere.com';
          Contact."First Name" := '------';
          Contact."Middle Name" := '------';
          Contact.Surname := '------';
          Contact."Job Title" := '------';
          Contact.Initials := '------';
          Contact."Mobile Phone No." := '';
          //-NPR5.53 [358656]
          //Contact."Search E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', Contact."No.");
          Contact."Search E-Mail" := '------@----';
          //+NPR5.53 [358656]
          Contact."Company Name":= '------';
          Contact.Pager := '';
          Contact."Magento Contact" := false;
          Contact."Magento Administrator" := false;
          Contact.Modify(true);

          if Contact."Company No." ='' then
            exit;
          AnonymizeCompanyNo(Contact."Company No.");
        end;
    end;

    local procedure AnonymizeCompanyNo(VarContactNo: Code[20])
    var
        Contact: Record Contact;
    begin
        if VarContactNo = '' then
          exit;

        if Contact.Get(Contact."Company No.") then begin
            Contact.Name := '------';
            Contact."Search Name" := '------';
            Contact."Name 2" := '------';
            Contact.Address := '------ --';
            Contact."Address 2" := '------ --';
            Contact.City := '';
            Contact."Phone No." := '';
            Contact."Fax No." := '';
            Contact."VAT Registration No." := '';;
            Clear(Contact.Picture);
            Contact."Post Code" := '';
            Contact."Country/Region Code" := '';
            //-NPR5.53 [358656]
            //Contact."E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', Contact."No.");
            Contact."E-Mail" := '------@----';
            //-NPR5.53 [358656]
            Contact."Home Page" := 'www.nowhere.com';
            Contact."First Name" := '------';
            Contact."Middle Name" := '------';
            Contact.Surname := '------';
            Contact."Job Title" := '------';
            Contact.Initials := '------';
            Contact."Mobile Phone No." := '';
            //-NPR5.53 [358656]
            //Contact."Search E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', Contact."No.");
            Contact."Search E-Mail" := '------@----';
            //+NPR5.53 [358656]
            Contact."Company Name":= '------';
            Contact.Pager := '';
            Contact."Magento Contact" := false;
            Contact."Magento Administrator" := false;
            Contact.Modify(true);
          end;
    end;

    local procedure AnonymizeSalesInvoices(VarCustNo: Code[20])
    var
        SalesInvHdr: Record "Sales Invoice Header";
    begin
        SalesInvHdr.Reset;
        SalesInvHdr.SetRange("Sell-to Customer No.",VarCustNo);
        if not SalesInvHdr.FindFirst then
          exit
        else
          repeat
            SalesInvHdr."Sell-to Customer Name" := '------';
            SalesInvHdr."Sell-to Customer Name 2" := '------';
            SalesInvHdr."Sell-to Address" := '------ --';
            SalesInvHdr."Sell-to Address 2" := '------ --';
            SalesInvHdr."Sell-to City" := '';
            SalesInvHdr."Sell-to Contact" := '------';
            SalesInvHdr."Sell-to Post Code" := '';
            SalesInvHdr."Sell-to County" := '';
            SalesInvHdr."Sell-to Country/Region Code" := '';
            SalesInvHdr."Ship-to Post Code" := '';
            SalesInvHdr."Ship-to County" := '';
            SalesInvHdr."Ship-to Country/Region Code" := '';
            SalesInvHdr."Ship-to Name" := '------';
            SalesInvHdr."Ship-to Name 2" := '------';
            SalesInvHdr."Ship-to Address" := '------ --';
            SalesInvHdr."Ship-to Address 2" := '------ --';
            SalesInvHdr."Ship-to City" := '';
            SalesInvHdr."Ship-to Contact" := '------';
            SalesInvHdr."VAT Registration No." := '';
            SalesInvHdr."Bill-to Customer No." := '';
            SalesInvHdr."Bill-to Name" := '------';
            SalesInvHdr."Bill-to Name 2" := '------';
            SalesInvHdr."Bill-to Address" := '------ --';
            SalesInvHdr."Bill-to Address 2" := '------ --';
            SalesInvHdr."Bill-to City" := '';
            SalesInvHdr."Bill-to Contact" := '------';
            SalesInvHdr."Ship-to Code" := '';
            SalesInvHdr."Bill-to Post Code" := '';
            SalesInvHdr."Bill-to County" := '';
            SalesInvHdr."Bill-to Country/Region Code" := '';
            //-NPR5.53 [358656]
            //SalesInvHdr."Bill-to E-mail" := STRSUBSTNO ('anonymous%1@nowhere.com', VarCustNo);
            SalesInvHdr."Bill-to E-mail" := '------@----';
            //+NPR5.53 [358656]
            SalesInvHdr."Sell-to Post Code":= '';
            SalesInvHdr."Sell-to County" := '';
            SalesInvHdr."Sell-to Country/Region Code" := '';

            SalesInvHdr.Modify(true);
          until SalesInvHdr.Next =0;
    end;

    local procedure AnonymizeSalesCrMemos(VarCustNo: Code[20])
    var
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHdr.Reset;
        SalesCrMemoHdr.SetRange("Sell-to Customer No.",VarCustNo);
        if not SalesCrMemoHdr.FindFirst then
          exit
        else
          repeat
            SalesCrMemoHdr."Sell-to Customer Name" := '------';
            SalesCrMemoHdr."Sell-to Customer Name 2" := '------';
            SalesCrMemoHdr."Sell-to Address" := '------ --';
            SalesCrMemoHdr."Sell-to Address 2" := '------ --';
            SalesCrMemoHdr."Sell-to City" := '';
            SalesCrMemoHdr."Sell-to Contact" := '------';
            SalesCrMemoHdr."Sell-to Post Code" := '';
            SalesCrMemoHdr."Sell-to County" := '';
            SalesCrMemoHdr."Sell-to Country/Region Code" := '';
            SalesCrMemoHdr."Ship-to Post Code" := '';
            SalesCrMemoHdr."Ship-to County" := '';
            SalesCrMemoHdr."Ship-to Country/Region Code" := '';
            SalesCrMemoHdr."Ship-to Name" := '------';
            SalesCrMemoHdr."Ship-to Name 2" := '------';
            SalesCrMemoHdr."Ship-to Address" := '------ --';
            SalesCrMemoHdr."Ship-to Address 2" := '------ --';
            SalesCrMemoHdr."Ship-to City" := '';
            SalesCrMemoHdr."Ship-to Contact" := '------';
            SalesCrMemoHdr."VAT Registration No." := '';
            SalesCrMemoHdr."Bill-to Customer No." := '';
            SalesCrMemoHdr."Bill-to Name" := '------';
            SalesCrMemoHdr."Bill-to Name 2" := '------';
            SalesCrMemoHdr."Bill-to Address" := '------ --';
            SalesCrMemoHdr."Bill-to Address 2" := '------ --';
            SalesCrMemoHdr."Bill-to City" := '';
            SalesCrMemoHdr."Bill-to Contact" := '------';
            SalesCrMemoHdr."Ship-to Code" := '';
            SalesCrMemoHdr."Bill-to Post Code" := '';
            SalesCrMemoHdr."Bill-to County" := '';
            SalesCrMemoHdr."Bill-to Country/Region Code" := '';
            //-NPR5.53 [358656]
            //SalesCrMemoHdr."Bill-to E-mail" := STRSUBSTNO ('anonymous%1@nowhere.com', VarCustNo);
            SalesCrMemoHdr."Bill-to E-mail" := '------@----';
            //+NPR5.53 [358656]
            SalesCrMemoHdr."Sell-to Post Code":= '';
            SalesCrMemoHdr."Sell-to County" := '';
            SalesCrMemoHdr."Sell-to Country/Region Code" := '';
            SalesCrMemoHdr.Modify(true);
          until SalesCrMemoHdr.Next =0;
    end;

    local procedure InsertLogEntry(CustNo: Code[20];Success: Boolean;OpenSales: Boolean;OpenCLE: Boolean;TransactionInPeriod: Boolean;Member: Boolean)
    var
        GDPRLogEntry: Record "Customer GDPR Log Entries";
    begin
        GDPRLogEntry.Init;
        GDPRLogEntry."Entry No" := EntryNo + 1;
        GDPRLogEntry."Customer No" := CustNo;
        case Success of
          true:
            GDPRLogEntry.Status := GDPRLogEntry.Status::Anonymised;
          false:
            GDPRLogEntry.Status := GDPRLogEntry.Status::"Could Not be anonymised";
        end;

        GDPRLogEntry."Open Sales Documents" := OpenSales;
        GDPRLogEntry."Open Cust. Ledger Entry" := OpenCLE;
        GDPRLogEntry."Has transactions" := TransactionInPeriod;
        GDPRLogEntry."Customer is a Member" := Member;
        GDPRLogEntry."Log Entry Date Time" := CurrentDateTime;
        GDPRLogEntry."Anonymized By" := UserId;
        GDPRLogEntry.Insert;
    end;

    local procedure AnonymizeSalesArchives(VarCustNo: Code[20])
    var
        SalesHdrArchive: Record "Sales Header Archive";
    begin
        SalesHdrArchive.Reset;
        SalesHdrArchive.SetRange("Sell-to Customer No.",VarCustNo);
        if not SalesHdrArchive.FindFirst then
          exit
        else
          repeat
            SalesHdrArchive."Sell-to Customer Name" := '------';
            SalesHdrArchive."Sell-to Customer Name 2" := '------';
            SalesHdrArchive."Sell-to Address" := '------ --';
            SalesHdrArchive."Sell-to Address 2" := '------ --';
            SalesHdrArchive."Sell-to City" := '';
            SalesHdrArchive."Sell-to Contact" := '------';
            SalesHdrArchive."Sell-to Post Code" := '';
            SalesHdrArchive."Sell-to County" := '';
            SalesHdrArchive."Sell-to Country/Region Code" := '';
            SalesHdrArchive."Ship-to Post Code" := '';
            SalesHdrArchive."Ship-to County" := '';
            SalesHdrArchive."Ship-to Country/Region Code" := '';
            SalesHdrArchive."Ship-to Name" := '------';
            SalesHdrArchive."Ship-to Name 2" := '------';
            SalesHdrArchive."Ship-to Address" := '------ --';
            SalesHdrArchive."Ship-to Address 2" := '------ --';
            SalesHdrArchive."Ship-to City" := '';
            SalesHdrArchive."Ship-to Contact" := '------';
            SalesHdrArchive."VAT Registration No." := '';
            SalesHdrArchive."Bill-to Customer No." := '';
            SalesHdrArchive."Bill-to Name" := '------';
            SalesHdrArchive."Bill-to Name 2" := '------';
            SalesHdrArchive."Bill-to Address" := '------ --';
            SalesHdrArchive."Bill-to Address 2" := '------ --';
            SalesHdrArchive."Bill-to City" := '';
            SalesHdrArchive."Bill-to Contact" := '------';
            SalesHdrArchive."Ship-to Code" := '';
            SalesHdrArchive."Bill-to Post Code" := '';
            SalesHdrArchive."Bill-to County" := '';
            SalesHdrArchive."Bill-to Country/Region Code" := '';
            SalesHdrArchive."Sell-to Post Code":= '';
            SalesHdrArchive."Sell-to County" := '';
            SalesHdrArchive."Sell-to Country/Region Code" := '';
            SalesHdrArchive.Modify(true);
          until SalesHdrArchive.Next =0;
    end;

    local procedure AnonymizeSalesShipments(VarCustNo: Code[20])
    var
        SalesShipmentHdr: Record "Sales Shipment Header";
    begin
        SalesShipmentHdr.Reset;
        SalesShipmentHdr.SetRange("Sell-to Customer No.",VarCustNo);
        if not SalesShipmentHdr.FindFirst then
          exit
        else
          repeat
            SalesShipmentHdr."Sell-to Customer Name" := '------';
            SalesShipmentHdr."Sell-to Customer Name 2" := '------';
            SalesShipmentHdr."Sell-to Address" := '------ --';
            SalesShipmentHdr."Sell-to Address 2" := '------ --';
            SalesShipmentHdr."Sell-to City" := '';
            SalesShipmentHdr."Sell-to Contact" := '------';
            SalesShipmentHdr."Sell-to Post Code" := '';
            SalesShipmentHdr."Sell-to County" := '';
            SalesShipmentHdr."Sell-to Country/Region Code" := '';
            SalesShipmentHdr."Ship-to Post Code" := '';
            SalesShipmentHdr."Ship-to County" := '';
            SalesShipmentHdr."Ship-to Country/Region Code" := '';
            SalesShipmentHdr."Ship-to Name" := '------';
            SalesShipmentHdr."Ship-to Name 2" := '------';
            SalesShipmentHdr."Ship-to Address" := '------ --';
            SalesShipmentHdr."Ship-to Address 2" := '------ --';
            SalesShipmentHdr."Ship-to City" := '';
            SalesShipmentHdr."Ship-to Contact" := '------';
            SalesShipmentHdr."VAT Registration No." := '';
            SalesShipmentHdr."Bill-to Customer No." := '';
            SalesShipmentHdr."Bill-to Name" := '------';
            SalesShipmentHdr."Bill-to Name 2" := '------';
            SalesShipmentHdr."Bill-to Address" := '------ --';
            SalesShipmentHdr."Bill-to Address 2" := '------ --';
            SalesShipmentHdr."Bill-to City" := '';
            SalesShipmentHdr."Bill-to Contact" := '------';
            SalesShipmentHdr."Ship-to Code" := '';
            SalesShipmentHdr."Bill-to Post Code" := '';
            SalesShipmentHdr."Bill-to County" := '';
            SalesShipmentHdr."Bill-to Country/Region Code" := '';
            SalesShipmentHdr."Sell-to Post Code":= '';
            SalesShipmentHdr."Sell-to County" := '';
            SalesShipmentHdr."Sell-to Country/Region Code" := '';
            //-NPR5.53 [358656]
            //SalesShipmentHdr."Bill-to E-mail" := STRSUBSTNO ('anonymous%1@nowhere.com', VarCustNo);
            SalesShipmentHdr."Bill-to E-mail" := '------@----';
            //+NPR5.53 [358656]
            SalesShipmentHdr.Modify(true);
          until SalesShipmentHdr.Next =0;
    end;

    local procedure AnonymizeReturnReceipts(VarCustNo: Code[20])
    var
        ReturnRcptHdr: Record "Return Receipt Header";
    begin
        ReturnRcptHdr.Reset;
        ReturnRcptHdr.SetRange("Sell-to Customer No.",VarCustNo);
        if not ReturnRcptHdr.FindFirst then
          exit
        else
          repeat
            ReturnRcptHdr."Sell-to Customer Name" := '------';
            ReturnRcptHdr."Sell-to Customer Name 2" := '------';
            ReturnRcptHdr."Sell-to Address" := '------ --';
            ReturnRcptHdr."Sell-to Address 2" := '------ --';
            ReturnRcptHdr."Sell-to City" := '';
            ReturnRcptHdr."Sell-to Contact" := '------';
            ReturnRcptHdr."Sell-to Post Code" := '';
            ReturnRcptHdr."Sell-to County" := '';
            ReturnRcptHdr."Sell-to Country/Region Code" := '';
            ReturnRcptHdr."Ship-to Post Code" := '';
            ReturnRcptHdr."Ship-to County" := '';
            ReturnRcptHdr."Ship-to Country/Region Code" := '';
            ReturnRcptHdr."Ship-to Name" := '------';
            ReturnRcptHdr."Ship-to Name 2" := '------';
            ReturnRcptHdr."Ship-to Address" := '------ --';
            ReturnRcptHdr."Ship-to Address 2" := '------ --';
            ReturnRcptHdr."Ship-to City" := '';
            ReturnRcptHdr."Ship-to Contact" := '------';
            ReturnRcptHdr."VAT Registration No." := '';
            ReturnRcptHdr."Bill-to Customer No." := '';
            ReturnRcptHdr."Bill-to Name" := '------';
            ReturnRcptHdr."Bill-to Name 2" := '------';
            ReturnRcptHdr."Bill-to Address" := '------ --';
            ReturnRcptHdr."Bill-to Address 2" := '------ --';
            ReturnRcptHdr."Bill-to City" := '';
            ReturnRcptHdr."Bill-to Contact" := '------';
            ReturnRcptHdr."Ship-to Code" := '';
            ReturnRcptHdr."Bill-to Post Code" := '';
            ReturnRcptHdr."Bill-to County" := '';
            ReturnRcptHdr."Bill-to Country/Region Code" := '';
            ReturnRcptHdr."Sell-to Post Code":= '';
            ReturnRcptHdr."Sell-to County" := '';
            ReturnRcptHdr.Modify(true);
          until ReturnRcptHdr.Next =0;
    end;

    local procedure AnonymizeJobs(VarCustNo: Code[20])
    var
        Job: Record Job;
    begin
        Job.Reset;
        Job.SetRange("Bill-to Customer No.",VarCustNo);
        if not Job.FindFirst then
          exit
        else
          repeat
            Job."Bill-to Address" := '------ --';
            Job."Bill-to Address 2" := '------ --';
            Job."Bill-to City" := '';
            Job."Bill-to Contact" := '------';
            Job."Bill-to Country/Region Code" := '';
            Job."Bill-to County" := '';
            //-NPR5.53 [358656]
            //Job."Bill-to E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', VarCustNo);
            Job."Bill-to E-Mail" := '------@----';
            //+NPR5.53 [358656]
            Job."Bill-to Name" := '------';
            Job."Bill-to Name 2" := '------';
            Job."Bill-to Post Code" := '';
            //-NPR5.53 [358656]
            //Job."Organizer E-Mail" := STRSUBSTNO ('anonymous%1@nowhere.com', VarCustNo);
            Job."Organizer E-Mail" := '------@----';
            //+NPR5.53 [358656]
            Job."Person Responsible Name" := '------';
            Job."Person Responsible" := '------';
            Job.Modify(true);


          until Job.Next =0;
    end;

    local procedure PopulateCustToAnonymise()
    var
        GDPRSetup: Record "Customer GDPR SetUp";
        DateFormulaTxt: Text[250];
        VarPeriod: DateFormula;
        VarEntryNo: Integer;
        Window: Dialog;
        Customer: Record Customer;
        CLE: Record "Cust. Ledger Entry";
        CustToAnonymize: Record "Customers to Anonymize";
        ILE: Record "Item Ledger Entry";
        NoCLE: Boolean;
        NoILE: Boolean;
        VarDateToUse: Date;
        NoTrans: Boolean;
    begin
        //-NPR5.53 [358656]
        CustToAnonymize.Reset;
        CustToAnonymize.DeleteAll;


        if GDPRSetup.Get then;

        DateFormulaTxt := '-' + Format(GDPRSetup."Anonymize After");
        Evaluate(VarPeriod,DateFormulaTxt);


        VarEntryNo := 0;
        Customer.Reset;
        Customer.SetRange(Customer.Anonymized,false);
        Customer.SetFilter(Customer."Customer Posting Group",GDPRSetup."Customer Posting Group Filter");
        Customer.SetFilter(Customer."Gen. Bus. Posting Group",GDPRSetup."Gen. Bus. Posting Group Filter");
        //-NPR5.54 [358656]
        Customer.SetFilter("Last Date Modified",'<>%1',0D);
        //+NPR5.54 [358656]
        if Customer.FindSet then
          repeat
            //-NPR5.54 [358656]
            //IF (TODAY - Customer."Last Date Modified") >= (TODAY - CALCDATE(VarPeriod,TODAY)) THEN BEGIN

            NoTrans := true;

            CLE.Reset;
            CLE.SetCurrentKey("Customer No.","Posting Date","Currency Code");
            CLE.SetRange("Customer No.",Customer."No.");
            NoTrans := CLE.FindFirst;

            if NoTrans then begin
              ILE.Reset;
              ILE.SetCurrentKey("Source Type","Source No.","Item No.","Variant Code","Posting Date");
              ILE.SetRange(ILE."Source Type",ILE."Source Type"::Customer);
              ILE.SetRange(ILE."Source No.",Customer."No.");
              NoTrans := ILE.FindFirst;
            end;

            if NoTrans then begin
              if (Today - Customer."Last Date Modified") >= (Today - CalcDate(VarPeriod,Today)) then begin
                CustToAnonymize.Init;
                CustToAnonymize."Entry No" := VarEntryNo;
                CustToAnonymize."Customer No" := Customer."No.";
                CustToAnonymize."Customer Name" := Customer.Name;
                CustToAnonymize.Insert;
                VarEntryNo += 1;
              end;
            end else begin
          //-NPR5.54 [358656]
              NoCLE := false;
              NoILE := false;
              CLE.Reset;
              CLE.SetCurrentKey("Customer No.","Posting Date","Currency Code");
              CLE.SetRange("Customer No.",Customer."No.");
              CLE.SetFilter("Posting Date",'>%1',CalcDate(VarPeriod,Today));
              if not CLE.FindFirst then
                NoCLE := true;

              ILE.Reset;
              ILE.SetCurrentKey("Source Type","Source No.","Item No.","Variant Code","Posting Date");
              ILE.SetRange(ILE."Source Type",ILE."Source Type"::Customer);
              ILE.SetRange(ILE."Source No.",Customer."No.");
              ILE.SetFilter("Posting Date",'>%1',CalcDate(VarPeriod,Today));
              if not ILE.FindFirst then
                NoILE := true;


              if NoILE and NoCLE then begin
                CustToAnonymize.Init;
                CustToAnonymize."Entry No" := VarEntryNo;
                CustToAnonymize."Customer No" := Customer."No.";
                CustToAnonymize."Customer Name" := Customer.Name;
                CustToAnonymize.Insert;
                VarEntryNo += 1;
              end;
            end;
          until Customer.Next =0;
        //+NPR5.53 [358656]
    end;
}

