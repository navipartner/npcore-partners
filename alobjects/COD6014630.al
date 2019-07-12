codeunit 6014630 "Touch - Sale POS (Web)"
{
    // NPR4.10/VB/20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629  CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.12/VB/20150703  CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.14/VB/20150908  CASE 220186 Fixed text constants
    // NPR4.14/VB/20150909  CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925  CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20151001  CASE 224232 Number formatting
    // NPR4.15/VB/20150930  CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.15/BHR/20151022 CASE 224603 Pass the parameter correctly, so that additional discount works as well
    // NPR4.16/JDH/20151019 CASE 225415 Recompiled to refresh field links to Register (fields have been rearranged)
    // NPR4.17/VB/20150104  CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20151221  CASE 229508 Changed how number formatting is handled
    // NPR5.00/VB/20151221  CASE 229375 Limiting search box to 50 characters
    // NPR5.00/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.01/VB/20160210 CASE 233201 Resetting EAN Box Field after setting quantity
    // NPR5.01/VB/20160215 CASE 226188 Returning back in payment menu.
    // MM1.01/TSA/20151222 CASE 230149 Added new keyword MM_SCAN_CARD
    // MM1.05/TSA/20160121  case Adding the member number value to serial no field
    // MM1.05/TSA/20160121  CASE Adding member info capture page to react on membership sales
    // TM1.09/TSA/20160202  CASE 232952 Added function to support scanning a ticket
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // MM1.09/TSA/20160285 CASE 235685 Rework the MM_SCAN_CARD
    // NPR5.20/BR/20160225  CASE  231481 Extended terminal integration
    // NPR5.20/BR/20160225  CASE  231481 Moved check on keyword
    // NPR5.20/VB/20160301  CASE 235863 Filtering by salesperson fixed.
    // NPR5.20/JC/20160303  CASE 234744 New function INSERT_PAYMENT_CUSTCASH
    // NPR5.20/VB/20160304  CASE 235306 New lookup functionality (card, new)
    // NPR5.20/JC/20160311  CASE 236201 Updated function SALE_REVERSE PushSaleReverse
    // NPR5.20/MHA/20150315 CASE 235325 Added Publisher function HandleMetaTriggerEvent()
    // NPR5.20/JDH/20160321 CASE 237255 Changed call to CreateGiftVoucher - parameter changed from text to dec
    // NPR4.21/JDH/20160211 CASE 234339 corrected how filters is transferred to get the saved sales
    // NPR4.21/MMV/20160215 CASE 234421 Added changes made to object "Touch - Sale POS" for parity.
    // NPR4.21/MMV/20160215 CASE 224257 Added captions instead of hardcode for tax free messages.
    // NPR4.21/JC/20160302  CASE 234744 New function INSERT_PAYMENT_CUSTCASH
    // NPR4.21/JC/20160311  CASE 236201 New function SALE_REVERSE
    // NPR5.22/JDH/20160331 CASE 237986 Showlastsaleinformation cleaned up - was executing a lot of unneeded code
    // NPR5.22/MHA/20160405 CASE 238459 Added Preemptive filter on Lookup
    // NPR5.22/VB/20160406 CASE 237866 Handling sales line data delta instead of full set
    // NPR5.22/MMV/20160408 CASE 232067 Added support for Customer Location Mgt.
    // NPR5.22/BR/20160412  CASE  231481 Added support for turning the terminal on/offline
    // NPR5.22/VB/20160421 CASE 239536 Cleaning up last sales line state as part of view switching, to avoid disappearing sales lines after switching to payment view
    // NPR5.22/BR/20160412  CASE  231481 Added support for Installation of terminal
    // NPR5.23/MMV/20160503 CASE 237189 Refactored customer display calls
    // NPR5.23/VB/20160505 CASE 238378 Clearing of EanBoxText after lookup.
    // NPR5.23/MMV/20160512 CASE 232067 Added audit roll trace when importing receipt from customer location.
    // NPR5.23/JDH /20160518 CASE 240916 Removed unused Variables and text constants
    // NPR5.23/TTH/20160526 CASE 242158 Redesigned the code to enable a modal form requesting a return reason code.
    // NPR5.23/TS/20160527  CASE 242686 Open Retail Item Card instead of Item Card
    // NPR5.23/MMV /20160527 CASE 237189 Removed deprecated function WriteToCustomerDisplay()
    // NPR5.23.02/BR  /20160623 CASE 244575 Bypass item lookup functionality
    // NPR5.25/VB/20160702 CASE 246015 Caching of payment lines and sending deltas to front end
    // NPR5.26/JC/20160705 CASE 244948 SaveSale() & GetSavedSale() & Complete_PushSaleReverse() Amount not displayed correctly - workaround/temp fix,
    // NPR5.26/BHR/20162507 CASE 246774 Confirmation box before posting customer sale
    // NPR5.26/BHR/20160208 CASE 244948 Prevent resetting unit price of return sales.
    // NPR5.26/OSFI/20160810 CASE 246167 POS Info functionality.
    // NPR5.26/MMV /20160811 CASE 246204 Added tax free changes from CU 6014551 that should have been merged in NPR4.21.
    // NPR5.26/CLVA /20160811 CASE 244944 Added CashKeeper functionality
    // NPR5.26/OSFI/20160810 CASE 246167 POS Info Suspend and Retrieve
    // NPR5.26/BHR/20160823 CASE 247882 Reset state to display retrieved sales
    // #Temp/OSFI/20160901 Case 250708  Commented out changes for case 244944
    // NPR5.26/CLVA /20160811 CASE 244944 Added 2nd display functionality
    // NPR5.27/BHR/20162110 CASE 255864 get contact details for POS info
    // NPR5.27/JDH /20161024 CASE 254925 Login Numpad not shown - there is a login numpad on the loginscreen already
    // NPR5.28/MMV /20161107 CASE 254575 Added support for e-mail prompt at view switch to payment.
    //                                   Added some missing state clearing to CancelSale()
    // NPR5.28/VB/20161107 CASE 257796 Implemented logic for "Update Infobox During Sale" from Register table.
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.29/BR/20161124 CASE 258876 Added option to filter item list with Button Parameter
    // NPR5.29/MMV /20161214 CASE 261034 Changed signature on POSCustomerLocation function.
    // NPR5.30/MHA /20170201  CASE 264918 Np Photo Module removed
    // NPR5.30/MHA /20170302  CASE 267291 Added Publisher function OnBeforeDebitSale(),OnBeforeGotoPayment()
    // NPR5.31/MMV /20170321  CASE 264112 New POS trigger function.
    // NPR5.31/BHR /20170322  CASE 269754 Modified caption Text10600071 and correct description with 'Credit Voucher Ref'.
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.32/ANEN/20170403 CASE 270854 Clear MenuLines1 (Touch Screen Setup - Menu Lines) in ExecFunction for MM and TM
    // NPR5.31/MMV /20170410  CASE 271728 Added validate on empty customer no. when cancelling sale to clear inherited state.
    //                                    Removed support for deprecated field "Default Customer no.".
    // NPR5.31/TJ  /20170411  CASE 270496 Added UoM to show up next to Unit Price label in the infobox on sale view screen
    // NPR5.32/BR  /20170412  CASE 264202 Extended EANBox functionality
    // NPR5.32/BR  /20170216  CASE 266151 By default show only unblocked items in the Lookup
    // NPR5.32/BHR /20170502  CASE 270885 Change the text constant Text10600216
    // NPR5.32/JC  /20170510  CASE 274462 Meta triggers TOTAL_DISCOUNTPCT_VAR & LINE_DISCOUNTPCT_VAR with supporting functions
    // NPR5.32/BHR /20170525  CASE 270885 Add trigger for Initialization of sales doc
    // NPR5.33/JC  /20170620  CASE 280535 Fixed issue with fetching pos line when there is no line on cancel
    // NPR5.33/CLVA/20170629  CASE 272155 Added support for reports on IOS
    // NPR5.35/JC  /20170727  CASE 278757 Added trigger Code PRINT_GUARANTEE to print warranty from POS
    // NPR5.35/JC  /20170701  CASE 281761 Screen refresh, Added function ScreenChangeRefresh()
    // NPR5.35/BR  /20170808 CASE 285762 Fix error when closing terminal
    // NPR5.35/JDH /20170829 CASE 288492 Added Description to Deposit lines
    // NPR5.36/TJ  /20170918  CASE 286283 Replaced danish specific letters in hardcoded words with english letters (Bemaerk and indlaest)
    // NPR5.37/BR  /20171017  CASE 293711 Change handling of giving change to customer
    // NPR5.38/MMV /20171218  CASE 300126 Don't stop execution for sales doc. meta trigger errors: The error is not doing meaningful rollback and we need to continue to init new receipt regardless.
    // NPR5.38/MHA /20180115  CASE 302221 Added Contact information to LoadSavedSale()
    // NPR5.39/MHA /20180202  CASE 302779 Added OnFinishSale POS Workflow
    // NPR5.40/BHR /20180322 CASE 308408 Rename variable Grid to Grids
    // NPR5.46/CLVA/20180920 CASE 328581 Removed relation to CU 6014532 Customer Display Mgt.
    // NPR5.48/MHA /20181115 CASE 334633 Removed reference to deleted function CheckSavedSales() in Codeunit 6014435


    trigger OnRun()
    begin
    end;

    var
        Buffer: Record "NPR - TEMP Buffer" temporary;
        PaymentTypePOS: Record "Payment Type POS";
        MenuLines1: Record "Touch Screen - Menu Lines";
        MenuLines2: Record "Touch Screen - Menu Lines";
        MenuLinePopupTmp: Record "Touch Screen - Menu Lines" temporary;
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
        Setuplinie: Record "Touch Screen - Menu Lines";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        PaymentLinePOSObject: Codeunit "Touch - Payment Line POS";
        SaleLinePOSObject: Codeunit "Touch - Sales Line POS";
        TempSalesHeader: Record "Sales Header" temporary;
        This: Record "Sale POS";
        IsCashSale: Boolean;
        IsTaxFreeEnabled: Boolean;
        Validering: Code[50];
        ValideringLast: Code[50];
        CopyValidering: Code[50];
        LastSaleFigures: array[3] of Decimal;
        LastTypeStr: Text[30];
        CurrentMenuLevel: Integer;
        Text10600003: Label 'Sale temporarily on hold';
        Text10600013: Label 'Quantity must be 0 on no. %1!';
        Text10600014: Label 'Unit price cannot be 0 on no. %1!';
        Text10600027: Label 'The transaction was not completed!';
        Text10600051: Label 'The sales window cannot contain lines!';
        Text10600071: Label 'Credit voucher  %1';
        Text10600095: Label 'Save Sale cancelled, because no sales lines present! \Press Cancel Sale instead!';
        Text10600107: Label 'Item number %1 does not exist.';
        Text10600112: Label 'No lines to modify.';
        Text10600118: Label 'Customer/club member already chosen. Remove customer then choose new.';
        Text10600200: Label 'Error';
        Text10600202: Label 'Function not usable in offline mode!';
        Text10600206: Label 'Cancelled';
        Text10600208: Label 'Payment Info';
        Text10600209: Label 'Sale (LCY)';
        Text10600210: Label 'Payed';
        Text10600211: Label 'Balance';
        Text10600212: Label 'Enter description.';
        QueriedClose: Option No,Yes,Refresh;
        HideInputDialog: Boolean;
        State: DotNet npNetState0;
        ViewType: DotNet npNetViewType;
        StateData: DotNet npNetDictionary_Of_T_U;
        LastLineTemp: Record "Sale Line POS" temporary;
        LastPmtLineTemp: Record "Sale Line POS" temporary;
        SessionMgt: Codeunit "POS Web Session Management";
        UI: Codeunit "POS Web UI Management";
        Marshaller: Codeunit "POS Event Marshaller";
        Initialized: Boolean;
        FunctionState: Option Main,FindElement;
        UpdatePosition: Boolean;
        t014: Label 'Type in the receipt number to be annulled.';
        t016: Label 'Type receipt no. first!';
        MethodName_PushQuantity: Label 'Push Quantity';
        MethodName_PushLineDiscountPct: Label 'PushLineDiscountPct';
        MethodName_PushTotalAmount: Label 'PushTotalAmount';
        MethodName_PushTotalDiscount: Label 'PushTotalDiscount';
        MethodName_PushDiscountPct: Label 'PushDiscountPct';
        MethodName_PushLineDiscountAmount: Label 'PushLineDiscountAmount';
        MethodName_PushLineUnitPrice: Label 'PushLineUnitPrice';
        MethodName_PushRegisterChange: Label 'PushRegisterChange';
        MethodName_PushSaleReverse: Label 'PushSaleReverse';
        MethodName_PushSaleAnnull: Label 'PushSaleAnnull';
        MethodName_PushRegisterOpen: Label 'PushRegisterOpen';
        LastFuncStr: Code[50];
        Text10600215: Label 'Auxiliary Terminal function parameter invalid.';
        TaxFreeEnabledMsg: Label 'Tax Free Refund enabled';
        TaxFreeDisabledMsg: Label 'Tax Free Refund disabled';
        Text10600216: Label 'Do you want to create Sales Document?';
        DepositDescription: Label 'Deposit %1';

    procedure Initialize(StateIn: DotNet npNetState0)
    begin
        State := StateIn;
        Initialized := true;

        SaleInit(true, true);
    end;

    procedure Finalize()
    begin
        Marshaller.Finalize();
        ClearAll();
    end;

    local procedure IsInitialized(): Boolean
    begin
        exit(Initialized and (not IsNull(State)));
    end;

    local procedure "-------------------------------------------"()
    begin
    end;

    local procedure "-              OLD FUNCTIONS              -"()
    begin
    end;

    local procedure "--------------------------------------------"()
    begin
    end;

    local procedure "."()
    begin
    end;

    procedure "--- Primary Entry Function"()
    begin
    end;

    procedure ExecFunction(FuncStr: Code[50]) ret: Boolean
    var
        RetailSalesCode: Codeunit "Retail Sales Code";
        RetailFormCode: Codeunit "Retail Form Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        AuditRollForm: Page "Audit Roll";
        FormEkspStatistik: Page "Turnover Stats";
        cuSkanner: Codeunit "Scanner - Functions";
        GiftCertCreated: Boolean;
        SaleLinePOS: Record "Sale Line POS";
        SalesLine: Record "Sale Line POS";
        Account: Record "G/L Account";
        Register: Record Register;
        ItemLedgerEntry: Record "Item Ledger Entry";
        AuditRoll: Record "Audit Roll";
        Description: Text[50];
        tmpStr: Text[1024];
        t025: Label 'Customer number not chosen.';
        t032: Label 'Debit sale change is cancelled by sales person.';
        item: Record Item;
        t038: Label 'New sales ticket no';
        t039: Label 'You can not have sales lines when balancing the register. First cancel the sale!';
        Int: Integer;
        t040: Label 'Description';
        t041: Label 'Enter amount.';
        ReturnLabelLastDateUsed: Date;
        Dec: Decimal;
        DummyText: Text;
        MetaTriggerMgt: Codeunit "Meta Trigger Management";
        t045: Label 'You can not have sales lines when closing the Payment Terminal. First cancel the sale!';
        StringLib: Codeunit "String Library";
        MM_MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MM_PrePushResult: Integer;
        MM_PostPushResult: Integer;
        MM_PushAction: Text[250];
        TM_TicketRetailManagement: Codeunit "TM Ticket Retail Management";
        TM_PrePushResult: Integer;
        TM_PostPushResult: Integer;
        TM_PushAction: Text[250];
        POSCustLocMgt: Codeunit "POS Customer Location Mgt.";
        POSCustLocReceipt: Record "Sale POS";
        POSInfoManagement: Codeunit "POS Info Management";
    begin
        //execFunction
        LastFuncStr := FuncStr;

        with This do begin
            SetScreenView(State.ViewType);
            FuncStr := UpperCase(FuncStr);
            RetailSetup.Get;
            Register.Get("Register No.");

            //-NPR5.20
            //-NPR4.02
            //IF MetaTriggerMgt.IsKeyword(FuncStr) THEN BEGIN
            //+NPR4.02
            //+NPR5.20
            if not HandleMetaTrigger(FuncStr, 0, This, SaleLinePOS) then
                case FuncStr of
                    /*----- LOGIN -----*/
                    'PRINT_LAST_RECEIPT':
                        TouchScreenFunctions.PrintLastReceipt(This, 0);
                    'PRINT_LAST_RECEIPT_A4':
                        TouchScreenFunctions.PrintLastReceipt(This, 1);
                    'PRINT_LAST_RECEIPT_DEBIT':
                        TouchScreenFunctions.PrintLastReceipt(This, 2);
                    'PRINT_LAST':
                        TouchScreenFunctions.PrintLastReceipt(This, 3);
                    'REGISTER_LOCK':
                        begin
                            SetScreenView(ViewType.Locked);
                        end;
                    'REGISTER_CHANGE':
                        begin
                            PushRegisterChange();
                            exit;
                        end;
                    'RECEIPT2NPORDER':
                        RetailFormCode.ReceiptToRetailOrder(This, 0, true, "Retail Document Type"::"Retail Order");
                    'RECEIPT2CUSTIMIZATION':
                        RetailFormCode.ReceiptToRetailOrder(This, 0, true, "Retail Document Type"::Customization);
                    'SHIPMENT2NPORDER':
                        RetailFormCode.ShipmentToRetailOrder(This, true);

                    /*----- SALE -----*/
                    'SALE_SAVE':
                        begin
                            SaveSale();
                            //-NPR5.35 [281761]
                            UpdateSaleLinePOSObject();
                            //+NPR5.35
                        end;
                    'CANCEL_SALE':
                        begin
                            if State.IsCurrentView(ViewType.Payment) then begin
                                GotoSale();
                            end;
                            QueryClose;
                        end;
                    'TOGGLE_SALEVAT_YN':
                        begin
                            "Price including VAT" := not "Price including VAT";
                            Validate("Customer No.");
                            Modify(true);
                        end;
                    'FUNCTIONS_SALE':
                        Functions('');
                    'FUNCTIONS_DISCOUNT':
                        begin
                            if Validering <> '' then begin
                                Dec := UI.ParseDecimal(Validering);
                                if Dec = 0 then begin
                                    SaleLinePOSObject.ChangeDiscountOnActiveLine(Dec, false);
                                    Validering := '';
                                    exit;
                                end;
                            end;
                            Functions('DISCOUNT');
                        end;
                    'PRINTS':
                        Functions('PRINTS');
                    'QUANTITY_POS':
                        begin
                            PushQuantity(1);
                            exit;
                        end;
                    'QUANTITY_NEG':
                        begin
                            PushQuantity(-1);
                        end;
                    'ITEMGROUPS':
                        begin
                            FindElement();
                            MenuLines1."Filter No." := '';
                        end;
                    'TYPE_SALE_RETURN':
                        ReverseQtyOnSaleLines(This);
                    'OUT_PAYMENT':
                        if PAGE.RunModal(PAGE::"Touch Screen - G/L Accounts", Account) = ACTION::LookupOK then begin
                            Validering := Account."No.";
                            EnterHit('ACCOUNT');
                            Commit;
                            Dec := 0;
                            if not Marshaller.NumPad(t041, Dec, false, false) then
                                Error('');
                            SaleLinePOSObject.ChangeUnitPriceOnActiveLine(Dec);
                            Commit;
                            Description := CopyStr(Marshaller.SearchBox(Text10600212, '', 50), 1, 50);
                            if Description <> '' then
                                SaleLinePOSObject.SetDescription(Description);
                            //-NPR4.12
                            PaymentLinePOSObject.CalculateBalance(Dec);
                            //+NPR4.12
                        end;

                    'INSERT_PAYMENT':
                        InsertPaymentLine(0);
                    'INSERT_PAYMENT_CASH':
                        InsertPaymentLine(2);
                    'INSERT_PAYMENT_CUSTCASH':
                        InsertPaymentLine(3); //-NPR5.20
                    'SALE_GIFTVOUCHER':
                        begin
                            RetailFormCode.GiftVoucherPush(This, Register,
                                                              GiftCertCreated, true, SaleLinePOS, false);
                            SaleLinePOSObject.JumpEnd;
                        end;
                    'SALE_CITYGIFTVOUCHER':
                        begin
                            RetailFormCode.CityGiftVoucherPush(This, Register, GiftCertCreated, true, SaleLinePOS,
                                                                   false);
                            SaleLinePOSObject.JumpEnd;
                        end;
                    'INSURANCE_INSERT':
                        begin
                            SetScreenView(ViewType.Insurance);
                            FindElement();
                        end;
                    'ITEM_LEDGERENTRIES':
                        begin
                            if (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale) and
                               (SaleLinePOS.Type = SaleLinePOS.Type::Item) then begin
                                ItemLedgerEntry.Reset;
                                ItemLedgerEntry.SetCurrentKey("Item No.");
                                ItemLedgerEntry.SetRange("Item No.", SaleLinePOS."No.");
                                PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgerEntry);
                            end;
                        end;

                    /* Selection contract */
                    'SAMPLING_SEND',
                   'SAMPLING_GET',

                   /* Retail Customer order */
                   'NPORDER_SEND',
                   'NPORDER_GET',

                   /* Rental contract */
                   'CONTRACTRENT_SEND',

                   /* Purchase contract */
                   'CONTRACTPURCH_SEND',

                   /* Retail Customization */
                   'TAILOR_SEND',
                   'TAILOR_GET',

                   /* Retail Quote */
                   'QUOTE_SEND',
                   'QUOTE_GET':
                        RetailDocumentHandling(FuncStr);

                    'SALE_REVERSE':
                        begin
                            PushSaleReverse();
                            exit;
                        end;
                    'SALE_ANNULL':
                        begin
                            PushSaleAnnull();
                            exit;
                        end;
                    'IMPORT_SALE':
                        begin
                            TouchScreenFunctions.ImportSalesTicket(This, Validering);
                        end;
                    'BALANCE_REGISTER':
                        begin
                            if RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline then
                                Marshaller.Error_Protocol(Text10600200, Text10600202, true);

                            if RetailSalesLineCode.LineExists(This) then
                                Marshaller.Error_Protocol(Text10600200, t039, true);

                            NewSalesTicketNo(t038);
                            if not RetailFormCode.CheckSales(This) then
                                exit;

                            //-NPR5.48 [334633]
                            //IF NOT RetailFormCode.CheckSavedSales( This ) THEN BEGIN
                            //  GetSavedSale;
                            //  EXIT;
                            //END;
                            //+NPR5.48 [334633]

                            if RetailFormCode.BalanceRegister(This) then begin
                                Commit;
                                SetScreenView(ViewType.BalanceRegister);
                                QueryClose;
                            end else begin
                                Error('');
                            end;
                        end;
                    'SCANNER_GET_SALE':
                        cuSkanner.initSale(This);

                        //-#TM1.09
                    'TM_SCAN_TICKET':
                        begin
                            TM_PrePushResult := TM_TicketRetailManagement.TouchSalesPrePush(SaleLinePOS, MenuLines1, Validering);
                            case TM_PrePushResult of
                                0:
                                    ; // do nothing
                                1:
                                    EnterPush();
                                else
                                    Error(TM_TicketRetailManagement.GetErrorMessage(TM_PrePushResult));
                            end;

                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            TM_PostPushResult := TM_TicketRetailManagement.TouchSalesPostPush(SaleLinePOS, MenuLines1, TM_PushAction, Validering);
                            case TM_PostPushResult of
                                0:
                                    ; // do nothing
                                1:
                                    EnterHit(TM_PushAction);
                                else
                                    Error(TM_TicketRetailManagement.GetErrorMessage(TM_PostPushResult));
                            end;

                            //-NPR5.32
                            Clear(MenuLines1);
                            //+NPR5.32

                            exit(true);
                        end;
                    //+#TM1.09
                    //-MM1.09
                    'MM_SCAN_CARD':
                        begin
                            MM_PrePushResult := MM_MemberRetailIntegration.TouchSalesPrePush(This, SaleLinePOS, MenuLines1, Validering);
                            case (MM_PrePushResult) of
                                0:
                                    ; // do nothing
                                1:
                                    EnterPush(); // Uses value from validering
                                else
                                    Marshaller.DisplayError(Text10600200, MM_MemberRetailIntegration.GetErrorText(MM_PrePushResult), false);
                            end;

                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            MM_PostPushResult := MM_MemberRetailIntegration.TouchSalesPostPush(This, SaleLinePOS, MenuLines1, MM_PushAction, Validering);
                            case (MM_PostPushResult) of
                                0:
                                    ; // do nothing
                                1:
                                    EnterHit(MM_PushAction); // Uses value from validering
                                else
                                    Marshaller.DisplayError(Text10600200, MM_MemberRetailIntegration.GetErrorText(MM_PostPushResult), false);
                            end;

                            //-NPR5.32
                            Clear(MenuLines1);
                            //+NPR5.32

                            exit(true);

                        end;
                    //-MM1.09
                    'SCANNER_MEMBERCARD':
                        begin
                            Validering := TouchScreenFunctions.ScanCustomerCard;
                            if "Customer No." <> '' then begin
                                Marshaller.DisplayError(Text10600200, Text10600118, false);
                                exit;
                            end;
                            EnterHit('KONTANTKUNDE');
                        end;
                    'SERIAL_NUMBER':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            exit(TouchScreenFunctions.SetSerialNumber(SaleLinePOS, false));
                        end;
                    'SERIAL_NUMBER_ARB':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            exit(TouchScreenFunctions.SetSerialNumber(SaleLinePOS, true));
                        end;
                    'COMMENT_INSERT':
                        begin
                            Validering := '*';
                            ButtonDefault;
                        end;
                    'COMMENT_EDIT':
                        RetailFormCode.EditComments(This);
                    'REPAIR_GET':
                        begin
                            RetailFormCode.FetchRepair(This);
                            Validering := "Customer No.";
                            case "Customer Type" of
                                "Customer Type"::Ord:
                                    SetCustomer();
                                "Customer Type"::Cash:
                                    SetContact();
                            end;
                        end;
                    'RETURN_SALE':
                        TouchScreenFunctions.ReturnSale(This);
                    'ITEM_INVENTORY':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            if SaleLinePOS.Type = SaleLinePOS.Type::Item then begin
                                item.Get(SaleLinePOS."No.");
                                item.SetRecFilter;
                                PAGE.RunModal(PAGE::"Item Availability by Location", item);
                            end;
                        end;
                    'ITEM_INVENTORY_ALL':
                        begin
                            PAGE.RunModal(PAGE::"Items by Location");
                        end;
                    'ITEMCARD_EDIT':
                        begin
                            //-NPR4.14
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            //+NPR4.14
                            if SaleLinePOS.Type = SaleLinePOS.Type::Item then begin
                                if item.Get(SaleLinePOS."No.") then
                                    item.SetRecFilter;
                                PAGE.RunModal(6014425, item);
                            end;
                        end;
                    'GOTO_SALE':
                        GotoSale();
                    'SAVE_SALE':
                        begin
                            SaveSale();
                            //-NPR5.35 [281761]
                            UpdateSaleLinePOSObject();
                            //+NPR5.35
                        end;
                    'GET_SALE':
                        begin
                            GetSavedSale;
                            //-NPR5.35 [281761]
                            UpdateSaleLinePOSObject();
                            //+NPR5.35
                        end;
                    'GOTO_PAYMENT':
                        GotoPayment();
                    'COPY_ITEM':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            Validering := SaleLinePOS."No.";
                            ButtonDefault;
                        end;
                    /*----- Std. Orders -----------*/
                    'SALE2POS':
                        RetailSalesCode.Sale2SalePOS(This, TempSalesHeader);
                    /*----- Terminal ------------- */
                    'TERMINAL_OPENCLOSE':
                        begin
                            RetailSetup.Get;
                            Register.Get("Register No.");
                        end;
                        //-NPR5.20
                        //'TERMINAL_ENDOFDAY'     : TouchScreenFunctions.CallTerminal(This, 'ENDOFDAY');
                    'TERMINAL_OPENSHIFT':
                        begin
                            if RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline then begin
                                Marshaller.DisplayError(Text10600200, Text10600202, true);
                            end;
                            Register.TestField("Register No.");
                            This."Register No." := Register."Register No.";
                            TouchScreenFunctions.CallTerminal(This, 'OPENSHIFT', 0);
                        end;
                    'TERMINAL_AUX':
                        begin
                            if RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline then begin
                                Marshaller.DisplayError(Text10600200, Text10600202, true);
                            end;
                            Register.TestField("Register No.");
                            This."Register No." := Register."Register No.";
                            if not Evaluate(Int, MenuLines1.Parametre) then
                                Marshaller.DisplayError(Text10600200, Text10600215, true);
                            TouchScreenFunctions.CallTerminal(This, 'AUX', Int);
                        end;
                    'TERMINAL_ENDOFDAY':
                        begin
                            if RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline then begin
                                Marshaller.DisplayError(Text10600200, Text10600202, true);
                            end;
                            if RetailSalesLineCode.LineExists(This) then
                                Marshaller.DisplayError(Text10600200, t045, true);
                            NewSalesTicketNo(t038);
                            if not RetailFormCode.CheckSales(This) then
                                exit;
                            Register.TestField("Register No.");
                            This."Register No." := Register."Register No.";
                            TouchScreenFunctions.CallTerminal(This, 'ENDOFDAY', 0);
                            //GotoPayment();
                            IsCashSale := false;
                            //-NPR5.35 [285762]
                            //EnterHit('AFSLUTBETALING');
                            //+NPR5.35
                        end;

                    //'TERMINAL_UNLOCK'       : TouchScreenFunctions.CallTerminal(This, 'UNLOCK');
                    'TERMINAL_UNLOCK':
                        TouchScreenFunctions.CallTerminal(This, 'UNLOCK', 0);
                    //+NPR5.20
                    //-NPR5.22
                    'TERMINAL_OFFLINE':
                        begin
                            Register.TestField("Register No.");
                            This."Register No." := Register."Register No.";
                            if not Evaluate(Int, MenuLines1.Parametre) then
                                Marshaller.DisplayError(Text10600200, Text10600215, true);
                            TouchScreenFunctions.CallTerminal(This, 'SETOFFLINE', Int);
                        end;
                    'TERMINAL_INSTALL':
                        begin
                            Register.TestField("Register No.");
                            This."Register No." := Register."Register No.";
                            TouchScreenFunctions.CallTerminal(This, 'INSTALL', 0);
                        end;
                        //+NPR5.22
                        /*----- Customer ------------- */
                    'CUSTOMER':
                        begin
                            Register.Get("Register No.");
                            case Register."Touch Screen Customerclub" of
                                Register."Touch Screen Customerclub"::Functions:
                                    Functions('CUSTOMER');
                                Register."Touch Screen Customerclub"::"Invoice Customer":
                                    SetCustomer();
                                Register."Touch Screen Customerclub"::Contact:
                                    SetContact();
                            end;
                        end;
                    'CUSTOMER_ILE':
                        TouchScreenFunctions.ItemLedgerEntries(This."Customer Type", This."Customer No.");
                    'CUSTOMER_CRM':
                        SetContact();
                    'CUSTOMER_STD':
                        begin
                            SetCustomer();
                            //-NPR4.14
                            Commit;
                            //+NPR4.14
                        end;
                    'CUSTOMER_REMOVE':
                        begin
                            Validate("Customer No.", '');
                            Modify;
                        end;
                    'CUSTOMER_SET':
                        begin
                            Validate("Customer No.", Validering);
                            Validering := '';
                        end;
                    'CUSTOMER_PAY':
                        DebitSale();
                    'DEBIT_INFO':
                        begin
                            if "Customer No." = '' then begin
                                Marshaller.DisplayError(Text10600200, t025, false);
                                exit;
                            end;

                            TempSalesHeader.FilterGroup := 2;
                            TempSalesHeader.SetRange("Document Type", TempSalesHeader."Document Type");
                            TempSalesHeader.SetRange("No.", TempSalesHeader."No.");
                            TempSalesHeader.FilterGroup := 0;

                            if PAGE.RunModal(PAGE::"Debit sale info", TempSalesHeader) <> ACTION::LookupOK then
                                Marshaller.Error_Protocol(Text10600206, t032, true);
                        end;
                    'CUSTOMER_CLE':
                        begin
                            if "Customer No." = '' then begin
                                SetCustomer();
                                Commit;
                            end;
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            tmpStr := TouchScreenFunctions.BalanceRegisterEntries(This, SaleLinePOS);
                            if tmpStr <> '' then begin
                                Commit;
                                Marshaller.DisplayError(Text10600200, tmpStr, false);
                            end;
                            Validering := '';
                        end;
                    'CUSTOMER_PAYMENT':
                        RetailFormCode.CustomerPayment(This);
                    'CUSTOMER_INFO':
                        begin
                            TouchScreenFunctions.InfoCustomer(This, DummyText, Buffer);
                            PAGE.RunModal(PAGE::"Touch Screen - Info", Buffer);
                        end;
                    'CUSTOMER_STAFF':
                        begin
                            EnterHit('DEBITSTAFF');
                        end;
                    'CUSTOMER_PARAM':
                        begin
                            Validering := MenuLines1.Parametre;
                            EnterHit('DEBITCUSTOMER');
                        end;
                    'CUSTOMER_ASKATTREF':
                        begin
                            TouchScreenFunctions.AskRefAtt(This, false);
                        end;

                        /*----- SALE - STATS/INFO -----*/
                    'TURNOVER_SALE':
                        begin
                            Buffer.DeleteAll(true);
                            TouchScreenFunctions.GetSalesStats(This, DummyText, Buffer);
                            PAGE.RunModal(PAGE::"Touch Screen - Info", Buffer);
                        end;
                    'TURNOVER_REPORT':
                        begin
                            FormEkspStatistik.SetTSMode(true);
                            FormEkspStatistik.SetRecord(This);
                            FormEkspStatistik.RunModal();
                        end;
                    'TURNOVER_STATS':
                        begin
                            Buffer.DeleteAll(true);
                            TouchScreenFunctions.GetTurnoverStats(This, DummyText, Buffer);
                            PAGE.RunModal(PAGE::"Touch Screen - Info", Buffer);
                        end;

                    /*----- SALE - DISCOUNT -----*/
                    'LINE_AMOUNT':
                        SetLineAmount(0);
                    'LINE_UNITPRICE':
                        begin
                            PushLineUnitPrice();
                            exit;
                        end;
                    'TOTAL_AMOUNT':
                        begin
                            PushTotalAmount();
                            exit;
                        end;
                    'TOTAL_DISCOUNT':
                        begin
                            PushTotalDiscount();
                            exit;
                        end;
                    'TOTAL_DISCOUNTPCT_ABS':
                        begin
                            PushDiscountPct(false);
                            exit;
                        end;
                    'TOTAL_DISCOUNTPCT_REL':
                        begin
                            PushDiscountPct(true);
                            exit;
                        end;
                    'DISCOUNTPCT_CR':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            TouchScreenFunctions.DiscountCR(SaleLinePOS);
                        end;
                    'LINE_DISCOUNTPCT_ABS':
                        begin
                            PushLineDiscountPct(false);
                            exit;
                        end;
                    'LINE_DISCOUNTPCT_REL':
                        begin
                            PushLineDiscountPct(true);
                            exit;
                        end;
                    'LINE_DISCOUNT_BLOCK':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            TouchScreenFunctions.DiscountBlockLine(SaleLinePOS);
                        end;
                    'LINE_DISCOUNT_AMOUNT':
                        begin
                            PushLineDiscountAmount();
                            exit;
                        end;
                    'SALE_INIT':
                        SaleInit(true, true);
                    //-NPR5.32 [270885]
                    'SALE_INIT_ORDER':
                        begin
                            if (Register."Touch Screen Login Type" = Register."Touch Screen Login Type"::Automatic) then begin
                                NewSale();
                                SetScreenView(ViewType.Payment);
                                SetScreenView(ViewType.Sale);
                            end else
                                SaleInit(true, true);
                        end;
                    //+NPR5.32 [270885]
                    //-NPR5.32 [274462]
                    'TOTAL_DISCOUNTPCT_VAR':
                        begin
                            PushTotalDiscountPctVar();
                            exit;
                        end;
                    'LINE_DISCOUNTPCT_VAR':
                        begin
                            PushLineDiscountPctVar();
                            exit;
                        end;
                    //+NPR5.32

                    /*-- Line modify ---*/
                    'SET_DESCRIPTION':
                        begin
                            Validering := Marshaller.SearchBox(t040, t040, 50);
                            if Validering <> '' then
                                SaleLinePOSObject.SetDescription(Validering)
                            else
                                exit;
                        end;

                    /*----- PRINTS -----*/
                    'PRINT_EXCHLABEL_LINE_ONE',
                    'PRINT_EXCHLABEL     ':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            RetailFormCode.PrintLabelExchangeLabel(0, SaleLinePOS, ReturnLabelLastDateUsed);
                        end;
                    'PRINT_EXCHLABEL_ALL':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            RetailFormCode.PrintLabelExchangeLabel(2, SaleLinePOS, ReturnLabelLastDateUsed);
                        end;
                    'PRINT_EXCHLABEL_LINE_ALL':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            RetailFormCode.PrintLabelExchangeLabel(1, SaleLinePOS, ReturnLabelLastDateUsed);
                        end;
                    'PRINT_EXCHLABEL_SELECT':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            RetailFormCode.PrintLabelExchangeLabel(3, SaleLinePOS, ReturnLabelLastDateUsed);
                        end;
                    'PRINT_EXCHLABEL_PACKAGE':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            RetailFormCode.PrintLabelExchangeLabel(4, SaleLinePOS, ReturnLabelLastDateUsed);
                        end;
                    'PRINT_OVERRIDE':
                        begin
                            //-NPR4.21
                            StringLib.Construct(MenuLines1.Parametre);
                            if Evaluate("Custom Print Object Type", StringLib.SelectStringSep(1, '?')) and Evaluate("Custom Print Object ID", StringLib.SelectStringSep(2, '?')) then
                                Modify;
                            //IF EVALUATE("Custom Print Object ID", MenuLines1.Parametre) THEN
                            //  MODIFY;
                            //+NPR4.21
                        end;

                    'PRINT_ITEM_LABEL':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            TouchScreenFunctions.PrintLabel(SaleLinePOS);
                        end;
                    'PRINT_ITEM_LABEL_ALL':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            SaleLinePOS.SetRecFilter;
                            SaleLinePOS.SetRange("Line No.");
                            TouchScreenFunctions.PrintLabelAll(SaleLinePOS);
                        end;
                    //-NPR5.35 [278757]
                    'PRINT_GUARANTEE':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            TouchScreenFunctions.PrintWarrantyCertificate(SaleLinePOS);
                        end;
                    //+NPR5.35 [278757]

                    /*----- PAYMENT -----*/
                    'FUNCTIONS_PAYMENT':
                        FindElement;
                    'PAYMENT_TYPE':
                        begin
                            if not State.IsCurrentView(ViewType.Payment) then
                                GotoPayment();
                            if State.IsCurrentView(ViewType.Payment) then begin
                                if This.Parameters <> '' then
                                    PaymentType(PaymentTypePOS."Processing Type"::Cash, This.Parameters);
                            end else
                                exit;
                        end;
                    'PAYMENT_GIFTVOUCHER':
                        PaymentType(PaymentTypePOS."Processing Type"::"Gift Voucher", '');
                    'PAYMENT_CREDITVOUCHER':
                        PaymentType(PaymentTypePOS."Processing Type"::"Credit Voucher", '');
                    'CREDITVOUCHER_CREATE':
                        begin
                            CreateCreditVoucher();

                            if PaymentLinePOSObject.LastSale(3) < TouchScreenFunctions.CalcPaymentRounding("Register No.")
                            then begin
                                IsCashSale := false;
                                EnterHit('AFSLUTBETALING');
                            end;

                        end;
                    //-NPR4.02
                    'HIDE_INPUT_DIALOG':
                        begin
                            HideInputDialog := true;
                        end;
                    'SHOW_INPUT_DIALOG':
                        begin
                            HideInputDialog := false;
                        end;
                    'QUICK_PAYMENT':
                        begin
                            if not State.IsCurrentView(ViewType.Payment) then
                                GotoPayment();
                            PaymentLinePOSObject.SetHideInputDialog(HideInputDialog);
                            PaymentLinePOSObject.CalculateBalance(Dec);
                            Register.Get("Register No.");
                            PaymentTypePOS.Get(Register."Primary Payment Type");
                            if PaymentLinePOSObject.CreatePaymentLine(PaymentTypePOS."No.", Dec, "Register No.", "Sales Ticket No.", Date, '', IsCashSale, '') = 1 then begin
                                Marshaller.DisplayError(Text10600200, PaymentLinePOSObject.GetErrorText, false);
                                Validering := '';
                                Register.Get("Register No.");
                                PaymentTypePOS.Get(Register."Primary Payment Type");
                                Error('');
                                exit;
                            end else begin
                                IsCashSale := false;
                                EnterHit('AFSLUTBETALING');
                            end;
                        end;
                    //+NPR4.02
                    /*----- GENERAL -----*/
                    'ENTERPUSH':
                        EnterPush;
                    'FUNCTIONS_ITEM':
                        Functions('ITEMFUNCTIONS');
                    'SALE_QUIT':
                        QueryClose;
                    'REGISTER_OPEN':
                        begin
                            if State.IsCurrentView(ViewType.Locked) then
                                exit(false);
                            PushRegisterOpen();
                            exit;
                        end;
                    //-NPR5.28
                    //       'GOTO_LINE'            : BEGIN
                    //                                  SalesLine.RESET;
                    //                                  SaleLinePOSObject.GETRECORD(SalesLine);
                    //                                  SalesLine.SETRECFILTER;
                    //                                  IF TouchScreenFunctions.GoToLine(This, SalesLine) THEN
                    //                                    SaleLinePOSObject.SetLine(SalesLine);
                    //                                END;
                    //+NPR5.28
                    'DELETE_LINE':
                        DeleteLine;
                    'LOOKUP':
                        begin
                            Lookup;
                            MenuLines1."Filter No." := '';
                        end;
                    'INFO':
                        ShowLineInformation();
                    'ZOOM':
                        ShowSaleLineDetails();
                    //-NPR5.27
                    //'DIMS_SALE'            : ShowDimensions;
                    'DIMS_SALE':
                        This.ShowDocDim;
                    //+NPR5.27
                    'TAX_FREE':
                        begin
                            //-NPR4.21
                            //MESSAGE('Tax Free Refund er sat til');
                            Message(TaxFreeEnabledMsg);
                            //+NPR4.21
                            IsTaxFreeEnabled := true;
                        end;
                    'SHOP_IN_SHOP':
                        begin
                            ExportSale(This);
                        end;

                    'AUDIT_ROLL_VIEW':
                        begin
                            Clear(AuditRollForm);
                            Clear(AuditRoll);

                            AuditRoll.SetRange("Register No.", "Register No.");
                            AuditRollForm.SetExtFilters(true);
                            AuditRollForm.SetTableView(AuditRoll);
                            AuditRollForm.RunModal;
                        end;
                    'GOBACK':
                        GoBack;
                    'GOTOROOT':
                        GoToRoot();

                        /*----- 2013 Additions ------*/
                    'REPEAT_ENTRY':
                        begin
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            Validering := SaleLinePOS."No.";
                            ButtonDefault;
                        end;
                    'TERMINAL_PAY': //-NPR4.11
                                    //PaymentType(PaymentTypePOS."Processing Type"::"Cash Terminal", Register."Touch Screen Credit Card");
                        begin
                            if not State.IsCurrentView(ViewType.Payment) then
                                GotoPayment();
                            PaymentType(PaymentTypePOS."Processing Type"::EFT, Register."Touch Screen Credit Card");
                        end;
                    //+NPR4.11
                    //-NPR5.22
                    'CUST_LOCATION_EXPORT':
                        if POSCustLocMgt.SaveSaleToLoc(MenuLines1.Parametre, This) then begin
                            NewSale();

                            if (Register."Touch Screen Login Type" = Register."Touch Screen Login Type"::Automatic) then begin
                                //Refresh state - currently necessary
                                SetScreenView(ViewType.Payment);
                                SetScreenView(ViewType.Sale);
                            end;

                            if Register."Touch Screen Login autopopup" and (Register."Touch Screen Login Type" <> Register."Touch Screen Login Type"::Automatic) then begin
                                Commit;
                                Validering := '';
                                EnterPush;
                            end;
                        end;
                    'CUST_LOCATION_IMPORT':
                        if POSCustLocMgt.GetSaleFromLoc(MenuLines1.Parametre, This, POSCustLocReceipt) then
                            LoadSavedSale(POSCustLocReceipt);
                    'CUST_LOCATION_LIST':
                        POSCustLocMgt.List(false, true);
                    'CUST_LOCATION_PRINT':
                        POSCustLocMgt.Print(0, This, MenuLines1.Parametre);
                    //-NPR5.31 [264112]
                    'CUST_LOCATION_STAMP_IMPORT':
                        if POSCustLocMgt.StampSaleAndGetFromLoc(MenuLines1.Parametre, This, POSCustLocReceipt) then
                            LoadSavedSale(POSCustLocReceipt);
                    //+NPR5.31 [264112]
                    //-NPR5.26 OSFI
                    'POS_INFO':
                        POSInfoManagement.ProcessPOSInfoMenuFunction(LastLineTemp, MenuLines1.Parametre);
                        //+NPR5.26 OSFI
                    else begin
                            //-NPR5.20
                            if MetaTriggerMgt.IsKeyword(FuncStr) then begin //Handle keywords that are not user defined and not listed in CASE above
                                                                            //+NPR5.20
                                Parameters := FuncStr;
                                ClearLastError();
                                if RetailSalesDocMgt.Run(This) or (GetLastErrorText <> '') then begin
                                    if (GetLastErrorText <> '') then
                                        //-NPR5.38 [300126]
                                        //ERROR(GETLASTERRORTEXT);
                                        Message(GetLastErrorText);
                                    //+NPR5.38 [300126]
                                end else
                                    if RetailSalesDocImpMgt.Run(This) or (GetLastErrorText <> '') then begin
                                        if (GetLastErrorText <> '') then
                                            //-NPR5.38 [300126]
                                            //ERROR(GETLASTERRORTEXT);
                                            Message(GetLastErrorText);
                                        //+NPR5.38 [300126]
                                    end else
                                        if FuncStr <> '' then begin
                                            Validering := FuncStr;
                                            EnterPush;
                                        end;
                                //-NPR5.20
                                //END;
                            end else
                                if FuncStr <> '' then begin
                                    Validering := FuncStr;
                                    EnterPush;
                                    //END;
                                    //+NPR5.20
                                end;
                        end;

                        HandleMetaTrigger(FuncStr, 1, This, SaleLinePOS);
                        //-NPR5.20
                end;
            //-NPR4.02
            //END ELSE IF FuncStr <> '' THEN BEGIN
            //  Validering := FuncStr;
            //  EnterPush;
            //END;
            //+NPR4.02
            //+NPR5.20
            Marshaller.RequestRefreshSalesLineData();
            Validering := '';
            Clear(MenuLines1);
            Find;
            exit(true);
        end;

    end;

    procedure "--- Aux"()
    begin
    end;

    procedure AutoDebit(): Boolean
    begin
        case Register."Customer No. auto debit sale" of
            Register."Customer No. auto debit sale"::Auto:
                begin
                    DebitSale();
                    exit(true);
                end;
            Register."Customer No. auto debit sale"::AskPayment:
                begin
                end;
            Register."Customer No. auto debit sale"::AskDebit:
                begin
                end;
        end;
    end;

    procedure ButtonDefault()
    var
        t003: Label 'Screenview: %1 \User ID: %2 \Type: %3 \Customer Type: %4 \Customer No: %5 \Is Cash Sale: %6';
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        Dec: Decimal;
    begin
        with This do begin
            SetScreenView(State.ViewType);

            if CopyStr(Validering, 1, 1) in ['�', '$', '?'] then begin
                CopyValidering := CopyStr(Validering, 2);
                Validering := '';
                if UpperCase(CopyStr(CopyValidering, 1, 4)) = 'PAY.' then begin
                    if not State.IsCurrentView(ViewType.Payment) then
                        GotoPayment();
                    if State.IsCurrentView(ViewType.Payment) then begin
                        if CopyStr(CopyValidering, 5) <> '' then
                            PaymentType(PaymentTypePOS."Processing Type"::Cash, CopyStr(CopyValidering, 5));
                    end else
                        exit;
                end else
                    if UpperCase(CopyStr(CopyValidering, 1, 4)) = 'SALE' then begin
                        if State.IsCurrentView(ViewType.Sale) then begin
                            ImportSale(CopyStr(CopyValidering, 5));
                        end;
                    end else
                        if UpperCase(CopyStr(CopyValidering, 1, 1)) = 'V' then begin
                            if State.IsCurrentView(ViewType.Sale) then begin
                                SaleLinePOSObject.ValidateVendorItemNoOnLine(CopyStr(CopyValidering, 2), This);
                            end;
                        end else
                            case UpperCase(CopyValidering) of
                                'USERID':
                                    Validering := UserId;
                                'R':
                                    Validering := ValideringLast;
                                'OBJECTID':
                                    begin
                                        Error('');
                                    end;
                                'VER':
                                    begin
                                        Validering := '';
                                        Error('');
                                    end;
                                'VARS':
                                    begin
                                        Validering := '';
                                        Marshaller.Error_Protocol('INFO', StrSubstNo(t003, State.ViewType, UserId, 'Sale', "Customer Type", "Customer No.", IsCashSale), true);
                                    end;
                                'SCREENVIEW':
                                    begin
                                        Validering := '';
                                        exit;
                                    end;
                                'URL':
                                    begin
                                        Error('');
                                    end;
                                'HALT':
                                    begin
                                        SetScreenView(ViewType.Halt);
                                        QueryClose;
                                    end;
                                else begin
                                        ExecFunction(ConvertStr(CopyValidering, '.?', '__'));
                                        exit;
                                    end;
                            end;
            end;

            if State.IsCurrentView(ViewType.Locked) then begin
                EnterHit('LOCKED');
                exit;
            end;

            ValideringLast := Validering;

            if State.IsCurrentView(ViewType.Sale) then begin
                if Validering = '*' then begin
                    CopyValidering := Validering;
                    Validering := '';
                    EnterHit('DESCRIPTION');
                    exit
                end;

                if Validering = '**' then begin
                    EnterHit('KONTANTKUNDE');
                    exit
                end;
                EnterHit('EKSPEDITION');
                exit;
            end;

            // LOGIN
            if State.IsCurrentView(ViewType.Login) then begin
                EnterHit('LOGIN');
                exit;
            end;

            // BETALING
            if State.IsCurrentView(ViewType.Payment) then begin
                if Validering <> '' then begin
                    PaymentLinePOSObject.CalculateBalance(Dec);
                    if (Dec < TouchScreenFunctions.CalcPaymentRounding("Register No.")) then begin
                        IsCashSale := false;                              // BETALING ok!
                        EnterHit('AFSLUTBETALING');
                        exit;
                    end;
                    Register.Get("Register No.");
                    PaymentTypePOS.Get(Register."Primary Payment Type");
                    EnterHit('PAYMENT');
                end else begin
                    PaymentLinePOSObject.CalculateBalance(Dec);
                    if (Dec < TouchScreenFunctions.CalcPaymentRounding("Register No.")) then begin
                        IsCashSale := false;                              // BETALING ok!
                        EnterHit('AFSLUTBETALING');
                        exit;
                    end;
                    Register.Get("Register No.");
                    PaymentTypePOS.Get(Register."Primary Payment Type");
                    EnterHit('PAYMENT');
                end;
            end;

            if State.IsCurrentView(ViewType.SubFindItem) then EnterHit('SUBFINDVARE');
            if State.IsCurrentView(ViewType.SubFindAccount) then EnterHit('SUBFINDKONTO');
            if State.IsCurrentView(ViewType.SubFindCustomer) then EnterHit('SUBFINDDEBITOR');
            if State.IsCurrentView(ViewType.SubFindPayment) then EnterHit('SUBFINDBETALING');
            if State.IsCurrentView(ViewType.BalanceRegister) then EnterHit('KASSEAFSLUTNING');

            SaleLinePOSObject.CalculateBalance;
        end;
    end;

    procedure CancelSale(): Boolean
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        tmpBonnummer: Code[20];
        FormCode: Codeunit "Retail Form Code";
    begin
        //AnnullerEkspedition

        with This do begin

            if State.IsCurrentView(ViewType.Halt) then exit;

            FormCode.CancelSalesTicket(This);

            IsCashSale := false;

            DeleteDimOnEkspAndLines;
            //-NPR5.31 [271728]
            Validate("Customer No.", '');
            //+NPR5.31 [271728]

            "Register No." := FormCode.FetchRegisterNumber;
            TouchScreen := true;
            Register.Get("Register No.");

            "Sales Ticket No." := FormCode.FetchSalesTicketNumber("Register No.");
            tmpBonnummer := "Sales Ticket No.";

            "Salesperson Code" := '';
            //-NPR5.31 [271728]
            //"Customer No." := '';
            //+NPR5.31 [271728]
            "Saved Sale" := false;

            //-NPR5.28 [254575]
            Clear("Issue Tax Free Voucher");
            Clear(IsTaxFreeEnabled);
            Clear("Send Receipt Email");
            Clear("Customer Location No.");
            //+NPR5.28 [254575]

            SetSaleScreenVisible();

            "Sales Ticket No." := tmpBonnummer;

            TouchScreenFunctions.TestSalesDate;

            FilterGroup := 2;
            SetRange("Register No.", "Register No.");
            SetRange("Sales Ticket No.", "Sales Ticket No.");
            FilterGroup := 0;

            TouchScreenFunctions.SetRegisterStatus(This, true);
            SetScreenView(ViewType.Login);
            "Salesperson Code" := '';

            //-NPR5.23
            //  IF Register."Customer Display" THEN
            //    WriteToCustomerDisplay(t002, Register);
            //-NPR5.46 [328581]
            //CustomerDisplayMgt.OnPOSAction(This,Register,2,'');
            //+NPR5.46 [328581]
            //+NPR5.23

            TouchScreen := true;
            Commit;

            Validering := '';

            SetSaleScreenVisible();
        end;
    end;

    procedure CreateCreditVoucher(): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSTest: Record "Sale Line POS";
        LineNo: Integer;
        "Action": Action;
        t001: Label 'Credit voucher was not created!';
        t002: Label 'Credit voucher value:';
        t003: Label 'The total must be negative.';
        Dec: Decimal;
    begin
        //TilgodebevisKnap
        with This do begin
            PaymentLinePOSObject.CalculateBalance(Dec);

            if Dec >= 0 then
                Marshaller.Error_Protocol(t001, t003, true);

            Dec := -Dec;
            if not Marshaller.NumPad(t002, Dec, true, false) then
                Error('');
            if Dec < 0 then
                Dec := -Dec;

            SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.");
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Date);
            SaleLinePOS.SetFilter("Sale Type", '%1|%2', SaleLinePOS."Sale Type"::Sale
                                                           , SaleLinePOS."Sale Type"::Deposit
                                                           , SaleLinePOS."Sale Type"::"Out payment");
            if SaleLinePOS.Find('+') then LineNo := SaleLinePOS."Line No." + 10000 else LineNo := 10000;
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := "Register No.";
            SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
            SaleLinePOS."Line No." := LineNo;
            SaleLinePOS.Date := Date;
            SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
            SaleLinePOS.Validate("No.", Register."Credit Voucher Account");
            SaleLinePOS."Location Code" := Register."Location Code";
            SaleLinePOS."Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
            SaleLinePOS.Quantity := 1;
            //-NPR5.31 [269754]
            //SaleLinePOS.Description := Text10600071;
            //+NPR5.31 [269754]

            //-NPR5.20
            //IF PaymentLinePOSObject.CreateGiftVoucher(SaleLinePOS,UI.FormatDecimal(Dec)) THEN BEGIN
            if PaymentLinePOSObject.CreateGiftVoucher(SaleLinePOS, Dec) then begin
                //+NPR5.20
                //-NPR5.31 [269754]
                SaleLinePOS.Description := StrSubstNo(Text10600071, SaleLinePOS."Credit voucher ref.");
                //+NPR5.31 [269754]
                SaleLinePOS.Insert;

                CopyValidering := '';

                PaymentLinePOSObject.CalculateBalance(Dec);

                SaleLinePOSTest.SetRange("Register No.", "Register No.");
                SaleLinePOSTest.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOSTest.SetRange(Date, Date);
                if SaleLinePOSTest.FindSet then
                    repeat
                        if (SaleLinePOSTest."Sale Type" <> SaleLinePOSTest."Sale Type"::Payment) and
                          (SaleLinePOSTest.Type <> SaleLinePOSTest.Type::Payment) and (SaleLinePOSTest.Type <> SaleLinePOSTest.Type::Comment) then begin
                            if SaleLinePOSTest.Quantity = 0 then Error(Text10600013, SaleLinePOSTest."No.");
                            if SaleLinePOSTest."Unit Price" = 0 then Error(Text10600014, SaleLinePOSTest."No.");
                        end;
                    until SaleLinePOSTest.Next = 0;
            end else begin
                Commit;
                Marshaller.Error_Protocol(Text10600200, t001, true);
            end;

        end;
    end;

    procedure DebitSale()
    var
        FormCode: Codeunit "Retail Form Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        sl: Record "Sale Line POS";
    begin
        // Betaldebet
        //-NPR5.30 [267291]
        OnBeforeDebitSale(This);
        //+NPR5.30 [267291]
        with This do begin
            sl.SetRange("Register No.", "Register No.");
            sl.SetRange("Sales Ticket No.", "Sales Ticket No.");
            sl.SetRange(Date, Today);
            sl.SetRange("Sale Type", sl."Sale Type"::Deposit);
            sl.SetRange(Type, sl.Type::Customer);
            sl.DeleteAll(true);
            //-NPR4.14
            //IF ("Customer Type" = "Customer Type"::Ord) AND ("Customer No." <> '') THEN BEGIN
            //   FormCode.CreateSalesHeader(This, TempSalesHeader);
            //   IF TransferToInvoice() THEN BEGIN
            //      Register.GET("Register No.");
            //      NewSale();
            //   END;
            //   EXIT;
            //END;
            //+NPR4.14
            if "Customer No." = '' then begin
                if not TouchScreenFunctions.SaleDebit(This, TempSalesHeader, Validering, false) then
                    Error('');
                //-NPR4.14
                if ("Customer Type" = "Customer Type"::Ord) and ("Customer No." <> '') then begin
                    //-NPR5.26 [246774]
                    if Confirm(Text10600216, true) then begin
                        //+NPR5.26 [246774]
                        FormCode.CreateSalesHeader(This, TempSalesHeader);
                        if TransferToInvoice() then begin
                            Register.Get("Register No.");
                            NewSale();
                        end;
                        exit;
                        //-NPR5.26 [246774]
                    end else begin
                        "Customer No." := '';
                        Modify;
                        exit;
                    end;
                    //+NPR5.26 [246774]
                end;
                //+NPR4.14
                exit;
            end else begin
                //-NPR5.23
                if "Customer Type" = "Customer Type"::Ord then begin
                    //-NPR5.26 [246774]
                    if Confirm(Text10600216, false) then begin
                        //+NPR5.26 [246774]
                        FormCode.CreateSalesHeader(This, TempSalesHeader);
                        if TransferToInvoice() then begin
                            Register.Get("Register No.");
                            NewSale();
                        end;
                        exit;
                        //-NPR5.26 [246774]
                    end else
                        exit;
                    //+NPR5.26 [246774]
                end;
                //+NPR5.23
            end;

            if ("Customer Type" <> "Customer Type"::Ord) then begin
                exit;
            end;
        end;
    end;

    procedure DeleteLine()
    var
        "Retail Sales Line Code": Codeunit "Retail Sales Line Code";
    begin
        //deleteline
        with This do begin
            if State.IsCurrentView(ViewType.Sale) then begin
                if "Retail Sales Line Code".LineExists(This) then begin
                    SaleLinePOSObject.DeleteActiveRecord("Customer No.");
                end;
            end;

            if State.IsCurrentView(ViewType.Payment) then begin
                PaymentLinePOSObject.DeleteRecord('');
            end;
            OnAfterAfterGetCurrentRecord();
            UpdatePosition := true;

            //-NPR5.26
            //-NPR5.46 [328581]
            //CustomerDisplayMgt.OnPOSAction(This,Register,3,'');
            //+NPR5.46 [328581]
            //+NPR5.26
        end;
    end;

    procedure EndSale() retur: Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
        ConfTaxFree: Label 'Do you wish to print Tax free receipt ?';
        HeadConfTaxFree: Label 'Tax Free';
        FormCode: Codeunit "Retail Form Code";
        POSSale: Codeunit "POS Sale";
        Dec: Decimal;
        ChangeInsertedAsOutPayment: Decimal;
        POSGiveChange: Codeunit "POS Give Change";
    begin
        //AfslutEKSPEDITION
        with This do begin
            PaymentLinePOSObject.CalculateBalance(Dec);

            //-NPR5.26
            //-NPR5.46 [328581]
            //CustomerDisplayMgt.OnPOSAction(This,Register,4,UI.FormatDecimal(Dec));
            //+NPR5.46 [328581]
            //+NPR5.26

            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange("Credit Card Tax Free", true);
            if SaleLinePOS.Find('-') then
                IsTaxFreeEnabled := Marshaller.Confirm(HeadConfTaxFree, ConfTaxFree);

            //-NPR4.21
            "Issue Tax Free Voucher" := IsTaxFreeEnabled;
            //+NPR4.21

            Modify;
            //-NPR5.37 [293711]
            ChangeInsertedAsOutPayment := POSGiveChange.CalcAndInsertChange(This);
            PaymentLinePOSObject.CalculateBalance(Dec);
            //+NPR5.37 [293711]

            retur := FormCode.FinishSale(This, Dec, 0, true, TempSalesHeader,
                                               SaleLinePOSObject.GetBalance);
            //-NPR5.39 [302779]
            Commit;
            POSSale.InvokeOnFinishSaleWorkflow(This);
            Commit;
            if CODEUNIT.Run(CODEUNIT::"POS End Sale Post Processing", This) then;
            //+NPR5.39 [302779]
            //-NPR5.37 [293711]
            retur := retur + ChangeInsertedAsOutPayment;
            //+NPR5.37 [293711]

            //-NPR4.21
            //  IF IsTaxFreeEnabled THEN BEGIN
            //    AuditRoll.SETRANGE("Sales Ticket No.", This."Sales Ticket No.");
            //    AuditRoll.SETRANGE("Register No.", "Register No.");
            //    IF AuditRoll.FIND('-') THEN BEGIN
            //      Table := AuditRoll;
            //      LinePrintMgt.ProcessPrint(CODEUNIT::"Report - Tax Free Receipt",Table)
            //    END;
            //  END;
            //+NPR4.21

            SaleInit(true, false);

            ShowLastSaleInformation();
        end;
    end;

    procedure EnterHit(str: Text[250])
    var
        RetailFormCode: Codeunit "Retail Form Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        ItemComment: Record Item;
        SalesLineCopy: Record "Sale Line POS";
        ReturnReason: Record "Return Reason";
        SaleLinePOS: Record "Sale Line POS";
        Salesperson: Record "Salesperson/Purchaser";
        Item: Record Item;
        RetailEkspLineCode: Codeunit "Retail Sales Line Code";
        newtxt: Text[1024];
        strpos1: Integer;
        strlen1: Integer;
        t004: Label 'This register is locked!';
        t005: Label 'Register unlocked!';
        t008: Label 'No sales from the register.';
        t009: Label 'Register %1 not configured for Sales!';
        t010: Label 'Register %1 has now been balanced.';
        t011: Label 'Register is locked! \Type in unlock code to open.';
        t012: Label 'Locking register';
        t013: Label 'Return reason must be chosen ';
        Code20: Code[20];
        Code10: Code[10];
        t017: Label 'New sales ticket no.';
        t018: Label 'Register balancing cancelled';
        RegNo: Code[20];
        ReceiptNo: Code[20];
        Pling: Char;
        pos: Integer;
        Qty: Decimal;
        tempstr: Code[250];
        CurrAntal: Decimal;
        ExchangeLabelMgt: Codeunit "Exchange Label Management";
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MemberReturnCode: Integer;
        TicketRetailManagement: Codeunit "TM Ticket Retail Management";
        TicketReturnCode: Integer;
    begin
        with This do begin
            SaleLinePOSObject.SetTableView("Register No.", "Sales Ticket No.");
            PaymentLinePOSObject.SetTableView("Register No.", "Sales Ticket No.");

            str := UpperCase(str);

            if State.IsCurrentView(ViewType.Locked) then begin
                if not Marshaller.NumPadCode(t011, Validering, false, true) then
                    Error('');

                if Validering = RetailSetup."Open Register Password" then begin
                    SetScreenView(ViewType.Login);
                    Validering := '';
                    Marshaller.DisplayError(t012, t005, false);
                    "Salesperson Code" := '';
                    SetSaleScreenVisible();
                    //-NPR5.23
                    //TouchScreenFunctions.Write2Display(This,Register,1,'');
                    //-NPR5.46 [328581]
                    //CustomerDisplayMgt.OnPOSAction(This,Register,0,'');
                    //+NPR5.46 [328581]
                    //+NPR5.23
                    exit;
                end else begin
                    Validering := '';
                    Marshaller.Error_Protocol(t012, t004, true);
                end;
            end;

            // --------------------------------- BETALING
            if str = 'PAYMENT' then begin
                PaymentType(PaymentTypePOS."Processing Type"::Cash, PaymentTypePOS."No.");
                Register.Get("Register No.");
                PaymentTypePOS.Get(Register."Primary Payment Type");
                Validering := '';
            end;

            // ------------------------------- AFSLUTBETALING
            if str = 'AFSLUTBETALING' then begin
                EndPayment();
                IsCashSale := false;
                Validering := '';
                SetSaleScreenVisible();
                ShowLastSaleInformation();
                Commit;
                if Register."Touch Screen Login autopopup" then begin
                    Validering := '';
                    EnterPush;
                end;
                exit;
            end;

            // ------------------------ LOGIN
            if str = 'LOGIN' then begin
                CopyValidering := Validering;
                Validering := '';

                if CopyValidering = '' then
                    exit;
                //-NPR5.23
                //TouchScreenFunctions.Write2Display(This,Register,1,'');
                //-NPR5.46 [328581]
                //CustomerDisplayMgt.OnPOSAction(This,Register,0,'');
                //+NPR5.46 [328581]
                //+NPR5.23
                if StrPos(CopyValidering, '*') > 0 then
                    CopyValidering := CopyStr(CopyValidering, 1, StrLen(CopyValidering) - 1);
                Register.Get("Register No.");
                //"Price including VAT" := Register."Price including VAT std.";
                "Price including VAT" := true;
                if not GetSalesPersonCode() then
                    exit;
                //-NPR5.20
                SessionMgt.SetSalespersonCode("Salesperson Code");
                //+NPR5.20
                SaleLinePOSObject.CalculateBalance;
                "Location Code" := Register."Location Code";
                "Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
                "Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
                Modify(true);

                case TouchScreenFunctions.RegisterTestOpen(This) of
                    Register.Status::" ":  /* register not init */
                        begin
                            Message(t009, "Register No.");
                            Commit;
                            SetScreenView(ViewType.BalanceRegister);
                            QueryClose;
                        end;
                    Register.Status::Afsluttet:
                        begin
                        end;
                    Register.Status::Ekspedition:  /* normal login */
                        begin
                            SetScreenView(ViewType.Sale);
                            Register.Get("Register No.");
                            SetSaleScreenVisible();
                            FilterGroup := 2;
                            SetRange("Register No.", "Register No.");
                            SetRange("Sales Ticket No.", "Sales Ticket No.");
                            FilterGroup := 0;
                        end;
                    10: /* No, don't open register */
                        begin
                            Marshaller.Error_Protocol(t018, t008, true);
                            SetScreenView(ViewType.BalanceRegister);
                            QueryClose;
                        end;
                    11: /* register not closed prior today */
                        begin

                            RegNo := "Register No.";
                            ReceiptNo := "Sales Ticket No.";

                            NewSalesTicketNo(t017);

                            if not RetailFormCode.BalanceRegister(This) then begin
                                Message(t008);
                                Commit;
                                SetScreenView(ViewType.BalanceRegister);
                                QueryClose;
                            end else begin
                                Message(t010, This."Register No.");
                                Commit;
                                SetScreenView(ViewType.BalanceRegister);
                                QueryClose;
                            end;
                        end;
                    12: /* register just opened */
                        begin
                            Salesperson.Get("Salesperson Code");
                            NewSale();
                            Validering := Salesperson."Register Password";
                            EnterHit('LOGIN');
                        end;
                end;
                SetSaleScreenVisible();
            end;

            // ----------------------- EKSPEDITION, FIND VARE/DEBITOR/KONTO
            if (str = 'EKSPEDITION') then begin

                TouchScreenFunctions.TestSalesDate;

                case RetailEkspLineCode.GetAltNoType(Validering) of
                    0:
                        ;  /* Item */
                    1:    /* Customer */
                        begin
                            ExecFunction('CUSTOMER_STD');
                            exit;
                        end;
                    2:    /* CRM Customer */
                        begin
                            ExecFunction('CUSTOMER_CRM');
                            exit;
                        end;
                end;

                SetScreenView(ViewType.Sale);

                CopyValidering := Validering;
                IsCashSale := false;
                Validering := '';

                if (StrLen(CopyValidering) > 1) then begin

                    //-NPR4.10
                    /* EXCHANGE LABEL */
                    if ExchangeLabelMgt.ScanExchangeLabel(This, Validering, CopyValidering) then
                        exit;
                    //+NPR4.10


                    /* QUANTITY */
                    if (StrPos(CopyValidering, '*') = StrLen(CopyValidering)) then begin
                        newtxt := DelStr(CopyValidering, StrLen(CopyValidering), 1);
                        if UI.TryParseDecimal(CurrAntal, newtxt) then CopyValidering := '';
                        SaleLinePOSObject.ChangeQuantityOnActiveLine(This, CurrAntal);
                        if RetailSetup."Reason for Return Mandatory" then
                            SaleLinePOSObject.SetReturnReason('');
                        exit;
                    end;

                    /* NEG. QUANTITY */

                    if (StrPos(CopyValidering, '-') = StrLen(CopyValidering)) then begin
                        newtxt := DelStr(CopyValidering, StrLen(CopyValidering), 1);
                        if UI.TryParseDecimal(CurrAntal, '-' + newtxt) then CopyValidering := '';
                        SaleLinePOSObject.ChangeQuantityOnActiveLine(This, CurrAntal);
                        if RetailSetup."Reason for Return Mandatory" then begin
                            Commit;
                            if PAGE.RunModal(PAGE::"Touch Screen - Return Reasons", ReturnReason) = ACTION::LookupOK then begin
                                SaleLinePOSObject.SetReturnReason(ReturnReason.Code);
                            end else
                                Error(t013);
                        end;
                        if RetailSetup."Reset unit price on neg. sale" then begin
                            SaleLinePOSObject.ChangeUnitPriceOnActiveLine(0);
                            Commit;
                            SetLineAmount(0);
                        end;
                        exit;
                    end;

                    /* % DISCOUNT */

                    if ((StrPos(CopyValidering, '/') = StrLen(CopyValidering)) and
                       (StrPos(CopyValidering, '+') = 0)) or ((StrPos(CopyValidering, '�') = StrLen(CopyValidering)) and
                       (StrPos(CopyValidering, '+') = 0)) then begin
                        newtxt := DelStr(CopyValidering, StrLen(CopyValidering), 1);
                        if UI.TryParseDecimal(CurrAntal, newtxt) then CopyValidering := '';
                        SaleLinePOSObject.GETRECORD(SaleLinePOS);
                        TouchScreenFunctions.CheckLine(SaleLinePOS);
                        Code10 := RetailEkspLineCode.AskReasonCode;
                        SaleLinePOSObject.ChangeDiscountOnActiveLine(CurrAntal, false);
                        SaleLinePOSObject.SetReasonCode(Code10);
                        exit;
                    end;

                    /* EXTRA DISCOUNT % */

                    if ((StrPos(CopyValidering, '/') = StrLen(CopyValidering)) and
                       (StrPos(CopyValidering, '+') = 1)) or ((StrPos(CopyValidering, '�') = StrLen(CopyValidering)) and
                       (StrPos(CopyValidering, '+') = 1)) then begin
                        newtxt := DelStr(CopyValidering, StrLen(CopyValidering), 1);
                        if UI.TryParseDecimal(CurrAntal, newtxt) then CopyValidering := '';
                        SaleLinePOSObject.GETRECORD(SaleLinePOS);
                        TouchScreenFunctions.CheckLine(SaleLinePOS);
                        Code10 := RetailEkspLineCode.AskReasonCode;
                        SaleLinePOSObject.ChangeDiscountOnActiveLine(CurrAntal, true);
                        SaleLinePOSObject.SetReasonCode(Code10);
                        exit;
                    end;

                    /* AMOUNT */

                    if (StrPos(CopyValidering, '+') = StrLen(CopyValidering)) then begin
                        Validering := DelStr(CopyValidering, StrLen(CopyValidering), 1);
                        SetLineAmount(2);
                        exit;
                    end;

                    /* DESCRIPTION */

                    Pling := 39;
                    pos := StrPos(CopyValidering, Format(Pling));
                    if (pos = 1) then begin
                        newtxt := DelStr(CopyValidering, StrLen(CopyValidering), 1);
                        if UI.TryParseDecimal(CurrAntal, newtxt) then CopyValidering := '';
                        SaleLinePOSObject.GETRECORD(SaleLinePOS);
                        TouchScreenFunctions.CheckLine(SaleLinePOS);
                        SaleLinePOS.Description := DelStr(CopyValidering, pos, 1);
                        SaleLinePOS.Modify;
                        exit;
                    end;


                end;

                strpos1 := StrPos(CopyValidering, '*');
                strlen1 := StrLen(CopyValidering);

                /* QUANTITY & ITEM */

                if (strpos1 = strlen1) and (strlen1 > 1) then begin
                    CopyValidering := CopyStr(CopyValidering, 1, strlen1 - 1);
                end;
                if (strpos1 < strlen1) and (strlen1 > 1) and (strpos1 > 0) then begin
                    newtxt := CopyStr(CopyValidering, 1, strpos1 - 1);
                    CopyValidering := CopyStr(CopyValidering, strpos1 + 1);

                    SaleLinePOSObject.JumpEnd;

                    if CopyValidering <> '' then begin

                        if not SaleLinePOSObject.InsertItemLine(CopyValidering, This) then begin
                            SaleLinePOSObject.SetValidation('');
                            Marshaller.Error_Protocol(Text10600200, StrSubstNo(Text10600107, CopyValidering), true);
                        end else
                            if (MenuLines1.Parametre <> '') and UI.TryParseDecimal(Qty, MenuLines1.Parametre) then begin
                                SaleLinePOSObject.ChangeQuantityOnActiveLine(This, Qty);
                            end;

                        if UI.TryParseDecimal(CurrAntal, newtxt) then CopyValidering := '';
                        SaleLinePOSObject.ChangeQuantityOnActiveLine(This, CurrAntal);

                        /* GROUP SALE ITEM */
                        if SaleLinePOSObject.IsGroupSale() then begin
                            Commit;
                            Code20 := '';
                            if SaleLinePOS."Unit Price" = 0 then
                                if not SetLineAmount(1) then;
                        end;

                        if (SaleLinePOS.Type = SaleLinePOS.Type::Item) then begin
                            if ItemComment.Get(SaleLinePOS."No.") then begin
                                ItemComment.CalcFields(Comment);
                                if ItemComment.Comment and RetailSetup."Item remarks" then begin
                                    Commit;
                                end;
                            end;
                        end;

                    end;
                    SaleLinePOSObject.JumpEnd;
                    exit;
                end;

                // SaleLinePOSObject.JumpEnd;
                //-NPR4.10
                /*
                IF (STRLEN(CopyValidering) = 13) AND (COPYSTR(CopyValidering,1,2)= RetailSetup."EAN Prefix Exhange Label") THEN BEGIN
                  "Retursalg Bonnummer" := CopyValidering;
                  MODIFY;
                  COMMIT;
                  returnvalue := RetailSalesCode.Tilbagef�rBon(This); //GlobalSalePOS
                  SaleLinePOS.RESET;
                  SaleLinePOS.SETRANGE("Register No.","Register No.");
                  SaleLinePOS.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                  SaleLinePOS.SETRANGE(Type, SaleLinePOS.Type::Item);
                  IF SaleLinePOS.FIND('-') THEN BEGIN
                    SaleLinePOS.VALIDATE("No.");
                    SaleLinePOS.MODIFY;
                  END;

                  EXIT;
                END;
                */
                //+NPR4.10

                if CopyValidering <> '' then begin
                    /* INSERT LINE */

                    if not SaleLinePOSObject.InsertItemLine(CopyValidering, This) then begin
                        SaleLinePOSObject.SetValidation('');
                        Marshaller.Error_Protocol(Text10600200, StrSubstNo(Text10600107, CopyValidering), true);
                    end else
                        if MenuLines1.Parametre <> '' then begin
                            Qty := UI.ParseDecimal(MenuLines1.Parametre);
                            SaleLinePOSObject.ChangeQuantityOnActiveLine(This, Qty);
                        end;

                    SaleLinePOSObject.GETRECORD(SaleLinePOS);

                    /* GROUP SALE ITEM */
                    if SaleLinePOSObject.IsGroupSale() then begin
                        Commit;
                        Code20 := '';
                        if SaleLinePOS."Unit Price" = 0 then
                            if not SetLineAmount(1) then;
                    end;

                    if Item.Get(SaleLinePOSObject.GetLineItemNumber) then begin
                        if (Item."Costing Method" = Item."Costing Method"::Specific) and
                           (SaleLinePOS."Serial No." = '') then begin
                            Commit;
                            Code20 := '';
                            if not ExecFunction('SERIAL_NUMBER') then;
                        end;
                    end;

                    //-MM80.1.05
                    MemberReturnCode := MemberRetailIntegration.NewMemberSalesInfoCapture(SaleLinePOS);
                    if (MemberReturnCode < 0) then
                        Marshaller.DisplayError(Text10600200, MemberRetailIntegration.GetErrorText(MemberReturnCode), true);
                    //+MM80.1.05

                    //-TM1.09
                    TicketReturnCode := TicketRetailManagement.NewTicketSalesAdmissionCapture(SaleLinePOS);
                    if (TicketReturnCode < 0) then
                        Marshaller.DisplayError(Text10600200, TicketRetailManagement.GetErrorMessage(TicketReturnCode), true);
                    //+TM1.09

                    SaleLinePOSObject.GETRECORD(SaleLinePOS);
                    Commit;
                    RetailEkspLineCode.OnAfterInsertSalesLine(SaleLinePOS, SalesLineCopy);
                    Register.Get("Register No.");
                    //-NPR5.23
                    SaleLinePOSObject.UpdateCustomerDisplay();
                    //+NPR5.23
                    if "Customer No." <> '' then begin
                        if AutoDebit then
                            exit;
                    end;
                end;
            end;

            // ----------------------- FIND BETALING

            if (str = 'SUBFINDBETALING') then begin
                SetScreenView(ViewType.Payment);
                PaymentType(PaymentTypePOS."Processing Type"::Cash, PaymentTypePOS."No.");
                Validering := '';
                Validering := '';
            end;

            // --------------------------------- DESCRIPTION
            if str = 'DESCRIPTION' then begin
                SaleLinePOSObject.InsertItemLine(CopyValidering, This);
                Validering := '';
            end;

            // --------------------------------- KONTANT KUNDE
            if str = 'KONTANTKUNDE' then begin
                tempstr := '<KONTANT>';
                TouchScreenFunctions.SaleCashCustomer(This, TempSalesHeader, Validering);
                Validering := '';
            end;

            // --------------------------------- DEBET KUNDE
            if str = 'DEBITCUSTOMER' then begin
                tempstr := '<DEBET>';
                if Validering <> '' then
                    "Customer No." := Validering;
                if not TouchScreenFunctions.SaleDebit(This, TempSalesHeader, Validering, false) then
                    exit;
                Validate("Customer No.");
                Modify;
                Validering := '';
            end;

            // --------------------------------- DEBET KUNDE
            if str = 'DEBITSTAFF' then begin
                tempstr := '<DEBET>';
                if Validering <> '' then
                    "Customer No." := Validering;
                if not TouchScreenFunctions.SaleDebit(This, TempSalesHeader, Validering, true) then
                    exit;
                Validate("Customer No.");
                Modify;
                Validering := '';
            end;

            // --------------------------------- ACCOUNT
            if str = 'ACCOUNT' then begin
                tempstr := '<ACCOUNT>';
                if Validering = '' then Lookup;
                SaleLinePOSObject.SetValidation(Validering);
                SaleLinePOSObject.InsertItemLine(tempstr, This);
                Validering := '';
            end;


            // --------------------------------- FORSIKRING
            if str = 'FORSIKRING' then begin
                This.Parameters := Validering;
                Validering := '';
                SetScreenView(ViewType.Sale);
                TouchScreenFunctions.InsertInsurrance(This);
            end;

            Validering := '';
            SaleLinePOSObject.JumpEnd;
        end;

    end;

    procedure EndPayment()
    var
        Testlinie: Record "Sale Line POS";
        FormCode: Codeunit "Retail Form Code";
        Dec: Decimal;
        VarSaleLinePOS: Record "Sale Line POS";
    begin
        //AfslutBetaling
        with This do begin

            Commit;

            FormCode.OnEndsaleChecklines(This, SaleLinePOSObject.GetBalance);

            FormCode.SaleStat(This);


            PaymentLinePOSObject.CalculateBalance(Dec);

            // tester gennem linier
            Testlinie.SetRange("Register No.", "Register No.");
            Testlinie.SetRange("Sales Ticket No.", "Sales Ticket No.");
            Testlinie.SetRange(Date, Date);
            if Testlinie.Find('-') then
                repeat
                    if (Testlinie."Sale Type" <> Testlinie."Sale Type"::Payment) and
                      (Testlinie.Type <> Testlinie.Type::Payment) and (Testlinie.Type <> Testlinie.Type::Comment) then begin
                    end;
                until Testlinie.Next = 0;

            Testlinie.SetRange("Sale Type", Testlinie."Sale Type"::Payment);
            Testlinie.SetRange(Type, Testlinie.Type::Payment);
            if Testlinie.Find('-') then
                repeat
                    PaymentTypePOS.Get(Testlinie."No.");
                    if PaymentTypePOS."Account Type" = PaymentTypePOS."Account Type"::"G/L Account" then
                        PaymentTypePOS.TestField("G/L Account No.");
                    PaymentTypePOS.TestField(Status, PaymentTypePOS.Status::Active);
                    if (PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::EFT) and
                       (Testlinie."Amount Including VAT" <> 0) and (not Testlinie."Cash Terminal Approved") then begin
                        Commit;
                        CODEUNIT.Run(CODEUNIT::"Call Terminal Integration", Testlinie);
                        Commit;
                        if not Testlinie."Cash Terminal Approved" then
                            Error(Text10600027);
                    end;
                    //-NPR5.26
                    //Temp-
                    //temp commented out because of compile error
                    //IF (PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Gift Voucher") AND
                    //   (Testlinie."Amount Including VAT" <> 0) AND (NOT Testlinie."Cash Terminal Approved") THEN BEGIN
                    //    IF CashKeeperSetup.GET("Register No.") THEN BEGIN
                    //      IF Dec < 0 THEN BEGIN
                    //        VarSaleLinePOS.RESET;
                    //        VarSaleLinePOS := Testlinie;
                    //        VarSaleLinePOS."Amount Including VAT" := Dec;
                    //        CODEUNIT.RUN(6059949,VarSaleLinePOS);
                    //      END;
                    //    END;
                    //END;
                    //TEmp+
                    //+NPR5.26
                    if (PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::DIBS) and
                       (Testlinie."Amount Including VAT" <> 0) and (not Testlinie."Cash Terminal Approved") then begin
                        if (not Testlinie."Cash Terminal Approved") then begin
                            Commit;
                            if not Testlinie."Cash Terminal Approved" then
                                Error(Text10600027);
                        end;
                    end;
                until Testlinie.Next = 0;

            //-NPR5.26
            //Temp-
            //temp commented out because of compile error
            //  IF CashKeeperSetup.GET("Register No.") THEN BEGIN
            //    VarSaleLinePOS.RESET;
            //    VarSaleLinePOS.SETRANGE("Register No.","Register No.");
            //   VarSaleLinePOS.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            //    VarSaleLinePOS.SETRANGE(Date,Date);
            //    VarSaleLinePOS.SETRANGE("Sale Type",VarSaleLinePOS."Sale Type"::Sale);
            //    IF VarSaleLinePOS.FINDSET THEN BEGIN
            //      VarSaleLinePOS.CALCSUMS("Amount Including VAT");
            //      IF VarSaleLinePOS."Amount Including VAT" < 0 THEN
            //        CODEUNIT.RUN(6059948,VarSaleLinePOS);
            //    END;
            //  END;
            //Temp+
            //+NPR5.26

            if Testlinie.Find('-') then;

            LastSaleFigures[1] := PaymentLinePOSObject.LastSale(1);
            LastSaleFigures[2] := PaymentLinePOSObject.LastSale(2);
            LastSaleFigures[3] := EndSale;

            Register.Get("Register No.");

            "Customer No." := '';

        end;
    end;

    procedure EnterPush() ret: Boolean
    var
        t001: Label 'Type item number, EAN or short code. Max. 20 characters.';
        t002: Label 'Type in your sales code and press ENTER.';
        newRegNo: Code[20];
        RetailFormCode: Codeunit "Retail Form Code";
        newRegister: Record Register;
        t004: Label 'Invalid register number %1';
        "Retail Sales Line Code": Codeunit "Retail Sales Line Code";
        DoExit: Boolean;
    begin
        //EnterPush

        ret := true;
        CopyValidering := Validering;
        Validering := '';

        if CopyValidering <> '' then
            newRegNo := RetailFormCode.GetRegisterFromAltNo(CopyValidering);

        if newRegNo <> '' then begin
            if "Retail Sales Line Code".LineExists(This) then
                Marshaller.Error_Protocol(Text10600200, Text10600051, true);
            if not newRegister.Get(newRegNo) then begin
                Marshaller.Error_Protocol(Text10600200, StrSubstNo(t004, newRegNo), true);
                Error('');
            end;
            Register.setThisRegisterNo(newRegNo);
            SetScreenView(ViewType.RegisterChange);
            QueryClose;
            exit(true);
        end;

        case true of
            State.IsCurrentView(ViewType.Login):
                begin
                    case Register."Touch Screen Login Type" of
                        //-NPR5.27 [254925]
                        //Register."Touch Screen Login Type"::Automatic :
                        //  BEGIN
                        //    IF CopyValidering = '' THEN
                        //      DoExit := NOT Marshaller.NumPadCode(t002,CopyValidering,TRUE,TRUE);
                        //  END;
                        //+NPR5.27 [254925]
                        Register."Touch Screen Login Type"::Quick:
                            begin
                                if CopyValidering = '' then
                                    Functions('USERS');
                            end;
                        Register."Touch Screen Login Type"::"Normal Numeric":
                            begin
                                if CopyValidering = '' then
                                    DoExit := not Marshaller.NumPadCode(t002, CopyValidering, true, true);
                            end;
                    end;
                end;
            State.IsCurrentView(ViewType.Sale):
                begin
                    if CopyValidering = '' then
                        DoExit := not Marshaller.NumPadCode(t001, CopyValidering, false, false);
                end;
            State.IsCurrentView(ViewType.Locked):
                begin
                    EnterHit('LOCKED');
                    exit;
                end;
        end;

        if DoExit then begin
            Validering := '';
            CopyValidering := '';
            exit(false);
        end;

        if CopyValidering <> '' then
            Validering := CopyValidering;

        CopyValidering := '';

        //-NPR5.32 [264202]
        //IF NOT BarcodeParser.ProcessBarcode(Validering) THEN
        //+NPR5.32 [264202]
        ButtonDefault;
    end;

    procedure ExportSale("Sale POS": Record "Sale POS")
    begin
        "Sale POS".SetRecFilter;
        Error('AL-Conversion: TODO #361926 - AL: COD6014630 "Touch - Sale POS (Web)" ALC issues');
        SaveSale();
    end;

    procedure FindElement()
    var
        vare1: Record Item;
    begin
        //findelement

        if State.IsCurrentView(ViewType.Login) then exit;

        // FIND VARE
        if (State.ViewType = ViewType.Sale) then begin
            if Validering <> '' then begin
                vare1.Reset;
                vare1.SetCurrentKey(Description);
                vare1.SetFilter(Description, '%1', '*@' + Validering + '*');
                Validering := '';
                if PAGE.RunModal(6014525, vare1) = ACTION::LookupOK then begin
                    Validering := vare1."No.";
                    EnterHit('EKSPEDITION');
                end;
                exit;
            end else begin
                FunctionState := FunctionState::FindElement;
                Marshaller.Functions('', 'ITEM');
            end;
        end;
    end;

    local procedure Functions(theseFunctions: Code[50])
    var
        Heading: Text;
        t001: Label 'Functions - Login';
        t002: Label 'Functions - Payment';
        t003: Label 'Functions - Sale';
        t004: Label 'Sales personal';
        t005: Label 'Item Groups/Items';
        t006: Label 'Payment types';
        t007: Label 'How is the debit sale going to be printed?';
        t008: Label 'Insurances';
        t009: Label 'Keyboard';
        t010: Label 'Discounts';
        t011: Label 'Printouts';
        t012: Label 'Functions - Customers';
        t013: Label 'Functions - Items';
        text001: Label 'Unknown function list %1';
        MenuLine: Record "Touch Screen - Menu Lines";
    begin
        //Funktioner
        if State.IsCurrentView(ViewType.Locked) then begin
            EnterHit('LOCKED');
            exit;
        end;

        if theseFunctions = '' then begin
            case true of
                State.IsCurrentView(ViewType.Login):
                    theseFunctions := 'LOGIN';
                State.IsCurrentView(ViewType.Sale):
                    theseFunctions := 'EKSPEDITION';
                State.IsCurrentView(ViewType.Payment):
                    theseFunctions := 'PAYMENT';
            end;
        end;

        case theseFunctions of
            'LOGIN':
                Heading := t001;
            'EKSPEDITION':
                Heading := t003;
            'PAYMENT':
                Heading := t002;
            'USERS':
                Heading := t004;
            'ITEM':
                Heading := t005;
            'BETALINGSVALG':
                Heading := t006;
            'FORSIKRING':
                Heading := t008;
            'KEYBOARD':
                Heading := t009;
            'DISCOUNT':
                Heading := t010;
            'PRINTS':
                Heading := t011;
            'CUSTOMER':
                Heading := t012;
            'ITEMFUNCTIONS':
                Heading := t013;
            'DEBITPRINT':
                Heading := t007;
            'DEBITSALEPOST':
                ;
        end;
        Heading := '  ' + Heading;

        Marshaller.Functions(Heading, theseFunctions);

        MenuLine.Reset;
        case theseFunctions of
            'LOGIN':
                MenuLine.SetRange(Type, MenuLine.Type::Login);
            'EKSPEDITION':
                MenuLine.SetRange(Type, MenuLine.Type::"Sale Functions");
            'PAYMENT':
                MenuLine.SetRange(Type, MenuLine.Type::"Payment Functions");
            'KASSEAFSLUTNING':
                MenuLine.SetRange(Type, MenuLine.Type::"Sale Form");
            'USERS':
                MenuLine.SetRange(Type, MenuLine.Type::User);
            'ITEM':
                MenuLine.SetRange(Type, MenuLine.Type::Item);
            'BETALINGSVALG':
                MenuLine.SetRange(Type, MenuLine.Type::PaymentType);
            'CUSTOMER':
                MenuLine.SetRange(Type, MenuLine.Type::"Customer Functions");
            'FINANS':
                MenuLine.SetRange(Type, MenuLine.Type::"G/L Account");
            'FORSIKRING':
                MenuLine.SetRange(Type, MenuLine.Type::Insurance);
            'KEYBOARD':
                MenuLine.SetRange(Type, MenuLine.Type::Keyboard);
            'DISCOUNT':
                MenuLine.SetRange(Type, MenuLine.Type::Discount);
            'PRINTS':
                MenuLine.SetRange(Type, MenuLine.Type::Prints);
            'REPORTS':
                MenuLine.SetRange(Type, MenuLine.Type::Reports);
            'ITEMFUNCTIONS':
                MenuLine.SetRange(Type, MenuLine.Type::"Item Functions");
            'DEBITPRINT':
                ;
            'DEBTISALEPOST':
                ;
            else
                Marshaller.Error_Protocol('', StrSubstNo(text001, theseFunctions), true);
        end;

        MenuLine.SetRange(Level, 0);
        MenuLine.SetRange(Visible, true);
        MenuLine.SetFilter("Register Type", '%1|%2', '', Register."Register Type");
        if not MenuLine.Find('-') then;
        MenuLinePopupTmp.Copy(MenuLine);
        if MenuLinePopupTmp.Insert then;
        UpdateFunctionsPopupButtons(MenuLine);
    end;

    procedure GetSavedSale()
    var
        SavedSales: Page "Touch Screen - Saved sales";
        Ekspeditionshoved: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        Value: Integer;
        t001: Label 'Sales window may not contain sales linies!';
        HasSaleLines: Boolean;
        OkSelected: Boolean;
    begin
        //GetSavedSale
        with This do begin
            RetailSetup.Get;

            Value := -1;
            SaleLinePOS.Reset;
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            if SaleLinePOS.Find('-') then begin
                repeat
                    if SaleLinePOS."No." <> '' then
                        Error(t001);
                until SaleLinePOS.Next = 0;
            end else
                SaleLinePOS.DeleteAll(true);

            SaleLinePOS.Reset;
            case RetailSetup."Show saved expeditions" of
                RetailSetup."Show saved expeditions"::All:
                    ;
                RetailSetup."Show saved expeditions"::Register:
                    Ekspeditionshoved.SetRange("Register No.", "Register No.");
                RetailSetup."Show saved expeditions"::Salesperson:
                    Ekspeditionshoved.SetRange("Salesperson Code", "Salesperson Code");
                RetailSetup."Show saved expeditions"::"Register+Salesperson":
                    begin
                        Ekspeditionshoved.SetRange("Register No.", "Register No.");
                        Ekspeditionshoved.SetRange("Salesperson Code", "Salesperson Code");
                    end;
            end;

            Ekspeditionshoved.SetRange("Saved Sale", true);
            SetSavedExpFilter(Ekspeditionshoved);

            if Ekspeditionshoved.IsEmpty then exit;
            Commit;

            //-NPR5.33 [280535]
            Clear(SaleLinePOS);
            SaleLinePOS.SetRange("Register No.", This."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", This."Sales Ticket No.");
            HasSaleLines := not SaleLinePOS.IsEmpty;
            //+NPR5.33 [280535]

            SavedSales.DisableFetchButton();
            //-NPR4.21
            //SavedSales.SETRECORD(Ekspeditionshoved);
            SavedSales.SetTableView(Ekspeditionshoved);
            //+NPR4.21
            SavedSales.LookupMode(true);
            if SavedSales.RunModal = ACTION::LookupOK then begin
                SavedSales.GetRecord(Ekspeditionshoved);
                LoadSavedSale(Ekspeditionshoved);
                //-NPR5.33 [280535]
                OkSelected := true;
                //+NPR5.33 [280535]
            end;

            //+NPR5.33 [280535]
            if HasSaleLines or OkSelected then begin
                //-NPR5.26 [244948]
                //-NPR5.26 [247882]
                ClearStateData();
                //+NPR5.26 [247882]
                Clear(SaleLinePOS);
                SaleLinePOS.SetRange("Register No.", This."Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", This."Sales Ticket No.");
                SaleLinePOS.FindFirst;
                SaleLinePOSObject.SetLine(SaleLinePOS);
                SaleLinePOSObject.CalculateBalance();
                SetSaleScreenVisible();
                //+NPR5.26 [244948]
            end;
            //+NPR5.33 [280535]

        end;
    end;

    procedure GetSalesPersonCode(): Boolean
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        //Hents�lgerkode()
        with This do begin
            if not TouchScreenFunctions.GetSalespersonCode(This, Register, CopyValidering) then begin
                Validering := '';
                EnterPush;
                exit(false);
            end;
            exit(true);
        end;
    end;

    procedure GotoPayment()
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        Eksplinie: Record "Sale Line POS";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        t003: Label 'Create a customer order or delivery?';
        t004: Label 'Order and delivery?';
        t005: Label 'No sales lines';
        t006: Label 'No sales lines present. Continue payment?';
    begin
        // SkiftTilBetaling
        //-NPR5.30 [267291]
        OnBeforeGotoPayment(This);
        //+NPR5.30 [267291]
        with This do begin
            if State.IsCurrentView(ViewType.Login) then exit;

            RetailSetup.Get;
            if RetailSetup."Warning - Sale with no lines" and
              not RetailSalesLineCode.LineExists(This) then
                if not Marshaller.Confirm(t005, t006) then exit;

            Validering := '';

            if (RetailSetup."Customer No." = RetailSetup."Customer No."::"Before payment") and
               ("Customer No." = '') then begin
                Commit;
                SetCustomer();
            end;

            //-NPR5.28 [254575]
            TouchScreenFunctions.ReceiptEmailPrompt(This);
            //+NPR5.28 [254575]

            if (RetailSetup."Create retail order" = RetailSetup."Create retail order"::"Before payment") and not
               (("Retail Document Type" = "Retail Document Type"::"Retail Order") and
               ("Retail Document No." <> '')) then begin
                Commit;
                if Marshaller.Confirm(t004, t003) then begin
                    ExecFunction('NPORDER_SEND');
                    exit;
                end;
            end;

            Eksplinie.SetRange("Register No.", "Register No.");
            Eksplinie.SetRange("Sales Ticket No.", "Sales Ticket No.");
            Eksplinie.SetRange(Type, Eksplinie.Type::Item);
            Eksplinie.SetRange("Sale Type", Eksplinie."Sale Type"::Sale);
            if Eksplinie.Find('-') then
                repeat
                    TouchScreenFunctions.CheckVariax(Eksplinie);
                until Eksplinie.Next = 0;
            Register.Get("Register No.");

            if "Customer No." <> '' then begin
                if AutoDebit then
                    exit;
            end;

            TouchScreenFunctions.TestRegisterRegistration(This);
            SetScreenView(ViewType.Payment);

            PaymentMenu();
        end;
    end;

    procedure GotoSale()
    var
        Dec: Decimal;
    begin
        // TilEKSPEDITION
        if IsTaxFreeEnabled then begin
            IsTaxFreeEnabled := false;
            //-NPR4.21
            //MESSAGE('Tax Free Refund er fravalgt');
            Message(TaxFreeDisabledMsg);
            //+NPR4.21
        end;

        PaymentLinePOSObject.CalculateBalance(Dec);

        SetScreenView(ViewType.Sale);
        SetSaleScreenVisible();

        IsCashSale := false;
        Validering := '';
    end;

    procedure ImportSale("Expedition No.": Code[20])
    var
        "Sale Line POS Saved": Record "Sale Line POS";
        "Sale Line POS Current": Record "Sale Line POS";
        "Sale Line POS Tmp": Record "Sale Line POS";
        "Line No.": Integer;
    begin
        /*** Get saved variables ***/
        with This do begin
            "Sale Line POS Saved".SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Line No.");
            "Sale Line POS Saved".SetRange("Sales Ticket No.", "Expedition No.");
            "Sale Line POS Saved".SetRange("Sale Type", "Sale type"::Sale);
            "Sale Line POS Saved".SetRange("Gift Voucher Ref.", '');

            /*** Find last line no. ***/
            "Sale Line POS Current".SetRange("Sales Ticket No.", "Sales Ticket No.");
            "Sale Line POS Current".SetRange("Register No.", "Register No.");
            "Sale Line POS Current".SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Line No.");
            if "Sale Line POS Current".FindLast() then
                "Line No." := 10000 + "Sale Line POS Current"."Line No."
            else
                "Line No." := 10000;

            if "Sale Line POS Saved".Find('-') then
                repeat
                    with "Sale Line POS Saved" do begin
                        "Sale Line POS Tmp".Get("Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.");
                    end;
                    "Sale Line POS Tmp".Rename("Register No.", "Sales Ticket No.", Date, "Sale Line POS Saved"."Sale Type", "Line No.");
                    "Line No." += 10000;
                until "Sale Line POS Saved".Next = 0;
        end;

    end;

    procedure InsertPaymentLine(DialogType: Option List,Input,Direct,DirectCustCash)
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        Linie: Record "Sale Line POS";
        "Integer": Integer;
        tmpStr: Text[30];
        InputAmount: Label 'Enter Amount';
        ConfEnterAmount: Label 'No entries selected. Do you wish to enter amount?';
        Dec: Decimal;
        amountSuggest: Decimal;
        txtNoCustomer: Label 'Choose a Customer';
        tempstr: Code[250];
        CustCashDirectTotal: Decimal;
        AuditRollCusCash: Record "Audit Roll";
        Customer: Record Customer;
    begin
        with This do begin
            if ("Customer No." = '') and ((DialogType = DialogType::List) or (DialogType = DialogType::Direct)
                         or (DialogType = DialogType::DirectCustCash)) then begin //-NPR5.20
                SetCustomer();
                Commit;
            end;
            Commit;
            SelectLatestVersion;
            Linie.SetRange("Register No.", "Register No.");
            Linie.SetRange("Sales Ticket No.", "Sales Ticket No.");
            Integer := 10000;
            if Linie.Find('+') then;
            Integer += Linie."Line No.";

            Linie.Init;
            Linie."Register No." := "Register No.";
            Linie."Sales Ticket No." := "Sales Ticket No.";
            Linie.Date := WorkDate;
            Linie."Sale Type" := Linie."Sale Type"::Deposit;
            Linie.Type := Linie.Type::Customer;
            Linie."No." := "Customer No.";
            Linie."Line No." := Integer;

            Linie.Insert(true);

            //-NPR5.35 [288492]
            if not Customer.Get("Customer No.") then
                Clear(Customer);

            //SaleLinePOSObject.SetDescription(STRSUBSTNO(DepositDescription, Customer.Name));
            Linie.Description := StrSubstNo(DepositDescription, Customer.Name);
            //+NPR5.35 [288492]

            if DialogType = DialogType::List then begin
                if "Customer No." = '' then
                    Error(txtNoCustomer);
                tmpStr := TouchScreenFunctions.BalanceRegisterEntries(This, Linie);
                Commit;
                if tmpStr <> '' then
                    Marshaller.DisplayError(Text10600200, tmpStr, false);
            end;

            if DialogType = DialogType::Input then begin
                tempstr := TouchScreenFunctions.BalanceInvoice(This, Linie, Validering);
                Commit;
                if tmpStr <> '' then
                    Marshaller.DisplayError(Text10600200, tmpStr, false);
            end;

            //-NPR5.20
            //IF DialogType = DialogType::Direct THEN BEGIN
            if (DialogType = DialogType::Direct) or (DialogType = DialogType::DirectCustCash) then begin
                //+NPR5.20
                if "Customer No." = '' then
                    Error(txtNoCustomer);
                Commit;
                //-NPR5.20
                if (DialogType = DialogType::Direct) then begin
                    //+NPR5.20
                    if Marshaller.NumPad(InputAmount, amountSuggest, true, false) then begin
                        Linie.Validate(Amount, amountSuggest);
                        Linie.Validate("Amount Including VAT", amountSuggest);
                        Linie.Validate("Unit Price", amountSuggest);
                        Linie.Modify;
                    end else
                        Error('');
                    //-NPR5.20
                end else begin
                    if (This."Register No." <> '') and (This."Sales Ticket No." <> '') then begin

                        AuditRollCusCash.SetRange("Register No.", This."Register No.");
                        AuditRollCusCash.SetRange("Sales Ticket No.", This."Sales Ticket No.");
                        AuditRollCusCash.SetFilter("Sale Type", '%1|%2', AuditRollCusCash."Sale Type"::Sale, AuditRollCusCash."Sale Type"::"Debit Sale");
                        AuditRollCusCash.SetFilter(Quantity, '>0');
                        if AuditRollCusCash.FindSet then
                            repeat
                                CustCashDirectTotal := CustCashDirectTotal + AuditRollCusCash."Amount Including VAT";
                            until AuditRollCusCash.Next = 0;

                        Dec := CustCashDirectTotal;
                    end;

                    Linie.Validate(Amount, Dec);
                    Linie.Validate("Amount Including VAT", Dec);
                    Linie.Validate("Unit Price", Dec);
                    Linie.Modify;
                end;
                //+NPR5.20
            end;


            if Linie.Find('+') then;

            if (Linie.Amount = 0) and (DialogType = DialogType::List) then
                if Marshaller.Confirm('', ConfEnterAmount) then
                    if Marshaller.NumPad(InputAmount, Dec, true, false) then begin
                        Linie.Validate(Amount, Dec);
                        Linie.Validate("Amount Including VAT", Dec);
                        Linie.Validate("Unit Price", Dec);
                        Linie.Modify;
                    end else
                        Error('');
            //-NPR5.35 [288492]
            UpdateSaleLinePOSObject();
            //+NPR5.35 [288492]

            if (Linie.Amount = 0) and (DialogType = DialogType::List) then
                Message('Bemaerk ingen indbetalinger er indlaest!');

            if Linie.Amount = 0 then
                if Linie.Delete then;

            Validering := '';
        end;
    end;

    procedure LoadSavedSale(var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS1: Record "Sale Line POS";
        GlobalSalePOS: Record "Global Sale POS";
        PaymentTypePOS: Record "Payment Type POS";
        LineIsGiftVoucher: Boolean;
        Value: Integer;
        SavedGiftVoucher: Record "Gift Voucher";
        RetailFormCode: Codeunit "Retail Form Code";
        Text0000001: Label 'Transferred to location receipt %1';
        POSInfoManagement: Codeunit "POS Info Management";
    begin
        with This do begin
            "Customer No." := SalePOS."Customer No.";
            "Customer Type" := SalePOS."Customer Type";
            //-NPR5.38 [302221]
            "Customer Name" := SalePOS."Customer Name";
            Name := SalePOS.Name;
            Address := SalePOS.Address;
            "Address 2" := SalePOS."Address 2";
            "Post Code" := SalePOS."Post Code";
            City := SalePOS.City;
            "Contact No." := SalePOS."Contact No.";
            Reference := SalePOS.Reference;
            //+NPR5.38 [302221]
            Date := Today;
            "Start Time" := Time;
            "External Document No." := SalePOS."External Document No.";
            "Price including VAT" := SalePOS."Price including VAT";
            Modify(true);

            //-NPR5.26
            POSInfoManagement.RetrieveSavedLines(This, SalePOS);
            //+NPR5.26

            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            if SaleLinePOS.Find('-') then
                repeat
                    LineIsGiftVoucher := false;
                    if (Value <> SaleLinePOS."Sale Type"::Sale) and
                       (SaleLinePOS."Gift Voucher Ref." = '') then begin
                        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then begin
                            PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
                            PaymentTypePOS.SetRange("G/L Account No.", SaleLinePOS."No.");
                            if not PaymentTypePOS.Find('-') then
                                Value := SaleLinePOS."Sale Type"
                            else
                                LineIsGiftVoucher := true;
                        end else
                            Value := SaleLinePOS."Sale Type";
                    end;
                    SaleLinePOS1 := SaleLinePOS;
                    SaleLinePOS1."Register No." := "Register No.";
                    SaleLinePOS1."Sales Ticket No." := "Sales Ticket No.";
                    //-NPR5.22
                    Clear(SaleLinePOS1."Customer Location No.");
                    //+NPR5.22
                    //-NPR5.26 [244948]
                    if SaleLinePOS1.Quantity < 0 then
                        SaleLinePOS1.Insert(false)
                    else
                        //+NPR5.26 [244948]
                        SaleLinePOS1.Insert(true);
                    if (SaleLinePOS."Gift Voucher Ref." <> '') or LineIsGiftVoucher then begin
                        SaleLinePOS1.Description := SaleLinePOS.Description;
                        if Value = -1 then
                            Value := SaleLinePOS."Sale Type"::Sale;
                        SaleLinePOS1.Modify;
                    end;
                    if SaleLinePOS1."Gift Voucher Ref." <> '' then begin
                        if SavedGiftVoucher.Get(SaleLinePOS1."Gift Voucher Ref.") then begin
                            SavedGiftVoucher."Sales Ticket No." := SaleLinePOS1."Sales Ticket No.";
                            SavedGiftVoucher."Issuing Sales Ticket No." := SaleLinePOS1."Sales Ticket No.";
                            SavedGiftVoucher.Modify(false);
                        end
                    end;
                until SaleLinePOS.Next = 0;



            //-NPR5.23
            if SalePOS."Customer Location No." <> '' then
                RetailFormCode.AuditRollCancelSale(SalePOS, StrSubstNo(Text0000001, "Sales Ticket No."));
            //+NPR5.23

            // Fix Exchange Labels Reference
            GlobalSalePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            GlobalSalePOS.ModifyAll("Sales Ticket No.", "Sales Ticket No.");

            SaleLinePOS.ModifyAll("From Selection", false);
            SaleLinePOS.DeleteAll;

            SalePOS.SetRange("Register No.", SalePOS."Register No.");
            SalePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SalePOS.Delete(true);

        end;
    end;

    procedure Lookup()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        Template: DotNet npNetTemplate;
        UI: Codeunit "POS Web UI Management";
        ItemRecRef: RecordRef;
        Position: Text;
        EventSubscriber: Codeunit "Touch - Event Subscribers";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        // Lookup
        //-NPR5.29 [258876]
        if MenuLines1.Parametre <> '' then
            Item.SetFilter("No.", MenuLines1.Parametre);
        //+NPR5.29 [258876]

        Clear(MenuLines1);

        //-NPR5.32 [266151]
        Item.SetRange("Blocked on Pos", false);
        //+NPR5.32 [266151]

        if State.IsCurrentView(ViewType.Login) then exit;

        if Item.Get(SaleLinePOSObject.GetLineItemNumber()) then;
        //-NPR5.22
        //Validering := '';
        //
        //ItemRecRef.GETTABLE(Item);
        ItemRecRef.GetTable(Item);

        //-NPR5.23.02 [244575]
        if not RetailSetup."Use NAV Lookup in POS" then
            //+NPR5.23.02 [244575]
            if TouchScreenFunctions.SetupTempItem(Validering, TempItem) then
                ItemRecRef.GetTable(TempItem);
        Validering := '';
        //-NPR5.23
        //-NPR5.23.02 [244575]
        if not RetailSetup."Use NAV Lookup in POS" then
            //+NPR5.23.02 [244575]
            Marshaller.ClearEanBoxText();
        //+NPR5.23
        //+NPR5.22
        UI.ConfigureLookupTemplate(Template, ItemRecRef);
        //-NPR5.20
        //Position := Marshaller.Lookup(Item.TABLECAPTION,Template,ItemRecRef);
        //-NPR5.23.02 [244575]
        if not RetailSetup."Use NAV Lookup in POS" then begin
            //+NPR5.23.02 [244575]
            EventSubscriber.ConfigureItem(Marshaller);
            BindSubscription(EventSubscriber);
            //-NPR5.23
            //Position := Marshaller.Lookup(Item.TABLECAPTION,Template,ItemRecRef,FALSE,TRUE,PAGE::"Item Card");
            Position := Marshaller.Lookup(Item.TableCaption, Template, ItemRecRef, false, true, PAGE::"Retail Item Card");
            //-NPR5.23
            //+NPR5.20
            if Position <> '' then begin
                Item.SetPosition(Position);
                if Item.Find() then begin
                    Validering := Item."No.";
                    EnterHit('EKSPEDITION');
                end;
            end;
            //-NPR5.23.02 [244575]
        end else begin
            if PAGE.RunModal(PAGE::"Retail Item List", Item) = ACTION::LookupOK then begin
                Validering := Item."No.";
                EnterHit('EKSPEDITION');
            end;
        end;
        //+NPR5.23.02 [244575]
    end;

    procedure OnAfterAfterGetCurrentRecord()
    var
        SaleLinePOS: Record "Sale Line POS";
        i: Integer;
        "Retail Sales Line Code": Codeunit "Retail Sales Line Code";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Text00001: Label 'Variant Description';
    begin
        // OnAfterAfterGetCurrentRecord
        i := 1;

        SetScreenView(State.ViewType);

        case true of
            State.IsCurrentView(ViewType.Login):
                begin
                    ShowLastSaleInformation();
                end;
            State.IsCurrentView(ViewType.Sale):
                begin
                    SaleLinePOSObject.GETRECORD(SaleLinePOS);
                    case SaleLinePOS.Type of
                        SaleLinePOS.Type::Item:
                            begin
                                if State.IsCurrentView(ViewType.Sale) then begin
                                    if "Retail Sales Line Code".LineExists(This) then begin
                                        if not Item.Get(SaleLinePOS."No.") then exit;

                                        //+NPR5.28
                                        if not Register."Skip Infobox Update in Sale" then begin
                                            //-NPR5.28
                                            ClearInfoBox();
                                            SetInfoBoxHeader(SaleLinePOS.Description, '');
                                            SetInfoBox(0, SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.");
                                            //-NPR5.31 [270496]
                                            if SaleLinePOS."Unit of Measure Code" <> '' then
                                                SetInfoBox(1, SaleLinePOS.FieldCaption("Unit Price") + ' (' + SaleLinePOS."Unit of Measure Code" + ')', UI.FormatDecimal(SaleLinePOS."Unit Price"))
                                            else
                                                //+NPR5.31 [270496]
                                                SetInfoBox(1, SaleLinePOS.FieldCaption("Unit Price"), UI.FormatDecimal(SaleLinePOS."Unit Price"));
                                            SetInfoBox(2, '', '');
                                            if SaleLinePOS."Variant Code" <> '' then begin
                                                ItemVariant.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code");
                                                SetInfoBox(2, Text00001, ItemVariant.Description);
                                            end;
                                            UpdateInfoBox();
                                            //+NPR5.28
                                        end;
                                        //-NPR5.28
                                    end else begin
                                        ShowLastSaleInformation();
                                    end;
                                end;
                            end;
                    end;
                end;
            State.IsCurrentView(ViewType.Payment):
                ShowPaymentInformation();
        end;
    end;

    procedure PaymentMenu()
    var
        Dec: Decimal;
    begin
        //PaymentMenu()
        with This do begin
            PaymentLinePOSObject.CalculateBalance(Dec);
            Register.Get("Register No.");
            //-NPR5.23
            //TouchScreenFunctions.Write2Display(This,Kasse,2,UI.FormatDecimal(Dec));
            //-NPR5.46 [328581]
            //CustomerDisplayMgt.OnPOSAction(This,Register,3,UI.FormatDecimal(Dec));
            //+NPR5.46 [328581]
            //+NPR5.23
            SetPaymentMenuVisible();
        end;
    end;

    procedure PaymentType(intBehandlingsart: Integer; BetKode: Code[10])
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        Rabatkode: Code[10];
        t001: Label 'You have to setup a Payment Type Code for %1';
        t005: Label 'Cash sales on invoice customers are blocked!';
        t006: Label 'Complete CASH sale anyways?';
        t007: Label 'Primary payment type on Register %1 not given! ';
        FormCode: Codeunit "Retail Form Code";
        PaymentType2: Record "Payment Type POS";
        Dec: Decimal;
    begin
        //betalingsmiddel
        with This do begin
            RetailSetup.Get;
            if (not RetailSetup."Allow Customer Cash Sale") and
               ("Customer No." <> '') and
               ("Customer Type" = "Customer Type"::Ord) then
                if not Confirm(t005 + '\' + t006, false) then begin
                    Validering := '';
                    Marshaller.Error_Protocol(Text10600200, t005, true);
                end;

            Register.Get("Register No.");

            PaymentTypePOS.Reset;
            if BetKode <> '' then
                TouchScreenFunctions.GetPaymentType(PaymentTypePOS, Register, BetKode)
            else
                PaymentTypePOS.SetRange("Processing Type", intBehandlingsart);

            if not PaymentTypePOS.Find('-') then begin
                if BetKode <> '' then
                    Marshaller.Error_Protocol(Text10600200, StrSubstNo(t001, BetKode), true)
                else
                    Marshaller.Error_Protocol(Text10600200, StrSubstNo(t001, PaymentTypePOS."Processing Type"), true);
            end;

            if Register."Primary Payment Type" = '' then begin
                Marshaller.Error_Protocol(Text10600200, StrSubstNo(t007, Register."Register No."), true);
            end;

            Rabatkode := '';

            case PaymentTypePOS."Processing Type" of
                PaymentTypePOS."Processing Type"::Cash:
                    begin
                        PaymentLinePOSObject.DeleteRecord(Register."Primary Payment Type");
                    end;
                PaymentTypePOS."Processing Type"::"Point Card":
                    begin
                        PaymentLinePOSObject.DeleteRecord(BetKode);
                    end;
                PaymentTypePOS."Processing Type"::"Manual Card",
                PaymentTypePOS."Processing Type"::"Other Credit Cards",
                PaymentTypePOS."Processing Type"::"Terminal Card",
                PaymentTypePOS."Processing Type"::"Credit Voucher",
                PaymentTypePOS."Processing Type"::"Gift Voucher":
                    ;
                PaymentTypePOS."Processing Type"::"Foreign Currency":
                    begin
                        PaymentLinePOSObject.DeleteRecord(BetKode);
                    end;
                PaymentTypePOS."Processing Type"::"Foreign Credit Voucher",
                PaymentTypePOS."Processing Type"::"Foreign Gift Voucher":
                    begin
                    end;
                PaymentTypePOS."Processing Type"::Invoice:
                    begin
                        Commit;
                        if "Customer No." = '' then begin
                            Validering := '';
                            EnterHit('DEBITCUSTOMER');
                            if "Customer No." = '' then Error('');
                            Commit;
                        end;
                        FormCode.CreateSalesHeader(This, TempSalesHeader);
                    end;
            end;

            PaymentLinePOSObject.CalculateBalance(Dec);

            /* Inds�t betalingslinie */
            if PaymentTypePOS."Account Type" = PaymentTypePOS."Account Type"::"G/L Account" then
                PaymentTypePOS.TestField("G/L Account No.");

            PaymentTypePOS.TestField(Status, PaymentTypePOS.Status::Active);
            CopyValidering := Validering;
            Validering := '';

            case
                PaymentLinePOSObject.CreatePaymentLine(
                  PaymentTypePOS."No.",
                  Dec,
                  "Register No.",
                  "Sales Ticket No.",
                  Date,
                  Rabatkode,
                  IsCashSale,
                  CopyValidering)
            of
                0:
                    ;
                1:
                    begin
                        Validering := '';
                        Register.Get("Register No.");
                        PaymentTypePOS.Get(Register."Primary Payment Type");
                        Marshaller.Error_Protocol(Text10600200, PaymentLinePOSObject.GetErrorText, true);
                        exit;
                    end;
            end;

            IsCashSale := false;

            PaymentType2 := PaymentTypePOS;

            Register.Get("Register No.");
            PaymentTypePOS.Get(Register."Primary Payment Type");

            /* Initialis�r ENTER tast knap-tekst */
            case PaymentTypePOS."Processing Type" of
                PaymentTypePOS."Processing Type"::"Foreign Credit Voucher",
                PaymentTypePOS."Processing Type"::"Foreign Gift Voucher",
                PaymentTypePOS."Processing Type"::Invoice:
                    begin
                        if Validering <> '' then begin
                            Register.Get("Register No.");
                            PaymentTypePOS.Get(Register."Primary Payment Type");
                        end;
                    end;
                PaymentTypePOS."Processing Type"::"Foreign Currency":
                    begin
                        Register.Get("Register No.");
                        PaymentTypePOS.Get(Register."Primary Payment Type");
                    end;
                else begin
                        Register.Get("Register No.");
                        PaymentTypePOS.Get(Register."Primary Payment Type");
                    end;
            end;

            Validering := '';

            PaymentLinePOSObject.CalculateBalance(Dec);
            PaymentLinePOSObject.JumpEnd();

            if (PaymentLinePOSObject.LastSale(3) < TouchScreenFunctions.CalcPaymentRounding("Register No.")) and
               PaymentType2."Auto End Sale" then begin
                IsCashSale := false;                              // BETALING ok!
                EnterHit('AFSLUTBETALING');
            end;
        end;

    end;

    procedure PushQuantity(Factor: Integer): Boolean
    var
        t002: Label 'Type the quantity of items on this line.';
        t003: Label 'Type the quantity of items in return on this line.';
        SaleLinePOS: Record "Sale Line POS";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Context: DotNet npNetProtocolContext;
        DialogText: Text;
    begin
        if not RetailSalesLineCode.LineExists(This) then begin
            Marshaller.DisplayError(Text10600200, Text10600112, false);
            exit(false);
        end;

        if Validering = '' then begin
            SaleLinePOSObject.GETRECORD(SaleLinePOS);
            if Factor > 0 then
                DialogText := t002
            else
                DialogText := t003;

            Context := Context.ProtocolContext(MethodName_PushQuantity);
            Context.MethodArguments.Add('__FuncStr', LastFuncStr);
            Context.MethodArguments.Add('Factor', Factor);
            Marshaller.NumPad_Protocol(DialogText, Abs(SaleLinePOS.Quantity), true, false, Context);
        end else
            Complete_PushQuantity(UI.ParseDecimal(Validering), Factor);
    end;

    procedure NewSale()
    begin
        with This do begin
            Validering := '';
            IsCashSale := false;

            /* Initialize */

            SaleInit(true, false);
        end;

    end;

    procedure NewSalesTicketNo(WhyText: Text[50])
    var
        RetailFormCode: Codeunit "Retail Form Code";
        xSale: Record "Sale POS";
        newSale: Record "Sale POS";
    begin
        with This do begin
            xSale.Copy(This);

            RetailFormCode.AuditRollCancelSale(This, WhyText);

            newSale.Init;
            newSale.Copy(xSale);
            newSale."Sales Ticket No." := RetailFormCode.FetchSalesTicketNumber("Register No.");
            newSale.Insert(true);

            Get(newSale."Register No.", newSale."Sales Ticket No.");

            /* no-user felter */
            FilterGroup := 2;
            SetRange("Register No.", newSale."Register No.");
            SetRange("Sales Ticket No.", newSale."Sales Ticket No.");
            FilterGroup := 0;

        end;

    end;

    procedure RetailDocumentHandling(FuncStr: Text[30])
    var
        t009: Label 'You have not set a Serial Number from the item. \ \Sales line deleted if the item requires a serial number!';
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        "Retail Document Handling": Codeunit "Retail Document Handling";
    begin
        with This do begin
            case FuncStr of
                /* Selection contract */
                'SAMPLING_SEND':
                    begin
                        "Retail Document Type" := "Retail Document Type"::"Selection Contract";
                        if not "Retail Document Handling".Sale2RetailDocument(This) then
                            Error(t009);

                        Modify;

                        if Deposit > 0 then begin
                            TouchScreenFunctions.TestRegisterRegistration(This);
                            PaymentMenu();
                        end else begin
                            Commit;
                            Clear(LastSaleFigures);
                            NewSale();
                        end;
                    end;
                'SAMPLING_GET':
                    begin
                        "Retail Document Type" := "Retail Document Type"::"Selection Contract";
                        "Retail Document Handling".RetailDocument2Sale(This, "Salesperson Code");
                        Validering := "Customer No.";
                        if Validering <> '' then
                            case "Customer Type" of
                                "Customer Type"::Ord:
                                    SetCustomer();
                                "Customer Type"::Cash:
                                    SetContact();
                            end;
                        Validering := '';
                        Commit;
                    end;

                /* Retail Customer order */
                'NPORDER_SEND':
                    begin
                        "Retail Document Type" := "Retail Document Type"::"Retail Order";
                        if not
                         "Retail Document Handling".Sale2RetailDocument(This) then
                            Error(t009);

                        Modify;

                        if Deposit > 0 then begin
                            TouchScreenFunctions.TestRegisterRegistration(This);
                            PaymentMenu();
                        end else begin
                            Commit;
                            Clear(LastSaleFigures);
                            NewSale();
                        end;
                    end;
                'NPORDER_GET':
                    begin
                        "Retail Document Type" := "Retail Document Type"::"Retail Order";
                        "Retail Document Handling".RetailDocument2Sale(This, "Salesperson Code");
                    end;

                /* Rental contract */
                'CONTRACTRENT_SEND':
                    begin
                        "Retail Document Type" := "Retail Document Type"::"Rental contract";
                        if not
                        "Retail Document Handling".Sale2RetailDocument(This) then
                            Error(t009);

                        Modify;

                        if Deposit > 0 then begin
                            TouchScreenFunctions.TestRegisterRegistration(This);
                            PaymentMenu();
                        end else begin
                            Commit;
                            Clear(LastSaleFigures);
                            NewSale();
                        end;
                    end;

                /* Purchase contract */
                'CONTRACTPURCH_SEND':
                    begin
                        "Retail Document Type" := "Retail Document Type"::"Purchase contract";
                        if not "Retail Document Handling".Sale2RetailDocument(This) then
                            Error(t009);

                        Modify;

                        Clear(LastSaleFigures);
                        NewSale();
                    end;

                /* Retail Customization */
                'TAILOR_SEND':
                    begin
                        "Retail Document Type" := "Retail Document Type"::Customization;
                        if not "Retail Document Handling".Sale2RetailDocument(This) then
                            Error(t009);

                        Modify;

                        if Deposit > 0 then begin
                            TouchScreenFunctions.TestRegisterRegistration(This);
                            PaymentMenu();
                        end else begin
                            Commit;
                            PaymentMenu;
                        end;
                    end;
                'TAILOR_GET':
                    begin
                        "Retail Document Type" := "Retail Document Type"::Customization;
                        "Retail Document Handling".RetailDocument2Sale(This, "Salesperson Code");
                        Validering := "Customer No.";
                        case "Customer Type" of
                            "Customer Type"::Ord:
                                SetCustomer();
                            "Customer Type"::Cash:
                                SetContact();
                        end;
                        Validering := '';
                        Commit;
                    end;
                /* Retail Quote */
                'QUOTE_SEND':
                    begin
                        "Retail Document Type" := "Retail Document Type"::Quote;
                        if not "Retail Document Handling".Sale2RetailDocument(This) then
                            Error(t009);

                        Modify;

                        if Deposit > 0 then begin
                            TouchScreenFunctions.TestRegisterRegistration(This);
                            PaymentMenu();
                        end else begin
                            Commit;
                            Clear(LastSaleFigures);
                            NewSale();
                        end;
                    end;
                //-NPR5.20
                'QUOTE_GET':
                    begin
                        "Retail Document Type" := "Retail Document Type"::Quote;
                        "Retail Document Handling".RetailDocument2Sale(This, "Salesperson Code");
                        Validering := "Customer No.";
                        case "Customer Type" of
                            "Customer Type"::Ord:
                                SetCustomer();
                            "Customer Type"::Cash:
                                SetContact();
                        end;
                        Validering := '';
                        Commit;
                    end;
                    //+NPR5.20
            end;
        end;

    end;

    procedure ReverseQtyOnSaleLines(var EkspeditionRec: Record "Sale POS")
    begin
        SaleLinePOSObject.SetReverseQtySignFactor;
    end;

    local procedure SaleInit(NewReceiptNo: Boolean; NewLogin: Boolean)
    var
        FormCode: Codeunit "Retail Form Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        if not IsInitialized() then
            exit;

        with This do begin
            if NewLogin then begin
                This."Salesperson Code" := '';
            end else begin
                if Register."Touch Screen Login Type" <> Register."Touch Screen Login Type"::Automatic then begin
                    This."Salesperson Code" := '';
                end;
            end;

            This."External Document No." := '';

            /* Get register No. */
            This."Register No." := FormCode.FetchRegisterNumber;
            Register.Get(This."Register No.");
            Register.TestField("Return Payment Type");
            //-NPR4.16
            //Register.TESTFIELD("Primary Sales Type");
            //+NPR4.16

            //-NPR5.23
            //  IF Register."Customer Display" AND
            //     (Register.DisplayWriteMethod = Register.DisplayWriteMethod::MSComm)
            //       THEN Utility.ComportOpen(Register,TRUE);
            //+NPR5.23

            /* Next ticket no. */
            if NewReceiptNo then
                This."Sales Ticket No." := FormCode.FetchSalesTicketNumber(This."Register No.");

            ItemsVisible(true);

            // tid + dato
            Date := Today;
            "Start Time" := Time;
            "Sale type" := "Sale type"::Sale;

            /* Clear references */
            "Contact No." := '';
            Reference := '';

            /* Clear retail document info */
            Clear("Retail Document Type");
            Clear("Retail Document No.");
            //-NPR5.26 [246204]
            Clear("Custom Print Object ID");
            Clear("Custom Print Object Type");
            Clear("Issue Tax Free Voucher");
            Clear(IsTaxFreeEnabled);
            //+NPR5.26 [246204]
            //-NPR5.28 [254575]
            Clear("Send Receipt Email");
            //+NPR5.28 [254575]

            //-NPR5.22
            Clear("Customer Location No.");
            //+NPR5.22

            /* Welcome greeting on display */
            //-NPR5.23
            //TouchScreenFunctions.Write2Display(This,Register,1,'');
            //-NPR5.46 [328581]
            //CustomerDisplayMgt.OnPOSAction(This,Register,0,'');
            //+NPR5.46 [328581]
            //+NPR5.23

            "Saved Sale" := false;
            TouchScreen := true;

            SaleLinePOSObject.SetTableView("Register No.", "Sales Ticket No.");
            PaymentLinePOSObject.SetTableView("Register No.", "Sales Ticket No.");

            /* tjek om der er ekspeditioner p� rev.rullen efter d.d. */
            TouchScreenFunctions.TestSalesDate;

            Insert(true);

            //-NPR5.31 [271728]
            //  IF RetailSetup."Default Customer no." <> '' THEN BEGIN
            //    "Customer Type" := "Customer Type"::Ord;
            //    VALIDATE("Customer No.", RetailSetup."Default Customer no.");
            //  END ELSE
            //+NPR5.31 [271728]
            Validate("Customer No.", '');

            RetailSalesDocMgt.Reset();

            /* no-user felter */
            FilterGroup := 2;
            SetRange("Register No.", "Register No.");
            SetRange("Sales Ticket No.", "Sales Ticket No.");
            FilterGroup := 0;

            /* s�t p� kasse-rec. at kassen er �bnet */
            TouchScreenFunctions.SetRegisterStatus(This, true);

            /* vis resten af formen */
            SetSaleScreenVisible();
        end;

    end;

    procedure SetSavedExpFilter(var EkspeditionLok: Record "Sale POS")
    begin
        with This do begin
            if RetailSetup."Show Stored Tickets" then begin
                case RetailSetup."Show saved expeditions" of
                    RetailSetup."Show saved expeditions"::All:
                        begin
                            EkspeditionLok.SetCurrentKey("Salesperson Code", "Saved Sale");
                            EkspeditionLok.SetRange("Saved Sale", true);
                        end;
                    RetailSetup."Show saved expeditions"::Register:
                        begin
                            EkspeditionLok.SetCurrentKey("Salesperson Code", "Saved Sale");
                            EkspeditionLok.SetRange("Register No.", Register."Register No.");
                            EkspeditionLok.SetRange("Saved Sale", true);
                        end;
                    RetailSetup."Show saved expeditions"::Salesperson:
                        begin
                            EkspeditionLok.SetCurrentKey("Salesperson Code", "Saved Sale");
                            EkspeditionLok.SetRange("Salesperson Code", "Salesperson Code");
                            EkspeditionLok.SetRange("Saved Sale", true);
                        end;
                    RetailSetup."Show saved expeditions"::"Register+Salesperson":
                        begin
                            EkspeditionLok.SetCurrentKey("Salesperson Code", "Saved Sale");
                            EkspeditionLok.SetRange("Salesperson Code", "Salesperson Code");
                            EkspeditionLok.SetRange("Register No.", Register."Register No.");
                            EkspeditionLok.SetRange("Saved Sale", true);
                        end;
                end;
            end;
        end;
    end;

    procedure SetSaleScreenVisible()
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        with This do begin
            Validering := '';
            Register.Get("Register No.");

            if "Salesperson Code" <> '' then begin  // Logged in
                SetScreenView(ViewType.Sale);
            end else begin                          // Not logged in
                SetScreenView(ViewType.Login);

                if (Register."Touch Screen Login Type" = Register."Touch Screen Login Type"::Automatic) and ("Salesperson Code" <> '') then begin
                    Salesperson.Get("Salesperson Code");
                    Validering := Salesperson."Register Password";
                    EnterHit('LOGIN');
                end;
            end;
        end;
    end;

    procedure SetPaymentMenuVisible()
    begin
        PaymentTypePOS.Get(Register."Primary Payment Type");

        SetScreenView(ViewType.Payment);
    end;

    procedure SaveSale()
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        FormCode: Codeunit "Retail Form Code";
        t002: Label 'Do you want to save the current sale?';
        t003: Label 'Save current sale?';
        "Retail Sales Line Code": Codeunit "Retail Sales Line Code";
        SaleLinePOS: Record "Sale Line POS";
    begin
        with This do begin
            if not "Retail Sales Line Code".LineExists(This) then begin
                Marshaller.DisplayError(Text10600200, Text10600095, false);
                exit;
            end;

            if not Marshaller.Confirm(t003, t002) then
                exit;

            "Saved Sale" := true;
            Modify;
            FormCode.AuditRollCancelSale(This, Text10600003);
            TouchScreenFunctions.SetRegisterStatus(This, false);

            if Modify then;

            Validering := '';

            SaleInit(true, false);

            SetSaleScreenVisible();

            if Register."Touch Screen Login autopopup" then begin
                Commit;
                Validering := '';
                EnterPush;
            end;

            //-244948 [244948]
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := This."Register No.";
            SaleLinePOS."Sales Ticket No." := This."Sales Ticket No.";
            SaleLinePOS.Date := Today;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
            SaleLinePOS."Line No." := 10000;
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS.Description := 'Empty Line for Total 0';
            SaleLinePOS.Insert(false);
            Commit;
            SaleLinePOSObject.SetLine(SaleLinePOS);
            SaleLinePOSObject.CalculateBalance();

            SetSaleScreenVisible();

            SaleLinePOS.Delete(false);
            //+244948 [244948]

        end;
    end;

    procedure ShowLineInformation()
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        int1: Integer;
        SaleLinePOS: Record "Sale Line POS";
        t002: Label 'Info only works on sales lines. Currently no sales lines present!';
        DummyText: Text;
    begin
        // VisInfoPaaLinie

        with This do begin
            Buffer.DeleteAll(true);

            case true of
                State.IsCurrentView(ViewType.Sale):
                    begin
                        SaleLinePOSObject.GETRECORD(SaleLinePOS);
                        if SaleLinePOS."No." = '' then begin
                            Marshaller.Error_Protocol(Text10600200, t002, true);
                            exit;
                        end;
                        case SaleLinePOS."Sale Type" of
                            SaleLinePOS."Sale Type"::Sale:
                                begin
                                    if int1 = 0 then exit;
                                end;
                            SaleLinePOS."Sale Type"::Deposit:
                                begin
                                    SaleLinePOSObject.GETRECORD(SaleLinePOS);
                                    "Customer No." := SaleLinePOS."No.";
                                    int1 := SaleLinePOS."Line No.";
                                    Modify;
                                end;
                            SaleLinePOS."Sale Type"::"Out payment":
                                exit;
                        end;
                        SaleLinePOSObject.GETRECORD(SaleLinePOS);
                        TouchScreenFunctions.InfoLine(This, DummyText, Buffer, SaleLinePOS);
                    end;
            end;
            PAGE.RunModal(PAGE::"Touch Screen - Info", Buffer);
        end;
    end;

    procedure ShowLastSaleInformation()
    var
        t001: Label 'Last sale';
        LastSaleDateText: Text;
        Total: Decimal;
        Payed: Decimal;
        ReturnAmount: Decimal;
        LastReceiptNo: Text;
        LabelTotal: Label 'Total';
        LabelPayed: Label 'Total payed';
        LabelReturnAmount: Label 'Change';
    begin
        with This do begin
            ClearInfoBox;
            //-NPR5.22 - Auditroll not used for anything - was local
            //AuditRoll.SETRANGE("Register No.","Register No.");
            //AuditRoll.SETFILTER("Sale Type",'<>%1', AuditRoll."Sale Type"::"�ben/Luk");
            //AuditRoll.SETFILTER(Type,'<>%1', AuditRoll.Type::Cancelled);
            //IF AuditRoll.FINDLAST() THEN BEGIN
            //  AuditRoll.SETRANGE(Type);
            //+NPR5.22
            GetLastSaleInfo(LastSaleDateText, Total, Payed, ReturnAmount, LastReceiptNo);
            SetInfoBoxHeader(t001, LastReceiptNo);
            SetInfoBox(0, LabelTotal, UI.FormatDecimal(Total));
            SetInfoBox(1, LabelPayed, UI.FormatDecimal(Payed));
            SetInfoBox(2, LabelReturnAmount, UI.FormatDecimal(ReturnAmount));
            //END; -NPR5.22

            UpdateInfoBox();
        end;
    end;

    procedure ShowPaymentInformation()
    var
        Total: Decimal;
        Payed: Decimal;
        ReturnAmount: Decimal;
    begin
        GetPaymentInfo(Total, Payed, ReturnAmount);
        ClearInfoBox();
        SetInfoBoxHeader(Text10600208, '');
        SetInfoBox(0, Text10600209, UI.FormatDecimal(Total));
        SetInfoBox(1, Text10600210, UI.FormatDecimal(Payed));
        SetInfoBox(2, Text10600211, UI.FormatDecimal(ReturnAmount));
        UpdateInfoBox();
    end;

    procedure SetLineAmount(gruppesalg: Integer): Boolean
    var
        t001: Label 'Type the line amount, ie. for full quantity. Not only per piece.';
        t002: Label 'This is an item group \(item marked as Item Group). \Type in the price for this line.';
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        SaleLinePOS: Record "Sale Line POS";
        t005: Label 'Type unit price for this item.';
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        ErrIllegalAmount: Label 'Error. Illegal amount.';
        Code10: Code[10];
        Dec: Decimal;
        Question: Text;
    begin
        with This do begin
            if not RetailSalesLineCode.LineExists(This) then begin
                Marshaller.DisplayError(Text10600200, Text10600112, false);
                exit(false);
            end;

            case true of
                State.IsCurrentView(ViewType.Payment):
                    begin
                        PaymentLinePOSObject.GETRECORD(SaleLinePOS);
                        if PaymentLinePOSObject.LineIsEmpty then
                            Marshaller.Error_Protocol(Text10600200, Text10600112, true);
                        PaymentLinePOSObject.NoOnValidate(SaleLinePOS, '');
                    end;
                else begin
                        if SaleLinePOSObject.LineExists then begin
                            SaleLinePOSObject.ResetDiscountOnActiveLine;
                            Commit;
                            SaleLinePOSObject.GETRECORD(SaleLinePOS);
                            TouchScreenFunctions.CheckLine(SaleLinePOS);

                            case gruppesalg of
                                0:
                                    if SaleLinePOS."Unit Price" = 0 then
                                        Question := t005
                                    else
                                        Question := t001;
                                1:
                                    Question := t002;
                            end;
                            if not Marshaller.NumPad(Question, Dec, false, false) then
                                exit(false);

                            if SaleLinePOSObject.IsLineZero() then begin
                                if Dec > 1000000 then
                                    Error(ErrIllegalAmount);

                                SaleLinePOSObject.ChangeUnitPriceOnActiveLine(Dec);
                                Validering := '';
                                //-NPR5.23
                                SaleLinePOSObject.UpdateCustomerDisplay();
                                //+NPR5.23
                                exit(true);
                            end else begin
                                Code10 := RetailSalesLineCode.AskReasonCode();
                                SaleLinePOSObject.ChangeAmountOnActiveLine(Dec);
                                SaleLinePOSObject.SetDiscountCode(Code10);
                                //-NPR5.23
                                SaleLinePOSObject.UpdateCustomerDisplay();
                                //+NPR5.23
                            end;
                        end;
                    end;
            end;

            PaymentLinePOSObject.CalculateBalance(Dec);

            Validering := '';
            exit(true);
        end;
    end;

    procedure SetCustomer()
    var
        Linie: Record "Sale Line POS";
        FormCode: Codeunit "Retail Form Code";
        t002: Label 'You cannot change customer when doing customer deposits.';
    begin
        //Pushdebitor
        with This do begin

            Validate("Customer No.", '');
            Modify;
            Commit;

            Linie.SetRange("Register No.", "Register No.");
            Linie.SetRange("Sales Ticket No.", "Sales Ticket No.");
            ;
            Linie.SetRange(Type, Linie.Type::Customer);
            if Linie.Find('-') then
                Marshaller.Error_Protocol(Text10600200, t002, true);

            EnterHit('DEBITCUSTOMER');
            RetailSetup.Get;
            if (RetailSetup."Auto edit debit sale") and ("Customer No." <> '') then begin
                FormCode.CreateSalesHeader(This, TempSalesHeader);
                Commit;
                ExecFunction('DEBIT_INFO');
            end;
            Register.Get("Register No.");
            if "Customer No." <> '' then begin
                if AutoDebit then
                    exit;
            end;

            MenuLines1."Filter No." := '';

            if (State.ViewType = ViewType.Payment) and (not IsCashSale) then begin
                GotoPayment();
            end;
        end;
    end;

    procedure SetContact()
    begin
        with This do begin
            Register.Get("Register No.");

            EnterHit('KONTANTKUNDE');

            MenuLines1."Filter No." := '';

            if (State.ViewType = ViewType.Payment) and (not IsCashSale) then begin
                GotoPayment();
            end;
        end;
    end;

    procedure ShowSaleLineDetails(): Boolean
    var
        formZoom: Page "Touch Screen - Sales Line Zoom";
        Linie: Record "Sale Line POS";
        "Retail Sales Line Code": Codeunit "Retail Sales Line Code";
    begin
        //ZoomEkspLines

        if not "Retail Sales Line Code".LineExists(This) then begin
            Marshaller.DisplayError(Text10600200, Text10600112, false);
            exit(false);
        end;

        Clear(formZoom);
        SaleLinePOSObject.GETRECORD(Linie);
        if Linie."Line No." = 0 then exit(false);
        PAGE.RunModal(PAGE::"Touch Screen - Sales Line Zoom", Linie);
    end;

    procedure TransferToInvoice() ret: Boolean
    begin
        if not RetailSalesDocMgt.ProcessPOSSale(This) then
            exit(false);

        Clear(LastSaleFigures);

        ret := true;
    end;

    procedure "------------"()
    begin
    end;

    procedure ItemsVisible(b: Boolean)
    begin
        if b then begin
            InitFunctions(State.ViewType, 'SALESMENU', This."Register No.", This."Salesperson Code", Validering);
        end else begin
            Clear(b);
        end;
    end;

    procedure PressedFunction(No: Integer): Code[30]
    var
        SalesPerson: Record "Salesperson/Purchaser";
        EnterHitStr: Text[30];
        int1: Integer;
        t001: Label 'User not found';
        t002: Label 'There is no password on this user';
    begin
        MenuLines1.Reset;

        Setuplinie.CopyFilter(Type, MenuLines1.Type);

        MenuLines1.SetRange(Visible, true);
        MenuLines1.SetRange("No.", No);
        Setuplinie.CopyFilter(Type, MenuLines2.Type);

        MenuLines2.SetCurrentKey("Menu No.", Type, "No.");

        if not MenuLines1.Find('-') then exit;
        if MenuLines1.Count = 1 then begin
            case MenuLines1.Type of
                MenuLines1.Type::Item:
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then begin
                            UpdateTouchScreenButtons(MenuLines2);
                        end else begin
                            case MenuLines1."Run as" of
                                MenuLines1."Run as"::Report:
                                    begin
                                        SetScreenView(ViewType.SubFindItem);
                                    end;
                                else begin
                                        case MenuLines1."Line Type" of
                                            MenuLines1."Line Type"::Item,
                                            MenuLines1."Line Type"::"Item Group":
                                                begin
                                                    Validering := MenuLines1."Filter No.";
                                                end;
                                        end;
                                        SetScreenView(ViewType.Sale);
                                    end;
                            end;
                        end;
                    end;
                MenuLines1.Type::"G/L Account":
                    begin
                        Validering := MenuLines1."Filter No.";
                    end;
                MenuLines1.Type::User:
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then begin
                            UpdateTouchScreenButtons(MenuLines2);
                        end else begin
                            SalesPerson.Reset;
                            SalesPerson.SetRange(Code, MenuLines1."Filter No.");
                            if not SalesPerson.Find('-') then begin
                                Error(t001);
                            end else
                                if SalesPerson."Register Password" = '' then
                                    Error(t002);
                            Validering := SalesPerson."Register Password";
                            EnterHitStr := 'LOGIN';
                        end;
                    end;
                MenuLines1.Type::"Payment Form":
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then
                            UpdateTouchScreenButtons(MenuLines2)
                        else begin
                            case MenuLines1."Line Type" of
                                MenuLines1."Line Type"::Internal:
                                    ExecFunction(MenuLines1."Filter No.");
                                else
                                    PaymentType(PaymentTypePOS."Processing Type"::Cash, MenuLines1."Filter No.")
                            end;
                        end;
                    end;
                MenuLines1.Type::Login,
                MenuLines1.Type::"Sale Functions",
                MenuLines1.Type::"Payment Functions",
                MenuLines1.Type::"Sale Form",
                MenuLines1.Type::Discount,
                MenuLines1.Type::"Customer Functions",
                MenuLines1.Type::"Item Functions",
                MenuLines1.Type::Prints:
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then begin
                            UpdateTouchScreenButtons(MenuLines2);
                        end else begin
                            PressedFunction_Run(MenuLines1);
                        end;
                    end;
                MenuLines1.Type::PaymentType:
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then begin
                            UpdateTouchScreenButtons(MenuLines2);
                        end else begin
                            PaymentTypePOS.Reset;
                            PaymentTypePOS.SetRange("No.", MenuLines1."Filter No.");
                            PaymentTypePOS.Find('-');
                            EnterHitStr := MenuLines1."Filter No.";
                            SetScreenView(ViewType.Payment);
                        end;
                    end;
                MenuLines1.Type::Insurance:
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then begin
                            UpdateTouchScreenButtons(MenuLines2);
                        end else begin
                            SetScreenView(ViewType.Sale);
                            EnterHitStr := 'FORSIKRING';
                        end;
                    end;
                MenuLines1.Type::Keyboard:
                    begin
                        MenuLines2 := MenuLines1;
                        MenuLines2.Next;
                        if MenuLines2.Level > MenuLines1.Level then begin
                            UpdateTouchScreenButtons(MenuLines2);
                        end;
                    end;
                MenuLines1.Type::Reports:
                    begin
                        Evaluate(int1, MenuLines1."Filter No.");
                        REPORT.RunModal(int1);
                    end;
            end;
        end;
    end;

    local procedure PressedFunction_Run(MenuLines1: Record "Touch Screen - Menu Lines")
    var
        int1: Integer;
        SaleLinePOS: Record "Sale Line POS";
        MPOSReporthandler: Codeunit "MPOS Report handler";
    begin
        case MenuLines1."Line Type" of
            MenuLines1."Line Type"::Internal:
                //-NPR5.32 [274462]
                begin
                    //IF (MenuLines1.Parametre<>'') AND (This.Parameters='') THEN
                    if (MenuLines1.Parametre <> '') then
                        This.Parameters := MenuLines1.Parametre;
                    //+NPR5.32
                    ExecFunction(MenuLines1."Filter No.");
                end;
            MenuLines1."Line Type"::Page:
                begin
                    Evaluate(int1, MenuLines1."Filter No.");
                    PAGE.RunModal(int1);
                end;
            MenuLines1."Line Type"::Report:
                begin
                    Evaluate(int1, MenuLines1."Filter No.");
                    //-NPR5.33
                    MPOSReporthandler.ExecutionHandler(int1, This."Register No.");
                    //REPORT.RUNMODAL(int1);
                    //+NPR5.33
                end;
            MenuLines1."Line Type"::"Codeunit(sale)":
                begin
                    Evaluate(int1, MenuLines1."Filter No.");
                    //-NPR4.02
                    if (MenuLines1.Parametre <> '') and (This.Parameters = '') then
                        This.Parameters := MenuLines1.Parametre;
                    //+NPR4.02
                    CODEUNIT.Run(int1, This);
                end;
            MenuLines1."Line Type"::"Codeunit(line)":
                begin
                    Evaluate(int1, MenuLines1."Filter No.");
                    SaleLinePOSObject.GETRECORD(SaleLinePOS);
                    CODEUNIT.Run(int1, SaleLinePOS);
                end;
            MenuLines1."Line Type"::Hyperlink:
                begin
                    HyperLink(MenuLines1.Parametre);
                end;
            MenuLines1."Line Type"::Customer:
                begin
                    Validering := MenuLines1."Filter No.";
                    ExecFunction('CUSTOMER_SET');
                end;
            MenuLines1."Line Type"::Item,
            MenuLines1."Line Type"::"Item Group":
                begin
                    Validering := MenuLines1."Filter No.";
                    ButtonDefault;
                end;
        end;
    end;

    procedure PressedPopupFunction(No: Integer; Back: Boolean)
    var
        MenuLine1: Record "Touch Screen - Menu Lines";
        MenuLine2: Record "Touch Screen - Menu Lines";
        DoPressFunction: Boolean;
        vare1: Record Item;
    begin
        if Back then begin
            if MenuLinePopupTmp.Count > 0 then begin
                MenuLine2.Copy(MenuLinePopupTmp);
                MenuLinePopupTmp.Delete;
                if MenuLinePopupTmp.FindLast then;
                UpdateFunctionsPopupButtons(MenuLine2);
            end;
            exit;
        end;

        MenuLinePopupTmp.CopyFilter(Type, MenuLine1.Type);
        MenuLine1.SetRange(Visible, true);
        MenuLine1.SetRange("No.", No);
        if MenuLine1.FindFirst then begin
            MenuLine2 := MenuLine1;
            if (MenuLine2.Next(1) = 1) and (MenuLine2.Level > MenuLine1.Level) then begin
                MenuLine2.CopyFilters(MenuLinePopupTmp);
                MenuLine2.SetRange(Level);
                MenuLine2.SetFilter("No.", '>=%1', MenuLine2."No.");
                MenuLinePopupTmp.Copy(MenuLine1);
                if MenuLinePopupTmp.Insert then;
                UpdateFunctionsPopupButtons(MenuLine2);
                exit;
            end;
            DoPressFunction := true;
        end;

        Marshaller.CloseFunctions();

        if DoPressFunction then
            case FunctionState of
                FunctionState::Main:
                    PressedFunction_Run(MenuLine1);
                FunctionState::FindElement:
                    begin
                        case MenuLines1."Line Type" of
                            MenuLines1."Line Type"::Item:
                                ButtonDefault;
                            MenuLines1."Line Type"::"Item Group":
                                begin
                                    vare1.Reset;
                                    vare1.SetCurrentKey("Item Group");
                                    vare1.SetFilter("Item Group", '%1', MenuLines1."Filter No.");
                                    Validering := '';
                                    if PAGE.RunModal(6014525, vare1) = ACTION::LookupOK then begin
                                        Validering := vare1."No.";
                                        EnterHit('EKSPEDITION');
                                    end;
                                end;
                        end;

                        // FIND BETALINGSVALG
                        if (State.ViewType = ViewType.Payment) then begin
                            Functions('BETALINGSVALG');
                            exit;
                        end;

                        // FIND FORSIKRING
                        if (State.ViewType = ViewType.Insurance) then begin
                            SetScreenView(ViewType.Sale);
                            Functions('FORSIKRING');
                            exit;
                        end;
                    end;
            end;
    end;

    procedure InitFunctions(ViewType: Integer; TypeStr: Text[30]; "Register No.": Code[20]; User: Code[20]; Validering1: Code[20]): Boolean
    var
        Heading: Text[30];
        t001: Label 'Functions - Login';
        t002: Label 'Functions - Payment';
        t003: Label 'Functions - Sale';
        t004: Label 'Sales personal';
        t005: Label 'Item Groups/Items';
        t006: Label 'Payment types';
        t008: Label 'Insurances';
        t009: Label 'Keyboard';
        t010: Label 'Discounts';
        t011: Label 'Printouts';
        t012: Label 'Functions - Customers';
        t013: Label 'Functions - Items';
        text001: Label 'Incorrect type string: %1. This is a bug, not a user error.';
    begin
        // InitFunctions
        with This do begin
            SetScreenView(ViewType);
            Validering := Validering1;

            Setuplinie.Reset;

            case TypeStr of
                'LOGIN':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Login);
                'EKSPEDITION':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::"Sale Functions");
                'PAYMENT':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::"Payment Functions");
                'SALESMENU':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::"Sale Form");
                'USERS':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::User);
                'ITEM':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Item);
                'BETALINGSVALG':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::PaymentType);
                'CUSTOMER':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::"Customer Functions");
                'FINANS':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::"G/L Account");
                'FORSIKRING':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Insurance);
                'KEYBOARD':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Keyboard);
                'DISCOUNT':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Discount);
                'PRINTS':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Prints);
                'REPORTS':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::Reports);
                'ITEMFUNCTIONS':
                    Setuplinie.SetFilter(Type, '=%1', Setuplinie.Type::"Item Functions");
                'DEBITPRINT':
                    ;
                'DEBTISALEPOST':
                    ;
                else
                    Marshaller.Error_Protocol('', StrSubstNo(text001, TypeStr), true);
            end;

            case TypeStr of
                'LOGIN':
                    Heading := t001;
                'EKSPEDITION':
                    Heading := t003;
                'PAYMENT':
                    Heading := t002;
                'USERS':
                    Heading := t004;
                'ITEM':
                    Heading := t005;
                'BETALINGSVALG':
                    Heading := t006;
                'FORSIKRING':
                    Heading := t008;
                'KEYBOARD':
                    Heading := t009;
                'DISCOUNT':
                    Heading := t010;
                'PRINTS':
                    Heading := t011;
                'CUSTOMER':
                    Heading := t012;
                'ITEMFUNCTIONS':
                    Heading := t013;
                'DEBITPRINT':
                    begin
                        exit(true);
                    end;
                'DEBITSALEPOST':
                    begin
                    end;
            end;

            LastTypeStr := TypeStr;

            CurrentMenuLevel := 0;

            Setuplinie.SetRange(Level, CurrentMenuLevel);
            Setuplinie.SetRange(Visible, true);
            Setuplinie.SetFilter("Register Type", '%1|%2', '', Register."Register Type");
            if not Setuplinie.Find('-') then;

            UpdateTouchScreenButtons(Setuplinie);
        end;
    end;

    local procedure UpdateTouchScreenButtons(InputLinie: Record "Touch Screen - Menu Lines")
    var
        UI: Codeunit "POS Web UI Management";
        IMenuButtonView: DotNet npNetIMenuButtonView;
        Grids: DotNet npNetButtonGrid;
        Direction: Option TopBottom,LeftRight;
    begin
        if (InputLinie."No." = 0) or (not State.View.Initialized) or (not State.View.HasMenu) then
            exit;

        IMenuButtonView := State.View.ToMenuButtonView();
        if IsNull(IMenuButtonView) then
            exit;
        //-NPR5.40 [308408]
        //Grid := IMenuButtonView.GetMenu();
        Grids := IMenuButtonView.GetMenu();
        //+NPR5.40 [308408]
        Setuplinie.CopyFilter(Type, InputLinie.Type);

        with InputLinie do begin
            "Grid Position" := "Grid Position"::"Bottom Center";
            CurrentMenuLevel := Level;
            Direction := Direction::TopBottom;

            SetRange("Grid Position", "Grid Position"::"Bottom Center");
            SetFilter("Register Type", '%1|%2', '', Register."Register Type");
            SetFilter(Terminal, '%1|%2', '', Register."Register No.");
        end;

        //-NPR5.40 [308408]
        //UI.ConfigureButtonGrid(Grid,InputLinie,Direction,0);
        //State.Marshaller.SetObjectProperty('n$.State.Context.View.buttonGridMenu',Grid.ToButtons());
        UI.ConfigureButtonGrid(Grids, InputLinie, Direction, 0);
        State.Marshaller.SetObjectProperty('n$.State.Context.View.buttonGridMenu', Grids.ToButtons());
        //+NPR5.40 [308408]
    end;

    local procedure UpdateFunctionsPopupButtons(var InputLinie: Record "Touch Screen - Menu Lines")
    var
        UI: Codeunit "POS Web UI Management";
        Grids: DotNet npNetButtonGrid;
        Direction: Option TopBottom,LeftRight;
    begin
        if (InputLinie."No." = 0) then
            exit;
        //-NPR5.40 [308408]
        //Grid := Grid.ButtonGrid(6,5,SessionMgt.ButtonsEnabledByDefault);
        Grids := Grids.ButtonGrid(6, 5, SessionMgt.ButtonsEnabledByDefault);
        //+NPR5.40 [308408]
        with InputLinie do begin
            "Grid Position" := "Grid Position"::"Bottom Center";
            Direction := Direction::TopBottom;

            SetRange("Grid Position", "Grid Position"::"Bottom Center");
        end;
        //-NPR5.40 [308408]
        //UI.ConfigureButtonGrid(Grid,InputLinie,Direction,0);
        //State.Marshaller.SetObjectProperty('n$.State.Context.FunctionspadDialog.grid',Grid.ToButtons());
        UI.ConfigureButtonGrid(Grids, InputLinie, Direction, 0);
        State.Marshaller.SetObjectProperty('n$.State.Context.FunctionspadDialog.grid', Grids.ToButtons());
        //+NPR5.40 [308408]
    end;

    procedure GoBack(): Boolean
    begin
        if CurrentMenuLevel = 0 then
            exit(true);

        if CurrentMenuLevel > 0 then
            //-NPR5.00
            //  InitFunctions(State.ViewType,LastTypeStr,Register."Register No.",This."Salesperson Code",Validering);
            UpdateTouchScreenButtons(Setuplinie);
        //+NPR5.00

        exit(false);
    end;

    procedure GoToRoot(): Boolean
    begin
        CurrentMenuLevel := 0;

        //-NPR5.00
        //InitFunctions(State.ViewType,LastTypeStr,Register."Register No.",This."Salesperson Code",Validering);
        UpdateTouchScreenButtons(Setuplinie);
        //+NPR5.00
    end;

    local procedure UpdateSaleLinePOSObject()
    var
        String: DotNet npNetString;
        POSWebUIManagement: Codeunit "POS Web UI Management";
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.35 [281761]
        //-NPR5.35 [288588]
        if State.IsCurrentView(ViewType.Sale) then begin
            SaleLinePOS.SetRange("Register No.", This."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", This."Sales Ticket No.");
            if SaleLinePOS.FindLast then
                SaleLinePOSObject.SetLine(SaleLinePOS)
            else begin
                SaleLinePOSObject.SetTableView(This."Register No.", This."Sales Ticket No.");
                String := This."Sales Ticket No.";
                Marshaller.SetObjectProperty('n$.State.Context.SaleTicketNo', String);
                Marshaller.RequestRefreshSalesLineData;
            end;
        end;
        //+NPR5.35
        //+NPR5.35
    end;

    procedure "----- Meta Code -----"()
    begin
    end;

    procedure HandleMetaTrigger(var MetaName: Code[50]; When: Option Before,After; var Sale: Record "Sale POS"; var "Sales Line": Record "Sale Line POS") Handled: Boolean
    var
        MetaTriggers: Record "Touch Screen - MetaTriggers";
        MetaFunctions: Record "Touch Screen - Meta Functions";
        int: Integer;
        MetaTriggerHandled: Boolean;
    begin
        //-NPR5.20
        MetaFunctions.SetRange(Action, MetaFunctions.Action::NavEvent);
        MetaFunctions.SetRange(Code, MetaName);
        if MetaFunctions.FindFirst and (When = When::Before) then begin
            MetaTriggerHandled := false;
            HandleMetaTriggerEvent(MetaName, Sale, "Sales Line", MetaTriggerHandled);
            exit(MetaTriggerHandled);
        end;
        //+NPR5.20

        MetaTriggers.Reset;
        MetaTriggers.SetCurrentKey(When, Sequence, "Register No.");
        MetaTriggers.SetRange("On function call", MetaName);
        MetaTriggers.SetRange(When, When);
        MetaTriggers.SetFilter("Register No.", '%1|%2', Sale."Register No.", '');
        if MetaTriggers.FindSet then
            repeat
                int := MetaTriggers.ID;
                Sale.Parameters := MetaTriggers."Var Record Param";
                if int > 0 then
                    case MetaTriggers."Line Type" of
                        MetaTriggers."Line Type"::Report:
                            begin
                                case MetaTriggers."Var Parameter" of
                                    MetaTriggers."Var Parameter"::" ":
                                        REPORT.RunModal(int, false, false);
                                    MetaTriggers."Var Parameter"::Sale:
                                        REPORT.RunModal(int, false, false, Sale);
                                    MetaTriggers."Var Parameter"::SalesLine:
                                        REPORT.RunModal(int, false, false, "Sales Line");
                                end;
                            end;
                        MetaTriggers."Line Type"::Page:
                            begin
                                case MetaTriggers."Var Parameter" of
                                    MetaTriggers."Var Parameter"::" ":
                                        PAGE.RunModal(int);
                                    MetaTriggers."Var Parameter"::Sale:
                                        PAGE.RunModal(int, Sale);
                                    MetaTriggers."Var Parameter"::SalesLine:
                                        PAGE.RunModal(int, "Sales Line");
                                end;
                            end;
                        MetaTriggers."Line Type"::Internal:
                            ExecFunction(MetaTriggers."Var Record Param");
                        MetaTriggers."Line Type"::Codeunit:
                            case MetaTriggers."Var Parameter" of
                                MetaTriggers."Var Parameter"::" ":
                                    CODEUNIT.Run(int);
                                MetaTriggers."Var Parameter"::Sale:
                                    CODEUNIT.Run(int, Sale);
                                MetaTriggers."Var Parameter"::SalesLine:
                                    CODEUNIT.Run(int, "Sales Line");
                            end;
                    end;
            until MetaTriggers.Next = 0
        else
            exit(false);

        exit(true);
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure HandleMetaTriggerEvent(MetaTriggerName: Code[50]; var SalePos: Record "Sale POS"; var SaleLinePos: Record "Sale Line POS"; var MetaTriggerHandled: Boolean)
    begin
        //-NPR5.20
        //+NPR5.20
    end;

    procedure "------ Form Logic ------"()
    begin
    end;

    procedure OnQueryCloseForm(): Boolean
    var
        t001: Label 'This will cancel the sale. If this is a sale to be re-used later, press SAVE first.\Continue?';
        t003: Label 'Cancel the sale?';
        RetailFormCode: Codeunit "Retail Form Code";
        SaleLinePOS: Record "Sale Line POS";
    begin
        with This do begin
            SetScreenView(State.ViewType);

            if State.IsCurrentView(ViewType.Halt) then begin
                CancelSale();
                Commit;
                exit(true);
            end;

            Register.Get("Register No.");

            /* LOCKED */
            if State.IsCurrentView(ViewType.Locked) then begin
                EnterHit('LOCKED');
                exit(false);
            end;

            /* LOGIN */
            if State.IsCurrentView(ViewType.Login) then begin
                if Validering <> '' then begin
                    Validering := '';
                    exit(false);
                end;
                "Salesperson Code" := '';
                CancelSale();
                exit(true);
            end;

            /* REGISTER_CHANGE */
            if State.IsCurrentView(ViewType.RegisterChange) then begin
                "Salesperson Code" := '';
                Validering := '';
                CancelSale();
                SaleInit(false, true);
                exit(false);
            end;

            /* ---------------------------------- BETALING */
            if State.IsCurrentView(ViewType.Payment) then begin
                if Validering <> '' then begin
                    Validering := '';
                    exit(false);
                end;
                GotoSale();
                exit(false);
            end;

            /* ---------------------------------- FIND VARE */
            if State.IsCurrentView(ViewType.SubFindItem) then begin
                SetSaleScreenVisible();
                exit(false);
            end;

            /* ---------------------------------- FIND BETALINGSVALG */
            if State.IsCurrentView(ViewType.SubFindPayment) then begin
                SetScreenView(ViewType.Payment);
                exit(false);
            end;

            /* -------------------------------------- KASSEAFSLUTNING */
            if State.IsCurrentView(ViewType.BalanceRegister) then begin
                Commit;
                "Salesperson Code" := '';
                Validate("Customer No.", '');
                SetSaleScreenVisible();

                exit(false);
            end;

            /* EKSPEDITION */
            if State.IsCurrentView(ViewType.Sale) then begin
                if Validering <> '' then begin
                    Validering := '';
                    exit(false);
                end;
                if ("Sales Ticket No." <> '') then begin
                    Clear(SaleLinePOS);
                    SaleLinePOS.SetRange("Register No.", "Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                    //-NPR5.31 [271728]
                    //IF SaleLinePOS.COUNT <> 0 THEN BEGIN
                    if not SaleLinePOS.IsEmpty then begin
                        //+NPR5.31 [271728]
                        if not Marshaller.Confirm(t003, t001) then
                            exit(false);
                        RetailFormCode.CheckSelection(This);
                        //-NPR5.30 [264918]
                        //RetailFormCode.CheckPhoto(This);
                        //+NPR5.30 [264918]
                        RetailFormCode.OnCancelSale(This);
                        CancelSale();
                        Commit;
                        if Register."Touch Screen Login autopopup" then begin
                            Validering := '';
                            EnterPush;
                        end;
                        SaleLinePOSObject.SetTableView("Register No.", "Sales Ticket No.");
                        PaymentLinePOSObject.SetTableView("Register No.", "Sales Ticket No.");
                        exit(false);
                        //-NPR4.14
                        //END ELSE BEGIN
                        //  IF "Drawer Opened" THEN
                        //    RetailFormCode.AuditRollCancelSale(This,t004);
                        //  TouchScreenFunctions.ResetSalesTicketNumber(This, -1);
                        //END;
                    end;
                    //+NPR4.14

                    DeleteDimOnEkspAndLines;

                    "Salesperson Code" := '';
                    Validate("Customer No.", '');
                    SetSaleScreenVisible();
                    Commit;

                    if Register."Touch Screen Login autopopup" then begin
                        Validering := '';
                        exit(not EnterPush);
                    end;
                    exit(false);
                end;
                exit(true);
            end;

            if State.IsCurrentView(ViewType.SubFindCustomer) or State.IsCurrentView(ViewType.SubFindAccount) or State.IsCurrentView(ViewType.SubFindItem) then begin
                if Validering <> '' then begin
                    Validering := '';
                    exit(false);
                end;

                SetScreenView(ViewType.Sale);
                SetSaleScreenVisible();
                exit(false);
            end;
        end;

    end;

    procedure "------ Inputs ------"()
    begin
    end;

    procedure SetValidation(_Validation: Code[20])
    begin
        Validering := _Validation;
    end;

    procedure SetSalesLinePosition(Position: Text[250])
    begin
        SaleLinePOSObject.SETPOSITION(Position);
    end;

    procedure SetPaymentLinePosition(Position: Text[250])
    begin
        PaymentLinePOSObject.SETPOSITION(Position);
    end;

    procedure GetLinePosition(): Text
    begin
        case true of
            State.IsCurrentView(ViewType.Sale):
                exit(SaleLinePOSObject.GETPOSITION());
            State.IsCurrentView(ViewType.Payment):
                exit(PaymentLinePOSObject.GETPOSITION());
        end;
    end;

    procedure SetScreenView(NewViewType: Integer)
    var
        String: DotNet npNetString;
    begin
        if State.IsCurrentView(NewViewType) then
            exit;

        ClearStateData();
        State.ViewType := NewViewType;
        Validering := '';

        case true of
            State.IsCurrentView(ViewType.Sale):
                begin
                    Setuplinie.SetRange(Type, Setuplinie.Type::"Sale Form");
                    State.Marshaller.ChangeScreen(State.ViewType);
                    //-NPR5.22
                    String := This."Sales Ticket No.";
                    Marshaller.SetObjectProperty('n$.State.Context.SaleTicketNo', String);
                    //+NPR5.22
                end;
            State.IsCurrentView(ViewType.Payment):
                begin
                    Setuplinie.SetRange(Type, Setuplinie.Type::"Payment Form");
                    State.Marshaller.ChangeScreen(State.ViewType)
                end;
            State.IsCurrentView(ViewType.Login):
                begin
                    Setuplinie.SetRange(Type, Setuplinie.Type::Login);
                    State.Marshaller.ChangeScreen(State.ViewType)
                end;
            State.IsCurrentView(ViewType.Locked):
                begin
                    State.Marshaller.ChangeScreen(State.ViewType)
                end;
        end;

        UpdateTouchScreenButtons(Setuplinie);
    end;

    procedure "-----------"()
    begin
    end;

    procedure GetSalesLines(Grids: DotNet npNetDataGrid)
    begin
        //-NPR5.40 [308408]
        // //-NPR5.22
        // //SaleLinePOSObject.GetSalesLinesWeb(Grid);
        // SaleLinePOSObject.GetSalesLinesWeb(Grid,LastLineTemp);
        // //+NPR5.22
        // State.Marshaller.SetSalesLineData(Grid);
        SaleLinePOSObject.GetSalesLinesWeb(Grids, LastLineTemp);
        State.Marshaller.SetSalesLineData(Grids);
        //-NPR5.40 [308408]
    end;

    procedure GetSalesTotal(): Decimal
    begin
        SaleLinePOSObject.CalculateBalance();
        exit(SaleLinePOSObject.GetSubTotal());
    end;

    procedure GetPaymentLines(Grids: DotNet npNetDataGrid)
    begin
        //-NPR5.40 [308408]
        // //-NPR5.25
        // //PaymentLinePOSObject.GetPaymentLines(Grid);
        // PaymentLinePOSObject.GetPaymentLines(Grid,LastPmtLineTemp);
        // //+NPR5.25
        // State.Marshaller.SetSalesLineData(Grid);

        PaymentLinePOSObject.GetPaymentLines(Grids, LastPmtLineTemp);
        State.Marshaller.SetSalesLineData(Grids);
        //+NPR5.40 [308408]
    end;

    procedure GetPaymentTotal() Total: Decimal
    begin
        PaymentLinePOSObject.CalculateBalance(Total);
    end;

    procedure "----- Info -----"()
    begin
    end;

    procedure RegisterNo(): Text[50]
    begin
        exit(This."Register No.")
    end;

    procedure SalesPersonName(): Text[50]
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if Salesperson.Get(This."Salesperson Code") then
            exit(Salesperson.Name)
    end;

    procedure SalesTicketNo(): Text
    begin
        exit(This."Sales Ticket No.")
    end;

    procedure GetPaymentInfo(var Total: Decimal; var Payed: Decimal; var ReturnAmount: Decimal)
    begin
        PaymentLinePOSObject.CalculateBalance(Total);

        Total := PaymentLinePOSObject.LastSale(1);
        Payed := PaymentLinePOSObject.LastSale(2);
        ReturnAmount := PaymentLinePOSObject.LastSale(3);
    end;

    procedure GetLastSaleInfo(var LastSaleDateText: Text[50]; var LastSaleTotal: Decimal; var LastSalePayment: Decimal; var LastSaleReturnAmount: Decimal; var LastReceiptNo: Text[20])
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        //-NPR5.22 - Not used - Audit roll was local
        //LastSaleDateText := FORMAT(AuditRoll."Sale Date") + ' | ' + FORMAT(AuditRoll."Closing Time");
        //+NPR5.22
        TouchScreenFunctions.GetLastSaleInfo(This."Register No.", LastSaleTotal, LastSalePayment, LastSaleDateText, LastSaleReturnAmount, LastReceiptNo);
    end;

    procedure GetCustomerName(): Text
    var
        Customer: Record Customer;
    begin
        if Customer.Get(This."Customer No.") then
            exit(Customer.Name)
    end;

    procedure GetContactName(): Text
    var
        Contact: Record Contact;
    begin
        //-NPR5.27 [255864]
        if Contact.Get(This."Contact No.") then
            exit(Contact.Name)
        //+NPR5.27 [255864]
    end;

    procedure "---- Page Query Info ----"()
    begin
    end;

    procedure QueryClose()
    begin
        QueriedClose := QueriedClose::Yes;
    end;

    local procedure QueryCloseRefresh()
    begin
        QueriedClose := QueriedClose::Refresh;
    end;

    procedure GetQueryClose() Value: Integer
    begin
        Value := QueriedClose;
        QueriedClose := QueriedClose::No;
    end;

    procedure GetCurrentMenuLevel() Level: Integer
    begin
        exit(CurrentMenuLevel);
    end;

    local procedure GetInfoBoxFromView(var InfoBox: DotNet npNetInfoBox)
    var
        ViewType: DotNet npNetViewType;
        SaleView: DotNet npNetSaleView;
        PaymentView: DotNet npNetPaymentView;
    begin
        case State.View.TypeAsInt of
            ViewType.Sale:
                begin
                    SaleView := State.View;
                    InfoBox := SaleView.InfoBox;
                end;
            ViewType.Payment:
                begin
                    PaymentView := State.View;
                    InfoBox := PaymentView.InfoBox;
                end;
        end;
    end;

    local procedure ClearInfoBox()
    var
        InfoBox: DotNet npNetInfoBox;
    begin
        GetInfoBoxFromView(InfoBox);
        if IsNull(InfoBox) then
            exit;

        InfoBox.Clear();
    end;

    local procedure SetInfoBox(Index: Integer; Caption: Text; Value: Variant)
    var
        InfoBox: DotNet npNetInfoBox;
    begin
        GetInfoBoxFromView(InfoBox);
        if IsNull(InfoBox) then
            exit;

        InfoBox.SetInfoBoxLabel(Index, Caption, Value);
    end;

    local procedure SetInfoBoxHeader(Caption: Text; Value: Variant)
    var
        InfoBox: DotNet npNetInfoBox;
    begin
        GetInfoBoxFromView(InfoBox);
        if IsNull(InfoBox) then
            exit;

        InfoBox.Header.Caption := Caption;
        InfoBox.Header.Value := Value;
    end;

    local procedure UpdateInfoBox()
    begin
        Marshaller.UpdateInfoBox(State.View);
    end;

    procedure ClearStateData()
    begin
        StateData := StateData.Dictionary();

        SetStateData('RegisterNo', RegisterNo);
        SetStateData('SalesPersonName', SalesPersonName);
        SetStateData('ReceiptNo', SalesTicketNo);

        //-NPR5.22
        LastLineTemp.DeleteAll();
        //+NPR5.22
        //-NPR5.25
        LastPmtLineTemp.DeleteAll();
        //+NPR5.25
    end;

    procedure SetStateData("Key": Text; Value: Variant)
    begin
        if StateData.ContainsKey(Key) then
            StateData.Item(Key, Value)
        else
            StateData.Add(Key, Value);
    end;

    procedure UpdateStateData()
    begin
        Marshaller.UpdateState(StateData);
    end;

    procedure GetUpdatePosition() Result: Boolean
    begin
        Result := UpdatePosition;
        UpdatePosition := false;
    end;

    local procedure "-----"()
    begin
    end;

    local procedure PushLineDiscountPct(KeepPrev: Boolean)
    var
        t006: Label 'Type in the discount % that you want to give on the current sales line.';
        Context: DotNet npNetProtocolContext;
    begin
        Context := Context.ProtocolContext(MethodName_PushLineDiscountPct);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Context.MethodArguments.Add('KeepPrev', KeepPrev);
        Marshaller.NumPad_Protocol(t006, 0, false, false, Context);
    end;

    local procedure PushTotalAmount()
    var
        t007: Label 'Type the total amount that you want the sale to cost.';
        Context: DotNet npNetProtocolContext;
    begin
        SaleLinePOSObject.CalculateBalance;
        Context := Context.ProtocolContext(MethodName_PushTotalAmount);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Marshaller.NumPad_Protocol(t007, 0, false, false, Context);
    end;

    local procedure PushTotalDiscount()
    var
        t004: Label 'Type in the total discount amount for the current sale.';
        Context: DotNet npNetProtocolContext;
    begin
        SaleLinePOSObject.CalculateBalance;
        Context := Context.ProtocolContext(MethodName_PushTotalDiscount);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Marshaller.NumPad_Protocol(t004, 0, false, false, Context);
    end;

    local procedure PushDiscountPct(KeepPrev: Boolean)
    var
        Context: DotNet npNetProtocolContext;
        t005: Label 'Type in the discount % that you want to give on each of the current sales lines.';
    begin
        Context := Context.ProtocolContext(MethodName_PushDiscountPct);
        Context.MethodArguments.Add('KeepPrev', KeepPrev);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Marshaller.NumPad_Protocol(t005, 0, false, false, Context);
    end;

    local procedure PushLineDiscountAmount()
    var
        Context: DotNet npNetProtocolContext;
        t024: Label 'Type in the discount amount that you want to give on the current sales line.';
    begin
        Context := Context.ProtocolContext(MethodName_PushLineDiscountAmount);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Marshaller.NumPad_Protocol(t024, 0, false, false, Context);
    end;

    local procedure PushLineUnitPrice()
    var
        Context: DotNet npNetProtocolContext;
        t015: Label 'Type in unit price.';
    begin
        Context := Context.ProtocolContext(MethodName_PushLineUnitPrice);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Marshaller.NumPad_Protocol(t015, 0, false, false, Context);
    end;

    local procedure PushRegisterChange()
    var
        Context: DotNet npNetProtocolContext;
        t017: Label 'Change to register number:';
    begin
        CopyValidering := Validering;

        Context := Context.ProtocolContext(MethodName_PushRegisterChange);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Marshaller.NumPad_ProtocolCode(t017, This."Register No.", true, false, Context);
    end;

    local procedure PushSaleReverse()
    var
        Context: DotNet npNetProtocolContext;
        Salesperson: Record "Salesperson/Purchaser";
        t028: Label '%1 does not have the rights to return sales ticket. Make a return sale instead.';
    begin
        Context := Context.ProtocolContext(MethodName_PushSaleReverse);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        //-NPR5.20
        Salesperson.Get(This."Salesperson Code");
        case Salesperson."Reverse Sales Ticket" of
            Salesperson."Reverse Sales Ticket"::No:
                Marshaller.Error_Protocol(Text10600200, StrSubstNo(t028, Salesperson.Name), true);
        end;
        //+NPR5.20
        Marshaller.NumPad_ProtocolCode(t014, '', true, false, Context);
    end;

    local procedure PushSaleAnnull()
    var
        Salesperson: Record "Salesperson/Purchaser";
        t028: Label '%1 does not have the rights to return sales ticket. Make a return sale instead.';
        Context: DotNet npNetProtocolContext;
    begin
        Context := Context.ProtocolContext(MethodName_PushSaleAnnull);
        Context.MethodArguments.Add('__FuncStr', LastFuncStr);
        Salesperson.Get(This."Salesperson Code");
        case Salesperson."Reverse Sales Ticket" of
            Salesperson."Reverse Sales Ticket"::No:
                Marshaller.Error_Protocol(Text10600200, StrSubstNo(t028, Salesperson.Name), true);
        end;
        Marshaller.NumPad_ProtocolCode(t014, '', true, false, Context);
    end;

    local procedure PushRegisterOpen()
    var
        t030: Label 'Open register drawer. This is locked by a password.';
        Context: DotNet npNetProtocolContext;
    begin
        CopyValidering := Validering;
        if RetailSetup."Open Register Password" <> '' then begin
            Context := Context.ProtocolContext(MethodName_PushRegisterOpen);
            Marshaller.NumPad_ProtocolCode(t030, '', false, true, Context);
        end else
            Complete_PushRegisterOpen(Validering);
    end;

    procedure ProcessNumpadResponse(Content: DotNet npNetNumPadResponseContent)
    begin
        case Content.Context.MethodName of
            MethodName_PushQuantity:
                Complete_PushQuantity(UI.ParseDecimal(Content.Text), Content.Context.MethodArguments.Item('Factor'));
            MethodName_PushLineDiscountPct:
                Complete_PushLineDiscountPct(UI.ParseDecimal(Content.Text), Content.Context.MethodArguments.Item('KeepPrev'));
            MethodName_PushTotalAmount:
                Complete_PushTotalAmount(UI.ParseDecimal(Content.Text));
            MethodName_PushTotalDiscount:
                Complete_PushTotalDiscount(UI.ParseDecimal(Content.Text));
            MethodName_PushDiscountPct:
                Complete_PushDiscountPct(UI.ParseDecimal(Content.Text), Content.Context.MethodArguments.Item('KeepPrev'));
            MethodName_PushLineDiscountAmount:
                Complete_PushLineDiscountAmount(UI.ParseDecimal(Content.Text));
            MethodName_PushLineUnitPrice:
                Complete_PushLineUnitPrice(UI.ParseDecimal(Content.Text));
            MethodName_PushRegisterChange:
                Complete_PushRegisterChange(Content.Text);
            MethodName_PushSaleReverse:
                Complete_PushSaleReverse(Content.Text);
            MethodName_PushSaleAnnull:
                Complete_PushSaleAnnull(Content.Text);
            MethodName_PushRegisterOpen:
                Complete_PushRegisterOpen(Content.Text);
        end;

        CompleteResponse(Content.Context.MethodArguments.Item('__FuncStr'));

        //-NPR5.26
        //-NPR5.46 [328581]
        //CustomerDisplayMgt.OnPOSAction(This,Register,3,'');
        //+NPR5.46 [328581]
        //+NPR5.26
    end;

    local procedure Complete_PushQuantity(Qty: Decimal; Factor: Decimal)
    var
        ReturnReason: Record "Return Reason";
        t001: Label 'You have typed a too big number! (%1)';
        t033: Label 'You must choose a return reason.';
        String: DotNet npNetString;
    begin
        CopyValidering := Validering;
        Validering := '';
        //-NPR5.01
        String := '';
        Marshaller.SetObjectProperty('n$.State.Context.View.EanBoxText.value', String);
        //+NPR5.01
        if Qty > 99999 then Error(t001, Qty);

        Qty := Factor * Qty;

        //-NPR5.38 [242158]
        if Factor < 0 then
            if RetailSetup."Reason for Return Mandatory" then
                if not (PAGE.RunModal(PAGE::"Touch Screen - Return Reasons", ReturnReason) = ACTION::LookupOK) then
                    Error(t033);
        //+NPR5.38 [242158]

        SaleLinePOSObject.ChangeQuantityOnActiveLine(This, Qty);
        SaleLinePOSObject.CalculateBalance;

        if Factor > 0 then begin
            if RetailSetup."Reason for Return Mandatory" then
                SaleLinePOSObject.SetReturnReason('');
        end else begin
            if RetailSetup."Reason for Return Mandatory" then begin
                //-NPR5.38 [242158]
                //COMMIT; // TODO - test and remove this commit, it's unnecessary in the new two-step architecture
                //IF PAGE.RUNMODAL(PAGE::"Touch Screen - Return Reasons",ReturnReason) = ACTION::LookupOK THEN
                SaleLinePOSObject.SetReturnReason(ReturnReason.Code)
                //ELSE
                //ERROR(t033);
                //+NPR5.38 [242158]
            end;
            if RetailSetup."Reset unit price on neg. sale" then begin
                SaleLinePOSObject.ChangeUnitPriceOnActiveLine(0);
                Commit; // TODO - test and remove this commit - it seems to be completely unnecessary
                SetLineAmount(0);
            end;
        end;


        //-NPR5.23
        SaleLinePOSObject.UpdateCustomerDisplay();
        //+NPR5.23
    end;

    local procedure Complete_PushLineDiscountPct(Disc: Decimal; KeepPrev: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Code10: Code[10];
    begin
        SaleLinePOSObject.GETRECORD(SaleLinePOS);
        TouchScreenFunctions.CheckLine(SaleLinePOS);
        Code10 := RetailSalesLineCode.AskReasonCode;
        SaleLinePOSObject.ChangeDiscountOnActiveLine(Disc, KeepPrev);
        SaleLinePOSObject.SetDiscountCode(Code10);
        //-NPR5.23
        SaleLinePOSObject.UpdateCustomerDisplay();
        //+NPR5.23
    end;

    local procedure Complete_PushTotalAmount(Amount: Decimal)
    var
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
    begin
        RetailSalesLineCode.SetTotalAmount(This, Amount);
    end;

    local procedure Complete_PushTotalDiscount(Discount: Decimal)
    var
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
    begin
        RetailSalesLineCode.SetTotalDiscountAmount(This, Discount);
    end;

    local procedure Complete_PushDiscountPct(Discount: Decimal; KeepPrev: Boolean)
    begin
        SaleLinePOSObject.TotalDiscountPercent(Discount, KeepPrev);
    end;

    local procedure Complete_PushLineDiscountAmount(Amount: Decimal)
    var
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Code10: Code[10];
    begin
        Code10 := RetailSalesLineCode.AskReasonCode;
        SaleLinePOSObject.ChangeDiscountAmountOnActLine(Amount);
        SaleLinePOSObject.SetDiscountCode(Code10);
        //-NPR5.23
        SaleLinePOSObject.UpdateCustomerDisplay();
        //+NPR5.23
    end;

    local procedure Complete_PushLineUnitPrice(Price: Decimal)
    var
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Code10: Code[10];
    begin
        Code10 := RetailSalesLineCode.AskReasonCode;
        SaleLinePOSObject.ChangeUnitPriceOnActiveLine(Price);
        SaleLinePOSObject.SetDiscountCode(Code10);
        //-NPR5.23
        SaleLinePOSObject.UpdateCustomerDisplay();
        //+NPR5.23
    end;

    local procedure Complete_PushRegisterChange(RegNo: Text)
    var
        Code10: Code[10];
        CopyValidering: Text;
        t018: Label 'Invalid register number %1.';
    begin
        Code10 := CopyStr(RegNo, 1, 10);
        if not Register.Get(Code10) then begin
            Validering := CopyValidering;
            Marshaller.Error_Protocol(Text10600200, StrSubstNo(t018, Code10), true);
        end;
        Register.setThisRegisterNo(Code10);
        QueryCloseRefresh();
        State.Marshaller.ChangeScreen(ViewType.RegisterChange);
    end;

    local procedure Complete_PushSaleReverse(SalesTicketNo: Code[20])
    var
        RetailSalesCode: Codeunit "Retail Sales Code";
        ReturnReason: Record "Return Reason";
        t033: Label 'You must choose a return reason.';
        SaleLinePOS: Record "Sale Line POS";
    begin
        if SalesTicketNo = '' then
            Marshaller.Error_Protocol(Text10600200, t016, true);
        RetailSalesCode.ReverseSalesTicket2(This, SalesTicketNo);

        //-NPR5.20
        Commit;

        //-244948 [244948]
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.", This."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", This."Sales Ticket No.");
        SaleLinePOS.FindFirst;
        SaleLinePOSObject.SetLine(SaleLinePOS);
        SaleLinePOSObject.CalculateBalance();
        SetSaleScreenVisible();
        //+244948 [244948]

        if RetailSetup."Reason for Return Mandatory" then begin
            if PAGE.RunModal(PAGE::"Touch Screen - Return Reasons", ReturnReason) = ACTION::LookupOK then begin
                SaleLinePOS.SetRange("Register No.", This."Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", This."Sales Ticket No.");
                SaleLinePOS.ModifyAll("Return Reason Code", ReturnReason.Code);
                SaleLinePOS.ModifyAll("Return Sale Sales Ticket No.", SalesTicketNo);
            end else
                Error(t033);
        end;
        //+NPR5.20
    end;

    local procedure Complete_PushSaleAnnull(SalesTicketNo: Code[20])
    var
        t001: Label 'Receipt No.';
        t002: Label 'not found!';
        t022: Label 'No sales lines!';
        t031: Label 'You are about to return sales ticket number %1.\Are you sure you want to continue?';
        SalesLine: Record "Sale Line POS";
        RetailSalesCode: Codeunit "Retail Sales Code";
        RetailFormCode: Codeunit "Retail Form Code";
        TouchScreenSavedSales: Page "Touch Screen - Saved sales";
        returnvalue: Boolean;
    begin
        with This do begin
            if SalesTicketNo = '' then
                Marshaller.Error_Protocol(Text10600200, t016, true);
            if not Confirm(StrSubstNo(t031, SalesTicketNo), false) then
                Error('');
            "Retursalg Bonnummer" := SalesTicketNo;
            Modify;
            Commit;
            returnvalue := RetailSalesCode.ReverseSalesTicket(This);
            if not returnvalue then begin
                "Retursalg Bonnummer" := '';
                Modify;
                Commit;
                SalesTicketNo := '';
                Marshaller.Error_Protocol(Text10600200, t001 + ' ' + SalesTicketNo + ' ' + t002, true);
            end;
            Commit;
            TouchScreenSavedSales.hide(true);
            TouchScreenSavedSales.DisableFetchButton();
            TouchScreenSavedSales.LookupMode(true);
            TouchScreenSavedSales.SetRecord(This);
            TouchScreenSavedSales.SetTableView(This);
            if TouchScreenSavedSales.RunModal <> ACTION::LookupOK then begin
                SaleLinePOSObject.DeleteAllLines;
                exit;
            end;
            if not RetailSetup."Editable eksp. reverse sale" then begin
                SaleLinePOSObject.GETRECORD(SalesLine);
                if SalesLine.IsEmpty then
                    Marshaller.Error_Protocol(Text10600200, t022, true);
                if RetailFormCode.ReturnSale(This, returnvalue) then begin
                    DebitSale();
                end else begin
                    GotoPayment();
                    EnterHit('AFSLUTBETALING');
                end;
                exit;
            end;
        end;
    end;

    local procedure Complete_PushRegisterOpen(Password: Code[20])
    var
        RetailFormCode: Codeunit "Retail Form Code";
        t029: Label 'You have typed a wrong register open code.';
    begin
        if Password <> RetailSetup."Open Register Password" then begin
            Validering := CopyValidering;
            Marshaller.Error_Protocol(Text10600200, t029, true);
        end;

        Validering := CopyValidering;
        RetailFormCode.OpenRegister();
        This."Drawer Opened" := true;
        This.Modify;
    end;

    local procedure CompleteResponse(FuncStr: Code[50])
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOSObject.GETRECORD(SaleLinePOS);

        HandleMetaTrigger(FuncStr, 1, This, SaleLinePOS);

        Marshaller.RequestRefreshSalesLineData();
        Validering := '';

        Clear(MenuLines1);
        This.Find;
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDebitSale(SalePOS: Record "Sale POS")
    begin
        //-NPR5.30 [267291]
        //+NPR5.30 [267291]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGotoPayment(SalePOS: Record "Sale POS")
    begin
        //-NPR5.30 [267291]
        //+NPR5.30 [267291]
    end;

    local procedure PushTotalDiscountPctVar()
    var
        Context: DotNet npNetProtocolContext;
        PresetDiscount: Decimal;
        MenuLines1: Record "Touch Screen - Menu Lines";
        MarshalStatus: DotNet npNetMarshalStatus;
    begin
        //-NPR5.32 [274462]
        SaleLinePOSObject.CalculateBalance;
        Evaluate(PresetDiscount, This.Parameters);
        Complete_PushTotalDiscountPctVar(PresetDiscount, false);
        //+NPR5.32
    end;

    local procedure PushLineDiscountPctVar()
    var
        Context: DotNet npNetProtocolContext;
        PresetDiscount: Decimal;
        MenuLines1: Record "Touch Screen - Menu Lines";
        MarshalStatus: DotNet npNetMarshalStatus;
    begin
        //-NPR5.32 [274462]
        Evaluate(PresetDiscount, This.Parameters);
        Complete_PushLineDiscountPctVar(PresetDiscount, false);
        //+NPR5.32
    end;

    local procedure Complete_PushTotalDiscountPctVar(Discount: Decimal; KeepPrev: Boolean)
    begin
        //-NPR5.32 [274462]
        SaleLinePOSObject.TotalDiscountPercent(Discount, KeepPrev);
        Marshaller.RequestRefreshSalesLineData();
        //+NPR5.32
    end;

    local procedure Complete_PushLineDiscountPctVar(Discount: Decimal; KeepPrev: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Code10: Code[10];
    begin
        //-NPR5.32 [274462]
        SaleLinePOSObject.GETRECORD(SaleLinePOS);
        TouchScreenFunctions.CheckLine(SaleLinePOS);
        SaleLinePOSObject.ChangeDiscountOnActiveLine(Discount, KeepPrev);
        Marshaller.RequestRefreshSalesLineData();
        //+NPR5.32
    end;
}

