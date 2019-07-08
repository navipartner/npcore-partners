page 6014652 "Touch Screen - Dialog (Web)"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.13/VB/20150730 CASE 213003 Refactored code to support setting properties through marshaller
    // NPR4.14/VB/20150904 CASE 213003 Merged changes
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.20/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.20/VB/20160302 CASE 235306 Extended Lookup functionality to support adding new records and showing the card
    // NPR5.22/VB/20160316 CASE 236519 Added support for configurable lookup templates and caching.
    // NPR5.23/MHA/20160510 CASE 241184 Caching Removed
    // NPR5.48/JDH /20181106 CASE 334584 Function LookupRequestData and LookupSendSingleRow. Renamed Parameter from Grid to DGrid. Grid is a reserved word in Ext V2

    Caption = 'Touch Screen - Dialog (Web)';
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

                trigger OnScreenSize(screen: DotNet Screen)
                begin
                end;

                trigger OnMessage(eventArgs: DotNet MessageEventArgs)
                begin
                    EventOnMessage(eventArgs);
                end;

                trigger OnResponse(response: DotNet ResponseInfo)
                begin
                end;

                trigger OnJavaScriptCallback(js: DotNet JavaScript)
                begin
                end;

                trigger OnDialogResponse(response: DotNet Response)
                begin
                    EventOnDialogResponse(response)
                end;

                trigger OnDataUpdated(dataSource: DotNet DataSource)
                begin
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        LookupRequestChunkSize := 10;
    end;

    var
        LookupRec: RecordRef;
        Util: Codeunit "POS Web Utilities";
        UI: Codeunit "POS Web UI Management";
        Events: Codeunit "Touch - Event Publisher";
        SessionMgt: Codeunit "POS Web Session Management";
        [WithEvents]
        Marshaller: DotNet Marshaller;
        Dlg: DotNet Dialog;
        Text001: Label 'Dialog is not initialized, and there was a request to show a dialog. This is a programming bug, not a user error.';
        Factory: DotNet MarshalEventArgsFactory;
        RequestFactory: DotNet RequestFactory;
        ConfirmResult: Boolean;
        NumPadResult: Text;
        SearchBoxResult: Text;
        CalendarGridResult: Date;
        CalendarGridRows: DotNet Array;
        LookupResult: Text;
        Cancelled: Boolean;
        LookupRequestChunkSize: Integer;
        IsLookupRecordsetOpen: Boolean;
        LookupHasMoreData: Boolean;
        LookupCardPageId: Integer;
        LookupShowCard: Boolean;
        LookupShowNew: Boolean;
        IsLookup: Boolean;

    procedure SetDialog(DlgIn: DotNet Dialog)
    begin
        Dlg := DlgIn;
    end;

    procedure ConfigureLookup(var LookupRecIn: RecordRef;LookupShowNewIn: Boolean;LookupShowCardIn: Boolean;LookupCardPageIdIn: Integer)
    begin
        LookupRec := LookupRecIn;
        LookupHasMoreData := LookupRec.FindSet();

        //-NPR5.20
        IsLookup := true;
        LookupShowNew := LookupShowNewIn;
        LookupShowCard := LookupShowCardIn;
        LookupCardPageId := LookupCardPageIdIn;
        //+NPR5.20
    end;

    procedure GetCancelled(): Boolean
    begin
        exit(Cancelled);
    end;

    procedure GetNumpadResult(): Text
    begin
        exit(NumPadResult);
    end;

    procedure GetSearchBoxResult(): Text
    begin
        exit(SearchBoxResult);
    end;

    procedure GetConfirmResult(): Boolean
    begin
        exit(ConfirmResult);
    end;

    procedure GetCalendarGridResult(): Date
    begin
        exit(CalendarGridResult);
    end;

    procedure GetCalendarGridRows(var SaleLinePOS: Record "Sale Line POS")
    var
        SaleLinePOSTemplate: Record "Sale Line POS";
        Util: Codeunit "POS Web Utilities";
        RecRef: RecordRef;
        IEnumerator: DotNet IEnumerator;
        KeyFields: Text;
    begin
        SaleLinePOSTemplate := SaleLinePOS;
        Clear(SaleLinePOS);

        IEnumerator := CalendarGridRows.GetEnumerator();
        while IEnumerator.MoveNext do begin
          KeyFields := IEnumerator.Current;

          SaleLinePOS := SaleLinePOSTemplate;
          Evaluate(SaleLinePOS."Sale Type",CopyStr(KeyFields,1,StrPos(KeyFields,';') - 1));
          Evaluate(SaleLinePOS."Line No.",CopyStr(KeyFields,StrPos(KeyFields,';') + 1));
          SaleLinePOS.Find;
          SaleLinePOS.Mark(true);
        end;

        SaleLinePOS.MarkedOnly(true);
    end;

    procedure GetLookupResult(): Text
    begin
        exit(LookupResult);
    end;

    local procedure LookupRequestData()
    var
        DGrid: DotNet DataGrid;
        Row: DotNet Dictionary_Of_T_U;
        LookupDlg: DotNet Lookup;
    begin
        LookupDlg := Dlg;

        DGrid := DGrid.DataGrid();
        if LookupHasMoreData then
          repeat
            //-NPR5.22
            //Row := Grid.NewRow();
            //Util.NavOneRecordToDictionary(LookupRec,Row,LookupDlg.Template);
            //-NPR5.23
            //IF SessionMgt.StoreLookupCache(LookupRec) THEN BEGIN
            //  Row := Grid.NewRow();
            //  Util.NavOneRecordToDictionary(LookupRec,Row,LookupDlg.Template);
            //END;
            Row := DGrid.NewRow();
            Util.NavOneRecordToDictionary(LookupRec,Row,LookupDlg.Template);
            //+NPR5.23
            //+NPR5.22
            LookupHasMoreData := LookupRec.Next() > 0;
          until (not LookupHasMoreData) or (DGrid.Rows.Count >= LookupRequestChunkSize);

        CurrPage.NPHost.SendRequest(RequestFactory.LookupSendData(DGrid,LookupHasMoreData));
    end;

    local procedure LookupSendSingleRow(RecRef: RecordRef)
    var
        DGrid: DotNet DataGrid;
        Row: DotNet Dictionary_Of_T_U;
        LookupDlg: DotNet Lookup;
        Params: DotNet Array;
    begin
        if not RecRef.Find() then
          exit;

        LookupDlg := Dlg;
        DGrid := DGrid.DataGrid();
        Row := DGrid.NewRow();
        Util.NavOneRecordToDictionary(RecRef,Row,LookupDlg.Template);
        CurrPage.NPHost.SendRequest(RequestFactory.LookupSendData(DGrid,false));

        Params := Params.CreateInstance(GetDotNetType(''),1);
        Params.SetValue(RecRef.GetPosition(),0);
        CurrPage.NPHost.SendRequest(RequestFactory.InvokeJavaScriptFunction('n$.Popup.LookupDialog.selectRecord',Params));
    end;

    local procedure EventTweakReady()
    begin
        //CurrPage.NPTweak.SetPageSize(Dlg.Width,Dlg.Height);
    end;

    local procedure EventFrameworkReady()
    var
        LookupCache: Record "Lookup Cache Log";
        RequestFactory: DotNet RequestFactory;
        Captions: DotNet Dictionary_Of_T_U;
        StartDate: DateTime;
        Timestamp: BigInteger;
    begin
        Marshaller := Marshaller.Marshaller();
        Marshaller.Initialize();

        UI.ConfigureCaptions(Marshaller);

        if CurrentClientType = CLIENTTYPE::Windows then begin
          CurrPage.NPHost.SendRequest(Factory.UpdateCss('@media only screen and (min-width : 320px) and (max-width : 768px){body,input,textarea,keygen,select,button{font-size:16px !important;}}').ToRequestInfo());
        end;

        //-NPR5.20
        if IsLookup then begin
          CurrPage.NPHost.SendRequest(Factory.SetObjectProperty('n$.Popup.LookupDialog.Options.ShowCard',LookupShowCard).ToRequestInfo());
          CurrPage.NPHost.SendRequest(Factory.SetObjectProperty('n$.Popup.LookupDialog.Options.ShowNew',LookupShowNew).ToRequestInfo());
        //-NPR5.22
          //-NPR5.23
          //IF LookupCache.GET(LookupRec.NUMBER) THEN;
          //StartDate := CREATEDATETIME(DMY2DATE(1,1,2000),0T);
          //IF LookupCache."Last Change" = 0DT THEN
          //  LookupCache."Last Change":= StartDate;
          //Timestamp := LookupCache."Last Change" - StartDate;
          //CurrPage.NPHost.SendRequest(Factory.SetObjectProperty('n$.Popup.LookupDialog.Options.LastUpdate',Timestamp).ToRequestInfo());
          //CurrPage.NPHost.SendRequest(Factory.SetObjectProperty('n$.Popup.LookupDialog.Options.LookupRec',LookupRec.NUMBER).ToRequestInfo());
          //+NPR5.23
        //+NPR5.22
        end;
        //+NPR5.20

        CurrPage.NPHost.ShowDialog(Dlg);
    end;

    local procedure EventOnMessage(EventArgs: DotNet MessageEventArgs)
    var
        RecRef: RecordRef;
        EventType: DotNet EventType;
        Dictionary: DotNet Dictionary_Of_T_U;
        MessageType: Integer;
    begin
        MessageType := EventArgs.Type;

        case MessageType of
          EventType.LookupRequestData:
            begin
              LookupRequestData();
            end;
        //-NPR5.20
          EventType.Insert:
            begin
              if IsLookup then begin
                RecRef.Open(LookupRec.Number);
                Events.OnLookupNew(LookupCardPageId,RecRef);
                if RecRef.Find() then
                  LookupSendSingleRow(RecRef);
              end;
            end;
          EventType.SelectionChanged:
            begin
              if IsLookup then begin
                Dictionary := EventArgs.ToSelectionChanged();
                RecRef.Open(LookupRec.Number);
                RecRef.SetPosition(Dictionary.Item('position'));
                Events.OnLookupShowCard(LookupCardPageId,RecRef);
              end;
            end;
        //+NPR5.20
        end;
    end;

    local procedure EventOnDialogResponse(Response: DotNet Response)
    var
        DialogType: DotNet DialogType;
        NumpadResponse: DotNet NumpadResponse;
        ConfirmResponse: DotNet ConfirmResponse;
        SearchBoxResponse: DotNet SearchBoxResponse;
        CalendarGridResponse: DotNet CalendarGridResponse;
        LookupResponse: DotNet LookupResponse;
        ResponseType: Integer;
    begin
        ResponseType := Response.DialogType;
        case ResponseType of
          DialogType.NumPad:
            begin
              NumPadResult := '';
              NumpadResponse := Response.AsNumpad();
              Cancelled := NumpadResponse.Cancelled;
              if not NumpadResponse.Cancelled then
                NumPadResult := NumpadResponse.Text
            end;
          DialogType.Confirm:
            begin
              ConfirmResponse := Response.AsConfirm();
              ConfirmResult := ConfirmResponse.Reply;
            end;
          DialogType.SearchBox:
            begin
              SearchBoxResponse := Response.AsSearchBox();
              Cancelled := SearchBoxResponse.Cancelled;
              if not SearchBoxResponse.Cancelled then
                SearchBoxResult := SearchBoxResponse.Text;
            end;
          DialogType.CalendarGrid:
            begin
              CalendarGridResponse := Response.AsCalendarGrid();
              Cancelled := CalendarGridResponse.Cancelled;
              if not Cancelled then begin
                CalendarGridResult := DT2Date(CalendarGridResponse.Date);
                CalendarGridRows := CalendarGridResponse.GetRows();
              end;
            end;
          DialogType.Lookup:
            begin
              LookupResponse := Response.AsLookup();
              Cancelled := LookupResponse.Cancelled;
              if not Cancelled then
                LookupResult := LookupResponse.Position;
            end;
        end;
        CurrPage.Close;
    end;

    local procedure EventMarshal(EventArgs: DotNet MarshalEventArgs)
    var
        KnownEvent: DotNet KnownEvent;
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

    trigger Marshaller::Marshal(eventArgs: DotNet MarshalEventArgs)
    begin
        EventMarshal(eventArgs);
    end;
}

