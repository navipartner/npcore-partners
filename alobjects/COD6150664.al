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

    procedure PrintWaiterPadPreReceiptPressed(WaiterPad: Record "NPRE Waiter Pad")
    begin
        PrintWaiterPadToPreReceipt(WaiterPad);
    end;

    procedure PrintWaiterPadPreOrderToKitchenPressed(WaiterPad: Record "NPRE Waiter Pad")
    begin
        //-NPR5.53 [360258]-revoked
        //NPHWaiterPadLine.RESET;
        //NPHWaiterPadLine.SETFILTER("Waiter Pad No.",WaiterPad."No.");
        //IF NPHWaiterPadLine.FINDSET THEN BEGIN
        //  NPHWaiterPadLine.MODIFYALL("Sent To. Kitchen Print", FALSE);
        //  PrintWaiterPadToKitchen(WaiterPad);
        //END;
        //+NPR5.53 [360258]-revoked
        PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',true);  //NPR5.53 [360258]
    end;

    procedure LinesAddedToWaiterPad(var WaiterPad: Record "NPRE Waiter Pad")
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
        SeatingLocation: Record "NPRE Seating Location";
        Confirmed: Boolean;
    begin
        //-NPR5.54 [382428]-revoked
        //WaiterPad.CALCFIELDS("Current Seating FF");
        //IF NOT (Seating.GET(WaiterPad."Current Seating FF") AND SeatingLocation.GET(Seating."Seating Location")) THEN
        //  SeatingLocation.INIT;
        //IF SeatingLocation."Auto Send Kitchen Order" = SeatingLocation."Auto Send Kitchen Order"::Default THEN BEGIN
        //  NPHHospitalitySetup.GET;
        //  SeatingLocation."Auto Send Kitchen Order" := NPHHospitalitySetup."Auto Send Kitchen Order" + 1;
        //END;
        //CASE SeatingLocation."Auto Send Kitchen Order" OF
        //+NPR5.54 [382428]-revoked
        //-NPR5.54 [382428]
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        case SetupProxy.AutoSendKitchenOrder of
        //+NPR5.54 [382428]
          SeatingLocation."Auto Send Kitchen Order"::No:
            Confirmed := false;
          SeatingLocation."Auto Send Kitchen Order"::Yes:
            Confirmed := true;
          SeatingLocation."Auto Send Kitchen Order"::Ask:
            Confirmed := Confirm(PrintKitchOderConfMsg,true);
        end;
        if Confirmed then
          //PrintWaiterPadToKitchen(WaiterPad);  //NPR5.53 [360258]-revoked
          PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',false);  //NPR5.53 [360258]
    end;

    local procedure PrintWaiterPadToKitchen(WaiterPad: Record "NPRE Waiter Pad";PrintType: Integer;FlowStatusCode: Code[10];ForceResend: Boolean)
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        //-NPR5.53 [360258]-revoked
        //NPHHospitalitySetup.GET;
        //TMPNPHWaiterPadLine.DELETEALL;
        //TMPNPHWaiterPadLine.RESET;
        //+NPR5.53 [360258]-revoked

        NPHWaiterPadLine.Reset;
        NPHWaiterPadLine.SetRange("Waiter Pad No.",WaiterPad."No.");
        PrintWaiterPadLinesToKitchen(WaiterPad,NPHWaiterPadLine,PrintType,FlowStatusCode,ForceResend);  //NPR5.53 [360258]
        //-NPR5.53 [360258]-revoked
        //NPHWaiterPadLine.SETRANGE("Sent To. Kitchen Print",FALSE);
        //NPHWaiterPadLine.SETCURRENTKEY("Waiter Pad No.", "Print Category", "Line No.");
        //IF NOT NPHWaiterPadLine.ISEMPTY THEN BEGIN
        //  FindAndPrintTemplates(WaiterPad,0);
        //  NPHWaiterPadLine.MODIFYALL("Sent To. Kitchen Print", TRUE);
        //END;
        //+NPR5.53 [360258]-revoked
    end;

    procedure PrintWaiterPadLinesToKitchen(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLineIn: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusCode: Code[10];ForceResend: Boolean)
    var
        FlowStatus: Record "NPRE Flow Status";
        FlowStatusTmp: Record "NPRE Flow Status" temporary;
        PrintCategoryTmp: Record "NPRE Print Category" temporary;
        SeatingLocation: Record "NPRE Seating Location";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        WaiterPadLine2: Record "NPRE Waiter Pad Line";
        WaiterPadLineOut: Record "NPRE Waiter Pad Line";
        PrintTemplateBuffer: Record "NPRE W.Pad Print Buffer" temporary;
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
        PrintCategoryFilter: Text;
        PrintDateTime: DateTime;
        SelectedSendOption: Option Cancel,"Only New",All;
        AskResendConfirmation: Boolean;
        KDSUpdated: Boolean;
    begin
        //-NPR5.54 [382428]
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        if not (SetupProxy.KitchenPrintingActivated or SetupProxy.KDSActivated) then
          exit;

        if not ForceResend then begin
          AskResendConfirmation := SetupProxy.ResendAllOnNewLines = SeatingLocation."Resend All On New Lines"::Ask;
          if not AskResendConfirmation then
            ForceResend := SetupProxy.ResendAllOnNewLines = SeatingLocation."Resend All On New Lines"::Yes;
        end;

        //+NPR5.54 [382428]
        //-NPR5.53 [360258]
        WaiterPadLine.Copy(WaiterPadLineIn);
        WaiterPadLine.FilterGroup(2);
        WaiterPadLine.SetFilter(Type,'<>%1',WaiterPadLine.Type::Comment);
        WaiterPadLine.FilterGroup(0);
        WaiterPadLine.SetAutoCalcFields("No. of Print Categories","Sent to Kitchen");

        PrintTemplateBuffer.DeleteAll;
        FlowStatusTmp.DeleteAll;
        PrintDateTime := CurrentDateTime;
        //AskResendConfirmation := TRUE;  //NPR5.54 [382428]-revoked

        FlowStatus.SetRange("Status Object",FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatusCode <> '' then
          FlowStatus.SetRange(Code,FlowStatusCode);
        if FlowStatus.FindSet then
          repeat
            FlowStatusTmp := FlowStatus;
            FlowStatusTmp.Insert;
          until FlowStatus.Next = 0;
        if FlowStatusCode = '' then begin
          FlowStatusTmp.Init;
          FlowStatusTmp."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
          FlowStatusTmp.Code := '';
          FlowStatusTmp.Insert;
        end;

        InitTempPrintCategoryList(PrintCategoryTmp);  //NPR5.54 [392956]

        if FlowStatusTmp.FindSet then
          repeat
            PrintCategoryFilter := FlowStatusTmp.AssignedPrintCategoriesAsFilterString();
            //-NPR5.54 [392956]-revoked
            //IF PrintCategoryFilter <> '' THEN BEGIN
            //  PrintCategory.SETFILTER(Code,PrintCategoryFilter);
            //  IF PrintCategory.FINDSET THEN
            //+NPR5.54 [392956]-revoked
            //-NPR5.54 [392956]
            if (PrintCategoryFilter <> '') or (FlowStatusTmp.Code = '') then begin
              if PrintCategoryFilter <> '' then
                PrintCategoryTmp.SetFilter(Code,PrintCategoryFilter)
              else
                PrintCategoryTmp.SetRange(Code,'');
              if PrintCategoryTmp.FindSet then
            //+NPR5.54 [392956]
                repeat
                  WaiterPadLine.SetRange("Print Category Filter",PrintCategoryTmp.Code);
                  WaiterPadLine.SetRange("Meal Flow Status Filter",FlowStatusTmp.Code);
                  WaiterPadLine.SetRange("Print Type Filter",PrintType);
                  if WaiterPadLine.FindSet then
                    repeat
                      if AskResendConfirmation and not ForceResend and WaiterPadLine."Sent to Kitchen" then begin
                        AskResendConfirmation := false;
                        SelectedSendOption :=
                          StrMenu(ResendOptions,1,
                            StrSubstNo(LinesHaveAlreadyBeenSent,WaiterPad.FieldCaption("Serving Step Code"),FlowStatusTmp.Code,PrintCategoryTmp.TableCaption,PrintCategoryTmp.Code));
                        if SelectedSendOption = SelectedSendOption::Cancel then
                          Error('');
                        ForceResend := SelectedSendOption = SelectedSendOption::All;
                      end;
                      //-NPR5.54 [392956]
                      WaiterPadLine2.Copy(WaiterPadLine);
                      WaiterPadLine2.SetRange("Print Category Filter");
                      WaiterPadLine2.CalcFields("No. of Print Categories");
                      if ((WaiterPadLine."No. of Print Categories" > 0) or
                          ((WaiterPadLine2."No. of Print Categories" = 0) and (PrintCategoryTmp.Code = '')))
                         and
                      //+NPR5.54 [392956]
                      //IF (WaiterPadLine."No. of Print Categories" > 0) AND  //NPR5.54 [392956]-revoked
                         (not WaiterPadLine."Sent to Kitchen" or ForceResend)
                      then begin
                        WaiterPadLineOut := WaiterPadLine;
                        WaiterPadLineOut.Mark := true;
                      end;
                    until WaiterPadLine.Next = 0;

                  WaiterPadLineOut.MarkedOnly(true);
                  if not WaiterPadLineOut.IsEmpty then begin  //NPR5.54 [382428] - BEGIN added
                    if SetupProxy.KitchenPrintingActivated then  //NPR5.54 [382428]
                      if FindPrintTemplates(WaiterPad,WaiterPadLineOut,PrintType,PrintCategoryTmp.Code,PrintTemplateBuffer) then begin
                        WaiterPadLineOut.FindSet;
                        repeat
                          //LogWaiterPadLinePrint(WaiterPadLineOut,PrintType,FlowStatusTmp."Status Object",FlowStatusTmp.Code,PrintCategoryTmp.Code,PrintDateTime);  //NPR5.54 [382428]-revoked
                          LogWaiterPadLinePrint(WaiterPadLineOut,PrintType,FlowStatusTmp.Code,PrintCategoryTmp.Code,PrintDateTime,0);  //NPR5.54 [382428]
                        until WaiterPadLineOut.Next = 0;
                      end;

                  //-NPR5.54 [382428]
                    if SetupProxy.KDSActivated then
                      KDSUpdated := KitchenOrderMgt.SendWPLinesToKitchen(WaiterPadLineOut,FlowStatusTmp.Code,PrintCategoryTmp.Code,PrintType,PrintDateTime) or KDSUpdated;
                  end;
                  //+NPR5.54 [382428]
                  WaiterPadLineOut.Reset;
                until PrintCategoryTmp.Next = 0;
            end;
          until FlowStatusTmp.Next = 0;

        //IF PrintTemplateBuffer.ISEMPTY THEN BEGIN  //NPR5.54 [382428]-revoked
        if PrintTemplateBuffer.IsEmpty and not KDSUpdated then begin  //NPR5.54 [382428]
          Message(NothingToSendLbl);
          exit;
        end;

        SendToPrint(PrintTemplateBuffer);
        //+NPR5.53 [360258]
    end;

    local procedure PrintWaiterPadToPreReceipt(var WaiterPad: Record "NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        //FindAndPrintTemplates(WaiterPad,1);  //NPR5.53 [360258]-revoked
        //-NPR5.53 [360258]
        WaiterPadLine.SetRange("Waiter Pad No.",WaiterPad."No.");
        FindAndPrintTemplates(WaiterPad,WaiterPadLine,GlobalPrintTemplate."Print Type"::"Pre Receipt",'');
        //+NPR5.53 [360258]
    end;

    local procedure FindAndPrintTemplates(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;PrintCategoryCode: Code[20])
    var
        PrintTemplateBuffer: Record "NPRE W.Pad Print Buffer" temporary;
    begin
        //-NPR5.53 [360258]-revoked
        /*
        NPRESeatingWaiterPadLink.SETRANGE("Waiter Pad No.",WaiterPad."No.");
        IF NPRESeatingWaiterPadLink.FINDSET THEN
          REPEAT
            IF NPRESeating.GET(NPRESeatingWaiterPadLink."Seating Code") THEN
              IF NPRESeating."Seating Location" <> '' THEN BEGIN
                TempSeatingLocation.Code := NPRESeating."Seating Location";
                TempSeatingLocation.INSERT;
              END;
          UNTIL NPRESeatingWaiterPadLink.NEXT = 0;
        
        IF TempSeatingLocation.FINDSET THEN
          REPEAT
            NPREPrintTemplate.SETRANGE("Print Type",PrintType);
            NPREPrintTemplate.SETRANGE("Seating Location",TempSeatingLocation.Code);
            IF NPREPrintTemplate.FINDSET THEN
              REPEAT
                TempTemplateHeader.Code := NPREPrintTemplate."Template Code";
                IF TempTemplateHeader.INSERT THEN;
              UNTIL NPREPrintTemplate.NEXT = 0
            ELSE
              FindForBlankLocation := TRUE;
          UNTIL TempSeatingLocation.NEXT = 0
        ELSE
          FindForBlankLocation := TRUE;
        IF FindForBlankLocation THEN BEGIN
          NPREPrintTemplate.SETRANGE("Print Type",PrintType);
          NPREPrintTemplate.SETRANGE("Seating Location",'');
          IF NPREPrintTemplate.FINDSET THEN
            REPEAT
              TempTemplateHeader.Code := NPREPrintTemplate."Template Code";
              IF TempTemplateHeader.INSERT THEN;
            UNTIL NPREPrintTemplate.NEXT = 0
        END;
        IF TempTemplateHeader.FINDSET THEN
          REPEAT
            IF TempTemplateHeader.Code <> '' THEN BEGIN
              NPREWaiterPad.COPY(WaiterPad);
              NPREWaiterPad.SETRECFILTER;
              RPTemplateMgt.PrintTemplate(TempTemplateHeader.Code, NPREWaiterPad, 0);
              CLEAR(NPREWaiterPad);
            END;
          UNTIL TempTemplateHeader.NEXT = 0;
        */
        //+NPR5.53 [360258]-revoked
        //-NPR5.53 [360258]
        PrintTemplateBuffer.DeleteAll;
        if FindPrintTemplates(WaiterPad,WaiterPadLine,PrintType,PrintCategoryCode,PrintTemplateBuffer) then
          SendToPrint(PrintTemplateBuffer);
        //+NPR5.53 [360258]

    end;

    local procedure FindPrintTemplates(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;PrintCategoryCode: Code[20];var PrintTemplateBuffer: Record "NPRE W.Pad Print Buffer") TemplateFound: Boolean
    var
        Seating: Record "NPRE Seating";
        SeatingLocation: Record "NPRE Seating Location";
        SeatingLocationTemp: Record "NPRE Seating Location" temporary;
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        FindForBlankLocation: Boolean;
    begin
        //-NPR5.53 [360258]
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
            if AddPrintTemplatesToBuffer(PrintTemplateBuffer,WaiterPadLine,SeatingLocationTemp,PrintType,PrintCategoryCode) then
              TemplateFound := true
            else
              FindForBlankLocation := true;
          until SeatingLocationTemp.Next = 0;

        if FindForBlankLocation then begin
          Clear(SeatingLocationTemp);
          if AddPrintTemplatesToBuffer(PrintTemplateBuffer,WaiterPadLine,SeatingLocationTemp,PrintType,PrintCategoryCode) then
            TemplateFound := true;
        end;
        //+NPR5.53 [360258]
    end;

    local procedure SendToPrint(var PrintTemplateBuffer: Record "NPRE W.Pad Print Buffer")
    var
        PrintTemplate: Record "RP Template Header";
        WaiterPad: Record "NPRE Waiter Pad";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        //-NPR5.53 [360258]
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
        //+NPR5.53 [360258]
    end;

    local procedure AddPrintTemplatesToBuffer(var PrintTemplateBuffer: Record "NPRE W.Pad Print Buffer";var WaiterPadLine: Record "NPRE Waiter Pad Line";SeatingLocation: Record "NPRE Seating Location";PrintType: Integer;PrintCategoryCode: Code[20]): Boolean
    var
        PrintTemplate: Record "NPRE Print Template";
    begin
        //-NPR5.53 [360258]
        PrintTemplate.SetRange("Print Type",PrintType);
        PrintTemplate.SetRange("Seating Location",SeatingLocation.Code);
        PrintTemplate.SetRange("Print Category Code",PrintCategoryCode);
        if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
          PrintTemplate.SetRange("Print Category Code",'');
        if not PrintTemplate.FindSet then
          exit(false);
        repeat
          if WaiterPadLine.FindSet then
            repeat
              PrintTemplateBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
              PrintTemplateBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
              PrintTemplateBuffer."Print Template Code" := PrintTemplate."Template Code";
              if SeatingLocation."Send by Print Category" then
                PrintTemplateBuffer."Print Category Code" := PrintCategoryCode
              else
                PrintTemplateBuffer."Print Category Code" := '';
              if not PrintTemplateBuffer.Find then
                PrintTemplateBuffer.Insert;
            until WaiterPadLine.Next = 0;
        until PrintTemplate.Next = 0;
        exit(true);
        //+NPR5.53 [360258]
    end;

    procedure LogWaiterPadLinePrint(WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusCode: Code[10];PrintCategoryCode: Code[20];PrintDateTime: DateTime;OutputType: Integer)
    var
        WPadLinePrintLogEntry: Record "NPRE W.Pad Line Prnt Log Entry";
    begin
        //-NPR5.53 [360258]
        WPadLinePrintLogEntry.Init;
        WPadLinePrintLogEntry."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
        WPadLinePrintLogEntry."Waiter Pad Line No." := WaiterPadLine."Line No.";
        WPadLinePrintLogEntry."Print Type" := PrintType;
        WPadLinePrintLogEntry."Print Category Code" := PrintCategoryCode;
        WPadLinePrintLogEntry."Flow Status Object" := WPadLinePrintLogEntry."Flow Status Object"::WaiterPadLineMealFlow;
        WPadLinePrintLogEntry."Flow Status Code" := FlowStatusCode;
        WPadLinePrintLogEntry."Sent Date-Time" := PrintDateTime;
        WPadLinePrintLogEntry."Output Type" := OutputType;  //NPR5.54 [382428]
        WPadLinePrintLogEntry."Entry No." := 0;
        WPadLinePrintLogEntry.Insert;
        //+NPR5.53 [360258]
    end;

    procedure RequestRunServingStepToKitchen(var WaiterPad: Record "NPRE Waiter Pad";AutoSelectFlowStatus: Boolean;FlowStatusCode: Code[10])
    var
        FlowStatus: Record "NPRE Flow Status";
    begin
        //-NPR5.53 [360258]
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

        PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Serving Request",FlowStatusCode,false);
        //+NPR5.53 [360258]
    end;

    procedure SelectAndRequestRunServingStepToKitchen(var WaiterPad: Record "NPRE Waiter Pad")
    var
        FlowStatus: Record "NPRE Flow Status";
    begin
        //-NPR5.53 [360258]
        FlowStatus.SetCurrentKey("Status Object","Flow Order");
        FlowStatus.SetRange("Status Object",FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if WaiterPad."Serving Step Code" <> '' then
          FlowStatus.Get(WaiterPad."Serving Step Code",FlowStatus."Status Object"::WaiterPadLineMealFlow);

        if PAGE.RunModal(0,FlowStatus) = ACTION::LookupOK then
          RequestRunServingStepToKitchen(WaiterPad,false,FlowStatus.Code);
        //+NPR5.53 [360258]
    end;

    local procedure SetWaiterPadMealFlowStatus(var WaiterPad: Record "NPRE Waiter Pad";NewFlowStatusCode: Code[10])
    var
        FlowStatus: Record "NPRE Flow Status";
        FlowStatusNew: Record "NPRE Flow Status";
    begin
        //-NPR5.53 [360258]
        if NewFlowStatusCode = '' then
          exit;
        if WaiterPad."Serving Step Code" <> '' then
          FlowStatus.Get(WaiterPad."Serving Step Code",FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatusNew.Get(NewFlowStatusCode,FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if (FlowStatusNew."Flow Order" > FlowStatus."Flow Order") or (WaiterPad."Serving Step Code" = '') then
          WaiterPad."Serving Step Code" := NewFlowStatusCode;
        WaiterPad."Last Req. Serving Step Code" := NewFlowStatusCode;
        WaiterPad.Modify;
        //+NPR5.53 [360258]
    end;

    local procedure AddComments(var WaiterPadLine: Record "NPRE Waiter Pad Line")
    var
        WaiterPadLine2: Record "NPRE Waiter Pad Line";
    begin
        //-NPR5.53 [360258]
        WaiterPadLine2.SetRange("Waiter Pad No.",WaiterPadLine."Waiter Pad No.");
        WaiterPadLine2 := WaiterPadLine;
        while (WaiterPadLine2.Next <> 0) and (WaiterPadLine2.Type = WaiterPadLine2.Type::Comment) do begin
          WaiterPadLine := WaiterPadLine2;
          WaiterPadLine.Mark := true;
        end;
        //+NPR5.53 [360258]
    end;

    procedure InitTempPrintCategoryList(var PrintCategoryTmp: Record "NPRE Print Category")
    var
        PrintCategory: Record "NPRE Print Category";
    begin
        //-NPR5.54 [392956]
        if not PrintCategoryTmp.IsTemporary then
          Error('CU6150664.InitTempPrintCategoryList must be called with temporary record set as parameter');
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
        //-NPR5.54 [392956]
    end;
}

