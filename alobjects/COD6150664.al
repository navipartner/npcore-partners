codeunit 6150664 "NPRE Restaurant Print"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/MMV /20170726 CASE 285002 Refactored kitchen print.
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412 CASE 309873 Print Templates moved to seperate table
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kintchen order'
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    //                                   (+deleted old commented lines)
    // NPR5.54/ALPO/20200226 CASE 392956 Send to kitchen print waiter pad lines with no print category assigned
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200420 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    //                                   (+deleted old commented lines)


    trigger OnRun()
    begin
    end;

    var
        ERRPrint: Label '%1 fcn. Print - Variant must be Record or Recordref';
        PrintKitchOderConfMsg: Label 'Do you want to send the order to the kitchen now?';
        NoMoreMealGroupsLbl: Label 'No more meal groups left to be sent to the kitchen.';
        NothingToSendLbl: Label 'Nothing to send.';
        LinesHaveAlreadyBeenSent: Label 'One or more lines for %1 ''%2'' and %3 ''%4'' have already been sent to kitchent.\\Please select what do you want to do:\';
        ResendOptions: Label 'Send only new lines,Send all lines including previously sent';
        GlobalPrintTemplate: Record "NPRE Print Template";
        SetupProxy: Codeunit "NPRE Restaurant Setup Proxy";
        NowhereToSend: Label 'Neither Kitchen Printing nor KDS is activated. You need to activate at least one of them to be able to use this functionality.';
        ServingReqestedMsg: Label 'Serving of %1 requested for seating %2 (waiter pad %3).';
        NotTempErr: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.';
        ObsoleteFunctionCalledMsg: Label 'Obsolete function called: %1.\This is a programming bug, not a user error. Please contact system vendor.\Call stack:\%2';

    procedure PrintWaiterPadPreReceiptPressed(WaiterPad: Record "NPRE Waiter Pad")
    begin
        PrintWaiterPadToPreReceipt(WaiterPad);
    end;

    procedure PrintWaiterPadPreOrderToKitchenPressed(WaiterPad: Record "NPRE Waiter Pad";ForceResend: Boolean)
    begin
        //PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',TRUE);  //NPR5.55 [399170]-revoked
        PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',ForceResend,true);  //NPR5.55 [399170]
    end;

    procedure LinesAddedToWaiterPad(var WaiterPad: Record "NPRE Waiter Pad")
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
        SeatingLocation: Record "NPRE Seating Location";
        Confirmed: Boolean;
    begin
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        case SetupProxy.AutoSendKitchenOrder of
          SeatingLocation."Auto Send Kitchen Order"::No:
            Confirmed := false;
          SeatingLocation."Auto Send Kitchen Order"::Yes:
            Confirmed := true;
          SeatingLocation."Auto Send Kitchen Order"::Ask:
            Confirmed := Confirm(PrintKitchOderConfMsg,true);
        end;
        if Confirmed then
          //PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',FALSE);  //NPR5.55 [399170]-revoked
          PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',false,false);  //NPR5.55 [399170]
    end;

    local procedure PrintWaiterPadToKitchen(WaiterPad: Record "NPRE Waiter Pad";PrintType: Integer;FlowStatusCode: Code[10];ForceResend: Boolean;ShowMsgIfNothingToSend: Boolean): Boolean
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        NPHWaiterPadLine.Reset;
        NPHWaiterPadLine.SetRange("Waiter Pad No.",WaiterPad."No.");
        //PrintWaiterPadLinesToKitchen(WaiterPad,NPHWaiterPadLine,PrintType,FlowStatusCode,ForceResend);  //NPR5.55 [399170]-revoked
        exit(PrintWaiterPadLinesToKitchen(WaiterPad,NPHWaiterPadLine,PrintType,FlowStatusCode,ForceResend,ShowMsgIfNothingToSend));  //NPR5.55 [399170]
    end;

    procedure "[Obsolete]PrintWaiterPadLinesToKitchen"(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLineIn: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusCode: Code[10];ForceResend: Boolean;ShowNothingToSendErr: Boolean): Boolean
    var
        FlowStatusTmp: Record "NPRE Flow Status" temporary;
        PrintCategoryTmp: Record "NPRE Print/Prod. Category" temporary;
        SeatingLocation: Record "NPRE Seating Location";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        WaiterPadLine2: Record "NPRE Waiter Pad Line";
        WaiterPadLineOut: Record "NPRE Waiter Pad Line";
        PrintTemplateBuffer: Record "NPRE W.Pad Line Output Buffer" temporary;
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
        PrintCategoryFilter: Text;
        PrintDateTime: DateTime;
        SelectedSendOption: Option Cancel,"Only New",All;
        OutputType: Integer;
        AskResendConfirmation: Boolean;
        KDSUpdated: Boolean;
        OutputTypeIsActive: Boolean;
    begin
        Error(ObsoleteFunctionCalledMsg, 'CU6150664.[Obsolete]PrintWaiterPadLinesToKitchen', GetLastErrorCallstack);  //NPR5.55 [382428]
        //-NPR5.55 [382428]-revoked
        /*
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        IF NOT (SetupProxy.KitchenPrintingActivated OR SetupProxy.KDSActivated) THEN
          //EXIT;  //NPR5.55 [399170]-revoked
          ERROR(NowhereToSend);  //NPR5.55 [399170]
        
        IF NOT ForceResend THEN BEGIN
          AskResendConfirmation := SetupProxy.ResendAllOnNewLines = SeatingLocation."Resend All On New Lines"::Ask;
          IF NOT AskResendConfirmation THEN
            ForceResend := SetupProxy.ResendAllOnNewLines = SeatingLocation."Resend All On New Lines"::Yes;
        END;
        
        WaiterPadLine.COPY(WaiterPadLineIn);
        WaiterPadLine.FILTERGROUP(2);
        WaiterPadLine.SETFILTER(Type,'<>%1',WaiterPadLine.Type::Comment);
        WaiterPadLine.FILTERGROUP(0);
        //WaiterPadLine.SETAUTOCALCFIELDS("No. of Print Categories","Sent to Kitchen");  //NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]/[382428]
        WaiterPadLine.SETAUTOCALCFIELDS(
          "No. of Print Categories", "Total No. of Print Categories", "No. of Serving Steps", "Total No. of Serving Steps",
          "Sent to Kitchen", "Sent to Kitchen Qty. (Base)");
        //+NPR5.55 [399170]/[382428]
        
        PrintTemplateBuffer.DELETEALL;
        FlowStatusTmp.DELETEALL;
        PrintDateTime := CURRENTDATETIME;
        FlowStatus.SETRANGE("Status Object",FlowStatus."Status Object"::WaiterPadLineMealFlow);
        IF FlowStatusCode <> '' THEN
          FlowStatus.SETRANGE(Code,FlowStatusCode);
        IF FlowStatus.FINDSET THEN
          REPEAT
            FlowStatusTmp := FlowStatus;
            FlowStatusTmp.INSERT;
          UNTIL FlowStatus.NEXT = 0;
        IF FlowStatusCode = '' THEN BEGIN
          FlowStatusTmp.INIT;
          FlowStatusTmp."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
          FlowStatusTmp.Code := '';
          FlowStatusTmp.INSERT;
        END;
        
        InitTempPrintCategoryList(PrintCategoryTmp);
        
        //-NPR5.55 [399170]
        FOR OutputType := WaiterPadLine."Output Type Filter"::Print TO WaiterPadLine."Output Type Filter"::KDS DO BEGIN
          OutputTypeIsActive :=
            ((OutputType = WaiterPadLine."Output Type Filter"::Print) AND SetupProxy.KitchenPrintingActivated) OR
            ((OutputType = WaiterPadLine."Output Type Filter"::KDS) AND SetupProxy.KDSActivated);
          IF OutputTypeIsActive THEN BEGIN
            WaiterPadLineOut.RESET;
            WaiterPadLine.SETRANGE("Output Type Filter",OutputType);
        //+NPR5.55 [399170]
            IF FlowStatusTmp.FINDSET THEN
              REPEAT
                PrintCategoryFilter := FlowStatusTmp.AssignedPrintCategoriesAsFilterString();
                IF (PrintCategoryFilter <> '') OR (FlowStatusTmp.Code = '') THEN BEGIN
                  IF PrintCategoryFilter <> '' THEN
                    PrintCategoryTmp.SETFILTER(Code,PrintCategoryFilter)
                  ELSE
                    PrintCategoryTmp.SETRANGE(Code,'');
                  IF PrintCategoryTmp.FINDSET THEN
                    REPEAT
                      WaiterPadLine.SETRANGE("Print Category Filter",PrintCategoryTmp.Code);
                      WaiterPadLine.SETRANGE("Serving Step Filter",FlowStatusTmp.Code);
                      WaiterPadLine.SETRANGE("Print Type Filter",PrintType);
                      IF WaiterPadLine.FINDSET THEN
                        REPEAT
                          //IF AskResendConfirmation AND NOT ForceResend AND WaiterPadLine."Sent to Kitchen" THEN BEGIN  //NPR5.55 [399170]-revoked
                          //-NPR5.55 [399170]
                          IF AskResendConfirmation AND NOT ForceResend AND WaiterPadLine."Sent to Kitchen" AND
                             (WaiterPadLine."Quantity (Base)" = WaiterPadLine."Sent to Kitchen Qty. (Base)")
                          THEN BEGIN
                          //+NPR5.55 [399170]
                            AskResendConfirmation := FALSE;
                            SelectedSendOption :=
                              STRMENU(ResendOptions,1,
                                STRSUBSTNO(LinesHaveAlreadyBeenSent,WaiterPad.FIELDCAPTION("Serving Step Code"),FlowStatusTmp.Code,PrintCategoryTmp.TABLECAPTION,PrintCategoryTmp.Code));
                            IF SelectedSendOption = SelectedSendOption::Cancel THEN
                              ERROR('');
                            ForceResend := SelectedSendOption = SelectedSendOption::All;
                          END;
        
                          WaiterPadLine2.COPY(WaiterPadLine);
                          WaiterPadLine2.SETRANGE("Print Category Filter");
                          WaiterPadLine2.CALCFIELDS("No. of Print Categories");
                          IF ((WaiterPadLine."No. of Print Categories" > 0) OR
                              ((WaiterPadLine2."No. of Print Categories" = 0) AND (PrintCategoryTmp.Code = '')))
                             AND
                             //(NOT WaiterPadLine."Sent to Kitchen" OR ForceResend)  //NPR5.55 [399170]-revoked
                             (NOT WaiterPadLine."Sent to Kitchen" OR (WaiterPadLine."Quantity (Base)" <> WaiterPadLine."Sent to Kitchen Qty. (Base)") OR ForceResend)  //NPR5.55 [399170]
                          THEN BEGIN
                            WaiterPadLineOut := WaiterPadLine;
                            WaiterPadLineOut.MARK := TRUE;
                          END;
                        UNTIL WaiterPadLine.NEXT = 0;
        
                      WaiterPadLineOut.MARKEDONLY(TRUE);
                      IF NOT WaiterPadLineOut.ISEMPTY THEN BEGIN
                        //IF SetupProxy.KitchenPrintingActivated THEN  //NPR5.55 [399170]-revoked
                        IF OutputType = WaiterPadLine."Output Type Filter"::Print THEN  //NPR5.55 [399170]
                          IF FindPrintTemplates(WaiterPad,WaiterPadLineOut,PrintType,PrintCategoryTmp.Code,FlowStatusTmp.Code{!},PrintTemplateBuffer) THEN BEGIN
                            WaiterPadLineOut.FINDSET;
                            REPEAT
                              LogWaiterPadLinePrint(WaiterPadLineOut,PrintType,FlowStatusTmp.Code,PrintCategoryTmp.Code,PrintDateTime,0);
                            UNTIL WaiterPadLineOut.NEXT = 0;
                          END;
        
                        //IF SetupProxy.KDSActivated THEN  //NPR5.55 [399170]-revoked
                        IF OutputType = WaiterPadLine."Output Type Filter"::KDS THEN  //NPR5.55 [399170]
                          KDSUpdated := KitchenOrderMgt.SendWPLinesToKitchen(WaiterPadLineOut,FlowStatusTmp.Code,PrintCategoryTmp.Code,PrintType,PrintDateTime) OR KDSUpdated;
                      END;
                      WaiterPadLineOut.RESET;
                    UNTIL PrintCategoryTmp.NEXT = 0;
                END;
              UNTIL FlowStatusTmp.NEXT = 0;
        //-NPR5.55 [399170]
          END;
        END;
        //+NPR5.55 [399170]
        
        IF PrintTemplateBuffer.ISEMPTY AND NOT KDSUpdated THEN BEGIN
          //-NPR5.55 [399170]-revoked
          //MESSAGE(NothingToSendLbl);
          //EXIT;
          //+NPR5.55 [399170]-revoked
          //-NPR5.55 [399170]
          IF ShowNothingToSendErr THEN
            ERROR(NothingToSendLbl);
          EXIT(FALSE);
          //+NPR5.55 [399170]
        END;
        
        SendToPrint(PrintTemplateBuffer);
        EXIT(TRUE);  //NPR5.55 [399170]
        */
        //+NPR5.55 [382428]-revoked

    end;

    procedure PrintWaiterPadLinesToKitchen(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLineIn: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusCode: Code[10];ForceResend: Boolean;ShowNothingToSendErr: Boolean): Boolean
    var
        FlowStatusTmp: Record "NPRE Flow Status" temporary;
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        WPadLineBuffer: Record "NPRE W.Pad Line Output Buffer" temporary;
        PrintTemplateBuffer: Record "NPRE W.Pad Line Output Buffer" temporary;
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        PrintDateTime: DateTime;
        KDSUpdated: Boolean;
    begin
        //-NPR5.55 [382428]
        InitTempFlowStatusList(FlowStatusTmp, FlowStatusTmp."Status Object"::WaiterPadLineMealFlow);
        if FlowStatusCode <> '' then
          FlowStatusTmp.SetRange(Code, FlowStatusCode);

        if not BufferWPadLinesForSending(WaiterPad, WaiterPadLineIn, PrintType, FlowStatusTmp, ForceResend, WPadLineBuffer) then begin
          if ShowNothingToSendErr then
            Error(NothingToSendLbl);
          exit(false);
        end;

        PrintTemplateBuffer.DeleteAll;
        PrintDateTime := CurrentDateTime;

        FlowStatusTmp.SetCurrentKey("Status Object","Flow Order");  //ensure serving steps are processed in correct order
        if FlowStatusTmp.FindSet then
          repeat
            WPadLineBuffer.SetRange("Serving Step", FlowStatusTmp.Code);
            if WPadLineBuffer.FindFirst then
              repeat
                WPadLineBuffer.SetRange("Output Type", WPadLineBuffer."Output Type");
                repeat
                  WaiterPadLine.Reset;
                  WPadLineBuffer.SetRange("Print Category Code", WPadLineBuffer."Print Category Code");
                  WPadLineBuffer.FindSet;
                  repeat
                    if WaiterPadLine.Get(WPadLineBuffer."Waiter Pad No.", WPadLineBuffer."Waiter Pad Line No.") then
                      WaiterPadLine.Mark := true;
                  until WPadLineBuffer.Next = 0;

                  WaiterPadLine.MarkedOnly(true);
                  if not WaiterPadLine.IsEmpty then
                    case WPadLineBuffer."Output Type" of
                      WPadLineBuffer."Output Type"::Print:
                        if FindPrintTemplates(
                            WaiterPad, WaiterPadLine, PrintType, WPadLineBuffer."Print Category Code", WPadLineBuffer."Serving Step", PrintTemplateBuffer)
                        then begin
                          WaiterPadLine.FindSet;
                          repeat
                            LogWaiterPadLinePrint(
                              WaiterPadLine, PrintType, WPadLineBuffer."Serving Step", WPadLineBuffer."Print Category Code", PrintDateTime, 0);
                          until WaiterPadLine.Next = 0;
                        end;
                      WPadLineBuffer."Output Type"::KDS:
                        KDSUpdated :=
                          KitchenOrderMgt.SendWPLinesToKitchen(
                            WaiterPadLine, WPadLineBuffer."Serving Step", WPadLineBuffer."Print Category Code", PrintType, PrintDateTime) or KDSUpdated;
                    end;

                  WPadLineBuffer.DeleteAll;
                  WPadLineBuffer.SetRange("Print Category Code");
                until not WPadLineBuffer.FindFirst;  //Print category loop
                WPadLineBuffer.SetRange("Output Type");
              until not WPadLineBuffer.FindFirst;  //Output type loop
          until FlowStatusTmp.Next = 0;

        if PrintTemplateBuffer.IsEmpty and not KDSUpdated then begin
          if ShowNothingToSendErr then
            Error(NothingToSendLbl);
          exit(false);
        end;

        SendToPrint(PrintTemplateBuffer);
        exit(true);
        //+NPR5.55 [382428]
    end;

    local procedure BufferWPadLinesForSending(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLineIn: Record "NPRE Waiter Pad Line";PrintType: Integer;var FlowStatus: Record "NPRE Flow Status";ForceResend: Boolean;var WPadLineBuffer: Record "NPRE W.Pad Line Output Buffer"): Boolean
    var
        PrintCategoryTmp: Record "NPRE Print/Prod. Category" temporary;
        SeatingLocation: Record "NPRE Seating Location";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        OutputType: Integer;
        AskResendConfirmation: Boolean;
        OutputTypeIsActive: Boolean;
    begin
        //-NPR5.55 [382428]
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        if not (SetupProxy.KitchenPrintingActivated or SetupProxy.KDSActivated) then
          Error(NowhereToSend);

        WaiterPadLine.Copy(WaiterPadLineIn);
        WaiterPadLine.FilterGroup(2);
        WaiterPadLine.SetFilter(Type, '<>%1', WaiterPadLine.Type::Comment);
        WaiterPadLine.FilterGroup(0);
        if WaiterPadLine.IsEmpty then
          exit(false);

        if not ForceResend then begin
          AskResendConfirmation := SetupProxy.ResendAllOnNewLines = SeatingLocation."Resend All On New Lines"::Ask;
          if not AskResendConfirmation then
            ForceResend := SetupProxy.ResendAllOnNewLines = SeatingLocation."Resend All On New Lines"::Yes;
        end;

        WPadLineBuffer.Reset;
        WPadLineBuffer.DeleteAll;

        InitTempPrintCategoryList(PrintCategoryTmp);

        for OutputType := WaiterPadLine."Output Type Filter"::Print to WaiterPadLine."Output Type Filter"::KDS do begin
          OutputTypeIsActive :=
            ((OutputType = WaiterPadLine."Output Type Filter"::Print) and SetupProxy.KitchenPrintingActivated) or
            ((OutputType = WaiterPadLine."Output Type Filter"::KDS) and SetupProxy.KDSActivated);
          if OutputTypeIsActive then
            BufferEligibleForSendingWPadLines(
              WaiterPadLine, OutputType, PrintType, FlowStatus, PrintCategoryTmp, ForceResend, AskResendConfirmation, WPadLineBuffer);
        end;

        exit(not WPadLineBuffer.IsEmpty);
        //+NPR5.55 [382428]
    end;

    procedure BufferEligibleForSendingWPadLines(var WaiterPadLine: Record "NPRE Waiter Pad Line";OutputType: Integer;PrintType: Integer;var FlowStatus: Record "NPRE Flow Status";var PrintCategory: Record "NPRE Print/Prod. Category";ForceResend: Boolean;AskResendConfirmation: Boolean;var WPadLineBuffer: Record "NPRE W.Pad Line Output Buffer")
    var
        WaiterPad: Record "NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        PrintCategoryFilter: Text;
        SelectedSendOption: Option Cancel,"Only New",All;
    begin
        //-NPR5.55 [382428]
        if WaiterPadLine.IsEmpty or FlowStatus.IsEmpty or PrintCategory.IsEmpty then
          exit;

        FlowStatus.SetCurrentKey("Status Object","Flow Order");
        FlowStatus.FindSet;
        repeat
          WaiterPadLine.FindSet;
          repeat
            PrintCategoryFilter := WaiterPadMgt.AssignedPrintCategoriesAsFilterString(WaiterPadLine.RecordId, FlowStatus.Code);
            if PrintCategoryFilter <> '' then
              PrintCategory.SetFilter(Code, PrintCategoryFilter)
            else
              PrintCategory.SetRange(Code, '');
            if PrintCategory.FindSet then
              repeat
                if WPadLineIsInScopeForSending(WaiterPadLine, PrintType, OutputType, FlowStatus.Code, PrintCategory.Code) then begin
                  WaiterPadLine.CalcFields("Sent to Kitchen", "Sent to Kitchen Qty. (Base)");
                  if AskResendConfirmation then
                    if not ForceResend and WaiterPadLine."Sent to Kitchen" and
                        (WaiterPadLine."Quantity (Base)" = WaiterPadLine."Sent to Kitchen Qty. (Base)")
                    then begin
                      AskResendConfirmation := false;
                      SelectedSendOption :=
                        StrMenu(ResendOptions, 1,
                          StrSubstNo(LinesHaveAlreadyBeenSent, WaiterPad.FieldCaption("Serving Step Code"), FlowStatus.Code, PrintCategory.TableCaption, PrintCategory.Code));
                      if SelectedSendOption = SelectedSendOption::Cancel then
                        Error('');
                      ForceResend := SelectedSendOption = SelectedSendOption::All;
                    end;

                  if not WaiterPadLine."Sent to Kitchen" or ForceResend or
                      (WaiterPadLine."Quantity (Base)" <> WaiterPadLine."Sent to Kitchen Qty. (Base)")
                  then begin
                    WPadLineBuffer."Output Type" := OutputType;
                    WPadLineBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
                    WPadLineBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
                    WPadLineBuffer."Print Category Code" := PrintCategory.Code;
                    WPadLineBuffer."Serving Step" := FlowStatus.Code;
                    if not WPadLineBuffer.Find then
                      WPadLineBuffer.Insert;
                  end;
                end;
              until PrintCategory.Next = 0;
          until WaiterPadLine.Next = 0;
        until FlowStatus.Next = 0;
        //+NPR5.55 [382428]
    end;

    local procedure WPadLineIsInScopeForSending(var WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;OutputType: Integer;ServingStepCode: Code[10];PrintCategoryCode: Code[20]): Boolean
    begin
        //-NPR5.55 [382428]
        WaiterPadLine.SetRange("Print Type Filter", PrintType);
        WaiterPadLine.SetRange("Output Type Filter", OutputType);
        WaiterPadLine.SetRange("Serving Step Filter", ServingStepCode);
        WaiterPadLine.SetRange("Print Category Filter", PrintCategoryCode);

        exit(
          ((WaiterPadLine.NoOfServingSteps() > 0) or
           ((WaiterPadLine.TotalNoOfServingSteps() = 0) and (ServingStepCode = '')))
          and
          ((WaiterPadLine.NoOfPrintCategories() > 0) or
           ((WaiterPadLine.TotalNoOfPrintCategories() = 0) and (PrintCategoryCode = ''))));
        //+NPR5.55 [382428]
    end;

    local procedure PrintWaiterPadToPreReceipt(var WaiterPad: Record "NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.",WaiterPad."No.");
        //FindAndPrintTemplates(WaiterPad,WaiterPadLine,GlobalPrintTemplate."Print Type"::"Pre Receipt",'');  //NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]
        if FindAndPrintTemplates(WaiterPad, WaiterPadLine, GlobalPrintTemplate."Print Type"::"Pre Receipt", '', '') then begin
          SetWaiterPadPreReceiptPrinted(WaiterPad, true, true);
          WaiterPadMgt.CloseWaiterPad(WaiterPad, false);
        end;
        //+NPR5.55 [399170]
    end;

    local procedure FindAndPrintTemplates(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;PrintCategoryCode: Code[20];ServingStep: Code[10]): Boolean
    var
        PrintTemplateBuffer: Record "NPRE W.Pad Line Output Buffer" temporary;
    begin
        PrintTemplateBuffer.DeleteAll;
        //IF FindPrintTemplates(WaiterPad,WaiterPadLine,PrintType,PrintCategoryCode,PrintTemplateBuffer) THEN  //NPR5.55 [399170]-revoked
        if FindPrintTemplates(WaiterPad,WaiterPadLine,PrintType,PrintCategoryCode,ServingStep,PrintTemplateBuffer) then begin  //NPR5.55 [399170]/[382428]
          SendToPrint(PrintTemplateBuffer);
        //-NPR5.55 [399170]
          exit(true);
        end;
        exit(false);
        //+NPR5.55 [399170]
    end;

    local procedure FindPrintTemplates(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;PrintCategoryCode: Code[20];ServingStep: Code[10];var PrintTemplateBuffer: Record "NPRE W.Pad Line Output Buffer") TemplateFound: Boolean
    var
        Seating: Record "NPRE Seating";
        SeatingLocation: Record "NPRE Seating Location";
        SeatingLocationTemp: Record "NPRE Seating Location" temporary;
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        FindForBlankLocation: Boolean;
    begin
        SeatingWaiterPadLink.SetRange("Waiter Pad No.",WaiterPad."No.");
        if SeatingWaiterPadLink.FindSet then
          repeat
            if Seating.Get(SeatingWaiterPadLink."Seating Code") then
              if Seating."Seating Location" <> '' then begin
                SeatingLocation.Code := Seating."Seating Location";
                if not SeatingLocation.Find then
                  SeatingLocation.Init;
                SeatingLocationTemp := SeatingLocation;
                SeatingLocationTemp.Insert;
              end;
          until SeatingWaiterPadLink.Next = 0;

        TemplateFound := false;
        FindForBlankLocation := not SeatingLocationTemp.FindSet;
        if not FindForBlankLocation then
          repeat
            //IF AddPrintTemplatesToBuffer(PrintTemplateBuffer,WaiterPadLine,SeatingLocationTemp,PrintType,PrintCategoryCode) THEN  //NPR5.55 [382428]-revoked
            if AddPrintTemplatesToBuffer(PrintTemplateBuffer, WaiterPadLine, SeatingLocationTemp, PrintType, PrintCategoryCode, ServingStep) then  //NPR5.55 [382428]
              TemplateFound := true
            else
              FindForBlankLocation := true;
          until SeatingLocationTemp.Next = 0;

        if FindForBlankLocation then begin
          Clear(SeatingLocationTemp);
          //IF AddPrintTemplatesToBuffer(PrintTemplateBuffer,WaiterPadLine,SeatingLocationTemp,PrintType,PrintCategoryCode) THEN  //NPR5.55 [382428]-revoked
          if AddPrintTemplatesToBuffer(PrintTemplateBuffer, WaiterPadLine, SeatingLocationTemp, PrintType, PrintCategoryCode, ServingStep) then  //NPR5.55 [382428]
            TemplateFound := true;
        end;
    end;

    local procedure SendToPrint(var PrintTemplateBuffer: Record "NPRE W.Pad Line Output Buffer")
    var
        PrintTemplate: Record "RP Template Header";
        WaiterPad: Record "NPRE Waiter Pad";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        if PrintTemplateBuffer.FindFirst then
          repeat
            PrintTemplateBuffer.SetRecFilter;
            PrintTemplateBuffer.SetRange("Waiter Pad Line No.");

            PrintTemplate.Get(PrintTemplateBuffer."Print Template Code");
            PrintTemplate.CalcFields("Table ID");
            case PrintTemplate."Table ID" of
              DATABASE::"NPRE Waiter Pad": begin
                WaiterPad.Get(PrintTemplateBuffer."Waiter Pad No.");
                WaiterPad.SetRecFilter;
                RPTemplateMgt.PrintTemplate(PrintTemplate.Code,WaiterPad,0);
              end;

              DATABASE::"NPRE Waiter Pad Line": begin
                WaiterPadLine.Reset;
                PrintTemplateBuffer.FindSet;
                repeat
                  WaiterPadLine.Get(PrintTemplateBuffer."Waiter Pad No.",PrintTemplateBuffer."Waiter Pad Line No.");
                  WaiterPadLine.Mark(true);
                  AddComments(WaiterPadLine);
                until PrintTemplateBuffer.Next = 0;
                WaiterPadLine.SetRange("Waiter Pad No.",PrintTemplateBuffer."Waiter Pad No.");
                WaiterPadLine.SetRange("Print Category Filter",PrintTemplateBuffer."Print Category Code");
                WaiterPadLine.MarkedOnly(true);
                RPTemplateMgt.PrintTemplate(PrintTemplate.Code,WaiterPadLine,0);
              end;
            end;

            PrintTemplateBuffer.DeleteAll;
            PrintTemplateBuffer.Reset;
          until not PrintTemplateBuffer.FindFirst;
    end;

    local procedure AddPrintTemplatesToBuffer(var PrintTemplateBuffer: Record "NPRE W.Pad Line Output Buffer";var WaiterPadLine: Record "NPRE Waiter Pad Line";SeatingLocation: Record "NPRE Seating Location";PrintType: Integer;PrintCategoryCode: Code[20];ServingStep: Code[10]): Boolean
    var
        PrintTemplate: Record "NPRE Print Template";
    begin
        PrintTemplate.SetRange("Print Type", PrintType);
        PrintTemplate.SetRange("Seating Location", SeatingLocation.Code);
        PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
        //-NPR5.55 [382428]
        PrintTemplate.SetRange("Restaurant Code", SeatingLocation."Restaurant Code");
        PrintTemplate.SetRange("Serving Step", ServingStep);
        //+NPR5.55 [382428]
        if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
          PrintTemplate.SetRange("Print Category Code", '');
        //-NPR5.55 [382428]
        if PrintTemplate.IsEmpty and (ServingStep <> '') then
          PrintTemplate.SetRange("Serving Step", '');
        if PrintTemplate.IsEmpty and (SeatingLocation."Restaurant Code" <> '') then begin
          PrintTemplate.SetRange("Restaurant Code", '');
          PrintTemplate.SetRange("Serving Step", ServingStep);
          PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
          if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
            PrintTemplate.SetRange("Print Category Code", '');
          if PrintTemplate.IsEmpty and (ServingStep <> '') then
            PrintTemplate.SetRange("Serving Step", '');
        end;
        //+NPR5.55 [382428]
        if not PrintTemplate.FindSet then
          exit(false);
        repeat
          if WaiterPadLine.FindSet then
            repeat
              Clear(PrintTemplateBuffer);  //NPR5.55 [382428]
              PrintTemplateBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
              PrintTemplateBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
              PrintTemplateBuffer."Print Template Code" := PrintTemplate."Template Code";
              //-NPR5.55 [382428]-revoked
              //IF SeatingLocation."Send by Print Category" THEN
              //  PrintTemplateBuffer."Print Category Code" := PrintCategoryCode
              //ELSE
              //  PrintTemplateBuffer."Print Category Code" := '';
              //+NPR5.55 [382428]-revoked
              //-NPR5.55 [382428]
              if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Print Category", PrintTemplate."Split Print Jobs By"::Both] then
                PrintTemplateBuffer."Print Category Code" := PrintCategoryCode;
              if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Serving Step", PrintTemplate."Split Print Jobs By"::Both] then
                PrintTemplateBuffer."Serving Step" := ServingStep;
              //+NPR5.55 [382428]
              if not PrintTemplateBuffer.Find then
                PrintTemplateBuffer.Insert;
            until WaiterPadLine.Next = 0;
        until PrintTemplate.Next = 0;
        exit(true);
    end;

    procedure LogWaiterPadLinePrint(WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusCode: Code[10];PrintCategoryCode: Code[20];PrintDateTime: DateTime;OutputType: Integer)
    var
        NewWPadLinePrintLogEntry: Record "NPRE W.Pad Line Prnt Log Entry";
    begin
        with NewWPadLinePrintLogEntry do begin
          Init;
          "Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
          "Waiter Pad Line No." := WaiterPadLine."Line No.";
          "Print Type" := PrintType;
          "Print Category Code" := PrintCategoryCode;
          "Flow Status Object" := "Flow Status Object"::WaiterPadLineMealFlow;
          "Flow Status Code" := FlowStatusCode;
          "Sent Date-Time" := PrintDateTime;
          "Output Type" := OutputType;
          //-NPR5.55 [399170]-revoked
          //"Entry No." := 0;
          //INSERT;
          //+NPR5.55 [399170]-revoked
        end;

        //-NPR5.55 [399170]
        WaiterPadLine.SetRange("Print Type Filter", NewWPadLinePrintLogEntry."Print Type");
        WaiterPadLine.SetRange("Serving Step Filter", NewWPadLinePrintLogEntry."Flow Status Code");
        WaiterPadLine.SetRange("Print Category Filter", NewWPadLinePrintLogEntry."Print Category Code");
        WaiterPadLine.SetRange("Output Type Filter", NewWPadLinePrintLogEntry."Output Type");
        WaiterPadLine.CalcFields("Sent to Kitchen Qty. (Base)");

        NewWPadLinePrintLogEntry."Sent Quanity (Base)" := WaiterPadLine."Quantity (Base)" - WaiterPadLine."Sent to Kitchen Qty. (Base)";

        InsertWaiterPadLinePrintLogEntry(NewWPadLinePrintLogEntry);
        //+NPR5.55 [399170]
    end;

    procedure InsertWaiterPadLinePrintLogEntry(var NewWPadLinePrintLogEntry: Record "NPRE W.Pad Line Prnt Log Entry")
    begin
        //-NPR5.55 [399170]
        NewWPadLinePrintLogEntry."Entry No." := 0;
        NewWPadLinePrintLogEntry.Insert;
        //+NPR5.55 [399170]
    end;

    procedure SplitWaiterPadLinePrintLogEntries(FromWaiterPadLine: Record "NPRE Waiter Pad Line";NewWaiterPadLine: Record "NPRE Waiter Pad Line";FullLineTransfer: Boolean)
    var
        WPadLinePrintLogEntry: Record "NPRE W.Pad Line Prnt Log Entry";
        NewWPadLinePrintLogEntry: Record "NPRE W.Pad Line Prnt Log Entry";
    begin
        //-NPR5.55 [399170]
        WPadLinePrintLogEntry.SetCurrentKey(
          "Waiter Pad No.","Waiter Pad Line No.","Print Type","Print Category Code","Flow Status Object","Flow Status Code","Output Type");
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", FromWaiterPadLine."Waiter Pad No.");
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", FromWaiterPadLine."Line No.");
        if WPadLinePrintLogEntry.FindSet then
          repeat
            NewWPadLinePrintLogEntry := WPadLinePrintLogEntry;
            if FullLineTransfer then begin
              NewWPadLinePrintLogEntry."Waiter Pad No." := NewWaiterPadLine."Waiter Pad No.";
              NewWPadLinePrintLogEntry."Waiter Pad Line No." := NewWaiterPadLine."Line No.";
              NewWPadLinePrintLogEntry.Modify;
            end else begin
              NewWPadLinePrintLogEntry."Sent Date-Time" := CurrentDateTime;
              NewWPadLinePrintLogEntry."Sent Quanity (Base)" := -NewWaiterPadLine."Quantity (Base)";
              NewWPadLinePrintLogEntry.Context := NewWPadLinePrintLogEntry.Context::"Line Splitting";
              InsertWaiterPadLinePrintLogEntry(NewWPadLinePrintLogEntry);

              NewWPadLinePrintLogEntry."Waiter Pad No." := NewWaiterPadLine."Waiter Pad No.";
              NewWPadLinePrintLogEntry."Waiter Pad Line No." := NewWaiterPadLine."Line No.";
              NewWPadLinePrintLogEntry."Sent Quanity (Base)" := NewWaiterPadLine."Quantity (Base)";
              InsertWaiterPadLinePrintLogEntry(NewWPadLinePrintLogEntry);

              WPadLinePrintLogEntry.SetRange("Print Type", WPadLinePrintLogEntry."Print Type");
              WPadLinePrintLogEntry.SetRange("Print Category Code", WPadLinePrintLogEntry."Print Category Code");
              WPadLinePrintLogEntry.SetRange("Flow Status Object", WPadLinePrintLogEntry."Flow Status Object");
              WPadLinePrintLogEntry.SetRange("Flow Status Code", WPadLinePrintLogEntry."Flow Status Code");
              WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type");
              WPadLinePrintLogEntry.FindLast;
              WPadLinePrintLogEntry.SetRange("Print Type");
              WPadLinePrintLogEntry.SetRange("Print Category Code");
              WPadLinePrintLogEntry.SetRange("Flow Status Object");
              WPadLinePrintLogEntry.SetRange("Flow Status Code");
              WPadLinePrintLogEntry.SetRange("Output Type");
            end;
          until WPadLinePrintLogEntry.Next = 0;
        //+NPR5.55 [399170]
    end;

    procedure RequestRunServingStepToKitchen(var WaiterPad: Record "NPRE Waiter Pad";AutoSelectFlowStatus: Boolean;FlowStatusCode: Code[10])
    var
        FlowStatus: Record "NPRE Flow Status";
    begin
        if AutoSelectFlowStatus then begin
          FlowStatus.SetCurrentKey("Status Object","Flow Order");
          FlowStatus.SetRange("Status Object",FlowStatus."Status Object"::WaiterPadLineMealFlow);
          if WaiterPad."Serving Step Code" = '' then
            FlowStatus.FindFirst
          else begin
            FlowStatus.Get(WaiterPad."Serving Step Code",FlowStatus."Status Object"::WaiterPadLineMealFlow);
            if FlowStatus.Next = 0 then
              Error(NoMoreMealGroupsLbl);
          end;
          FlowStatusCode := FlowStatus.Code;
        end;
        if FlowStatusCode = '' then
          exit;

        SetWaiterPadMealFlowStatus(WaiterPad,FlowStatusCode);

        //PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Serving Request",FlowStatusCode,FALSE);  //NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]
        while not PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Serving Request",FlowStatusCode,false,not AutoSelectFlowStatus) and AutoSelectFlowStatus do begin
          if FlowStatus.Next = 0 then
            Error(NoMoreMealGroupsLbl);
          FlowStatusCode := FlowStatus.Code;
          SetWaiterPadMealFlowStatus(WaiterPad,FlowStatusCode);
        end;

        WaiterPad.CalcFields("Current Seating FF");
        if FlowStatusCode <> FlowStatus.Code then
          FlowStatus.Get(FlowStatusCode,FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatus.Description = '' then
          FlowStatus.Description := FlowStatus.Code;
        Message(ServingReqestedMsg,FlowStatus.Description,WaiterPad."Current Seating FF",WaiterPad."No.");
        //+NPR5.55 [399170]
    end;

    procedure SelectAndRequestRunServingStepToKitchen(var WaiterPad: Record "NPRE Waiter Pad")
    var
        FlowStatus: Record "NPRE Flow Status";
    begin
        FlowStatus.SetCurrentKey("Status Object","Flow Order");
        FlowStatus.SetRange("Status Object",FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if WaiterPad."Serving Step Code" <> '' then
          FlowStatus.Get(WaiterPad."Serving Step Code",FlowStatus."Status Object"::WaiterPadLineMealFlow);

        if PAGE.RunModal(0,FlowStatus) = ACTION::LookupOK then
          RequestRunServingStepToKitchen(WaiterPad,false,FlowStatus.Code);
    end;

    local procedure SetWaiterPadMealFlowStatus(var WaiterPad: Record "NPRE Waiter Pad";NewFlowStatusCode: Code[10])
    var
        FlowStatus: Record "NPRE Flow Status";
        FlowStatusNew: Record "NPRE Flow Status";
    begin
        if NewFlowStatusCode = '' then
          exit;
        if WaiterPad."Serving Step Code" <> '' then
          FlowStatus.Get(WaiterPad."Serving Step Code",FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatusNew.Get(NewFlowStatusCode,FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if (FlowStatusNew."Flow Order" > FlowStatus."Flow Order") or (WaiterPad."Serving Step Code" = '') then
          WaiterPad."Serving Step Code" := NewFlowStatusCode;
        WaiterPad."Last Req. Serving Step Code" := NewFlowStatusCode;
        WaiterPad.Modify;
    end;

    local procedure AddComments(var WaiterPadLine: Record "NPRE Waiter Pad Line")
    var
        WaiterPadLine2: Record "NPRE Waiter Pad Line";
    begin
        WaiterPadLine2.SetRange("Waiter Pad No.",WaiterPadLine."Waiter Pad No.");
        WaiterPadLine2 := WaiterPadLine;
        while (WaiterPadLine2.Next <> 0) and (WaiterPadLine2.Type = WaiterPadLine2.Type::Comment) do begin
          WaiterPadLine := WaiterPadLine2;
          WaiterPadLine.Mark := true;
        end;
    end;

    procedure InitTempPrintCategoryList(var PrintCategoryTmp: Record "NPRE Print/Prod. Category")
    var
        PrintCategory: Record "NPRE Print/Prod. Category";
    begin
        if not PrintCategoryTmp.IsTemporary then
          Error(NotTempErr,'CU6150664.InitTempPrintCategoryList');
        PrintCategoryTmp.Reset;
        PrintCategoryTmp.DeleteAll;
        if PrintCategory.FindSet then
          repeat
            PrintCategoryTmp := PrintCategory;
            PrintCategoryTmp.Insert;
          until PrintCategory.Next = 0;
        PrintCategoryTmp.Init;
        PrintCategoryTmp.Code := '';
        if not PrintCategoryTmp.Find then
          PrintCategoryTmp.Insert;
    end;

    procedure InitTempFlowStatusList(var FlowStatusTmp: Record "NPRE Flow Status";StatusObject: Option)
    var
        FlowStatus: Record "NPRE Flow Status";
    begin
        //-NPR5.55 [382428]
        if not FlowStatusTmp.IsTemporary then
          Error(NotTempErr,'CU6150664.InitTempFlowStatusList');

        FlowStatusTmp.Reset;
        FlowStatusTmp.DeleteAll;

        FlowStatus.SetRange("Status Object", StatusObject);
        if FlowStatus.FindSet then
          repeat
            FlowStatusTmp := FlowStatus;
            FlowStatusTmp.Insert;
          until FlowStatus.Next = 0;

        FlowStatusTmp.Init;
        FlowStatusTmp."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
        FlowStatusTmp.Code := '';
        if not FlowStatusTmp.Find then
          FlowStatusTmp.Insert;
        //+NPR5.55 [382428]
    end;

    procedure SetWaiterPadPreReceiptPrinted(var WaiterPad: Record "NPRE Waiter Pad";Printed: Boolean;ModifyRec: Boolean)
    begin
        //-NPR5.55 [399170]
        WaiterPad."Pre-receipt Printed" := Printed;
        if ModifyRec then
          WaiterPad.Modify;
        //+NPR5.55 [399170]
    end;
}

