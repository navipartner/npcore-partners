codeunit 6014505 "Touch Screen - Functions"
{
    // VRT1.00/JDH/20150305 CASE 201022 Lookup of Variants is now based on table 5401 instead of VariaX table
    // NPR4.10/VB/20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629  CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.12/VB/20150708  CASE 213003 Fix for variant lookup under .NET client
    // NPR4.14/RMT/20150817 CASE 219385 Include "Indbetaling" in total sale info on screen
    // NPR4.14/VB/20150908  CASE 220185 Fixed text constants
    // NPR4.14/VB/20150909  CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925  CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.15/VB/20150930  CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.16/JDH/20151110 CASE 225285 Removed Color and Size references
    // NPR4.17/VB/20150104  CASE 225607 Changed references for compiling under NAV 2016
    // NPR4.18/MMV/20160122 CASE 232343 Print receipt even when no payment line is present.
    // NPR4.18/RMT/20160128 CASE 233094 test for serial numbers if applicable
    // NPR5.00/VB/20151221  CASE 229375 Limiting search box to 50 characters
    // NPR5.00/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106  CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160202 CASE 233204 Replacing Touch Customer page with touch lookup template
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.20/BR  /20160217  CASE  231481 Extended terminal integration, added parameter AuxFunctionNo to function CallTerminal
    // NPR5.20/VB  /20160304  CASE 235863 Support for more advanced lookup dialog.
    // NPR5.22/JDH /20160331  CASE 237986
    // NPR5.22/MHA /20160405  CASE 238459 Added Preemptive filter on Lookup
    // NPR5.22/BR  /20160412  CASE  231481 Added support for turning the terminal on/offline
    // NPR5.22/BR  /20160422  CASE  231481 Added support for Pepper installation
    // NPR5.23/VB  /20160505  CASE 238378 Clearing of EanBoxText after lookup.
    // NPR5.23/JDH /20160512  CASE 240916 removed reference to old Variant Solution
    // NPR5.23/MMV /20160512  CASE 240211 Send all retail journal lines when printing.
    // NPR5.23/MMV /20160519  CASE 241549 Moved manual lookup in report selection to mgt. codeunit.
    // NPR5.23/MMV /20160527  CASE 237189 Removed deprecated function - Write2Display()
    // NPR5.23/JDH /20160531  CASE 241098 Blocked variants wont be shown on the POS
    // NPR5.23/MMV /20160608  CASE 241990 Add Register No. when printing labels from POS.
    //                                    Support for Variety when attempting to print a variant item with empty variant code.
    // NPR5.23.01/BR  /20160620 CASE 244575 Optionally Use standard NAV Lookup in POS to increase performace
    // NPR5.26/MMV /20160818  CASE 248666 Added filter on TODAY in PrintLastReceipt(). Updated caption: ErrNoBon.
    // NPR5.26/MHA /20160831  CASE 250709 Restructured LookupCustomer() and SaleDebit() - SetupTempCustomerStaff() added
    // NPR5.26/BHR /20160907  CASE 248675 Display inventory on item variant lookup
    // NPR5.27/JC  /20160929  CASE 253347 Only use Item Tracking if Serial No. is created
    // NPR5.27/BHR /20161018  CASE 253261 skip filtering of dimension on Itemledger for Serialno.
    // NPR5.27/MHA /20161025  CASE 255580 Unused function deleted: CompareInsurrance()
    // NPR5.28/MMV /20161107  CASE 254575 Added function ReceiptEmailPrompt().
    // NPR5.28/TSA /20161110  CASE 248043 (Re)Added Support for Steria AUX functions SteriaAuxFunctions()
    // NPR5.28/VB  /20161122  CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.29/JDH /20161210  CASE 256289 Calling new Creditlimit CU to adapt to 2017 Zero footprint
    // NPR5.29/MMV /20161214  CASE 254575 Bugfix in ReceiptEmailPrompt()
    // NPR5.29/AP  /20170119  CASE 257938 Fixing dimension issues. Dimension Set not propagated correctly from header to line and with proper priority.
    // NPR5.31/MHA /20170110  CASE 262904 Deleted unused functions: HasDiscounts(),HasQuantityDiscount(),HasMixDiscount(),HasCampaign() and renamed Mixex Discount variables to English
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.31/MMV /20170313  CASE 268865 Bugfix in ReceiptEmailPrompt()
    // NPR5.33/MHA /20170614  CASE 275728 Added Publisher function OnBeforeRegisterOpen() and cleaned up function RegisterOpen()
    // NPR5.35/JC  /20170727  CASE 278757 Created function PrintWarrantyCertificate() to print warranty from POS
    // NPR5.35/BR  /20170815  CASE 284379 Added support for Cashback
    // NPR5.36/TJ  /20170907  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.36/JC  /20170908  CASE 286989 Revalidate qty on sales line after setting customer with regards to discount in saledebit()
    // NPR5.36/TJ  /20170920  CASE 241650 Applied hotfix from MarianneDulong to BalanceRegisterEntries
    // NPR5.37/MMV /20171024  CASE 294353 Fixed wrong use of report selection, added in NPR5.35.
    // NPR5.38/BR  /20180118  CASE 302761 Added functionality to skip Audit Roll creation if "Create POS Entries Only"
    // NPR5.40/TS  /20180308  CASE 307432 Removed reference to MSP Dankort
    // NPR5.40/JDH /20180320  CASE 308647 Deleted a lot of functions that wasnt used any more
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.45/MHA /20180821 CASE 324395 SaleLinePOS."Unit Price (LCY)" Renamed to "Unit Cost (LCY)"
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring

    Permissions = TableData "Audit Roll"=rimd;

    trigger OnRun()
    begin
        //MakeBeep;
    end;

    var
        RetailSetupGlobal: Record "Retail Setup";
        RetailSalesCode: Codeunit "Retail Sales Code";
        RetailContractMgt: Codeunit "Retail Contract Mgt.";
        RetailFormCodeGlobal: Codeunit "Retail Form Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Utility: Codeunit Utility;
        Text001: Label 'Error';
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        LastInteger: Integer;
        Text002: Label 'Superuser password';
        Txt_SendReceiptEmail: Label 'Send receipt as e-mail?';
        Txt_InvalidEmail: Label '%1 has an invalid/missing e-mail. Please change/add.';
        Txt_CustomerEmail: Label 'Customer E-mail Address:';
        Err_MissingCustomer: Label 'No customer is attached to sale. Please add one if you want to send e-mail receipt.';

    procedure AskRefAtt(var SalePOS: Record "Sale POS";ForceContactNo: Boolean): Boolean
    var
        ReferenceTxt: Label 'Ext. Document No.';
        AttentionTxt: Label 'Attention:';
        Txt001: Label 'The reference number of the customers quote, order etc.';
        Txt002: Label 'The name on the customer collecting the goods.';
    begin
        //askRefAtt
        RetailSetupGlobal.Get;
        
        if (SalePOS."Customer No." = '') and ForceContactNo then begin
          SalePOS.Reference := '';
          SalePOS."Contact No." := '';
          SalePOS.Modify(true);
          exit(false);
        end;
        
        /* Because of a modify on the table Sale code*/
        Commit;
        
        if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and ForceContactNo then begin
          if RetailSetupGlobal."Ask for Reference" then begin
            SalePOS.Reference := CopyStr(POSEventMarshaller.SearchBox(ReferenceTxt,Txt001,50),1,20);
          end;
          if RetailSetupGlobal."Ask for Attention Name" then begin
            SalePOS."Contact No." := CopyStr(POSEventMarshaller.SearchBox(AttentionTxt,Txt002,50),1,30);
          end;
        end;
        
        if not ForceContactNo then begin
          SalePOS.Reference := CopyStr(POSEventMarshaller.SearchBox(ReferenceTxt,Txt001,50),1,30);
          SalePOS."Contact No." := CopyStr(POSEventMarshaller.SearchBox(AttentionTxt,Txt002,50),1,30);
          SalePOS.Modify;
        end;
        
        exit(true);

    end;

    procedure BalanceRegisterEntries(var SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS"): Text[250]
    var
        RetailSalesLineCode2: Codeunit "Retail Sales Line Code";
    begin
        //udlignDebitorposter()
        SalePOS.TestField("Salesperson Code");
        //-NPR5.36 [241650]
        // SaleLinePOS.TESTFIELD("Sale Type",SaleLinePOS."Sale Type"::Deposit);
        // SaleLinePOS.TESTFIELD(Type,SaleLinePOS.Type::Customer);
        // SaleLinePOS.VALIDATE("Buffer ID",SaleLinePOS."Register No." + '-' + SaleLinePOS."Sales Ticket No.");
        if RetailSalesLineCode2.LineExists(SalePOS) then begin
          SaleLinePOS.TestField("Sale Type",SaleLinePOS."Sale Type"::Deposit);
          SaleLinePOS.TestField(Type,SaleLinePOS.Type::Customer);
        end else begin
          SaleLinePOS.Init;
          SaleLinePOS."Register No." := SalePOS."Register No.";
          SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS.Date := WorkDate;
          SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
          SaleLinePOS.Type := SaleLinePOS.Type::Customer;
          SaleLinePOS."No." := SalePOS."Customer No.";
          SaleLinePOS."Line No." := 10000;
          SaleLinePOS.Insert(true);
        end;
        SaleLinePOS.Validate("Buffer ID",SaleLinePOS."Register No." + '-' + SaleLinePOS."Sales Ticket No.");
        //+NPR5.36 [241650]
        CODEUNIT.Run(CODEUNIT::"POS Apply Customer Entries",SaleLinePOS);
    end;

    procedure BalanceInvoice(var SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS";InvoiceIn: Code[20]) InvoiceNo: Code[20]
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        InputInvoice: Label 'Enter Invoice Number';
        SaleLinePOSCheck: Record "Sale Line POS";
        "Field": Record "Field";
        LineAmount: Decimal;
        ConfimBalance: Label 'Do you wish to apply %1 %2 for customer %3?';
        ErrDoubleEntry: Label 'Error. Document %1 %2 is alleredy selected for balancing.';
        ErrAllreadyBalanced: Label 'Error. Document %1 %2 is already balanced.';
        ErrCurrency: Label 'Error. Currency code %1 cannot be settled in this way';
        TextBalance: Label 'Balancing of %1';
    begin
        if SalePOS."Customer No." <> '' then
          CustLedgerEntry.SetRange("Customer No.",SalePOS."Customer No.");

        Commit;

        if InvoiceIn = '' then begin
          if not POSEventMarshaller.NumPadCode(InputInvoice,InvoiceNo,false,false) then
            exit('');
        end else
          InvoiceNo := InvoiceIn;

        if InvoiceNo in ['','<CANCEL>'] then
          exit('');

        CustLedgerEntry.SetRange("Document Type",CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.",InvoiceNo);
        CustLedgerEntry.SetRange(Open,true);
        InvoiceNo := '';
        if not CustLedgerEntry.FindFirst then begin
          Message(ErrAllreadyBalanced,
                  CustLedgerEntry.GetFilter("Document Type"),
                  CustLedgerEntry.GetFilter("Document No."));
          exit('');
        end;

        if Customer.Get(CustLedgerEntry."Customer No.") then;

        SaleLinePOSCheck.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOSCheck.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOSCheck.SetRange("Buffer Document Type",CustLedgerEntry."Document Type");
        SaleLinePOSCheck.SetRange("Buffer Document No.",CustLedgerEntry."Document No.");
        if SaleLinePOSCheck.FindFirst then begin
          Message(ErrDoubleEntry,CustLedgerEntry."Document Type",CustLedgerEntry."Document No.");
          exit('');
        end;

        if not Confirm(StrSubstNo(ConfimBalance,CustLedgerEntry."Document Type",CustLedgerEntry."Document No.",Customer.Name),true) then
          exit('');

        InvoiceNo := CustLedgerEntry."Document No.";

        SalePOS.Validate("Customer No.",CustLedgerEntry."Customer No.");

        if not (CustLedgerEntry."Currency Code" in ['','DKK']) then
          Error(ErrCurrency,CustLedgerEntry."Currency Code");

        Field.Get(21,14); // Debpost.restbel�b
        if Field.Class = Field.Class::FlowField then
          CustLedgerEntry.CalcFields("Remaining Amount");

        if (SaleLinePOS.Type = SaleLinePOS.Type::Customer) and
           (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Deposit) and
             (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
               (SaleLinePOS.Date <= CustLedgerEntry."Pmt. Discount Date") then
                LineAmount := (CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Original Pmt. Disc. Possible")
        else
          LineAmount := CustLedgerEntry."Remaining Amount";

        SaleLinePOS."Buffer Document Type" := CustLedgerEntry."Document Type";
        SaleLinePOS."Buffer Document No." := CustLedgerEntry."Document No.";
        SaleLinePOS.Validate(Quantity,1);
        SaleLinePOS.Validate("Unit Price",LineAmount);
        SaleLinePOS.Description := StrSubstNo(TextBalance,CustLedgerEntry.Description);
        SaleLinePOS.Modify;
    end;

    procedure BufferInit(var NPRTempBuffer: Record "NPR - TEMP Buffer";var TemplateCode: Code[50];var i: Integer;DescriptionFieldNo: Integer;Description: Text[250];Bold: Boolean;Color: Integer;Sel: Boolean;Indent: Integer)
    begin
        //bufferInit
        if i <= LastInteger then
          NPRTempBuffer.Get(TemplateCode,i)
        else begin
          NPRTempBuffer.Init;
          NPRTempBuffer.Template := TemplateCode;
          NPRTempBuffer."Line No." := i;
          NPRTempBuffer.Insert;
          LastInteger := i;
        end;

        case DescriptionFieldNo of
          1:
            begin
              NPRTempBuffer.Description := Description;
              NPRTempBuffer.Bold := Bold;
              NPRTempBuffer.Color := Color;
              NPRTempBuffer.Sel := Sel;
              NPRTempBuffer.Indent := Indent;
            end;
          2:
            begin
              NPRTempBuffer."Description 2" := Description;
              NPRTempBuffer."Bold 2" := Bold;
              NPRTempBuffer."Color 2" := Color;
              NPRTempBuffer."Sel 2" := Sel;
              NPRTempBuffer."Indent 2" := Indent;
            end;
          3:
            begin
              NPRTempBuffer."Description 3" := Description;
              NPRTempBuffer."Bold 3" := Bold;
              NPRTempBuffer."Color 3" := Color;
              NPRTempBuffer."Sel 3" := Sel;
              NPRTempBuffer."Indent 3" := Indent;
            end;
          4:
            begin
              NPRTempBuffer."Description 4" := Description;
              NPRTempBuffer."Bold 4" := Bold;
              NPRTempBuffer."Color 4" := Color;
              NPRTempBuffer."Sel 4" := Sel;
              NPRTempBuffer."Indent 4" := Indent;
            end;
          5:
            begin
              NPRTempBuffer."Description 5" := Description;
              NPRTempBuffer."Bold 5" := Bold;
              NPRTempBuffer."Color 5" := Color;
              NPRTempBuffer."Sel 5" := Sel;
              NPRTempBuffer."Indent 5" := Indent;
            end;
        end;

        NPRTempBuffer.Modify;
    end;

    procedure CalcPaymentRounding(RegisterNo: Code[10]) RoundingPrecision: Decimal
    var
        Register: Record Register;
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //beregnAfrunding
        Register.Get(RegisterNo);
        PaymentTypePOS.Get(Register."Primary Payment Type");
        RoundingPrecision := Round(PaymentTypePOS."Rounding Precision" / 2,0.001,'=');
    end;

    procedure CallTerminal(var SalePOS: Record "Sale POS";CallFunction: Code[20];AuxFunctionNo: Integer): Boolean
    var
        Txt001: Label 'The function %1 is not defined for the %2 terminal.';
        Register: Record Register;
        PepperProtocol: Codeunit "Pepper Protocol";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
        Txt002: Label 'Terminal succesfully opened.';
        Txt003: Label 'Terminal failed to open.';
        Txt004: Label 'Terminal succesfully closed.';
        Txt005: Label 'Terminal failed to close.';
        CCTrans: Record "Credit Card Transaction";
        Txt007: Label 'Terminal auxiliary function failed. ';
        Txt010: Label 'Terminal set to offline mode.';
        Txt011: Label 'Terminal could not be set to offline mode. ';
        Txt012: Label 'Terminal set to online mode.';
        Txt013: Label 'Terminal could not be set to online mode.';
        Txt014: Label 'Terminal succesfully installed.';
        Txt015: Label 'Terminal not installed.';
    begin
        //CallTerminal
        Register.Get(SalePOS."Register No.");

        case Register."Credit Card Solution" of
          //-NPR5.28 [248043]
          Register."Credit Card Solution"::Steria:
            begin
              case CallFunction of
                'ENDOFDAY':
                  SteriaAuxFunctions(9003,SalePOS,SaleLinePOS);
                'AUX':
                  SteriaAuxFunctions(AuxFunctionNo,SalePOS,SaleLinePOS);
              end;
            end;
          //+NPR5.28 [248043]

          //-NPR5.20
          Register."Credit Card Solution"::Pepper:
            begin
              case CallFunction of
                'OPENSHIFT':
                  begin
                    SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindLast then;
                    LineNo := SaleLinePOS."Line No.";

                    LineNo += 10000;
                    SaleLinePOS.Init;
                    SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
                    SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    SaleLinePOS.Validate("Line No.",LineNo);
                    SaleLinePOS.Validate(Date,Today);
                    SaleLinePOS.Validate(Type,SaleLinePOS.Type::"Open/Close");
                    SaleLinePOS.Validate("No.",'');
                    SaleLinePOS.Validate(Quantity,-0);
                    SaleLinePOS.Validate("Unit Price",0);
                    SaleLinePOS.Validate("Variant Code",'');

                      //SaleLinePOS.INSERT(TRUE);
                    PepperProtocol.InitializeProtocol;
                    //-NPR5.35 [284379]
                    //IF NOT PepperProtocol.Init(0,SaleLinePOS,0,0,FALSE) THEN
                    if not PepperProtocol.Init(0,0,SaleLinePOS,0,0,false) then
                    //+NPR5.35 [284379]
                      POSEventMarshaller.DisplayError(Text001,PepperProtocol.GetInitErrorText,true);
                    PepperProtocol.SetTransaction(1);
                    if PepperProtocol.SendTransaction then begin
                      CCTrans.Reset;
                      CCTrans.FilterGroup := 2;
                      CCTrans.SetCurrentKey("Register No.","Sales Ticket No.",Type);
                      CCTrans.SetRange("Register No.",SaleLinePOS."Register No.");
                      CCTrans.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
                      CCTrans.SetRange(Type,0);
                      CCTrans.SetRange("No. Printed",0);
                      CCTrans.FilterGroup := 0;
                      if (not Register."Terminal Auto Print") and (not CCTrans.IsEmpty) then
        //-NPR5.46 [290734]
                        CCTrans.PrintTerminalReceipt();
        //                CCTrans.PrintTerminalReceipt(FALSE);
        //+NPR5.46 [290734]
                      Message(Txt002)
                    end else
                      POSEventMarshaller.DisplayError(Text001,Txt003,true);
                   end;
                'ENDOFDAY':
                  begin
                    RetailSetupGlobal.Get;
                    RetailSetupGlobal.CheckOnline;
                    if SalePOS.TouchScreen then begin
                    end else begin
                      Error('Only touch support');
                    end;

                    SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindLast then;
                    LineNo := SaleLinePOS."Line No.";

                    LineNo += 10000;
                    SaleLinePOS.Init;
                    SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
                    SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    SaleLinePOS.Validate("Line No.",LineNo);
                    SaleLinePOS.Validate(Date,Today);
                    SaleLinePOS.Validate(Type,SaleLinePOS.Type::"Open/Close");
                    SaleLinePOS.Validate("No.",'');
                    SaleLinePOS.Validate(Quantity,-0);
                    SaleLinePOS.Validate("Unit Price",0);
                    SaleLinePOS.Validate("Variant Code",'');
                    //SaleLinePOS.INSERT(TRUE);
                    PepperProtocol.InitializeProtocol;
                    //-NPR5.35 [284379]
                    //IF NOT PepperProtocol.Init(0,SaleLinePOS,0,0,FALSE) THEN
                    if not PepperProtocol.Init(0,0,SaleLinePOS,0,0,false) then
                    //+NPR5.35 [284379]
                      POSEventMarshaller.DisplayError(Text001,PepperProtocol.GetInitErrorText,true);
                    PepperProtocol.SetTransaction(3);
                    if PepperProtocol.SendTransaction then begin
                      CCTrans.Reset;
                      CCTrans.FilterGroup := 2;
                      CCTrans.SetCurrentKey("Register No.","Sales Ticket No.",Type);
                      CCTrans.SetRange("Register No.",SaleLinePOS."Register No.");
                      CCTrans.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
                      CCTrans.SetRange(Type,0);
                      CCTrans.SetRange("No. Printed",0);
                      CCTrans.FilterGroup := 0;
                      if (not Register."Terminal Auto Print") and (not CCTrans.IsEmpty) then
        //-NPR5.46 [290734]
                        CCTrans.PrintTerminalReceipt();
        //                CCTrans.PrintTerminalReceipt(FALSE);
        //+NPR5.46 [290734]
                      Message(Txt004)
                    end else
                      POSEventMarshaller.DisplayError(Text001,Txt005,true);
                  end;
                'AUX':
                  begin
                    RetailSetupGlobal.Get;
                    RetailSetupGlobal.CheckOnline;
                    if SalePOS.TouchScreen then begin
                    end else begin
                      Error('Only touch support');
                    end;

                    SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindLast then;
                    LineNo := SaleLinePOS."Line No.";

                    LineNo += 10000;
                    SaleLinePOS.Init;
                    SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
                    SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    SaleLinePOS.Validate("Line No.",LineNo);
                    SaleLinePOS.Validate(Date,Today);
                    SaleLinePOS.Validate(Type,SaleLinePOS.Type::"Open/Close");
                    SaleLinePOS.Validate("No.",'');
                    SaleLinePOS.Validate(Quantity,-0);
                    SaleLinePOS.Validate("Unit Price",0);
                    SaleLinePOS.Validate("Variant Code",'');
                    //SaleLinePOS.INSERT(TRUE);
                    PepperProtocol.InitializeProtocol;
                    //-NPR5.35 [284379]
                    //IF NOT PepperProtocol.Init(0,SaleLinePOS,0,0,FALSE) THEN
                    if not PepperProtocol.Init(5,0,SaleLinePOS,0,0,false) then
                    //+NPR5.35 [284379]
                      POSEventMarshaller.DisplayError(Text001,PepperProtocol.GetInitErrorText,true);
                    PepperProtocol.SetAuxFunctionNo(AuxFunctionNo);
                    PepperProtocol.SetTransaction(5);
                    if PepperProtocol.SendTransaction then begin
                      CCTrans.Reset;
                      CCTrans.FilterGroup := 2;
                      CCTrans.SetCurrentKey("Register No.","Sales Ticket No.",Type);
                      CCTrans.SetRange("Register No.",SaleLinePOS."Register No.");
                      CCTrans.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
                      CCTrans.SetRange(Type,0);
                      CCTrans.SetRange("No. Printed",0);
                      CCTrans.FilterGroup := 0;
                      if (not Register."Terminal Auto Print") and (not CCTrans.IsEmpty) then
        //-NPR5.46 [290734]
                        CCTrans.PrintTerminalReceipt();
        //                CCTrans.PrintTerminalReceipt(FALSE);
        //+NPR5.46 [290734]
                    end else
                      POSEventMarshaller.DisplayError(Text001,Txt007,true);
                  end;
                'UNLOCK':
                  begin
                  end;
                  //-NPR5.22
                'SETOFFLINE':
                  begin
                    SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindLast then;
                    LineNo := SaleLinePOS."Line No.";

                    LineNo += 10000;
                    SaleLinePOS.Init;
                    SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
                    SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
                    SaleLinePOS.Validate("Line No.",LineNo);
                    SaleLinePOS.Validate(Date,Today);
                    SaleLinePOS.Validate(Type,SaleLinePOS.Type::"Open/Close");
                    SaleLinePOS.Validate("No.",'');
                    SaleLinePOS.Validate(Quantity,-0);
                    SaleLinePOS.Validate("Unit Price",0);
                    SaleLinePOS.Validate("Variant Code",'');
                    PepperProtocol.InitializeProtocol;
                    //-NPR5.35 [284379]
                    //IF NOT PepperProtocol.Init(0,SaleLinePOS,0,0,FALSE) THEN
                    if not PepperProtocol.Init(5,0,SaleLinePOS,0,0,false) then
                    //+NPR5.35 [284379]
                      POSEventMarshaller.DisplayError(Text001,PepperProtocol.GetInitErrorText,true);
                    case AuxFunctionNo of
                      0: //Offline
                        begin
                          if PepperProtocol.SetTerminalOfflineStatus(0) then
                            Message(Txt010)
                          else
                            Message(Txt011);
                        end;
                      1: //Offline
                        begin
                          if PepperProtocol.SetTerminalOfflineStatus(1) then
                            Message(Txt012)
                          else
                            Message(Txt013);
                        end;
                    end;
                  end;
                'INSTALL':
                  begin
                    if PepperProtocol.InstallTerminal(SalePOS."Register No.") then
                      Message(Txt014)
                    else
                      Message(Txt015);
                  end;

                  //+NPR5.22
                else
                  Error(Txt001,Register."Credit Card Solution",CallFunction);
              end;
            end;
          //+NPR5.20
          Register."Credit Card Solution"::POINT:
            begin
              case CallFunction of
        //         'ENDOFDAY' : "MSP Flexi Dankort Dialog".endofdayPoint;
        //         'UNLOCK'   : "MSP Flexi Dankort Dialog".unlockPoint;
                else
                  Error(Txt001,Register."Credit Card Solution",CallFunction);
              end;
            end;
          else
            Error(Txt001,Register."Credit Card Solution",CallFunction);
        end;
    end;

    local procedure SteriaAuxFunctions(NprAuxFunctionID: Integer;SalePOS: Record "Sale POS";var SaleLinePos: Record "Sale Line POS")
    var
        LineNo: Integer;
        CCTrans: Record "Credit Card Transaction";
        CreditCardProtocol: Codeunit "Credit Card Protocol C-sharp";
        Register: Record Register;
        SteriaAuxFunctionID: Integer;
        ProxyDialog: Page "Proxy Dialog";
        SelectedAuxFunction: Integer;
        SteriaAuxMenu: Label 'End,X-Report,Z-Report,Start Reconsiliation,Send Offline Transactions,Balance Inquiry,Print Stored Reports,Print Previous Reconciliation ';
    begin
        //-NPR5.28 [248043]
        Register.Get(SalePOS."Register No.");

        if not SalePOS.TouchScreen then
          Error('Only touch support');

        if (NprAuxFunctionID = 0) then begin
          // End,X-Report,Z-Report,Start Reconsiliation,Send Offline Transactions,Balance Inquiry,Print Stored Reports
          SelectedAuxFunction := StrMenu(SteriaAuxMenu,1);
          case SelectedAuxFunction of
            0:
              exit;
            1:
              exit;
            2:
              NprAuxFunctionID := 9001;
            3:
              NprAuxFunctionID := 9002;
            4:
              NprAuxFunctionID := 9003;
            5:
              NprAuxFunctionID := 9010;
            6:
              NprAuxFunctionID := 9100;
            7:
              NprAuxFunctionID := 9200;
            8:
              NprAuxFunctionID := 9201;
          end;
        end;

        case NprAuxFunctionID of
          9001:
            SteriaAuxFunctionID := 3136; // X-Report
          9002:
            SteriaAuxFunctionID := 3137; // Z-Report
          9003:
            SteriaAuxFunctionID := 3130; // Start reconsiliation
          9010:
            SteriaAuxFunctionID := 3138; // Send offline transactions to host
          9100:
            SteriaAuxFunctionID := 3135; // Start balance inquiry for a card
          9200:
            SteriaAuxFunctionID := 3030; // Print Stored Reports
          9201:
            SteriaAuxFunctionID := 3032; // Start copy of last reconciliation
          6:
            SteriaAuxFunctionID := 3139; // Print turnover report
          5:
            SteriaAuxFunctionID := 3830; // Start copy of last receipt
          7:
            SteriaAuxFunctionID := 3031; // Test communication to host
          else
            SteriaAuxFunctionID := 0;
        end;


        SaleLinePos.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePos.FindLast then;
        LineNo := SaleLinePos."Line No.";
        LineNo += 10000;

        SaleLinePos.Init;
        SaleLinePos.Validate("Register No.",SalePOS."Register No.");
        SaleLinePos.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePos.Validate("Line No.",LineNo);
        SaleLinePos.Validate(Date,Today);
        SaleLinePos.Validate(Type,SaleLinePos.Type::"Open/Close");
        SaleLinePos.Validate("No.",'');
        SaleLinePos.Validate(Quantity,-0);
        SaleLinePos.Validate("Unit Price",0);
        SaleLinePos.Validate("Variant Code",'');
        //SaleLinePOS.INSERT(TRUE);
        Commit;

        CreditCardProtocol.InitializeProtocol();
        if not (CreditCardProtocol.SetAuxFunction(Register."Credit Card Solution"::Steria,SteriaAuxFunctionID,SaleLinePos)) then
          POSEventMarshaller.DisplayError(Text001,'Function not supported.',true);
        CreditCardProtocol.InitSteriaSupport();

        Commit;
        ProxyDialog.RunProtocolModal(CODEUNIT::"Credit Card Protocol C-sharp");

        CCTrans.Reset;
        CCTrans.FilterGroup := 2;
        CCTrans.SetCurrentKey("Register No.","Sales Ticket No.",Type);
        CCTrans.SetRange("Register No.",SaleLinePos."Register No.");
        CCTrans.SetRange("Sales Ticket No.",SaleLinePos."Sales Ticket No.");
        CCTrans.SetRange(Type,0);
        CCTrans.SetRange("No. Printed",0);
        CCTrans.FilterGroup := 0;
        if (not Register."Terminal Auto Print") and (not CCTrans.IsEmpty) then
        //-NPR5.46 [290734]
          CCTrans.PrintTerminalReceipt();
        //  CCTrans.PrintTerminalReceipt(FALSE);
        //+NPR5.46 [290734]
        //+NPR5.28 [248043]
    end;

    procedure CheckLine(var SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        Txt001: Label 'It is not allowed to give special discount on this line. This line discount is controlled by the system!\ \(Discount type: %1 %2)';
        Txt002: Label 'Not allowed';
    begin
        //checkLine
        if SaleLinePOS."Custom Disc Blocked" then begin
           POSEventMarshaller.DisplayError(Txt002,StrSubstNo(Txt001,SaleLinePOS."Discount Type",SaleLinePOS."Discount Code"),true);
        end;

        exit(true);
    end;

    procedure CheckVariax(SaleLinePOS: Record "Sale Line POS")
    var
        ItemVariant: Record "Item Variant";
        ErrItemVariant: Label 'A line with item no. %1 must have a variant code';
        ErrItemVariantHeader: Label 'Variation code missing';
    begin
        if SaleLinePOS."Variant Code" = '' then begin
          ItemVariant.SetRange("Item No.",SaleLinePOS."No.");
          if ItemVariant.Find('-') then
            POSEventMarshaller.DisplayError(ErrItemVariantHeader,StrSubstNo(ErrItemVariant,SaleLinePOS."No."),true);
        end;
    end;

    procedure DeleteCustomerLine(var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Customer No. Line",true);
        SaleLinePOS.DeleteAll(true);
    end;

    procedure DiscountBlockLine(var SaleLinePOS: Record "Sale Line POS")
    var
        Password: Text;
    begin
        if SaleLinePOS."Custom Disc Blocked" then begin
          RetailSetupGlobal.Get;
          if RetailSetupGlobal."Password on unblock discount" <> '' then
            if (not POSEventMarshaller.NumPadText(Text002,Password,true,false)) or (RetailSetupGlobal."Password on unblock discount" <> Password) then
              exit;
          SaleLinePOS."Custom Disc Blocked" := false;
        end else
          SaleLinePOS."Custom Disc Blocked" := true;

        SaleLinePOS.Modify;
    end;

    procedure DiscountCR(var SalesLinePOS: Record "Sale Line POS"): Decimal
    var
        DG2: Decimal;
        Txt002: Label 'Contribution ratio %';
        n: Integer;
        ReasonCode: Code[10];
    begin
        ReasonCode := RetailSalesLineCode.AskReasonCode;
        n := 0;

        if SalesLinePOS.Amount <> 0 then
          DG2 := (SalesLinePOS.Amount - SalesLinePOS.Cost) * 100 / SalesLinePOS.Amount
        else
          DG2 := 0;

        if not POSEventMarshaller.NumPad(Txt002 + '\' + SalesLinePOS.Description,DG2,false,false) then
          exit;

        if SalesLinePOS.Cost <> SalesLinePOS.Amount then begin
          SalesLinePOS.Validate("Discount Type",SalesLinePOS."Discount Type"::Manual);
          SalesLinePOS.Validate("Discount Code",ReasonCode);
          SalesLinePOS.Validate(Amount,SalesLinePOS.Cost / ( 1 - DG2 / 100 ));
          SalesLinePOS.Modify;
        end;

        exit(SalesLinePOS.Cost / ( 1 - DG2 / 100));
    end;

    procedure GetPaymentType(var PaymentTypePOS: Record "Payment Type POS";var Register: Record Register;PaymentCode: Code[10]): Boolean
    begin
        //GetPaymentType
        PaymentTypePOS.Reset;
        PaymentTypePOS.SetRange("No.",PaymentCode);
        PaymentTypePOS.SetRange("Register No.",Register."Register No.");
        if PaymentTypePOS.Find('-') then
          exit(true);

        PaymentTypePOS.SetRange("Register No.");
        if PaymentTypePOS.Find('-') then
          exit(true);

        exit(false);
    end;

    procedure GetSalesStats(var SalePOS: Record "Sale POS";var HeadingText: Text[250];var NPRTempBuffer: Record "NPR - TEMP Buffer")
    var
        Txt001: Label 'Sales statistics';
        SalePOSStatistics: Page "Sale POS - Statistics";
    begin
        //hentVisEkspStat()
        HeadingText := Txt001;
        SalePOSStatistics.SetRecord(SalePOS);
        SalePOSStatistics.OnInit(0);
        SalePOSStatistics.GetSaleLineStat(NPRTempBuffer);
    end;

    procedure GetSalespersonCode(var SalePOS: Record "Sale POS";Register: Record Register;var RegisterPassword: Code[20]): Boolean
    var
        Txt004: Label 'You have typed an invalid salesperson code!';
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Txt005: Label 'Login Error';
        ErrLockedByOtherHeader: Label 'Login Error';
        ErrLockedByOtherSalesperson: Label 'Error. The register is locked to another user.';
    begin
        //Hents�lgerkode()
        SalespersonPurchaser.SetRange("Register Password",RegisterPassword);
        if SalespersonPurchaser.Find('-') then begin
          if Register."Lock Register To Salesperson" and
            (Register.Status = Register.Status::Ekspedition) and
            (SalespersonPurchaser.Code <> Register."Opened By Salesperson") then begin
            POSEventMarshaller.DisplayError(ErrLockedByOtherHeader,ErrLockedByOtherSalesperson,false);
            exit(false);
          end;
          //-NPR5.29 [257938]
          //Sale."Salesperson Code" := "S�lger/Indk�ber".Code;
          SalePOS.Validate("Salesperson Code",SalespersonPurchaser.Code);
          //+NPR5.29 [257938]
          RegisterPassword := '';
          TestSalesDate;
          SalePOS."Start Time" := Time;
          SalePOS.Date := Today;
          SalePOS."Location Code" := Register."Location Code";
          //Sale."Department Code" := Kasse."Shortcut Dimension 1 Code";
          //-NPR5.29 [257938]
          //  Sale."Shortcut Dimension 1 Code" := Kasse."Global Dimension 1 Code";
          //  Sale."Shortcut Dimension 2 Code" := Kasse."Global Dimension 2 Code";
          //+NPR5.29 [257938]
          if not SalePOS.Insert then
            SalePOS.Modify;
          exit(true);
        end else begin
          RegisterPassword := '';
          POSEventMarshaller.DisplayError(Txt005,Txt004,false);
          exit(false);
        end;
    end;

    procedure GetTurnoverStats(var SalePOS: Record "Sale POS";var HeadingText: Text[250];var NPRTempBuffer: Record "NPR - TEMP Buffer")
    var
        Txt001: Label 'Turnover statistics';
        TurnoverStatistics: Page "Turnover Statistics";
    begin
        //hentVisOmsStat
        Clear(TurnoverStatistics);
        Clear(NPRTempBuffer);
        //formOmsStat.SETRECORD(Eksp);              s
        TurnoverStatistics.Init;
        TurnoverStatistics.GetTurnoverStat(NPRTempBuffer);
        HeadingText := Txt001;
    end;

    procedure ImportSalesTicket(var SalePOS: Record "Sale POS";var ValidationCode: Code[50])
    var
        Text001: Label 'Type in the receipt number to be imported';
        Text002: Label 'MATCH';
        Text003: Label 'Type receipt no. first!';
        Text004: Label 'Receipt No.';
        Text005: Label 'not found!';
        AuditRoll: Record "Audit Roll";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
    begin
        if ValidationCode = '' then
          if not POSEventMarshaller.NumPadCode(Text001,ValidationCode,true,false) then begin
            ValidationCode := '';
            Error('');
          end;
        if ValidationCode = '' then begin
          POSEventMarshaller.DisplayError(Text002,Text003,true);
        end;

        AuditRoll.Reset;
        AuditRoll.SetRange("Sales Ticket No.",ValidationCode);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);
        AuditRoll.SetFilter(Quantity,'>%1',0);
        if not AuditRoll.FindSet then begin
          ValidationCode := '';
          POSEventMarshaller.DisplayError(Text002,Text004 + ' ' + ValidationCode + ' ' + Text005,true);
        end;

        SalePOS."Retursalg Bonnummer" := ValidationCode;
        SalePOS.Modify;
        Commit;
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then;
        LineNo := SaleLinePOS."Line No.";

        repeat
          LineNo += 10000;
          SaleLinePOS.Init;
          SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
          SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
          SaleLinePOS.Validate("Line No.",LineNo);
          SaleLinePOS.Validate(Date,Today);
          SaleLinePOS.Validate(Type,AuditRoll.Type);
          SaleLinePOS.Validate("No.",AuditRoll."No.");
          SaleLinePOS.Validate(Quantity,-AuditRoll.Quantity);
          SaleLinePOS.Validate("Unit Price",AuditRoll."Unit Price");
          SaleLinePOS.Validate("Variant Code",AuditRoll."Variant Code");
          if AuditRoll."Line Discount %" <> 0 then
            SaleLinePOS.Validate("Discount %",AuditRoll."Line Discount %");
          if AuditRoll."Line Discount Amount" <> 0 then
            SaleLinePOS.Validate("Discount Amount",AuditRoll."Line Discount Amount");
          SaleLinePOS.Insert(true);
        until AuditRoll.Next = 0;

        ValidationCode := '';
    end;

    procedure InfoItem(var SaleLinePOS: Record "Sale Line POS";var HeadingText: Text[250];var NPRTempBuffer: Record "NPR - TEMP Buffer")
    var
        Register: Record Register;
        Item: Record Item;
        SaleLinePOS2: Record "Sale Line POS";
        QuantityDiscountLine: Record "Quantity Discount Line";
        Txt003: Label 'Discounts';
        Txt004: Label 'of';
        Txt005: Label '=';
        Txt006: Label 'Mix discount';
        Txt007: Label 'Campaign discount';
        PeriodDiscountLine: Record "Period Discount Line";
        MixedDiscount: Record "Mixed Discount";
        MixedDiscountLine: Record "Mixed Discount Line";
        MixedDiscountLine2: Record "Mixed Discount Line";
        Item2: Record Item;
        i: Integer;
        ItemGroup: Record "Item Group";
        PeriodDiscount: Record "Period Discount";
        Txt013: Label 'General information';
        Txt017: Label 'Comments';
        CommentLine: Record "Comment Line";
        Txt018: Label 'Quantity discount';
        j: Integer;
        Txt019: Label '<No comments>';
        TemplateCode: Code[50];
        QuantityDiscountHeader: Record "Quantity Discount Header";
        Vendor: Record Vendor;
    begin
        //info_Item
        Clear(HeadingText);
        Item.Get(SaleLinePOS."No.");
        LastInteger := 0;
        
        /*-------------------------------------------- ITEM GENERAL ---------------------------------------------*/
        i := 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt013,true,0,true,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("No."),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Item."No.",false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption(Description),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Item.Description,false,0,false,0);
        
        //-NPR5.23 [240916]
        // IF EkspLine."Variant Code" <> '' THEN BEGIN
        //  IF "VariaX Variant Info".GET(EkspLine."Variant Code") THEN;
        //  BufferInit( Buffer, code50, i, 3, "VariaX Variant Info"."Dimension Values Description", FALSE, 0, FALSE, 0);
        // END;
        //+NPR5.23 [240916]
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Vendor No."),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Item."Vendor No.",false,0,false,0);
        
        if Vendor.Get(Item."Vendor No.") then
        BufferInit(NPRTempBuffer,TemplateCode,i,3,Vendor.Name,false,0,false,0);
        
        i += 1;
        if ItemGroup.Get(Item."Item Group") then;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Item Group"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Item."Item Group" + ' (' + ItemGroup.Description + ')',false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Price Includes VAT"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(Item."Price Includes VAT"),false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Unit Price"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Item."Unit Price",2),false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Unit List Price"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Item."Unit List Price",2),false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Unit Cost"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Item."Unit Cost",2),false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Last Direct Cost"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Item."Last Direct Cost",2),false,0,false,0);
        
        i += 1;
        if SaleLinePOS."Variant Code" <> '' then
          Item.SetRange("Variant Filter",SaleLinePOS."Variant Code");
        
        Item.CalcFields(Inventory);
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption(Inventory),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Item.Inventory,0),false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Group sale"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(Item."Group sale"),false,0,false,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Profit %"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Item."Profit %",2),false,0,false,0);
        
        /*-------------------------------------------- QUANTITY DISCOUNT ---------------------------------------------*/
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt003,true,0,true,0);
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Item.FieldCaption("Item Disc. Group"),true,0,false,0);
        BufferInit(NPRTempBuffer,TemplateCode,i,2,Item."Item Disc. Group",false,0,false,0);
        
        j := 0;
        SaleLinePOS2.Reset;
        SaleLinePOS2.SetCurrentKey("Register No.","Sales Ticket No.","No." );
        SaleLinePOS2.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("No.",Item."No.");
        SaleLinePOS2.CalcSums(Quantity);
        QuantityDiscountLine.SetRange("Item No.",Item."No.");
        //Flerstyk.SETFILTER(Quantity, '>%1', Eksplin.Quantity);
        if QuantityDiscountLine.Find('-') then
          repeat
            j += 1;
            i += 1;
            if j = 1 then
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt018,true,0,false,0);
            QuantityDiscountHeader.Get(QuantityDiscountLine."Item No.",QuantityDiscountLine."Main no.");
            BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(QuantityDiscountHeader."Starting Date") + ' - ' + Format(QuantityDiscountHeader."Closing Date"),false,0,false,0);
            BufferInit(NPRTempBuffer,TemplateCode,i,3,Utility.FormatDec2Text(QuantityDiscountLine.Quantity,0) + '  ' + Txt004 + '  ' + Utility.FormatDec2Text(QuantityDiscountLine."Unit Price",2),false,0,false,0);
            BufferInit(NPRTempBuffer,TemplateCode,i,4,Txt005 + '  ' + Utility.FormatDec2Text(QuantityDiscountLine.Total,2),false,0,false,0);
          until (QuantityDiscountLine.Next = 0)
        else begin
          i += 1;
          BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt018,true,0,false,0);
          BufferInit(NPRTempBuffer,TemplateCode,i,2,'',false,0,false,0);
        end;
        
        /*------------------------------------------- MIX DISCOUNT ---------------------------------*/
        j := 0;
        Register.Get(SaleLinePOS."Register No.");
        MixedDiscountLine.Reset;
        MixedDiscountLine.SetCurrentKey("No.");
        MixedDiscountLine.SetRange("No.",Item."No.");
        //-NPR5.31 [262904]
        MixedDiscountLine.SetRange("Disc. Grouping Type",MixedDiscountLine."Disc. Grouping Type"::Item);
        if not MixedDiscountLine.IsEmpty then begin
          MixedDiscountLine.FindSet;
        //IF MixedDiscountLine.FIND('-') THEN BEGIN
        //+NPR5.31 [262904]
          repeat                       // MixedDiscount findes
            MixedDiscount.SetRange(Code,MixedDiscountLine.Code);
            MixedDiscount.SetFilter("Global Dimension 1 Code",'%1|%2','',Register."Global Dimension 1 Code");
            MixedDiscount.SetFilter("Global Dimension 2 Code",'%1|%2','',Register."Global Dimension 2 Code");
            if MixedDiscount.FindSet then
              if MixedDiscount.Status = MixedDiscount.Status::Active then begin
                i += 1;
                j += 1;
                if j = 1 then
                  BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt006,true,0,false,0);
                BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(MixedDiscount."Starting date") + ' - ' + Format(MixedDiscount."Ending date"),false,0,false,0);
                BufferInit(NPRTempBuffer,TemplateCode,i,3,MixedDiscount.Code + '  ' + MixedDiscount.Description,false,0,false,0);
                BufferInit(NPRTempBuffer,TemplateCode,i,4,Utility.FormatDec2Text(MixedDiscount."Total Amount",2),false,0,false,0);
                MixedDiscountLine2.Reset;
                MixedDiscountLine2.SetRange(Code, MixedDiscount.Code);
                if MixedDiscountLine2.Find('-') then
                  repeat
                    if Item2.Get(MixedDiscountLine2."No.") then;
                    i += 1;
                    BufferInit(NPRTempBuffer,TemplateCode,i,3,Format(MixedDiscountLine2.Quantity) + 'x ' + Item2.Description,false,0,false,2);
                    BufferInit(NPRTempBuffer,TemplateCode,i,4,Utility.FormatDec2Text(Item2."Unit Price",2),false,0,false,0);
                  until MixedDiscountLine2.Next = 0;
            end;
          until MixedDiscountLine.Next = 0;
        end else begin
          i += 1;
          BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt006,true,0,false,0);
          BufferInit(NPRTempBuffer,TemplateCode,i,2,'',false,0,false,0);
        end;
        
        /*------------------------------------------- CAMPAIGN DISCOUNT ---------------------------------*/
        j := 0;
        PeriodDiscountLine.Reset;
        PeriodDiscountLine.SetCurrentKey("Item No.");
        PeriodDiscountLine.SetRange("Item No.",Item."No.");
        if PeriodDiscountLine.Find('-') then
          repeat
            PeriodDiscount.Get(PeriodDiscountLine.Code);
            if PeriodDiscount.Status = PeriodDiscount.Status::Active then begin
              i += 1;
              j += 1;
              if j = 1 then
                BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt007,true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(PeriodDiscount."Starting Date") + ' - ' + Format(PeriodDiscount."Ending Date"),false,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,3,'[' + PeriodDiscount.Code + '] ' + PeriodDiscount.Description,false,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,4,Utility.FormatDec2Text(PeriodDiscountLine."Campaign Unit Price",2),false,0,false,0);
            end;
          until PeriodDiscountLine.Next = 0
        else begin
          i += 1;
          BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt007,true,0,false,0);
          BufferInit(NPRTempBuffer,TemplateCode,i,2,'',false,0,false,0);
        end;
        
        /*------------------------------------------- VARIATIONS ---------------------------------*/
        //i += 1;
        //bufferInit( Buffer, code50, i, 1, t020, TRUE, 0, TRUE, 0);
        
        
        /*------------------------------------------- COMMENTS ---------------------------------*/
        
        i += 1;
        BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt017,true,0,true,0);
        
        Item.CalcFields(Comment);
        if Item.Comment then begin
          CommentLine.Reset;
          CommentLine.SetRange("Table Name",CommentLine."Table Name"::Item);
          CommentLine.SetRange("No.",Item."No.");
          CommentLine.Find('-');
          repeat
            i += 1;
            BufferInit(NPRTempBuffer,TemplateCode,i,1,CommentLine.Comment,false,0,false,0);
            BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(CommentLine.Date),false,0,false,0);
          until (CommentLine.Next = 0);
        end else begin
          i += 1;
          BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt019,false,0,false,0);
        end;
        
        /*------------------------------------------- EXT. ITEM TEXTS ---------------------------------*/
        
        //i += 1;
        //bufferInit( Buffer, code50, i, 1, t022, TRUE, 0, TRUE, 0);

    end;

    procedure InfoLine(var SalePOS: Record "Sale POS";var HeadingText: Text[250];var NPRTempBuffer: Record "NPR - TEMP Buffer";var SaleLinePOS: Record "Sale Line POS")
    begin
        //getInfo
        LastInteger := 0;

        if SaleLinePOS."Gift Voucher Ref." <> '' then begin
            //hentGavekortInfo(EkspLin, overskrift, underoverskrift, tekst);
            exit;
        end;
        case SaleLinePOS.Type of
          SaleLinePOS.Type::"G/L Entry":;
          SaleLinePOS.Type::Item:
            begin
              SalePOS.Parameters := SaleLinePOS."No.";
              InfoItem(SaleLinePOS,HeadingText,NPRTempBuffer);
            end;
          SaleLinePOS.Type::"Item Group":;
          SaleLinePOS.Type::Customer:
            begin
              InfoCustomer(SalePOS,HeadingText,NPRTempBuffer);
            end;
        end;

        if SaleLinePOS."Customer No. Line" then
          InfoCustomer(SalePOS,HeadingText,NPRTempBuffer);
    end;

    procedure InfoCustomer(var SalePOS: Record "Sale POS";var HeadingText: Text[250];var NPRTempBuffer: Record "NPR - TEMP Buffer") CommentLineExists: Boolean
    var
        Cust: Record Customer;
        CommentLine: Record "Comment Line";
        i: Integer;
        Txt002: Label 'Comments';
        Contact: Record Contact;
        Txt004: Label 'Basic data';
        Utility: Codeunit Utility;
        TemplateCode: Code[50];
    begin
        //getCustInfo
        case SalePOS."Customer Type" of
          SalePOS."Customer Type"::Ord:
            begin
              Cust.Get(SalePOS."Customer No.");
              Cust.CalcFields(Balance);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt004,true,0,true,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust."Search Name"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust."Search Name",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust.Address),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust.Address,false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust."Address 2"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust."Address 2",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust."Post Code"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust."Post Code",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust.City),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust.City,false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust."Country/Region Code"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust."Country/Region Code",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust."Phone No."),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Cust."Phone No.",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust."Credit Limit (LCY)"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(Cust."Credit Limit (LCY)"),false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust.Blocked),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(Cust.Blocked),false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Cust.FieldCaption(Cust.Balance),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Utility.FormatDec2Text(Cust.Balance,2),false,0,false,0);
        
              /* COMMENTS */
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt002,true,0,true,0);
        
              CommentLine.Reset;
              CommentLine.SetRange("Table Name",CommentLine."Table Name"::Customer);
              CommentLine.SetRange("No.",Cust."No.");
              CommentLineExists := false;
              if CommentLine.Find('-') then
                repeat
                  i += 1;
                  BufferInit(NPRTempBuffer,TemplateCode,i,1,CommentLine.Comment,false,0,false,0);
                  BufferInit(NPRTempBuffer,TemplateCode,i,2,Format(CommentLine.Date),false,0,false,0);
                  CommentLineExists := true;
                until (CommentLine.Next = 0);
            end;
          SalePOS."Customer Type"::Cash:
            begin
              Contact.Get(SalePOS."Customer No.");
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Txt004,true,0,true,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact."No."),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact."No.",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact.Name),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact.Name,false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact."Search Name"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact."Search Name",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact.Address),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact.Address,false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact."Address 2"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact."Address 2",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact."Post Code"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact."Post Code",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact.City),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact.City,false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact."Country/Region Code"),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact."Country/Region Code",false,0,false,0);
        
              i += 1;
              BufferInit(NPRTempBuffer,TemplateCode,i,1,Contact.FieldCaption(Contact."Phone No."),true,0,false,0);
              BufferInit(NPRTempBuffer,TemplateCode,i,2,Contact."Phone No.",false,0,false,0);
        
              /*
              { COMMENTS }
              i += 1;
              bufferInit( Buffer, code50, i, 1, t002, TRUE, 0, TRUE, 0);
        
              comment.RESET;
              comment.SETRANGE("Table Name", comment."Table Name"::Customer);
              comment.SETRANGE("No.", cust."No.");
              ret := FALSE;
              IF comment.FIND('-') THEN REPEAT
                i += 1;
                bufferInit( Buffer, code50, i, 1, comment.Comment, FALSE, 0, FALSE, 0);
                bufferInit( Buffer, code50, i, 2, FORMAT(comment.Date), FALSE, 0, FALSE, 0);
                ret := TRUE;
              UNTIL (comment.NEXT = 0);
              */
            end;
        end;

    end;

    procedure InsertInsurrance(SalePOS: Record "Sale POS")
    begin
        //IndsaetForsikring
        RetailContractMgt.InsertInsurance(SalePOS);
    end;

    procedure ItemLedgerEntries(SourceType: Option Customer,"Cash Customer";SourceNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Txt001: Label 'You must choose a customer number';
    begin
        //ItemLedgerEntries
        if SourceNo = '' then
          POSEventMarshaller.DisplayError(Text001,Txt001,true);

        //ItemLedgerEntry.SETCURRENTKEY("Source Type", "Source No.", "Entry Type", "Item No.", "Variant Code", "Posting Date");
        //itemledgerentry.SETRANGE( "Source Type", itemledgerentry."Source Type"::Item);
        //CASE "Source Type" OF
        //  "Source Type"::Customer : ItemLedgerEntry.SETRANGE( "Source Type" );
        //  "Source Type"::"Cash Customer" : ItemLedgerEntry.SETRANGE( "Source Type" );
        //END;
        ItemLedgerEntry.SetRange("Source No.",SourceNo);
        PAGE.RunModal(PAGE::"Item Ledger Entries",ItemLedgerEntry);
        //Cust.SETFILTER("No.", '%1', "Source No.");
        //REPORT.RUNMODAL(113, TRUE, FALSE, Cust);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterOpen(Register: Record Register)
    begin
        //-NPR5.33 [275728]
        //+NPR5.33 [275728]
    end;

    procedure ModifyGiftVoucher(var SaleLinePOS: Record "Sale Line POS") Modified: Boolean
    var
        GiftVoucher: Record "Gift Voucher";
    begin
        //retGavekort
        Modified := false;

        GiftVoucher.Reset;
        GiftVoucher.SetRange("No.",SaleLinePOS."Gift Voucher Ref.");
        if not GiftVoucher.Find('-') then
          exit(Modified);

        GiftVoucher.Amount := SaleLinePOS."Unit Price";
        Modified := GiftVoucher.Modify;
    end;

    procedure PrintLabel(var SaleLinePOS: Record "Sale Line POS")
    var
        Item: Record Item;
        Txt001: Label 'How many labels to print?  Is not put into inventory.';
        RetailJournalHeader: Record "Retail Journal Header";
        RetailJournalLine: Record "Retail Journal Line";
        Quantity: Decimal;
        Txt002: Label 'No item on this line';
        Txt003: Label 'You can only print labels on items';
        RetailFormCode: Codeunit "Retail Form Code";
        LabelLibrary: Codeunit "Label Library";
        ReportSelectionRetail: Record "Report Selection Retail";
        VarietyWrapper: Codeunit "Variety Wrapper";
    begin
        //printlabel
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) and
           (SaleLinePOS.Type <> SaleLinePOS.Type::"Item Group") and
           (SaleLinePOS.Type <> SaleLinePOS.Type::"BOM List") then
          POSEventMarshaller.DisplayError(Text001,Txt003,true);

        RetailJournalHeader.SetRange("No.", '_' + UserId + '_');
        RetailJournalHeader.DeleteAll;
        RetailJournalHeader.Reset;
        RetailJournalLine.SetRange("No.", '_' + UserId + '_');
        RetailJournalLine.DeleteAll;
        RetailJournalLine.Reset;
        RetailJournalHeader.Init;
        RetailJournalHeader."No." := '_' + UserId + '_';
        if RetailJournalHeader.Insert then;
        Commit;

        if Item.Get(SaleLinePOS."No.") then begin
          Item.CalcFields("Has Variants");
          if Item."Has Variants" then begin
            if SaleLinePOS."Variant Code" <> '' then begin
              Quantity := 1;
              if POSEventMarshaller.NumPad(Txt001,Quantity,false,false) then begin
                RetailJournalLine."No." := '_' + UserId + '_';
                RetailJournalLine."Line No." := 10000;
                RetailJournalLine.Validate("Item No.",Item."No.");
                RetailJournalLine.Validate("Quantity to Print",Quantity);
                RetailJournalLine.Validate("Variant Code",SaleLinePOS."Variant Code");
                //-NPR5.23 [241990]
                RetailJournalLine."Register No." := SaleLinePOS."Register No.";
                //+NPR5.23 [241990]
                RetailJournalLine.Insert;
              end else
                exit;
            //-NPR5.23 [240916]

        //    END ELSE BEGIN
        //      "VariaX  Functions".CallVariaXmatrixFromDoc( item,
        //                                       'LabelPrinting',
        //                                       0,
        //                                       "Retail Journal Header"."No.",
        //                                       0 );
            //-NPR5.23 [241990]
            end else begin
              RetailJournalLine.Init;
              RetailJournalLine."No." := '_' + UserId + '_';
              RetailJournalLine.Validate("Item No.",Item."No.");
              RetailJournalLine.Insert(true);
              VarietyWrapper.RetailJournalLineShowVariety(RetailJournalLine,0);
            end;
            //END;
            //+NPR5.23 [241990]

            RetailJournalLine.SetRange("No.",RetailJournalHeader."No.");
            //-NPR5.23
        //    IF "Retail Journal Line".FIND('+') THEN
        //      lastLine.COPY( "Retail Journal Line" );
        //
        //    IF "Retail Journal Line".FIND('-') THEN REPEAT
        //      bLastline := (lastLine."No." = "Retail Journal Line"."No.") AND
        //                   (lastLine."Line No." = "Retail Journal Line"."Line No.");
        //      RetailFormCode.e( "Retail Journal Line", bLastline ,'Retail');
        //    UNTIL "Retail Journal Line".NEXT = 0;
            if RetailJournalLine.FindSet then
              LabelLibrary.PrintRetailJournal(RetailJournalLine,ReportSelectionRetail."Report Type"::"Price Label");
            //+NPR5.23
            RetailJournalHeader.Delete(true);
          end else begin
            Quantity := 1;
            if POSEventMarshaller.NumPad(Txt001,Quantity,false,false) then
              RetailFormCode.PrintLabelItemCard(Item,false,Quantity,true);
          end;
        end else
          POSEventMarshaller.DisplayError(Text001,Txt002,true);
    end;

    procedure PrintLastReceipt(var SalePOS: Record "Sale POS";PrintFormat: Option Receipt,A4,Choose): Boolean
    var
        ErrNoBon: Label 'No receipts have been printed from this cash register!';
        AuditRoll: Record "Audit Roll";
        AuditRollList: Page "Audit Roll";
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        ReportSelectionRetail: Record "Report Selection Retail";
        RecRef: RecordRef;
    begin
        //udskrivSidsteBon
        AuditRoll.Reset;
        AuditRoll.SetRange("Register No.",SalePOS."Register No.");

        case PrintFormat of
          PrintFormat::Receipt,
          PrintFormat::A4:
            AuditRoll.SetFilter(Type,'<>%1&<>%2',AuditRoll.Type::Cancelled,AuditRoll.Type::"Open/Close");
          PrintFormat::Choose:
            begin
              AuditRoll.SetRange("Register No.");
              AuditRoll.SetFilter(Type,'<>%1&<>%2',AuditRoll.Type::Cancelled,AuditRoll.Type::"Open/Close");
            end;
        end;

        Clear(AuditRollList);
        AuditRollList.LookupMode(true);
        AuditRollList.SetExtFilters(true);
        AuditRollList.SetTableView(AuditRoll);

        if PrintFormat = PrintFormat::Choose then begin
          if AuditRollList.RunModal = ACTION::LookupOK then begin
            AuditRollList.GetRecord(AuditRoll);
            AuditRoll.SetRecFilter;
            Clear(AuditRollList);
          end else
          //+NPR5.26 [248666]
            exit(false);
        //    Marshaller.Error(text001,ErrNoBon,TRUE);
          //+NPR5.26 [248666]
        end else begin
          //-NPR5.26 [248666]
          AuditRoll.SetRange("Sale Date",Today);
          //+NPR5.26 [248666]
          AuditRoll.SetCurrentKey("Sales Ticket No.",Type);
          if not AuditRoll.Find('+') then begin
            POSEventMarshaller.DisplayError(Text001,ErrNoBon,false);
            exit(false);
          end;
          AuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        end;

        case PrintFormat of
          PrintFormat::Receipt,
          PrintFormat::Choose:
            begin
              //-NPR4.18
        //      IF Revisionsrulle.Type = Revisionsrulle.Type::Payment THEN BEGIN
        //        stdCU.PrintReceipt(Revisionsrulle, TRUE);
        //      END;
              //+NPR4.18
              if AuditRoll.Type = AuditRoll.Type::"Debit Sale" then begin
                //-NPR5.23
                RecRef.GetTable(AuditRoll);
                RetailReportSelectionMgt.SetRegisterNo(SalePOS."Register No.");
                RetailReportSelectionMgt.RunObjects(RecRef,ReportSelectionRetail."Report Type"::"Customer Sales Receipt");

        //        Rapportvalg.SETRANGE("Report Type",Rapportvalg."Report Type"::"Debet kvittering");
        //        Rapportvalg.SETRANGE( "Register No.", Eksp."Register No." );
        //        Rapportvalg.SETFILTER("Report ID",'<>0');
        //        IF NOT Rapportvalg.FIND('-') THEN
        //          Rapportvalg.SETRANGE( "Register No.", '' );
        //        IF Rapportvalg.FIND('-') THEN REPEAT
        //          REPORT.RUNMODAL(Rapportvalg."Report ID",FALSE,FALSE,Revisionsrulle);
        //        UNTIL Rapportvalg.NEXT = 0;
                //+NPR5.23
              //-NPR4.18
        //      END;
              end else
                StdCodeunitCode.PrintReceipt(AuditRoll,true);
              //+NPR4.18
            end;
          PrintFormat::A4:
            begin
              //-NPR4.18
        //      IF Revisionsrulle.Type = Revisionsrulle.Type::Payment THEN BEGIN
        //        Revisionsrulle.UdskrivBonA4( FALSE );
        //      END;
              //+NPR4.18
              if AuditRoll.Type = AuditRoll.Type::"Debit Sale" then begin
                AuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
                AuditRoll.SetFilter("Allocated No.",'<>%1','');
                AuditRoll.SetRange("No.");
                AuditRoll.SetRange("Line No.");
                AuditRoll.Find('-');
                SalesInvoiceHeader.Get(AuditRoll."Allocated No.");
                SalesInvoiceHeader.SetFilter("No.",'%1',AuditRoll."Allocated No.");
                SalesInvoiceHeader.PrintRecords(false);
              //-NPR4.18
        //      END;
              end else
                AuditRoll.PrintReceiptA4(false);
              //+NPR4.18
            end;
        end;

        exit(true);
    end;

    procedure PrintLabelAll(var SaleLinePOS: Record "Sale Line POS")
    var
        Item: Record Item;
        RetailJnlHeader: Record "Retail Journal Header";
        RetailJnlLine: Record "Retail Journal Line";
        SaleLinePOS2: Record "Sale Line POS";
        LabelLibrary: Codeunit "Label Library";
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        //printlabelAll
        if RetailJnlHeader.Get('_' + UserId + '_') then
          RetailJnlHeader.Delete(true);

        RetailJnlHeader.Init;
        RetailJnlHeader."No." := '_' + UserId + '_';
        RetailJnlHeader.Insert;
        RetailJnlLine.SetRange("No.",'_' + UserId + '_');

        SaleLinePOS2.Copy(SaleLinePOS);

        with SaleLinePOS2 do begin
          //creating retaillines to use for printing
          if SaleLinePOS2.FindSet then
            repeat
              if Type in [Type::Item,Type::"Item Group",Type::"BOM List"] then begin
                if Item.Get("No.") then begin
                  Item.CalcFields("Has Variants");
                  if (Item."Has Variants" and ("Variant Code" <> '')) or
                     (not Item."Has Variants") then begin
                    RetailJnlLine.Init;
                    RetailJnlLine."No." := '_' + UserId + '_';
                    RetailJnlLine."Line No." := "Line No.";
                    RetailJnlLine.Validate("Item No.",Item."No.");
                    RetailJnlLine.Validate("Quantity to Print",Quantity);
                    RetailJnlLine.Validate("Variant Code","Variant Code");
                    RetailJnlLine.Insert;
                  end;
                end;
              end;
            until SaleLinePOS2.Next = 0;
        end;

        //use retail lines for printing
        //-NPR5.23
        // IF RetailJnlLine.FINDSET THEN REPEAT
        //  RetailFormCode.PrintLabelRetailJournal(RetailJnlLine, RetailJnlLine."Line No." = SaleLinePOS2."Line No." ,'Retail');
        // UNTIL RetailJnlLine.NEXT = 0;
        if RetailJnlLine.FindSet then
          LabelLibrary.PrintRetailJournal(RetailJnlLine,ReportSelectionRetail."Report Type"::"Price Label");
        //+NPR5.23

        RetailJnlHeader.Delete(true);
    end;

    procedure Round2Payment(PaymentTypePOS: Record "Payment Type POS";Amount: Decimal): Decimal
    begin
        //Round2Payment
        if PaymentTypePOS."Rounding Precision" = 0 then
          exit(Amount);

        exit(Round(Amount,PaymentTypePOS."Rounding Precision",'='));
    end;

    procedure ReceiptEmailPrompt(var Sale: Record "Sale POS")
    var
        Register: Record Register;
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        Customer: Record Customer;
        Contact: Record Contact;
        EmailManagement: Codeunit "E-mail Management";
        ValidAddress: Boolean;
        Confirmed: Boolean;
        RepeatedPrompt: Boolean;
    begin
        Register.Get(Sale."Register No.");
        if not (Register."Sales Ticket Email Output" in [Register."Sales Ticket Email Output"::Prompt,Register."Sales Ticket Email Output"::"Prompt With Print Overrule"]) then
          exit;

        RepeatedPrompt := Sale."Send Receipt Email";

        //-NPR5.31 [268865]
        // IF (NOT Sale."Send Receipt Email") OR (STRLEN (Sale."Customer No.") = 0) THEN BEGIN
        //  Sale."Send Receipt Email" := Marshaller.Confirm('',Txt_SendReceiptEmail);
        //
        //  IF (NOT Sale."Send Receipt Email") AND (NOT RepeatedPrompt) THEN
        //    EXIT; //Only modify and commit rec when it is actually changed.
        //  Sale.MODIFY;
        //  COMMIT;
        //  IF (Sale."Send Receipt Email") THEN
        //    Marshaller.Error ('',Err_MissingCustomer,TRUE);
        //  EXIT;
        // END;

        if (not Sale."Send Receipt Email") or (StrLen(Sale."Customer No.") = 0) then begin
          Sale."Send Receipt Email" := POSEventMarshaller.Confirm('',Txt_SendReceiptEmail);

          if RepeatedPrompt <> Sale."Send Receipt Email" then begin
            Sale.Modify;
            Commit;
          end;

          if (not Sale."Send Receipt Email") then
            exit;

          if StrLen(Sale."Customer No.") = 0 then
            POSEventMarshaller.DisplayError('',Err_MissingCustomer,true);
        end;
        //+NPR5.31 [268865]

        if Sale."Customer Type" = Sale."Customer Type"::Cash then begin
          Contact.Get(Sale."Customer No.");
          ValidAddress := EmailManagement.CheckEmailSyntax(Contact."E-Mail");
          if ValidAddress then
            Confirmed := POSEventMarshaller.Confirm('',StrSubstNo('%1   %2',Txt_CustomerEmail,Contact."E-Mail"));

          if not Confirmed then
            repeat
              if not ValidAddress then
                Message(StrSubstNo(Txt_InvalidEmail,Contact.TableCaption));
              Confirmed := PAGE.RunModal(PAGE::"Contact Card",Contact) = ACTION::LookupOK;
              ValidAddress := EmailManagement.CheckEmailSyntax(Contact."E-Mail");
            until (ValidAddress or not Confirmed);
        end;

        if Sale."Customer Type" = Sale."Customer Type"::Ord then begin
          Customer.Get(Sale."Customer No.");
          ValidAddress := EmailManagement.CheckEmailSyntax(Customer."E-Mail");
          if ValidAddress then
            Confirmed := POSEventMarshaller.Confirm('',StrSubstNo('%1   %2',Txt_CustomerEmail,Customer."E-Mail"));

          if not Confirmed then
            repeat
              if not ValidAddress then
                Message(StrSubstNo(Txt_InvalidEmail,Customer.TableCaption));
              Confirmed := PAGE.RunModal(PAGE::"Customer Card",Customer) = ACTION::LookupOK;
              ValidAddress := EmailManagement.CheckEmailSyntax(Customer."E-Mail");
            until (ValidAddress or not Confirmed);
        end;

        Sale."Send Receipt Email" := ValidAddress and Confirmed;
        Sale.Modify;
        Commit;
    end;

    procedure RegisterTestOpen(var SalePOS: Record "Sale POS"): Integer
    var
        Txt002: Label 'Do you want to open register %1 with opening total of %2?';
        Register: Record Register;
        Txt004: Label 'The register has not been balanced since %1 and must be balanced before selling. Du you wish to balance now?';
        Txt005: Label 'Register balancing';
        Txt006: Label 'Notice IMPORTANT, the Date "Posting Allowed to" has been crossed.\Contact your superuser who can correct this date.\If you reply OK, the date will be corrected\ so the register will open today.';
    begin
        //register_testopen

        Register.Get(SalePOS."Register No.");

        case Register.Status of
          Register.Status::" ":;
          Register.Status::Afsluttet:
            begin
              Commit;
              if not RetailSalesCode.CheckPostingDateAllowed(WorkDate) then begin
                if Confirm(Txt006) then begin
                  RetailSalesCode.EditPostingDateAllowed(UserId,WorkDate);
                  Commit;
                  end else exit(10);
              end;
              if Confirm(StrSubstNo(Txt002,Register."Register No.",Register."Closing Cash"),true) then begin
                if RegisterOpen(SalePOS) then
                  exit(12)
                else begin
                  Commit;
                  exit(10);
                end;
              end else
                exit(10);
            end;
          Register.Status::Ekspedition:
            if Register."Opened Date" = Today then begin
              exit(Register.Status)                  // der kan foretages ekspeditioner
            end else begin
              case Register."Balancing every" of
                Register."Balancing every"::Day:
                  begin
                    Commit;
                    if POSEventMarshaller.Confirm(Txt005,StrSubstNo(Txt004,Register."Opened Date")) then
                      exit(11)
                    else
                      exit(10);
                  end;
                Register."Balancing every"::Manual:
                  begin
                    Register.Status := Register.Status::Ekspedition;
                    Register.Modify;
                    exit(Register.Status);
                  end;
              end;
            end;
        end;

        Register.Get(SalePOS."Register No.");
        exit(Register.Status);              // der kan ikke foretages ekspeditioner
    end;

    procedure RegisterOpen(var SalePOS: Record "Sale POS"): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        t001: Label 'Register opened by %1 with amount %2';
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
        RetailSetup: Record "Retail Setup";
    begin
        //register_open() : Boolean
        Register.Get(SalePOS."Register No.");
        //-NPR5.33 [275728]
        OnBeforeRegisterOpen(Register);
        //+NPR5.33 [275728]
        Register.LockTable;
        Register.Balanced := 0D;
        Register."Opened Date" := Today;
        Register.Status := Register.Status::Ekspedition;
        Register."Opening Cash" := Register."Closing Cash";
        Register."Closing Cash" := 0;
        Register."Opened By Salesperson" := SalePOS."Salesperson Code";
        Register.Modify;

        AuditRoll.Init;
        //-NPR5.33 [275728]
        ////Forny hvis vi �bner p� en gammel bon.
        //AuditRollCheck.SETFILTER("Sales Ticket No.",'>%1',SalePOS."Sales Ticket No.");
        //IF AuditRollCheck.FIND('+') THEN
        //  AuditRoll."Sales Ticket No." := FormCode.FetchSalesTicketNumber(SalePOS."Register No.")
        //ELSE
        //  AuditRoll."Sales Ticket No."    := SalePOS."Sales Ticket No.";
        //+NPR5.33 [275728]
        AuditRoll."Sales Ticket No." := SalePOS."Sales Ticket No.";

        Register."Opened on Sales Ticket" := AuditRoll."Sales Ticket No.";
        Register.Modify;

        //-NPR5.38 [302761]
        RetailSetup.Get;
        if not RetailSetup."Create POS Entries Only" then begin
        //+NPR5.38 [302761]
          AuditRoll."Register No." := SalePOS."Register No.";
          AuditRoll.Type := AuditRoll.Type::"Open/Close";
          AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
          Salesperson.Get(SalePOS."Salesperson Code");
          AuditRoll.Description := CopyStr(StrSubstNo(t001,Salesperson.Name,Register."Opening Cash"),1,50);
          AuditRoll."Sale Date" := Today;
          AuditRoll."Starting Time" := Time;
          AuditRoll."Closing Time" := Time;
          AuditRoll."Opening Cash" := Register."Opening Cash";
          AuditRoll.Posted := true;
          AuditRoll."Offline receipt no." := SalePOS."Sales Ticket No.";
          AuditRoll.Insert;
        //-NPR5.38 [302761]
        end;
        //+NPR5.38 [302761]
        //-NPR5.40
        //IF Register."Auto Open/Close Terminal" THEN
        //  MSPDankort.OpenTerminal;
        //+NPR5.40

        if SalePOS.Delete then;
        exit(true);
    end;

    procedure ReturnSale(var SalePOS: Record "Sale POS")
    var
        SalesLinePOS: Record "Sale Line POS";
    begin
        //ReturnSale
        SalesLinePOS.Reset;
        SalesLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SalesLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SalesLinePOS.SetFilter(Type,'%1|%2',SalesLinePOS.Type::Item, SalesLinePOS.Type::"Item Group");
        if SalesLinePOS.Find('-') then
          repeat
            SalesLinePOS.Validate(Quantity,-SalesLinePOS.Quantity);
            SalesLinePOS.Modify;
          until SalesLinePOS.Next = 0;
    end;

    procedure SaleDebit(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header" temporary;var ValidationText: Code[20];Internal: Boolean): Boolean
    var
        Customer: Record Customer;
        RetailSetup: Record "Retail Setup";
        POSCheckCrLimit: Codeunit "POS-Check Cr. Limit";
        "Filter": Code[20];
        SaleLinePOS: Record "Sale Line POS";
    begin

        Commit;
        RetailSetup.Get;
        Filter := ValidationText;
        ValidationText := '';
        if not LookupCustomer(Internal,Filter,Customer) then
          exit(false);

        DeleteCustomerLine(SalePOS);
        SalePOS.Validate("Customer Type",SalePOS."Customer Type"::Ord);
        SalePOS.Validate("Customer No.",Customer."No.");

        if RetailSetup."Customer Credit Level Warning" then begin
          RetailFormCodeGlobal.CreateSalesHeader(SalePOS,SalesHeader);
          Commit;
          //-NPR5.29 [256289]
          //IF NOT CustCheckCreditLimit.SalesHeaderPOSCheck(SalesHeader) THEN BEGIN
          if not POSCheckCrLimit.SalesHeaderPOSCheck(SalesHeader) then begin
          //+NPR5.29 [256289]
            DeleteCustomerLine(SalePOS);
            SalePOS."Customer No." := '';
            RetailFormCodeGlobal.CreateSalesHeader(SalePOS,SalesHeader);
            SalePOS.Validate("Customer No.");
          end;
        end;

        SalePOS.Modify;
         Commit;

        AskRefAtt(SalePOS,true);

        SalePOS.Modify;
        ValidationText := '';
        //-NPR5.36 [286989]
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter(Quantity,'<>0');
        if SaleLinePOS.FindSet(true, false) then repeat
          SaleLinePOS.Validate(Quantity);
          SaleLinePOS.Modify(true);
        until SaleLinePOS.Next = 0;
        //+NPR5.36
        exit(true);
    end;

    procedure SaleCashCustomer(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header" temporary;var SearchText: Code[20])
    var
        SaleLinePOS: Record "Sale Line POS";
        Customer: Record Customer;
        Register: Record Register;
        Contact: Record Contact;
        AuditRoll: Record "Audit Roll";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TouchScreenCRMContacts: Page "Touch Screen - CRM Contacts";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        //salgKontantKunde
        SalesInvoiceHeader.Reset;
        Customer.Reset;
        AuditRoll.Reset;
        SalesHeader.Reset;
        Clear(RetailSalesCode);
        Clear(GenJnlPostLine);
        SaleLinePOS.Reset;

        Commit;

        Register.Get(SalePOS."Register No.");

        if SearchText = '' then begin
          Contact.Reset;
          if SearchText <> '' then begin
            Contact.SetCurrentKey("Search Name");
            Contact.SetFilter("Search Name",'%1','*@' + SearchText + '*');
          end else
            Contact.Reset;
          SearchText := '';
          TouchScreenCRMContacts.SetRecord(Contact);
          TouchScreenCRMContacts.LookupMode(true);
          if PAGE.RunModal(PAGE::"Touch Screen - CRM Contacts",Contact) = ACTION::LookupOK then begin
            DeleteCustomerLine(SalePOS);
            SalePOS.Validate("Customer Type",SalePOS."Customer Type"::Cash);
            SalePOS.Validate("Customer No.",Contact."No.");
         end else if TouchScreenCRMContacts.LookupOk then begin
            DeleteCustomerLine(SalePOS);
            TouchScreenCRMContacts.GetRecord(Contact);
            SalePOS.Validate("Customer Type",SalePOS."Customer Type"::Cash);
            SalePOS.Validate("Customer No.",Contact."No.");
         end;
        end else begin
          SalePOS.Validate("Customer Type",SalePOS."Customer Type"::Cash);
          SalePOS.Validate("Customer No.",SearchText);
        end;

        AskRefAtt(SalePOS,true);

        SalePOS.Modify;

        SearchText := '';
    end;

    procedure ScanCustomerCard() Result: Code[20]
    var
        Txt001: Label 'Scan membership card';
    begin
        Result := POSEventMarshaller.SearchBox(Txt001,'',50);
    end;

    procedure SetSerialNumber(var SaleLinePOS: Record "Sale Line POS";SerialNoNotCreated: Boolean): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        NFRetailCode: Codeunit "NF Retail Code";
        Txt001: Label 'This is an item with a Serial Number.\Type in Serial Number from the item.';
        Txt009: Label 'You have not set a Serial Number from the item.';
        Txt010: Label 'The Serial Number is not found in the Item Ledger Entries!';
        Txt023: Label 'You have not set a Serial Number from the item to sell it.';
        InputText: Text[50];
        Item: Record Item;
    begin
        //-NPR4.18
        Item.Get(SaleLinePOS."No.");
        //-NPR5.27 [253261]
        RetailSetupGlobal.Get;
        //+NPR5.27 [253261]
        //-NPR5.27 [253347]
        //ItemTrackingCode.GET(item."Item Tracking Code");
        if not SerialNoNotCreated then
          ItemTrackingCode.Get(Item."Item Tracking Code");
        //+NPR5.27 [253347]
        //+NPR4.18
        if not POSEventMarshaller.NumPadText(Txt001,InputText,false,false) then
          exit(false);

        if SerialNoNotCreated then begin
          SaleLinePOS.Validate("Serial No. not Created",InputText);
        end else begin
          if (InputText = '') then begin
            POSEventMarshaller.DisplayError(Text001,Txt023,false);
            if not NFRetailCode.TR406SerialNoOnLookup(SaleLinePOS) then begin
              POSEventMarshaller.DisplayError(Text001,Txt009,false);
              exit(false);
            end;
            Item.Get(SaleLinePOS."No.");
            //-NPR4.16
            //"Sale Line POS"."Unit Cost" := "Sale Line POS".FindVareKostpris(item,"Sale Line POS".Color,"Sale Line POS".Size);
            SaleLinePOS."Unit Cost" := SaleLinePOS.FindItemCostPrice(Item);
            //+NPR4.16
            SaleLinePOS.Cost := SaleLinePOS."Unit Cost" * SaleLinePOS.Quantity;
            //-NPR5.45 [324395]
            //SaleLinePOS."Unit Price (LCY)" := SaleLinePOS."Unit Cost";
            SaleLinePOS."Unit Cost (LCY)" := SaleLinePOS."Unit Cost";
            //+NPR5.45 [324395]
            if SaleLinePOS.Modify then;
            exit(true);
          end else begin
           //-NPR4.18
            if ItemTrackingCode."SN Specific Tracking" then begin
            //+NPR4.18
              ItemLedgerEntry.SetCurrentKey(Open,Positive,"Item No.","Serial No.");
              ItemLedgerEntry.SetRange("Item No.",SaleLinePOS."No.");
              ItemLedgerEntry.SetRange("Serial No.",InputText);
              ItemLedgerEntry.SetRange(Open,true);
              ItemLedgerEntry.SetRange(Positive,true);
              ItemLedgerEntry.SetRange("Location Code",SaleLinePOS."Location Code");
              //-NPR5.27 [253261]
              if RetailSetupGlobal."Not use Dim filter SerialNo" = false then
              //+NPR5.27 [253261]
                ItemLedgerEntry.SetRange("Global Dimension 1 Code",SaleLinePOS."Shortcut Dimension 1 Code");
              if not ItemLedgerEntry.Find('-') then begin
                POSEventMarshaller.DisplayError(Text001,Txt010,false);
                exit(false);
              //-NPR4.18
              end;
              //+NPR4.18
            end;
            SaleLinePOS.Validate("Serial No.",InputText);
          end;
        end;

        SaleLinePOS.Modify(true);
        exit(true);
    end;

    procedure SetRegisterStatus(var Eksp: Record "Sale POS";Initialiseret: Boolean)
    begin
        //S�tkassestatus
    end;

    procedure TestRegisterRegistration(var SalePOS: Record "Sale POS") ret: Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        Item: Record Item;
        Txt001: Label 'You have to put a Serial Number on %1 !';
    begin
        //testkasseregistrering()

        //COMMIT;
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.Find('-') then
          repeat
            if (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale) and
              (SaleLinePOS.Type = SaleLinePOS.Type::Item) then begin
              Item.Get(SaleLinePOS."No.");
              if Item."Costing Method" = Item."Costing Method"::Specific then
                if SaleLinePOS."Serial No." = '' then
                  Error(Txt001,SaleLinePOS.Description);
              //-NPR5.23 [240916]
              // IF Vare."Size Group" <> '' THEN
              //   IF (Ekspl.Color = '') AND (Ekspl.Size = '') THEN
              //     ERROR(t002, Ekspl.Description);
              //+NPR5.23 [240916]
            end;
          until SaleLinePOS.Next = 0;
        SaleLinePOS.Reset;
    end;

    procedure TestSalesDate()
    var
        AuditRoll: Record "Audit Roll";
        Txt002: Label 'System date error - %1! Sales can not be made from this register, because of not closed sales on date %2.';
    begin
        //TjekdatoEKSPEDITION
        if WorkDate <> Today then begin
          //MESSAGE(t001);
          WorkDate := Today;
        end;
        AuditRoll.Init;
        AuditRoll.SetCurrentKey("Sale Date");
        AuditRoll.SetFilter("Sale Date",'%1..',Today + 1);
        if not AuditRoll.IsEmpty then
          Error(Txt002,Today,AuditRoll.GetRangeMin("Sale Date"));
    end;

    procedure VariationLookup(var SalesLinePOS: Record "Sale Line POS")
    var
        TMPRetailList: Record "Retail List" temporary;
        ItemVariant: Record "Item Variant";
        VariantCount: Integer;
        Item: Record Item;
    begin
        if SalesLinePOS.Silent then
          exit;

        ItemVariant.SetRange("Item No.",SalesLinePOS."No.");
        ItemVariant.SetRange(Blocked, false);

        if ItemVariant.FindSet then
          repeat
            if not ItemVariant.Blocked then begin
              Clear(Item);
              Item.SetRange("No.",ItemVariant."Item No.");
              Item.SetFilter("Variant Filter",ItemVariant.Code);
              if Item.FindFirst then
                Item.CalcFields(Inventory);
              VariantCount += 1;
              TMPRetailList.Number := VariantCount;
              TMPRetailList.Choice := ItemVariant.Description + ' ' + Item.FieldCaption(Inventory) + ': ' + Format(Item.Inventory);
              TMPRetailList.Value := ItemVariant.Code;
              TMPRetailList.Insert;
            end;
          until ItemVariant.Next = 0;

        if VariantCount > 0 then
          LookupVariant(SalesLinePOS,TMPRetailList);
    end;

    local procedure InitFilterFields(TableId: Integer;var TempField: Record "Field" temporary)
    var
        Customer: Record Customer;
        Item: Record Item;
        LookupTemplate: Record "Lookup Template";
        LookupTemplateLine: Record "Lookup Template Line";
    begin
        //-NPR5.22
        TempField.DeleteAll;

        LookupTemplateLine.SetRange("Lookup Template Table No.",TableId);
        LookupTemplateLine.SetFilter("Field No.",'>%1',0);
        LookupTemplateLine.SetRange(Searchable,true);
        if LookupTemplate.Get(TableId) and LookupTemplateLine.FindSet then begin
          repeat
            if not TempField.Get(LookupTemplateLine."Lookup Template Table No.",LookupTemplateLine."Field No.") then begin
              TempField.Init;
              TempField.TableNo := LookupTemplateLine."Lookup Template Table No.";
              TempField."No." := LookupTemplateLine."Field No.";
              TempField.Insert;
            end;
          until LookupTemplateLine.Next = 0;
          exit;
        end;
        case TableId of
          DATABASE::Item:
            begin
              TempField.Init;
              TempField.TableNo := DATABASE::Item;
              TempField."No." := Item.FieldNo("No.");
              TempField.Insert;

              TempField.Init;
              TempField.TableNo := DATABASE::Item;
              TempField."No." := Item.FieldNo(Description);
              TempField.Insert;
            end;
          DATABASE::Customer:
            begin
              TempField.Init;
              TempField.TableNo := DATABASE::Customer;
              TempField."No." := Customer.FieldNo("No.");
              TempField.Insert;

              TempField.Init;
              TempField.TableNo := DATABASE::Customer;
              TempField."No." := Customer.FieldNo(Name);
              TempField.Insert;
            end;
        end;
        //+NPR5.22
    end;

    procedure SetupTempCustomer(SearchString: Text;var TempCustomer: Record Customer temporary): Boolean
    var
        Customer: Record Customer;
        TempField: Record "Field" temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.22
        if SearchString = '' then
          exit(false);

        TempCustomer.DeleteAll;

        InitFilterFields(DATABASE::Customer,TempField);
        TempField.FindSet;
        repeat
          Clear(Customer);
          RecRef.GetTable(Customer);
          FieldRef := RecRef.Field(TempField."No.");
          FieldRef.SetFilter('@*' + ConvertStr(SearchString,' ','*') + '*');
          RecRef.SetTable(Customer);

          if Customer.FindSet then
            repeat
              if not TempCustomer.Get(Customer."No.") then begin
                TempCustomer.Init;
                TempCustomer := Customer;
                TempCustomer.Insert;
              end;
            until Customer.Next = 0;
        until TempField.Next = 0;

        exit(true);
        //+NPR5.22
    end;

    local procedure SetupTempCustomerStaff(var TempCust: Record Customer temporary)
    var
        Cust: Record Customer;
        RetailSetup: Record "Retail Setup";
        RecRef: RecordRef;
    begin
        //-NPR5.26 [250709]
        RecRef.GetTable(TempCust);
        if not RecRef.IsTemporary then
          exit;

        TempCust.DeleteAll;

        if not RetailSetup.Get then
          exit;

        Cust.Reset;
        Cust.SetFilter("Customer Price Group",'%1&<>%2',RetailSetup."Staff Price Group",'');
        if Cust.FindSet then
          repeat
            TempCust.Init;
            TempCust := Cust;
            TempCust.Insert;
          until Cust.Next = 0;

        Cust.Reset;
        Cust.SetFilter("Customer Disc. Group",'%1&<>%2',RetailSetup."Staff Disc. Group",'');
        if not Cust.FindSet then
          exit;

        if Cust.FindSet then
          repeat
            if not TempCust.Get(Cust."No.") then begin
              TempCust.Init;
              TempCust := Cust;
              TempCust.Insert;
            end;
          until Cust.Next = 0;
        //+NPR5.26 [250709]
    end;

    procedure SetupTempItem(SearchString: Text;var TempItem: Record Item temporary): Boolean
    var
        Item: Record Item;
        TempField: Record "Field" temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.22
        if SearchString = '' then
          exit(false);

        TempItem.DeleteAll;

        InitFilterFields(DATABASE::Item,TempField);
        TempField.FindSet;
        repeat
          Clear(Item);
          RecRef.GetTable(Item);
          FieldRef := RecRef.Field(TempField."No.");
          FieldRef.SetFilter('@*' + ConvertStr(SearchString,' ','*') + '*');
          RecRef.SetTable(Item);
          if Item.FindSet then
            repeat
              if not TempItem.Get(Item."No.") then begin
                TempItem.Init;
                TempItem := Item;
                TempItem.Insert;
              end;
            until Item.Next = 0;
        until TempField.Next = 0;

        exit(true);
        //+NPR5.22
    end;

    procedure GetLastSaleInfo("Register No.": Code[10];var Total: Decimal;var PaymentAmountTotal: Decimal;var LastSaleDate: Text[30];var ReturnAmountTotal: Decimal;var ReceiptNo: Text[30]): Boolean
    var
        AuditRoll: Record "Audit Roll";
    begin
        //getLastSaleRightCol
        AuditRoll.SetRange("Register No.","Register No.");
        AuditRoll.SetFilter("Sale Type",'<>%1',AuditRoll."Sale Type"::"Open/Close");
        AuditRoll.SetFilter(Type,'<>%1',AuditRoll.Type::Cancelled);
        //-NPR5.22
        AuditRoll.SetRange("Sale Date",Today);
        //+NPR5.22
        if AuditRoll.FindLast() then begin
          AuditRoll.SetRange(Type);
          //-NPR4.14
          //Eksp.SETRANGE("Sale Type",Eksp."Sale Type"::Salg);
          AuditRoll.SetFilter("Sale Type",'%1|%2',AuditRoll."Sale Type"::Sale,AuditRoll."Sale Type"::Deposit);
          //+NPR4.14
          AuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No." );
          if AuditRoll.FindSet() then
            repeat
              Total += AuditRoll."Amount Including VAT";
            until AuditRoll.Next = 0;
          AuditRoll.SetRange(Type,AuditRoll.Type::Payment);
          AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
          AuditRoll.SetFilter("Amount Including VAT",'>%1',0);
          if AuditRoll.FindSet() then
            repeat
              PaymentAmountTotal += AuditRoll."Amount Including VAT"
            until AuditRoll.Next = 0;
          AuditRoll.SetFilter("Amount Including VAT",'<%1',0);
          if AuditRoll.FindSet() then
            repeat
              ReturnAmountTotal += AuditRoll."Amount Including VAT";
            until AuditRoll.Next = 0;
          LastSaleDate := Format(AuditRoll."Sale Date") + ' | ' + Format(AuditRoll."Closing Time");
          ReceiptNo := AuditRoll."Sales Ticket No.";
        end;
    end;

    local procedure LookupVariant(var SalesLinePOS: Record "Sale Line POS";var TMPRetailList: Record "Retail List" temporary)
    var
        POSWebUIMgt: Codeunit "POS Web UI Management";
        LookupRec: RecordRef;
        Template: DotNet npNetTemplate;
        VariantCode: Text;
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR4.11
        TMPRetailList.FindFirst;
        LookupRec.GetTable(TMPRetailList);
        POSWebUIMgt.ConfigureLookupTemplate(Template,LookupRec);
        //-NPR5.20
        //VariantCode := Marshaller.Lookup(SaleLinePOS.FIELDCAPTION("Variant Code"),Template,LookupRec);
        VariantCode := POSEventMarshaller.Lookup(SaleLinePOS.FieldCaption("Variant Code"),Template,LookupRec,false,false,0);
        //+NPR5.20
        if VariantCode <> '' then begin
          LookupRec.SetPosition(VariantCode);
          if LookupRec.Find() then begin
            LookupRec.SetTable(TMPRetailList);
            SalesLinePOS.Validate("Variant Code",TMPRetailList.Value);
          end;
        end;
        //+NPR4.11
    end;

    local procedure LookupCustomer(Internal: Boolean;"Filter": Code[20];var Cust: Record Customer): Boolean
    var
        Cust2: Record Customer;
        RetailSetup: Record "Retail Setup";
        TempCust: Record Customer temporary;
        TouchEventSubscribers: Codeunit "Touch - Event Subscribers";
        Template: DotNet npNetTemplate;
        POSWebUIMgt: Codeunit "POS Web UI Management";
        RecRef: RecordRef;
        CustNo: Text;
    begin
        RetailSetup.Get;
        if Filter <> '' then
          POSEventMarshaller.ClearEanBoxText();

        if Internal then begin
          SetupTempCustomerStaff(TempCust);

          if RetailSetup."Use NAV Lookup in POS" then begin
            if PAGE.RunModal(PAGE::"Touch Screen - Customers",TempCust) <> ACTION::LookupOK then
              exit(false);

            Cust := TempCust;
            exit(true);
          end;

          RecRef.GetTable(TempCust);
        end else if Filter <> '' then begin
          SetupTempCustomer(Filter,TempCust);

          if RetailSetup."Use NAV Lookup in POS" then begin
            if PAGE.RunModal(PAGE::"Touch Screen - Customers",TempCust) <> ACTION::LookupOK then
              exit(false);

            Cust := TempCust;
            exit(true);
          end;

          RecRef.GetTable(TempCust);
        end else begin
          if RetailSetup."Use NAV Lookup in POS" then
            exit(PAGE.RunModal(PAGE::"Touch Screen - Customers",Cust) = ACTION::LookupOK);

          RecRef.GetTable(Cust);
        end;

        POSWebUIMgt.ConfigureLookupTemplate(Template,RecRef);
        TouchEventSubscribers.ConfigureCustomer(POSEventMarshaller);
        BindSubscription(TouchEventSubscribers);
        CustNo := POSEventMarshaller.Lookup(Cust.TableCaption,Template,RecRef,true,true,PAGE::"Customer Card");

        if CustNo = '' then
          exit(false);

        Cust2.SetPosition(CustNo);
        if not Cust2.Find then
          exit(false);

        Cust := Cust2;
        exit(true);
    end;

    procedure PrintWarrantyCertificate(var SaleLinePOS: Record "Sale Line POS")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
        SaleLinePOS2: Record "Sale Line POS";
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
    begin
        //PrintWarrantyCertificate
        //-NPR5.35 [278757]

        //SaleLinePOS2.COPY(SaleLinePOS);
        SaleLinePOS2 := SaleLinePOS;
        SaleLinePOS2.SetRecFilter;

        //-NPR5.37 [294353]
        RecRef.GetTable(SaleLinePOS2);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Warranty Certificate");

        // ReportSelectionRetail.SETRANGE("Report Type", ReportSelectionRetail."Report Type"::"Warranty Certificate");
        // IF ReportSelectionRetail.ISEMPTY THEN BEGIN
        //  Table := SaleLinePOS2;
        //  LinePrintMgt.ProcessCodeunit(CODEUNIT::"Report - Retail Warranty",Table);
        // END ELSE
        //  IF ReportSelectionRetail.FINDSET THEN REPEAT
        //    CASE TRUE OF
        //      ReportSelectionRetail."Report ID" > 0 :
        //        REPORT.RUN(ReportSelectionRetail."Report ID",FALSE,FALSE,SaleLinePOS2);
        //      ReportSelectionRetail."Codeunit ID" > 0 :
        //        BEGIN
        //          Table := SaleLinePOS2;
        //          LinePrintMgt.ProcessCodeunit(ReportSelectionRetail."Codeunit ID", Table);
        //        END;
        //    END;
        //  UNTIL ReportSelectionRetail.NEXT = 0;
        //+NPR5.37 [294353]

        //+NPR5.35
    end;
}

