codeunit 6150664 "NPRE Restaurant Print"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/MMV /20170726 CASE 285002 Refactored kitchen print.
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412 CASE 309873 Print Templates moved to seperate table
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kintchen order'
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
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
        NPHHospitalitySetup: Record "NPRE Restaurant Setup";
        Seating: Record "NPRE Seating";
        SeatingLocation: Record "NPRE Seating Location";
        Confirmed: Boolean;
    begin
        WaiterPad.CalcFields("Current Seating FF");
        if not (Seating.Get(WaiterPad."Current Seating FF") and SeatingLocation.Get(Seating."Seating Location")) then
          SeatingLocation.Init;
        if SeatingLocation."Auto Print Kitchen Order" = SeatingLocation."Auto Print Kitchen Order"::Default then begin
          NPHHospitalitySetup.Get;
          SeatingLocation."Auto Print Kitchen Order" := NPHHospitalitySetup."Auto Print Kitchen Order" + 1;
        end;
        case SeatingLocation."Auto Print Kitchen Order" of
          SeatingLocation."Auto Print Kitchen Order"::No:
            Confirmed := false;
          SeatingLocation."Auto Print Kitchen Order"::Yes:
            Confirmed := true;
          SeatingLocation."Auto Print Kitchen Order"::Ask:
            Confirmed := Confirm(PrintKitchOderConfMsg,true);
        end;
        if Confirmed then
          //PrintWaiterPadToKitchen(WaiterPad);  //NPR5.53 [360258]-revoked
          PrintWaiterPadToKitchen(WaiterPad,GlobalPrintTemplate."Print Type"::"Kitchen Order",'',false);  //NPR5.53 [360258]
    end;

    local procedure PrintWaiterPadToKitchen(WaiterPad: Record "NPRE Waiter Pad";PrintType: Integer;FlowStatusCode: Code[10];Resend: Boolean)
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
        PrintWaiterPadLinesToKitchen(WaiterPad,NPHWaiterPadLine,PrintType,FlowStatusCode,Resend);  //NPR5.53 [360258]
        //-NPR5.53 [360258]-revoked
        //NPHWaiterPadLine.SETRANGE("Sent To. Kitchen Print",FALSE);
        //NPHWaiterPadLine.SETCURRENTKEY("Waiter Pad No.", "Print Category", "Line No.");
        //IF NOT NPHWaiterPadLine.ISEMPTY THEN BEGIN
        //  FindAndPrintTemplates(WaiterPad,0);
        //  NPHWaiterPadLine.MODIFYALL("Sent To. Kitchen Print", TRUE);
        //END;
        //+NPR5.53 [360258]-revoked
    end;

    procedure PrintWaiterPadLinesToKitchen(WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLineIn: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusCode: Code[10];Resend: Boolean)
    var
        FlowStatus: Record "NPRE Flow Status";
        FlowStatusTmp: Record "NPRE Flow Status" temporary;
        PrintCategory: Record "NPRE Print Category";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        WaiterPadLineOut: Record "NPRE Waiter Pad Line";
        PrintTemplateBuffer: Record "NPRE W.Pad Print Buffer" temporary;
        PrintCategoryFilter: Text;
        PrintDateTime: DateTime;
        SelectedSendOption: Option Cancel,"Only New",All;
        AskResendConfirmation: Boolean;
    begin
        //-NPR5.53 [360258]
        WaiterPadLine.Copy(WaiterPadLineIn);
        WaiterPadLine.FilterGroup(2);
        WaiterPadLine.SetFilter(Type,'<>%1',WaiterPadLine.Type::Comment);
        WaiterPadLine.FilterGroup(0);
        WaiterPadLine.SetAutoCalcFields("No. of Print Categories","Sent to Kitchen");

        PrintTemplateBuffer.DeleteAll;
        FlowStatusTmp.DeleteAll;
        PrintDateTime := CurrentDateTime;
        AskResendConfirmation := true;

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

        if FlowStatusTmp.FindSet then
          repeat
            PrintCategoryFilter := FlowStatusTmp.AssignedPrintCategoriesAsFilterString();
            if PrintCategoryFilter <> '' then begin
              PrintCategory.SetFilter(Code,PrintCategoryFilter);
              if PrintCategory.FindSet then
                repeat
                  WaiterPadLine.SetRange("Print Category Filter",PrintCategory.Code);
                  WaiterPadLine.SetRange("Meal Flow Status Filter",FlowStatusTmp.Code);
                  WaiterPadLine.SetRange("Print Type Filter",PrintType);
                  if WaiterPadLine.FindSet then
                    repeat
                      if AskResendConfirmation and not Resend and WaiterPadLine."Sent to Kitchen" then begin
                        AskResendConfirmation := false;
                        SelectedSendOption :=
                          StrMenu(ResendOptions,1,
                            StrSubstNo(LinesHaveAlreadyBeenSent,WaiterPad.FieldCaption("Serving Step Code"),FlowStatusTmp.Code,PrintCategory.TableCaption,PrintCategory.Code));
                        if SelectedSendOption = SelectedSendOption::Cancel then
                          Error('');
                        Resend := SelectedSendOption = SelectedSendOption::All;
                      end;
                      if (WaiterPadLine."No. of Print Categories" > 0) and
                         (not WaiterPadLine."Sent to Kitchen" or Resend)
                      then begin
                        WaiterPadLineOut := WaiterPadLine;
                        WaiterPadLineOut.Mark := true;
                      end;
                    until WaiterPadLine.Next = 0;

                  WaiterPadLineOut.MarkedOnly(true);
                  if not WaiterPadLineOut.IsEmpty then
                    if FindPrintTemplates(WaiterPad,WaiterPadLineOut,PrintType,PrintCategory.Code,PrintTemplateBuffer) then begin
                      WaiterPadLineOut.FindSet;
                      repeat
                        LogWaiterPadLinePrint(WaiterPadLineOut,PrintType,FlowStatusTmp."Status Object",FlowStatusTmp.Code,PrintCategory.Code,PrintDateTime);
                      until WaiterPadLineOut.Next = 0;
                    end;
                  WaiterPadLineOut.Reset;
                until PrintCategory.Next = 0;
            end;
          until FlowStatusTmp.Next = 0;

        if PrintTemplateBuffer.IsEmpty then begin
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
              if SeatingLocation."Send by Prnt Category" then
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

    procedure LogWaiterPadLinePrint(WaiterPadLine: Record "NPRE Waiter Pad Line";PrintType: Integer;FlowStatusObject: Integer;FlowStatusCode: Code[10];PrintCategoryCode: Code[20];PrintDateTime: DateTime)
    var
        WPadLinePrintLogEntry: Record "NPRE W.Pad Line Prnt Log Entry";
    begin
        //-NPR5.53 [360258]
        WPadLinePrintLogEntry.Init;
        WPadLinePrintLogEntry."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
        WPadLinePrintLogEntry."Waiter Pad Line No." := WaiterPadLine."Line No.";
        WPadLinePrintLogEntry."Print Type" := PrintType;
        WPadLinePrintLogEntry."Print Category Code" := PrintCategoryCode;
        WPadLinePrintLogEntry."Flow Status Object" := FlowStatusObject;
        WPadLinePrintLogEntry."Flow Status Code" := FlowStatusCode;
        WPadLinePrintLogEntry."Sent Date-Time" := PrintDateTime;
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
}

