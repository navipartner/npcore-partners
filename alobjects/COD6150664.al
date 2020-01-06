codeunit 6150664 "NPRE Restaurant Print"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/MMV /20170726 CASE 285002 Refactored kitchen print.
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO /20180412 CASE 309873 Print Templates moved to seperate table
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kintchen order'


    trigger OnRun()
    begin
    end;

    var
        ERRPrint: Label '%1 fcn. Print - Variant must be Record or Recordref';
        PrintKitchOderConfMsg: Label 'Do you want to send the order to the kitchen now?';

    procedure PrintWaiterPadPreReceiptPressed(WaiterPad: Record "NPRE Waiter Pad")
    begin
        PrintWaiterPadToPreReceipt(WaiterPad);
    end;

    procedure PrintFullWaiterPadToKitchenPressed(WaiterPad: Record "NPRE Waiter Pad")
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        NPHWaiterPadLine.Reset;
        NPHWaiterPadLine.SetFilter("Waiter Pad No.", WaiterPad."No.");
        if NPHWaiterPadLine.FindSet then begin
          NPHWaiterPadLine.ModifyAll("Sent To. Kitchen Print", false);
          PrintWaiterPadToKitchen(WaiterPad);

        end;
    end;

    procedure LinesAddedToWaiterPad(var WaiterPad: Record "NPRE Waiter Pad")
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
        NPHHospitalitySetup: Record "NPRE Restaurant Setup";
        Seating: Record "NPRE Seating";
        SeatingLocation: Record "NPRE Seating Location";
        Confirmed: Boolean;
    begin
        //-NPR5.52 [360258]-revoked
        //NPHHospitalitySetup.GET;

        //IF NPHHospitalitySetup."Auto Print Kitchen Order" THEN PrintWaiterPadToKitchen(WaiterPad);
        //+NPR5.52 [360258]-revoked

        //-NPR5.52 [360258]
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
          PrintWaiterPadToKitchen(WaiterPad);
        //+NPR5.52 [360258]
    end;

    local procedure PrintWaiterPadToKitchen(WaiterPad: Record "NPRE Waiter Pad")
    var
        NPHWaiterPad: Record "NPRE Waiter Pad";
        NPHPrintCategory: Record "NPRE Print Category";
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
        PrintCategory: Code[10];
        TMPNPHWaiterPadLine: Record "NPRE Waiter Pad Line" temporary;
        NPHHospitalitySetup: Record "NPRE Restaurant Setup";
        RPTemplateHeader: Record "RP Template Header";
        RecordSend: Variant;
        MoreRecords: Boolean;
        RPTemplateMgt: Codeunit "RP Template Mgt.";
        PrintTemplate: Code[20];
        NewCategory: Boolean;
    begin
        NPHHospitalitySetup.Get;
        TMPNPHWaiterPadLine.DeleteAll;
        TMPNPHWaiterPadLine.Reset;

        NPHWaiterPadLine.Reset;
        NPHWaiterPadLine.SetFilter("Waiter Pad No.", '=%1', WaiterPad."No.");
        NPHWaiterPadLine.SetFilter("Sent To. Kitchen Print", '%1', false);
        NPHWaiterPadLine.SetCurrentKey("Waiter Pad No.", "Print Category", "Line No.");
        //-NPR5.41 [309873]
        //-NPR5.34 [285002]
        // IF NPHWaiterPadLine.FINDSET THEN BEGIN
        //  REPEAT
        //    PrintCategory := NPHWaiterPadLine."Print Category";
        //    MoreRecords := NPHWaiterPadLine.NEXT <> 0;
        //    NewCategory := PrintCategory <> NPHWaiterPadLine."Print Category";
        //    IF NewCategory OR (NOT MoreRecords) THEN BEGIN //Print the previously iterated print category
        //      IF PrintCategory = '' THEN
        //        PrintTemplate := NPHHospitalitySetup."Kitchen Order Template"
        //      ELSE BEGIN
        //        NPHPrintCategory.GET(PrintCategory);
        //        PrintTemplate := NPHPrintCategory."Kitchen Order Template";
        //      END;
        //      IF PrintTemplate <> '' THEN BEGIN //blank = no print
        //        NPHWaiterPad.COPY(WaiterPad);
        //        NPHWaiterPad.SETRECFILTER;
        //        NPHWaiterPad.SETFILTER("Print Category Filter", '=%1', PrintCategory);
        //        RPTemplateMgt.PrintTemplate(PrintTemplate, NPHWaiterPad, 0);
        //        CLEAR(NPHWaiterPad);
        //      END;
        //    END;
        //  UNTIL NOT MoreRecords;
        //
        //  FindAndPrintTemplates(WaiterPad,0)
        //
        //  NPHWaiterPadLine.MODIFYALL("Sent To. Kitchen Print", TRUE);
        // END;
        //+NPR5.34 [285002]
        if not NPHWaiterPadLine.IsEmpty then begin
          FindAndPrintTemplates(WaiterPad,0);
          NPHWaiterPadLine.ModifyAll("Sent To. Kitchen Print", true);
        end;
        //+NPR5.41 [309873]
    end;

    local procedure PrintWaiterPadToPreReceipt(var WaiterPad: Record "NPRE Waiter Pad")
    var
        NPHHospitalitySetup: Record "NPRE Restaurant Setup";
        RecordSend: Variant;
        RPTemplateHeader: Record "RP Template Header";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        //-NPR5.41 [309873]
        // NPHHospitalitySetup.GET;
        // NPHHospitalitySetup.TESTFIELD("Pre Receipt Template");
        // RPTemplateHeader.GET(NPHHospitalitySetup."Pre Receipt Template");
        // WaiterPad.SETRECFILTER;
        //
        // RecordSend := WaiterPad;
        //
        // //-NPR5.34 [285002]
        // //Print(RPTemplateHeader.Code, RecordSend);
        // RPTemplateMgt.PrintTemplate(RPTemplateHeader.Code, RecordSend, 0);
        // //+NPR5.34 [285002]
        FindAndPrintTemplates(WaiterPad,1);
        //+NPR5.41 [309873]
    end;

    local procedure FindAndPrintTemplates(WaiterPad: Record "NPRE Waiter Pad";PrintType: Option Kitchen,PreReceipt)
    var
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        NPRESeating: Record "NPRE Seating";
        TempSeatingLocation: Record "NPRE Seating Location" temporary;
        NPREPrintTemplate: Record "NPRE Print Template";
        TempTemplateHeader: Record "RP Template Header" temporary;
        NPREWaiterPad: Record "NPRE Waiter Pad";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
        FindForBlankLocation: Boolean;
    begin
        //-NPR5.41 [309873]
        NPRESeatingWaiterPadLink.SetRange("Waiter Pad No.",WaiterPad."No.");
        if NPRESeatingWaiterPadLink.FindSet then
          repeat
            if NPRESeating.Get(NPRESeatingWaiterPadLink."Seating Code") then
              if NPRESeating."Seating Location" <> '' then begin
                TempSeatingLocation.Code := NPRESeating."Seating Location";
                TempSeatingLocation.Insert;
              end;
          until NPRESeatingWaiterPadLink.Next = 0;

        if TempSeatingLocation.FindSet then
          repeat
            NPREPrintTemplate.SetRange("Print Type",PrintType);
            NPREPrintTemplate.SetRange("Seating Location",TempSeatingLocation.Code);
            if NPREPrintTemplate.FindSet then
              repeat
                TempTemplateHeader.Code := NPREPrintTemplate."Template Code";
                if TempTemplateHeader.Insert then;
              until NPREPrintTemplate.Next = 0
            else
              FindForBlankLocation := true;
          until TempSeatingLocation.Next = 0
        else
          FindForBlankLocation := true;
        if FindForBlankLocation then begin
          NPREPrintTemplate.SetRange("Print Type",PrintType);
          NPREPrintTemplate.SetRange("Seating Location",'');
          if NPREPrintTemplate.FindSet then
            repeat
              TempTemplateHeader.Code := NPREPrintTemplate."Template Code";
              if TempTemplateHeader.Insert then;
            until NPREPrintTemplate.Next = 0
        end;
        if TempTemplateHeader.FindSet then
          repeat
            if TempTemplateHeader.Code <> '' then begin
              NPREWaiterPad.Copy(WaiterPad);
              NPREWaiterPad.SetRecFilter;
              RPTemplateMgt.PrintTemplate(TempTemplateHeader.Code, NPREWaiterPad, 0);
              Clear(NPREWaiterPad);
            end;
          until TempTemplateHeader.Next = 0;
        //+NPR5.41 [309873]
    end;
}

