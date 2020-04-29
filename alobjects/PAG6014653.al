page 6014653 "Touch Screen - Balancing (Web)"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.13/VB/20150730 CASE 213003 Refactored code to support setting properties through marshaller
    // NPR4.14/VB/20150904 CASE 213003 Merged changes
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20151001 CASE 224232 Number formatting
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 225607 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.23/VB/20160612 CASE 243500 Fix for the issue with improperly interperting numbers passed from JavaScript if they included decimal separators in locales other than en-US
    // NPR5.31/VB/20170324 CASE 270035 Fixing issue with subtotal missing from register balancing page

    Caption = 'Touch Screen - Sale Balance Register';
    PageType = List;

    layout
    {
        area(content)
        {
            usercontrol(NPHost;"NaviPartner.Retail.Controls.IFramework")
            {

                trigger OnFrameworkReady()
                begin
                    EventFrameworkReady();
                end;

                trigger OnScreenSize(screen: DotNet npNetScreen)
                begin
                end;

                trigger OnMessage(eventArgs: DotNet npNetMessageEventArgs)
                begin
                    EventOnMessage(eventArgs);
                end;

                trigger OnResponse(response: DotNet npNetResponseInfo)
                begin
                end;

                trigger OnJavaScriptCallback(js: DotNet npNetJavaScript)
                begin
                end;

                trigger OnDialogResponse(response: DotNet npNetResponse)
                begin
                    EventOnDialogResponse();
                end;

                trigger OnDataUpdated(dataSource: DotNet npNetDataSource)
                begin
                    EventOnDataUpdated(dataSource);
                end;
            }
            usercontrol(NPTweak;"NaviPartner.Retail.Controls.WindowsClientHelper")
            {

                trigger ControlReady()
                begin
                    EventTweakReady();
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Dlg := Dlg.RegisterBalancing();
        Dlg.Width := 960; //ROUND(SessionMgt.ViewportWidth * 0.8,1);
        Dlg.Height := 700; //ROUND(SessionMgt.ViewportHeight * 0.7,1);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        exit(BalancingMgt.OnQueryClose());
    end;

    var
        BalancingMgt: Codeunit "Touch Screen - Balancing Mgt.";
        SessionMgt: Codeunit "POS Web Session Management";
        UI: Codeunit "POS Web UI Management";
        Util: Codeunit "POS Web Utilities";
        [WithEvents]
        Marshaller: DotNet npNetMarshaller;
        RequestFactory: DotNet npNetRequestFactory;
        Dlg: DotNet npNetRegisterBalancing;
        LastLinePosition: Text;

    procedure Initialize(RegNo: Code[20];"Sales Person": Code[10])
    begin
        BalancingMgt.Initialize();
        BalancingMgt.initForm(RegNo,"Sales Person");

        BalancingMgt.DoTheBalancing();
        BalancingMgt.OnAfterGetCurrRecord();
    end;

    procedure getClosingType(): Integer
    begin
        exit(BalancingMgt.getClosingType());
    end;

    procedure saveBalancedRegister(var Sale: Record "Sale POS";AfslutDato: Date;AfslutTid: Time;Afsluttet: Boolean)
    begin
        BalancingMgt.saveBalancedRegister(Sale,AfslutDato,AfslutTid,Afsluttet);
    end;

    local procedure UpdateFigures(RefreshRows: Boolean)
    var
        PeriodFigures: DotNet npNetDictionary_Of_T_U;
        BalancingFigures: DotNet npNetDictionary_Of_T_U;
        CountingLines: DotNet npNetDataGrid;
        DataSource: DotNet npNetDictionary_Of_T_U;
        Subtotal: Text;
    begin
        //-NPR5.31
        //BalancingMgt.UpdateFigures(PeriodFigures,BalancingFigures,CountingLines);
        BalancingMgt.UpdateFigures(PeriodFigures,BalancingFigures,CountingLines,Subtotal);
        //+NPR5.31
        CurrPage.NPHost.SendRequest(RequestFactory.SetObjectProperty('n$.State.RegisterBalancing.period',PeriodFigures));
        CurrPage.NPHost.SendRequest(RequestFactory.SetObjectProperty('n$.State.RegisterBalancing.balancing',BalancingFigures));
        //-NPR5.31
        //IF RefreshRows THEN
        //  CurrPage.NPHost.SendRequest(RequestFactory.SetObjectProperty('n$.State.RegisterBalancing.grid',CountingLines));
        if RefreshRows then begin
          CurrPage.NPHost.SendRequest(RequestFactory.SetObjectProperty('n$.State.RegisterBalancing.grid',CountingLines));
          CurrPage.NPHost.SendRequest(RequestFactory.SetObjectProperty('n$.State.RegisterBalancing.subtotal',Subtotal));
        end;
        //+NPR5.31
    end;

    local procedure LineSelectionChange(Row: DotNet npNetDictionary_Of_T_U;Type: Option Sale,Payment)
    begin
    end;

    local procedure EventOnMessage(EventArgs: DotNet npNetMessageEventArgs)
    var
        EventType: DotNet npNetEventType;
        MessageType: Integer;
        EanCode: Text[30];
        DoSendState: Boolean;
    begin
        MessageType := EventArgs.Type;
        case MessageType of
          EventType.ButtonClicked:
            begin
              EventOnMessageButtonPressed(EventArgs.ToButton());
            end;
          EventType.SelectionChanged:
            begin
              EventOnMessageSelectionChanged(EventArgs.ToSelectionChanged());
            end;
        end;
    end;

    local procedure EventOnMessageButtonPressed(Button: DotNet npNetButton)
    begin
        if BalancingMgt.ButtonClickedHandler(Button.Value) then
          CurrPage.Close()
        else
          UpdateFigures(true);
    end;

    local procedure EventOnMessageSelectionChanged(Row: DotNet npNetDictionary_Of_T_U)
    var
        Line: Record "Payment Type POS";
        RecRef: RecordRef;
        Position: Text;
    begin
        RecRef.GetTable(Line);
        Util.RowToNavRecord(Row,RecRef);
        RecRef.SetTable(Line);
        Line.Find;
        Position := Line.GetPosition();
        if Position <> LastLinePosition then begin
          LastLinePosition := Position;
          BalancingMgt.SetPosition(Position);
          UpdateFigures(false);
        end;
    end;

    local procedure EventOnDialogResponse()
    begin
        CurrPage.Close();
    end;

    local procedure EventOnDataUpdated(DataSource: DotNet npNetDataSource)
    var
        UltimoLCY: Decimal;
        BankLCY: Decimal;
        MoneyBagNo: Text;
        Comment: Text;
        UltimoLCYText: Text;
        BankLCYText: Text;
        UltimoLCYSet: Boolean;
        BankLCYSet: Boolean;
    begin
        //-NPR5.31
        // //-NPR5.23 [243500]
        // //UltimoLCY := DataSource.GetValue('UltimoLCY',GETDOTNETTYPE(0.01));
        // //BankLCY := DataSource.GetValue('BankLCY',GETDOTNETTYPE(0.01));
        // UltimoLCY := UI.ParseDecimal(DataSource.GetValue('UltimoLCY',GETDOTNETTYPE('')));
        // BankLCY := UI.ParseDecimal(DataSource.GetValue('BankLCY',GETDOTNETTYPE('')));
        // //+NPR5.23 [243500]
        UltimoLCYText := DataSource.GetValue('UltimoLCY',GetDotNetType(''));
        BankLCYText := DataSource.GetValue('BankLCY',GetDotNetType(''));
        if UltimoLCYText <> '' then begin
          UltimoLCY := UI.ParseDecimal(UltimoLCYText);
          UltimoLCYSet := UltimoLCY <> BalancingMgt.GetUltimoLCY();
        end;
        if BankLCYText <> '' then begin
          BankLCY := UI.ParseDecimal(BankLCYText);
          BankLCYSet := BankLCY <> BalancingMgt.GetBankLCY();
        end;
        //+NPR5.31
        MoneyBagNo := DataSource.GetValue('MoneyBagNo',GetDotNetType(''));
        Comment := DataSource.GetValue('Comment',GetDotNetType(''));

        //-NPR5.31
        //IF UltimoLCY <> BalancingMgt.GetUltimoLCY() THEN
        if UltimoLCYSet then
        //+NPR5.31
          BalancingMgt.pushUltimo(UltimoLCY);
        //-NPR5.31
        //IF BankLCY <> BalancingMgt.GetBankLCY() THEN
        if BankLCYSet then
        //+NPR5.31
          BalancingMgt.pushBank(BankLCY);
        if MoneyBagNo <> BalancingMgt.GetMoneyBagNo() then
          BalancingMgt.SetMoneyBagNo(MoneyBagNo);
        if Comment <> BalancingMgt.GetComment() then
          BalancingMgt.SetComment(Comment);

        UpdateFigures(false);
    end;

    local procedure EventTweakReady()
    begin
        CurrPage.NPTweak.SetPageSize(Dlg.Width,Dlg.Height);
    end;

    local procedure EventFrameworkReady()
    var
        Captions: DotNet npNetDictionary_Of_T_U;
    begin
        Marshaller := Marshaller.Marshaller();
        Marshaller.Initialize();

        UI.ConfigureCaptions(Marshaller);
        UI.ConfigureCustomLogo(Marshaller);
        UI.ConfigureFonts(Marshaller);

        CurrPage.NPHost.ShowDialog(Dlg);

        UpdateFigures(true);
    end;

    local procedure EventMarshal(EventArgs: DotNet npNetMarshalEventArgs)
    var
        KnownEvent: DotNet npNetKnownEvent;
    begin
        case EventArgs.EventType of
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
          KnownEvent.UpdateState:
            begin
              CurrPage.NPHost.SendRequest(EventArgs.ToRequestInfo());
            end;
          else
            Error('Unsupported marshalled event. This is a programming bug, not a user error. Event details:\\%1',EventArgs.ToJson());
        end;
    end;

    trigger Marshaller::Marshal(eventArgs: DotNet npNetMarshalEventArgs)
    begin
        EventMarshal(eventArgs);
    end;
}

