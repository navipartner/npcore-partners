codeunit 6014623 "POS Event Marshaller"
{
    // NPR4.10/VB/20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629  CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.11/VB/20150723  CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.13/MMV/20150716 CASE 218816 Added CLEAR on record variable before passing to .NET to mirror behaviour in CU 6014498 before marshal integration.
    // NPR4.14/VB/20150909  CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925  CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.15/VB/20150930  CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR9   /VB/20150104  CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.20/VB/20151221  CASE 229508 Exiting numpad with <CANCEL> to achieve the same behavior as earlier .NET solution
    // NPR5.20/VB/20151221  CASE 229375 Adding MaxLength parameter to SearchBox dialog
    // NPR5.20/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 229375 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.20/VB/20160303 CASE 235306 Support for more lookup functionality
    // NPR5.22/VB/20160401 CASE 237916 Resizing the calendar dialog to fit smaller screens
    // NPR5.22/VB/20160414 CASE 237026 Allowing direct invokation of Stargate methods without going through Proxy Dialog page
    // NPR5.22/VB/20160421 CASE 239536 Processing remaining requests from the protocol queue every time response is received.
    // NPR5.22/MMV/20160422 CASE 239625 TEMPORARY solution: Suppressed error on response process
    // NPR5.23/VB/20160505 CASE 240254 Additional fix in setting screen size due to margin added by NAV web client.
    // NPR5.23/VB/20160505 CASE 238378 Function to clear EanBoxText added.
    // NPR5.23/MHA/20160510 CASE 241234 COMMIT added before RUNMODAL in Lookup()
    // NPR5.23/VB/20160525 CASE 242588 Control add-in reference sharing and calling control add-in directly (without .NET Marshaller)
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.38/MHA /20180105  CASE 301053 Renamed functions Message() and Error() to DisplayMessage() and DisplayError() in preparation for V2
    // NPR5.40/BHR /20180322 CASE 308408 Rename variable Grid to PageGrid

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text1001: Label 'This codeunit must be initialized before calling. This is a programming bug, not a user error.';
        SessionMgt: Codeunit "POS Web Session Management";
        UI: Codeunit "POS Web UI Management";
        Marshaller: DotNet Marshaller;
        Text1002: Label 'Response was received from JavaScript, which indicates a problem.\\Response type: %1\Status: %2\Error message: %3\\This is a programming bug, not a user error.';
        Text1003: Label '%1 is not a valid number. You must enter a valid number.';
        Text1004: Label '%1 is not a valid date. You must enter a valid date.';
        [RunOnClient]
        POS: DotNet IFramework;

    procedure Initialize(MarshallerIn: DotNet Marshaller)
    begin
        //-NPR5.28
        // IF NOT SessionMgt.IsDotNet() THEN BEGIN
        //  Marshaller := MarshallerIn;
        //  Marshaller.Initialize();
        // END;
        Marshaller := MarshallerIn;
        Marshaller.Initialize();
        //+NPR5.28
    end;

    procedure SetPOSReference(POSIn: DotNet IFramework)
    begin
        //-NPR5.23 [242588]
        POS := POSIn;
        //+NPR5.23 [242588]
    end;

    procedure Finalize()
    begin
        ClearAll();
    end;

    procedure IsInitialized(): Boolean
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN
        //  EXIT(TRUE);
        //+NPR5.28
        exit(not IsNull(Marshaller));
    end;

    local procedure MakeSureThisIsInitialized()
    begin
        if not IsInitialized() then
          Error(Text1001);
    end;

    local procedure ProcessRequestResult(Result: DotNet Result)
    var
        MarshalStatus: DotNet MarshalStatus;
        Status: Integer;
    begin
        Status := Result.Status;

        case Status of
          MarshalStatus.Enqueued,
          MarshalStatus.Empty:
            exit;

          MarshalStatus.Rejected,
          MarshalStatus.Error:
            Error(Result.Error.PopAll());

          MarshalStatus.Success:
            begin
            end;
        end;
    end;

    procedure ProcessResponse(Response: DotNet ResponseInfo;var TouchSalePOS: Codeunit "Touch - Sale POS (Web)")
    var
        Content: DotNet ResponseContent;
        ResponseStatus: DotNet ResponseStatus;
        MarshalStatus: DotNet MarshalStatus;
        Result: DotNet Result;
        KnownEvent: DotNet KnownEvent;
        Status: Integer;
    begin
        Content := Marshaller.ProcessResponse(Response);

        Status := Content.Status;
        case Status of
          ResponseStatus.Ok:
            begin
              case Content.RequestKnownEventId of
                KnownEvent.NumPad: TouchSalePOS.ProcessNumpadResponse(Content);
              end;
            end;
          ResponseStatus.Cancelled:
            begin
              // Develop protocol response, when Touch Sale - POS codeunit is refactored
            end;
          //-NPR5.22
          // TODO - this block is here only temporarily. It must be refactored at the next version increase with proper response type
          ResponseStatus.Unknown:
            begin
              if Response.RequestType <> 'InvokeJavaScriptFunction' then;
                //-NPR5.22
                //ERROR(Text1002,Content.GetType(),Content.Status,Content.ErrorMessage);
                //+NPR5.22
            end;
          //+NPR5.22
          //-NPR5.22
        //  ELSE
        //    ERROR(Text1002,Content.GetType(),Content.Status,Content.ErrorMessage);
          //+NPR5.22
        end;

        //-NPR5.22
        //Result := Marshaller.ProcessNextRequest();
        //IF NOT ISNULL(Result) THEN
        //  ProcessRequestResult(Result);
        repeat
          Result := Marshaller.ProcessNextRequest();
          if not Result.Status.Equals(MarshalStatus.Empty) then
            ProcessRequestResult(Result);
        until Result.Status.Equals(MarshalStatus.Empty);
        //+NPR5.22
    end;

    local procedure "--- Individual Marshaller Requests ---"()
    begin
    end;

    procedure CancelRequest(RequestType: Text;Id: Guid;KnownType: Guid)
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.CancelRequest(RequestType,Id,KnownType));
    end;

    procedure CancelAllProtocolRequests()
    begin
        MakeSureThisIsInitialized();
        Marshaller.CancelAllProtocolRequests();
    end;

    procedure DimScreen(DoDim: Boolean)
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN BEGIN
        //  DimScreenDotNet(DoDim);
        //  EXIT;
        // END;
        //+NPR5.28

        if IsInitialized then
          ProcessRequestResult(Marshaller.DimScreen(DoDim));
    end;

    procedure DisplayMessage(Title: Text;Caption: Text)
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Dlg: DotNet Error;
    begin
        Error(Title,Caption,false);
    end;

    procedure DisplayError(Title: Text;Caption: Text;ThrowError: Boolean)
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Dlg: DotNet Error;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN BEGIN
        //  ErrorDotNet(Title,Caption,ThrowError);
        //  EXIT;
        // END;
        //+NPR5.28

        Dlg := Dlg.Error(Caption);
        Dlg.Title := Title;
        Dlg.Width := 520;
        Dlg.Height := 270;

        DimScreen(true);
        NPDialog.SetDialog(Dlg);
        NPDialog.RunModal;
        DimScreen(false);

        if ThrowError then
          Error('');
    end;

    procedure Error_Protocol(Title: Text;Caption: Text;ThrowError: Boolean)
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Dlg: DotNet Error;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN BEGIN
        //  ErrorDotNet(Title,Caption,ThrowError);
        //  EXIT;
        // END;
        //+NPR5.28

        if IsInitialized then
          ProcessRequestResult(
            Marshaller.Error(Title,Caption,ThrowError));

        if ThrowError then
          Error('');
    end;

    procedure Confirm(Title: Text;Caption: Text): Boolean
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Dlg: DotNet Confirm;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN
        //  EXIT(ConfirmDotNet(Title,Caption));
        //+NPR5.28

        Dlg := Dlg.Confirm(Title,Caption);
        Dlg.Width := 520;
        Dlg.Height := 270;

        DimScreen(true);
        NPDialog.SetDialog(Dlg);
        NPDialog.RunModal;
        DimScreen(false);

        exit(NPDialog.GetConfirmResult());
    end;

    procedure SearchBox(Title: Text;Caption: Text;MaxLength: Integer): Text
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Dlg: DotNet SearchBox;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN
        //  EXIT(SearchBoxDotNet(Title,Caption));
        //+NPR5.28

        Dlg := Dlg.SearchBox(Title,Caption);
        Dlg.Width := 600;
        Dlg.Height := 290;
        Dlg.MaxLength := MaxLength;

        DimScreen(true);
        NPDialog.SetDialog(Dlg);
        NPDialog.RunModal;
        DimScreen(false);

        if NPDialog.GetCancelled() then
          exit('<CANCEL>');

        exit(NPDialog.GetSearchBoxResult());
    end;

    procedure NumPad(Caption: Text;var InputResult: Decimal;NotBlank: Boolean;Masked: Boolean): Boolean
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        Dlg: DotNet Numpad;
        NumpadType: DotNet NumpadType;
        Cancelled: Boolean;
        ResultText: Text;
    begin
        // TODO
        // Numpad in javascript must be aware of the type
        // Numpad in javascript must not allow closing if data entered does not properly map to the type
        //-NPR5.28
        //IF NOT SessionMgt.IsDotNet() THEN BEGIN
        //+259086
          Dlg := Dlg.Numpad(Caption,UI.FormatDecimal(InputResult),Masked,NotBlank,NumpadType.Numeric);
          Dlg.Width := 520;
          Dlg.Height := 664 + (Util.CountOfChar(Caption,'\') * 24);

          DimScreen(true);

          repeat
            Clear(NPDialog);
            NPDialog.SetDialog(Dlg);
            NPDialog.RunModal;
            Cancelled := NPDialog.GetCancelled();
            if Cancelled then begin
              DimScreen(false);
              exit(false);
            end;
            ResultText := NPDialog.GetNumpadResult();
          until (not NotBlank) or (ResultText <> '');
          DimScreen(false);
        //-NPR5.28
        // END ELSE BEGIN
        //  ResultText := NumPadDotNet(Caption,UI.FormatDecimal(InputResult),NotBlank,Masked);
        //  IF ResultText = '<CANCEL>' THEN
        //    EXIT(FALSE);
        // END;
        //+NPR5.28

        if ResultText = '' then
          ResultText := UI.FormatDecimal(0);
        if not UI.TryParseDecimal(InputResult,ResultText) then
          Error(Text1003,ResultText);

        exit(true);
    end;

    procedure NumPadDate(Caption: Text;var InputResult: Date;NotBlank: Boolean;Masked: Boolean): Boolean
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        Dlg: DotNet Numpad;
        NumpadType: DotNet NumpadType;
        Cancelled: Boolean;
        Date: Date;
        ResultText: Text;
    begin
        //-NPR5.28
        //IF NOT SessionMgt.IsDotNet() THEN BEGIN
        //+NPR5.28
          Dlg := Dlg.Numpad(Caption,UI.FormatDate(InputResult),Masked,NotBlank,NumpadType.Date);
          Dlg.Width := 520;
          Dlg.Height := 664 + (Util.CountOfChar(Caption,'\') * 24);

          DimScreen(true);

          repeat
            Clear(NPDialog);
            NPDialog.SetDialog(Dlg);
            NPDialog.RunModal;
            Cancelled := NPDialog.GetCancelled();
            if Cancelled then begin
              DimScreen(false);
              exit(false);
            end;
            ResultText := NPDialog.GetNumpadResult();
          until (not NotBlank) or (ResultText <> '');
          DimScreen(false);
        //-NPR5.28
        // END ELSE BEGIN
        //  ResultText := NumPadDotNet(Caption,UI.FormatDate(InputResult),NotBlank,Masked);
        //  IF ResultText = '<CANCEL>' THEN
        //    EXIT(FALSE);
        // END;
        //+NPR5.28

        if ResultText = '' then
          ResultText := UI.FormatDate(Today);
        if not UI.TryParseDate(InputResult,ResultText) then
          Error(Text1003,ResultText);

        exit(true);
    end;

    procedure NumPadCode(Caption: Text;var InputResult: Code[1024];NotBlank: Boolean;Masked: Boolean): Boolean
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        Dlg: DotNet Numpad;
        NumpadType: DotNet NumpadType;
        Cancelled: Boolean;
        ResultText: Text;
    begin
        //-NPR5.28
        //IF NOT SessionMgt.IsDotNet() THEN BEGIN
        //+NPR5.28
          Dlg := Dlg.Numpad(Caption,InputResult,Masked,NotBlank,NumpadType.Text);
          Dlg.Width := 520;
          Dlg.Height := 664 + (Util.CountOfChar(Caption,'\') * 24);

          DimScreen(true);

          repeat
            Clear(NPDialog);
            NPDialog.SetDialog(Dlg);
            NPDialog.RunModal;
            Cancelled := NPDialog.GetCancelled();
            if Cancelled then begin
              DimScreen(false);
              exit(false);
            end;
            ResultText := NPDialog.GetNumpadResult();
          until (not NotBlank) or (ResultText <> '');
          DimScreen(false);
        //-NPR5.28
        // END ELSE BEGIN
        //  ResultText := NumPadDotNet(Caption,InputResult,NotBlank,Masked);
        //  IF ResultText = '<CANCEL>' THEN
        //    EXIT(FALSE);
        // END;
        //+NPR5.28

        InputResult := ResultText;

        exit(true);
    end;

    procedure NumPadText(Caption: Text;var InputResult: Text;NotBlank: Boolean;Masked: Boolean): Boolean
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        Dlg: DotNet Numpad;
        NumpadType: DotNet NumpadType;
        Cancelled: Boolean;
        ResultText: Text;
    begin
        //-NPR5.28
        //IF NOT SessionMgt.IsDotNet() THEN BEGIN
        //+NPR5.28
          Dlg := Dlg.Numpad(Caption,InputResult,Masked,NotBlank,NumpadType.Text);
          Dlg.Width := 520;
          Dlg.Height := 664 + (Util.CountOfChar(Caption,'\') * 24);

          DimScreen(true);

          repeat
            Clear(NPDialog);
            NPDialog.SetDialog(Dlg);
            NPDialog.RunModal;
            Cancelled := NPDialog.GetCancelled();
            if Cancelled then begin
              DimScreen(false);
              exit(false);
            end;
            ResultText := NPDialog.GetNumpadResult();
          until (not NotBlank) or (ResultText <> '');
          DimScreen(false);
        //-NPR5.28
        // END ELSE BEGIN
        //  ResultText := NumPadDotNet(Caption,InputResult,NotBlank,Masked);
        //  IF ResultText = '<CANCEL>' THEN
        //    EXIT(FALSE);
        // END;
        //+NPR5.28

        InputResult := ResultText;

        exit(true);
    end;

    procedure NumPad_Protocol(Caption: Text;Input: Decimal;NotBlank: Boolean;Masked: Boolean;Context: DotNet ProtocolContext)
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        Dlg: DotNet Numpad;
        NumpadType: DotNet NumpadType;
        Cancelled: Boolean;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN
        //  ERROR('You have called NumPad_Protocol from a DotNet client session. This is a programming bug, not a user error.');
        //+NPR5.28

        if IsInitialized then
          ProcessRequestResult(
            Marshaller.NumPad(Caption,UI.FormatDecimal(Input),Masked,NotBlank,NumpadType.Numeric,Context));
    end;

    procedure NumPad_ProtocolCode(Caption: Text;Input: Code[10];NotBlank: Boolean;Masked: Boolean;Context: DotNet ProtocolContext)
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        Dlg: DotNet Numpad;
        NumpadType: DotNet NumpadType;
        Cancelled: Boolean;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN
        //  ERROR('You have called NumPad_Protocol from a DotNet client session. This is a programming bug, not a user error.');
        //+NPR5.28

        if IsInitialized then
          ProcessRequestResult(
            Marshaller.NumPad(Caption,Input,Masked,NotBlank,NumpadType.Text,Context));
    end;

    procedure CalendarGrid(Caption: Text;DefaultDate: Date;var SaleLinePOS: Record "Sale Line POS";var Cancelled: Boolean): Date
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Util: Codeunit "POS Web Utilities";
        UI: Codeunit "POS Web UI Management";
        RecRef: RecordRef;
        PageGrid: DotNet DataGrid;
        Dlg: DotNet CalendarGrid;
    begin
        //-NPR5.28
        // IF SessionMgt.IsDotNet() THEN
        //  EXIT(CalendarGridDotNet(Caption,DefaultDate,SaleLinePOS,Cancelled));
        //+NPR5.28

        if DefaultDate = 0D then
          DefaultDate := Today;

        //-NPR5.40 [308408]
        //Grid := Grid.DataGrid();
        //UI.ConfigurePrintExchangeLabelsGrid(Grid);
        PageGrid := PageGrid.DataGrid();
        UI.ConfigurePrintExchangeLabelsGrid(PageGrid);
        //+NPR5.40 [308408]

        RecRef.GetTable(SaleLinePOS);
        //-NPR5.40 [308408]
        //Util.NavRecordToRowsMarked(RecRef,Grid);

        //Dlg := Dlg.CalendarGrid(Grid,CREATEDATETIME(DefaultDate,TIME));
        Util.NavRecordToRowsMarked(RecRef,PageGrid);

        Dlg := Dlg.CalendarGrid(PageGrid,CreateDateTime(DefaultDate,Time));
        //+NPR5.40 [308408]
        UI.ConfigureCalendarGridDialog(Dlg);
        //-NPR5.22
        //Dlg.Width := 1200;
        //-NPR5.23
        //Dlg.Width := 1024;
        Dlg.Width := 984;
        //+NPR5.23
        //+NPR5.22
        Dlg.Height := 650;

        DimScreen(true);
        NPDialog.SetDialog(Dlg);
        NPDialog.RunModal();
        DimScreen(false);

        Cancelled := NPDialog.GetCancelled();
        if not Cancelled then
          NPDialog.GetCalendarGridRows(SaleLinePOS);
        exit(NPDialog.GetCalendarGridResult());
    end;

    procedure Lookup(Caption: Text;Template: DotNet Template;var LookupRec: RecordRef;ShowNew: Boolean;ShowCard: Boolean;CardPageId: Integer): Text
    var
        NPDialog: Page "Touch Screen - Dialog (Web)";
        Dlg: DotNet Lookup;
    begin
        Dlg := Dlg.Lookup();
        Dlg.Template := Template;

        Dlg.Width := 900;
        Dlg.Height := 650;
        Dlg.Caption := Caption;

        DimScreen(true);
        NPDialog.SetDialog(Dlg);
        //-NPR5.20
        NPDialog.ConfigureLookup(LookupRec,ShowNew,ShowCard,CardPageId);
        //+NPR5.20
        //-NPR5.23
        Commit;
        //+NPR5.23
        NPDialog.RunModal();
        DimScreen(false);

        if NPDialog.GetCancelled() then
          exit('');

        exit(NPDialog.GetLookupResult());
    end;

    procedure Functions(Caption: Text;"Filter": Text)
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.Functions(Caption,Filter));
    end;

    procedure CloseFunctions()
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.CloseFunctions());
    end;

    procedure SetObjectProperty(Property: Text;Value: DotNet Object)
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.SetObjectProperty(Property,Value));
    end;

    procedure ConfigureFont(Font: DotNet Font)
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.ConfigureFont(Font));
    end;

    procedure RequestRefreshSalesLineData()
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.RequestRefreshSalesLineData());
    end;

    procedure UpdateInfoBox(View: DotNet View)
    var
        ViewType: DotNet ViewType;
        SaleView: DotNet SaleView;
        PaymentView: DotNet PaymentView;
        InfoBox: DotNet InfoBox;
    begin
        MakeSureThisIsInitialized();
        case View.TypeAsInt of
          ViewType.Sale:
            begin
              SaleView := View;
              InfoBox := SaleView.InfoBox;
            end;
          ViewType.Payment:
            begin
              PaymentView := View;
              InfoBox := PaymentView.InfoBox;
            end;
        end;

        if not IsNull(InfoBox) then
        //-NPR5.22
          //Marshaller.UpdateInfoBox(InfoBox));
          ProcessRequestResult(
            Marshaller.UpdateInfoBox(InfoBox));
        //+NPR5.22
    end;

    procedure UpdateState(StateData: DotNet Dictionary_Of_T_U)
    begin
        MakeSureThisIsInitialized();
        ProcessRequestResult(Marshaller.UpdateState(StateData));
    end;

    procedure RunTouchScreenSale()
    begin
        //-NPR5.28
        //IF SessionMgt.IsDotNet() THEN
        //  PAGE.RUNMODAL(PAGE::"Touch Screen - Sale")
        //ELSE
        //+NPR5.28
        PAGE.RunModal(PAGE::"Touch Screen - Sale (Web)")
    end;

    procedure InvokeDeviceMethod(Request: DotNet Request): Guid
    var
        Args: DotNet Array;
        "Object": DotNet Object;
        Envelope: DotNet RequestEnvelope;
    begin
        //-NPR5.22
        Args := Args.CreateInstance(GetDotNetType(Object),1);

        Envelope := Envelope.RequestEnvelope(Request);
        Args.SetValue(Envelope.ToString(),0);

        //-NPR5.23 [242588]
        //IF IsInitialized THEN
        //  ProcessRequestResult(
            //Marshaller.InvokeJavaScriptFunction('n$.Framework.InvokeDeviceMethod',Args));
        POS.InvokeDeviceMethod(Envelope.ToString());
        //+NPR5.23 [242588]
        exit(Envelope.MessageId);
        //+NPR5.22
    end;

    procedure ClearEanBoxText()
    var
        String: DotNet String;
    begin
        //-NPR5.23
        String := '';
        Marshaller.SetObjectProperty('[n$.State.Context.View.EanBoxText.value]',String);
        Marshaller.SetObjectProperty('[n$.State.Context.View.Context.EanBoxText]',String);
        //+NPR5.23
    end;
}

