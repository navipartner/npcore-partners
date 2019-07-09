page 6014651 "Touch Screen - Sale (Web)"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.12/VB/20150703 CASE 213003 Support for custom logo and fix for javascript-based dialogs
    // NPR4.13/VB/20150730 CASE 213003 Refactored to support new view type and to reuse code in other objects
    // NPR4.14/VB/20150904 CASE 213003 Merged changes
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150909 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20151001 CASE 224232 Number formatting
    // NPR4.14/VB/20151001 CASE 224312 Caching per session
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.17/VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/VB/20160106 CASE 231160 Updating last line information when switching between payment and sale views
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.22/VB/20160401 CASE 237541 Setting last sale data
    // NPR5.22/VB/20160407 CASE 237866 Specifying the line order on screen
    // NPR5.22/VB/20160414 CASE 237026 Allowing direct Stargate method invokation
    // NPR5.22/VB/20160421 CASE 239536 Adding event stubs that were missing (and could have caused runtime issues)
    // NPR5.23/VB/20160525 CASE 242588 Control add-in reference sharing and calling control add-in directly (without .NET Marshaller)
    // NPR5.25/MMV /20160804 CASE 245816 Only change sales line state if the incoming line fits the viewtype.
    // NPR5.27/BHR/20161021 CASE 255864 Add Contact details to the datagrid
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.38/MHA /20180108  CASE 298399 Added Publisher OnOpenPOSStandard()
    // NPR5.40/MHA /20180328  CASE 308907 Replaced Potentially critical OnOpenPOSStandard() in OnOpenPage() with OnInitializePageCompleted() in EventOnFrameworkReady()
    // NPR5.49/TJ  /20190201  CASE 335739 Using POS View Profile instead of Register

    Caption = 'Touch Screen - Sale';
    PageType = List;

    layout
    {
        area(content)
        {
            usercontrol(NPHost;"NaviPartner.Retail.Controls.IFramework")
            {

                trigger OnFrameworkReady()
                var
                    ObjectTrue: Variant;
                begin
                    EventOnFrameworkReady;
                    ObjectTrue := true;

                    case CurrentClientType of
                      CLIENTTYPE::Web:
                        SetFrontEndProperty('n$.UI.IsFullScreen',ObjectTrue);
                    end;
                end;

                trigger OnScreenSize(screen: DotNet npNetScreen)
                begin
                    EventOnScreenSize(screen);
                end;

                trigger OnMessage(eventArgs: DotNet npNetMessageEventArgs)
                begin
                    EventOnMessage(eventArgs);
                end;

                trigger OnResponse(response: DotNet npNetResponseInfo)
                begin
                    EventOnResponse(response);
                end;

                trigger OnJavaScriptCallback(js: DotNet npNetJavaScript)
                begin
                end;

                trigger OnDialogResponse(response: DotNet npNetResponse)
                begin
                end;

                trigger OnDataUpdated(dataSource: DotNet npNetDataSource)
                begin
                end;

                trigger OnInvokeMethodResponse(envelope: Text)
                var
                    ResponseEnvelope: DotNet npNetResponseEnvelope;
                begin
                    //-NPR5.22
                    OnInvokeDeviceMethodResponse(ResponseEnvelope.FromString(envelope));
                    //+NPR5.22
                end;

                trigger OnServiceCallError(message: Text)
                begin
                end;

                trigger OnObjectModel(id: Text;eventName: Text;jsonData: Text)
                begin
                end;

                trigger OnProtocol(eventName: Text;serializedData: Text;doCallback: Boolean)
                begin
                end;
            }
            usercontrol(Tweak;"NaviPartner.Retail.Controls.WindowsClientHelper")
            {

                trigger ControlReady()
                begin
                    CurrPage.Tweak.TweakMainScreen();
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        StateMgt.Finalize();
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.40 [308907]
        ////-NPR5.38 [298399]
        //OnOpenPOSStandard();
        ////+NPR5.38 [298399]
        //+NPR5.40 [308907]
        SessionMgt.StartPOSSession();
        //-NPR5.28
        //SessionMgt.MakeSureControlAddInTypeIsWeb();
        //+NPR5.28
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Initialized then
          exit(true);

        if not StateMgt.OnQueryCloseForm then begin
          SendState();
          exit(false);
        end;
        exit(true);
    end;

    var
        SavedSale: Record "Sale POS";
        StateMgt: Codeunit "Touch - Sale POS (Web)";
        POSMarshaller: Codeunit "POS Event Marshaller";
        Util: Codeunit "POS Web Utilities";
        UI: Codeunit "POS Web UI Management";
        SessionMgt: Codeunit "POS Web Session Management";
        [WithEvents]
        State: DotNet npNetState0;
        [WithEvents]
        Marshaller: DotNet npNetMarshaller;
        ViewType: DotNet npNetViewType;
        Factory: DotNet npNetMarshalEventArgsFactory;
        LastLinePosition: Text;
        DoLoadSavedSale: Boolean;
        CloseAllowed: Boolean;
        Text001: Label 'Attempted initialization of an incorrect view type.\\This is a bug, not a user error.\\Expected: %1, %2\Actual: %3,%4';
        Text002: Label 'To run this page on the Windows client, change the configuration for your register to show the Web version of the page.';
        Initialized: Boolean;

    local procedure ProcessQueryClose()
    var
        Args: DotNet npNetArray;
    begin
        case StateMgt.GetQueryClose of
          1:
            begin
              CloseAllowed := true;
              CurrPage.Close;
            end;
          2:
            begin
              Args := Args.CreateInstance(GetDotNetType(''),0);
              CurrPage.NPHost.SendRequest(Factory.InvokeJavaScriptFunction('n$.Framework.Refresh()',Args).ToRequestInfo());
            end;
        end;
    end;

    procedure SendState()
    begin
        if (not State.View.Initialized) then
          exit;

        Commit;

        case State.ViewType of
          ViewType.Login:
            if (not IsNull(State.View)) then begin
              //-NPR5.22
              //StateMgt.GetLastSaleInfo(LastSaleDateText,Total,Payed,ReturnAmount,LastReceiptNo);
              //StateMgt.SetStateData('LastSalePayment',UI.FormatDecimal(Payed));
              //StateMgt.SetStateData('LastSaleReturnAmount',UI.FormatDecimal(ReturnAmount));
              //StateMgt.SetStateData('LastSaleText',LastSaleDateText);
              //StateMgt.SetStateData('LastReceiptNo',LastReceiptNo);
              //StateMgt.SetStateData('LastSaleTotal',UI.FormatDecimal(Total));
              PrepareLastSaleState();
              //+NPR5.22
            end;
          ViewType.Sale:
            if (not IsNull(State.View)) then begin
              if (not IsNull(State.View.ToSaleView().DataGrid)) then
                StateMgt.GetSalesLines(State.View.ToSaleView().DataGrid);
              //-NPR5.22
              PrepareLastSaleState();
              //+NPR5.22
              //-NPR5.27 [255864]
              StateMgt.SetStateData('CustomerName',StateMgt.GetContactName);
              if StateMgt.GetContactName = '' then
              //-NPR5.27 [255864]
              StateMgt.SetStateData('CustomerName',StateMgt.GetCustomerName);
              SetFrontEndProperty('n$.State.Context.View.dataGrid.subtotal',UI.FormatDecimal(StateMgt.GetSalesTotal()));
            end;
          ViewType.Payment:
            if (not IsNull(State.View)) then begin
              if (not IsNull(State.View.ToPaymentView().DataGrid)) then
                StateMgt.GetPaymentLines(State.View.ToPaymentView().DataGrid);
              //-NPR5.27 [255864]
              StateMgt.SetStateData('Customer',StateMgt.GetContactName);
              if StateMgt.GetContactName = '' then
              //-NPR5.27 [255864]
              StateMgt.SetStateData('CustomerName',StateMgt.GetCustomerName);
              SetFrontEndProperty('n$.State.Context.View.dataGrid.subtotal',UI.FormatDecimal(StateMgt.GetPaymentTotal()));
            end;
        end;
        StateMgt.UpdateStateData();
    end;

    procedure MenuButtonPressed(ButtonCode: Code[20])
    begin
        if not State.View.Initialized then
          exit;

        case State.ViewType of
          ViewType.Login:
            begin
              case ButtonCode of
                'MAIN_MENU' : CurrPage.Close;
                'FUNCTIONS' : StateMgt.ExecFunction('FUNCTIONS_SALE');
              end;
            end;
          ViewType.Sale: ;
          ViewType.Payment: ;
        end;
    end;

    procedure LoadSavedSale(var Rec: Record "Sale POS")
    begin
        StateMgt.LoadSavedSale(Rec);
    end;

    procedure SetSavedSale(var SavedSaleIn: Record "Sale POS")
    begin
        SavedSale := SavedSaleIn;
        DoLoadSavedSale := true;
    end;

    local procedure InitializePage()
    var
        Register: Record Register;
        Captions: DotNet npNetDictionary_Of_T_U;
        String: DotNet npNetString;
        POSViewProfile: Record "POS View Profile";
    begin
        Clear(StateMgt);
        
        Marshaller := Marshaller.Marshaller;
        State := State.State(Marshaller);
        
        POSMarshaller.Initialize(Marshaller);
        //-NPR5.23 [242588]
        POSMarshaller.SetPOSReference(CurrPage.NPHost);
        //+NPR5.23 [242588]
        
        UI.ConfigureCaptions(Marshaller);
        UI.ConfigureCustomLogo(Marshaller);
        UI.ConfigureFonts(Marshaller);
        
        String := StrSubstNo('%1|%2|%3',PAGE::"Touch Screen - Sale (Web)",PAGE::"Touch Screen - Dialog (Web)",PAGE::"Touch Screen - Balancing (Web)");
        SetFrontEndProperty('n$.Window.CaptureDialogIDs',String);
        //-NPR5.49 [335739]
        /*
        //-NPR5.22
        SetFrontEndProperty('n$.Controls.Grid.options.ReverseOrder',SessionMgt.LineOrderOnScreen = Register."Line Order on Screen"::"1");
        //+NPR5.22
        */
        SetFrontEndProperty('n$.Controls.Grid.options.ReverseOrder',SessionMgt.LineOrderOnScreen = POSViewProfile."Line Order on Screen"::Reverse);
        //+NPR5.49 [335739]
        
        if CurrentClientType = CLIENTTYPE::Windows then begin
          CurrPage.NPHost.SendRequest(Factory.UpdateCss('@media only screen and (min-width : 320px) and (max-width : 768px){body,input,textarea,keygen,select,button{font-size:16px !important;}}').ToRequestInfo());
        end;
        
        StateMgt.Initialize(State);
        
        if DoLoadSavedSale then begin
          StateMgt.LoadSavedSale(SavedSale);
          StateMgt.SetSaleScreenVisible();
          DoLoadSavedSale := false;
        end;
        
        StateMgt.EnterPush;
        
        Initialized := true;

    end;

    local procedure MakeSureViewIsOfCorrectType(ExpectedViewType: DotNet npNetViewType;ExpectedType: DotNet npNetType;View: DotNet npNetView)
    begin
        if not View.IsType(ExpectedViewType,ExpectedType) then
          Error(Text001,ExpectedViewType,ExpectedType,View.Type,View.GetType());
    end;

    local procedure InitializeLoginView(View: DotNet npNetLoginView)
    begin
        MakeSureViewIsOfCorrectType(ViewType.Login,GetDotNetType(View),View);

        View.Initialize();
        UI.ConfigureView(View);
    end;

    local procedure InitializeSaleView(View: DotNet npNetSaleView)
    begin
        MakeSureViewIsOfCorrectType(ViewType.Sale,GetDotNetType(View),View);

        View.Initialize();
        UI.ConfigureView(View);

        StateMgt.ShowLastSaleInformation();
    end;

    local procedure InitializePaymentView(View: DotNet npNetPaymentView)
    begin
        MakeSureViewIsOfCorrectType(ViewType.Payment,GetDotNetType(View),View);

        View.Initialize();
        UI.ConfigureView(View);

        StateMgt.ShowPaymentInformation();
    end;

    local procedure InitializeLockedView(View: DotNet npNetLoginView)
    begin
        MakeSureViewIsOfCorrectType(ViewType.Locked,GetDotNetType(View),View);

        View.Initialize();
        UI.ConfigureView(View);
    end;

    local procedure EventOnFrameworkReady()
    begin
        InitializePage();
        //-NPR5.40 [308907]
        OnInitializePageCompleted()
        //+NPR5.40 [308907]
    end;

    local procedure EventOnMessage(EventArgs: DotNet npNetMessageEventArgs)
    var
        EventType: DotNet npNetEventType;
        MessageType: Integer;
        EanCode: Text[30];
        DoSendState: Boolean;
    begin
        if not State.View.Initialized then
          exit;

        MessageType := EventArgs.Type;
        case MessageType of
          EventType.CancelRequest:
            begin
              EventOnMessageCancelRequest(EventArgs.ToCancelRequest());
              DoSendState := false;
            end;
          EventType.CancelAllProtocolRequests:
            begin
              EventOnMessageCancelAllProtocolRequests();
              DoSendState := true;
            end;

          EventType.Refresh: ;
          EventType.ButtonClicked:
            begin
              EventOnMessageButtonPressed(EventArgs.ToButton(),EventArgs.Context);
              DoSendState := true;
            end;
          EventType.FunctionsButtonClicked:
            begin
              EventOnMessageFunctionsButtonPressed(EventArgs.ToButton(),EventArgs.Context);
              DoSendState := false;
            end;
          EventType.KeyDown:
            begin
              EventOnMessageKeyDown(EventArgs.ToKeyPress());
              DoSendState := true;
            end;
          EventType.EanCodeScanned:
            begin
              EventOnMessageEanCodeScanned(EventArgs.ToEanCodeScanned());
              DoSendState := true;
            end;
          EventType.SelectionChanged:
            begin
              EventOnMessageSelectionChanged(EventArgs.ToSelectionChanged());
              DoSendState := false;
            end;
          EventType.Login:
            begin
              EventOnMessageLogin(EventArgs.ToLogin());
              DoSendState := false;
            end;
        end;
        if DoSendState then
          SendState();

        ProcessQueryClose();
    end;

    local procedure EventOnMessageCancelRequest(Cancel: DotNet npNetCancelRequestMessageData)
    begin
        if not State.View.Initialized then
          exit;
        POSMarshaller.CancelRequest(Cancel.RequestType,Cancel.Id,Cancel.RequestKnownEventId);
    end;

    local procedure EventOnMessageCancelAllProtocolRequests()
    begin
        if not State.View.Initialized then
          exit;
        POSMarshaller.CancelAllProtocolRequests();
    end;

    local procedure EventOnMessageButtonPressed(Button: DotNet npNetButton;Context: DotNet npNetContext)
    begin
        if not State.View.Initialized then
          exit;

        StateMgt.SetValidation(Context.EanBoxText);
        if Button.MenuLineNo <> 0 then begin
          StateMgt.PressedFunction(Button.MenuLineNo);
          if StateMgt.GetUpdatePosition() then
            LastLinePosition := StateMgt.GetLinePosition();
        end else
          MenuButtonPressed(Button.Value);

        ProcessQueryClose();
    end;

    local procedure EventOnMessageFunctionsButtonPressed(Button: DotNet npNetButton;Context: DotNet npNetContext)
    var
        ButtonType: DotNet npNetButtonType;
    begin
        if not State.View.Initialized then
          exit;

        StateMgt.PressedPopupFunction(Button.MenuLineNo,Button.Type.Equals(ButtonType.Back));

        ProcessQueryClose();
    end;

    local procedure EventOnMessageEanCodeScanned(EanCodeScanned: DotNet npNetEanCodeScannedMessageData)
    begin
        if not State.View.Initialized then
          exit;

        StateMgt.SetValidation(EanCodeScanned.Ean);
        StateMgt.EnterPush;
    end;

    local procedure EventOnMessageKeyDown("Key": DotNet npNetKeyPressMessageData)
    var
        KeyCode: DotNet npNetKeyCode;
    begin
        if not State.View.Initialized then
          exit;

        case State.ViewType of
          ViewType.Login:
            begin
            end;
          ViewType.Sale:
            case Key.KeyCode of
              KeyCode.F6:   StateMgt.Lookup;
              KeyCode.F11:  StateMgt.ExecFunction('GOTO_PAYMENT');
              KeyCode.Esc:  StateMgt.ExecFunction('CANCEL_SALE');
            end;
          ViewType.Payment:
            case Key.KeyCode of
              KeyCode.F11:  StateMgt.ButtonDefault();
              KeyCode.Esc:  StateMgt.ExecFunction('GOTO_SALE');
            end;
        end;
    end;

    local procedure EventOnMessageLogin(Login: DotNet npNetLoginMessageData)
    begin
        if not State.View.Initialized then
          exit;

        StateMgt.SetValidation(Login.SalespersonCode);
        StateMgt.EnterHit('LOGIN');
    end;

    local procedure EventOnMessageSelectionChanged(Row: DotNet npNetDictionary_Of_T_U)
    var
        Type: Option Sale,Payment;
    begin
        if not State.View.Initialized then
          exit;

        case State.ViewType of
          ViewType.Sale:    SaleLineSelectionChange(Row,Type::Sale);
          ViewType.Payment: SaleLineSelectionChange(Row,Type::Payment);
        end;
    end;

    local procedure EventOnResponse(Response: DotNet npNetResponseInfo)
    begin
        POSMarshaller.ProcessResponse(Response,StateMgt);
    end;

    local procedure EventOnScreenSize(Screen: DotNet npNetScreen)
    begin
        SessionMgt.SetScreenMetrics(Screen.ScreenWidth,Screen.ScreenHeight,Screen.ViewportWidth,Screen.ViewportHeight);
    end;

    local procedure EventOnScreenChange(EventArgs: DotNet npNetChangeScreenEventArgs)
    begin
        State.ViewType := EventArgs.ViewType;
        if EventArgs.ViewType.Equals(ViewType.RegisterChange) then
          ProcessQueryClose();
    end;

    local procedure EventMarshal(EventArgs: DotNet npNetMarshalEventArgs)
    var
        KnownEvent: DotNet npNetKnownEvent;
    begin
        case EventArgs.EventType of
          KnownEvent.ChangeScreen: EventOnScreenChange(EventArgs.ToChangeScreenEventArgs());
          KnownEvent.RequestRefreshSalesLineData: SendState();

          // Start listing standard request events here
          KnownEvent.ClearInfoBoxContent,
          KnownEvent.ConfigureFont,
          KnownEvent.InvokeJavaScriptFunction,
          KnownEvent.DimScreen,
          KnownEvent.Error,
          KnownEvent.NumPad,
          KnownEvent.SetObjectProperty,
          KnownEvent.Functions,
          KnownEvent.CloseFunctions,
          KnownEvent.UpdateInfoBox,
          KnownEvent.UpdateState,
          KnownEvent.SetSalesLineData:
            begin
              CurrPage.NPHost.SendRequest(EventArgs.ToRequestInfo());
            end;
          else
            Error('Unsupported marshalled event. This is a programming bug, not a user error. Event details:\\%1',EventArgs.ToJson());
        end;
    end;

    local procedure SaleLineSelectionChange(Row: DotNet npNetDictionary_Of_T_U;Type: Option Sale,Payment)
    var
        SaleLine: Record "Sale Line POS";
        RecRef: RecordRef;
        Position: Text;
    begin
        RecRef.GetTable(SaleLine);
        Util.RowToNavRecord(Row,RecRef);
        RecRef.SetTable(SaleLine);
        if SaleLine.Find then begin
          Position := SaleLine.GetPosition();
          if Position <> LastLinePosition then begin
            case Type of
              //-NPR5.25 [245816]
        //      Type::Sale:    StateMgt.SetSalesLinePosition(SaleLine.GETPOSITION);
        //      Type::Payment: StateMgt.SetPaymentLinePosition(SaleLine.GETPOSITION);
              Type::Sale:
                begin
                  if SaleLine."Sale Type" = SaleLine."Sale Type"::Payment then
                    exit;
                  StateMgt.SetSalesLinePosition(SaleLine.GetPosition);
                end;
              Type::Payment:
                begin
                  if SaleLine."Sale Type" <> SaleLine."Sale Type"::Payment then
                    exit;
                  StateMgt.SetPaymentLinePosition(SaleLine.GetPosition);
                end;
              //+NPR5.25 [245816]
            end;
            //-231160
            //StateMgt.OnAfterAfterGetCurrentRecord;
            //+231160
          end;
          //-231160
          StateMgt.OnAfterAfterGetCurrentRecord;
          //+231160

          LastLinePosition := Position;
        end;
    end;

    local procedure SetFrontEndProperty(Property: Text;Value: Variant)
    begin
        CurrPage.NPHost.SendRequest(Factory.SetObjectProperty(Property,Value).ToRequestInfo());
    end;

    local procedure PrepareLastSaleState()
    var
        LastReceiptNo: Text[50];
        LastSaleDateText: Text[50];
        Total: Decimal;
        Payed: Decimal;
        ReturnAmount: Decimal;
    begin
        //-NPR5.22
        StateMgt.GetLastSaleInfo(LastSaleDateText,Total,Payed,ReturnAmount,LastReceiptNo);
        StateMgt.SetStateData('LastSalePayment',UI.FormatDecimal(Payed));
        StateMgt.SetStateData('LastSaleReturnAmount',UI.FormatDecimal(ReturnAmount));
        StateMgt.SetStateData('LastSaleText',LastSaleDateText);
        StateMgt.SetStateData('LastReceiptNo',LastReceiptNo);
        StateMgt.SetStateData('LastSaleTotal',UI.FormatDecimal(Total));
        //+NPR5.22
    end;

    local procedure InvokeMethodResponse(Envelope: Text)
    var
        ResponseEnvelope: DotNet npNetResponseEnvelope;
    begin
        //-NPR5.22
        OnInvokeDeviceMethodResponse(ResponseEnvelope.FromString(Envelope,GetDotNetType(ResponseEnvelope)));
        //+NPR5.22
    end;

    [BusinessEvent(false)]
    local procedure OnInvokeDeviceMethodResponse(ResponseEnvelope: DotNet npNetResponseEnvelope)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializePageCompleted()
    begin
        //-NPR5.40 [308907]
        //+NPR5.40 [308907]
    end;

    trigger State::OnInitializeView(type: Integer;view: DotNet npNetView)
    begin
        case type of
          ViewType.Login:   InitializeLoginView(view);
          ViewType.Sale:    InitializeSaleView(view);
          ViewType.Payment: InitializePaymentView(view);
          ViewType.Locked:  InitializeLockedView(view);
        end;
    end;

    trigger State::OnChangeView(newType: Integer;newView: DotNet npNetView)
    begin
        if newView.Initialized then begin
          CurrPage.NPHost.ClearView();
          CurrPage.NPHost.SetView(newView);

          case newType of
            ViewType.Sale:    StateMgt.ShowLastSaleInformation();
            ViewType.Payment: StateMgt.ShowPaymentInformation();
          end;
        end;
        SendState();
    end;

    trigger Marshaller::Marshal(eventArgs: DotNet npNetMarshalEventArgs)
    begin
        EventMarshal(eventArgs);
    end;
}

