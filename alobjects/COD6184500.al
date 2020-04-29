codeunit 6184500 "CleanCash Wrapper"
{
    // NPR4.21/JHL/20160302 CASE 222417 Created for wrapping CleanCash for the uses of only Swedish customer
    // NPR5.26/JHL/20160711 CASE 242776 Out comment the functionality to check the connection.
    // NPR5.26/JHL/20160916 CASE 244106 Handling the print function for CleanCash as subscriber to event publish by CU 6014560
    //                           The functions InitCleanCashData, GetLines and GetCleanCashInformation is changed to local function
    // NPR5.32/MMV /20170511 CASE 241995 Retail Print 2.0: Added OnReceiptFooter() subscriber for new receipt footer event.
    // NPR5.39/MHA /20180202  CASE 302779 Added OnFinishSale POS Workflow and deleted deprecated function CreateOnSaleCleanCashWrapper()
    // NPR5.40/MMV /20180208  CASE 304639 Changed event signature of OnReceiptFooter()

    TableNo = "Audit Roll";

    trigger OnRun()
    var
        "Object": Record "Object";
        LastSalesTicketNo: Code[20];
    begin
        //-NPR5.26
        //IF NOT IsCleanCashPossible THEN
        //  EXIT;

        //AuditRoll.COPY(Rec);
        //IF NOT IsRegisterCleanCash(AuditRoll) THEN
        //  EXIT;

        //RunSalesTicket();
        //+NPR5.26
    end;

    var
        CleanCashCommunication: Codeunit "CleanCash Communication";
        CleanCashAuditRoll: Record "CleanCash Audit Roll";
        LastReceiptNo: Code[10];
        Text000: Label 'Create Sales in CleanCash';

    local procedure RunSalesTicket(var AuditRoll: Record "Audit Roll")
    var
        CleanCashAuditRollMgt: Codeunit "CleanCash AuditRoll Mgt.";
        AuditRoll2: Record "Audit Roll";
    begin
        AuditRoll2.Copy(AuditRoll);
        CleanCashAuditRollMgt.Run(AuditRoll2);
    end;

    procedure RunMissingSalesTicket()
    begin
        if not IsCleanCashPossible then
          exit;

        CleanCashCommunication.RunMultiSalesTicket();
    end;

    procedure TestConnection(RegisterNo: Code[20])
    begin
        if not IsCleanCashPossible then
          exit;

        //-NPR5.26
        //CleanCashCommunication.CheckConnection(RegisterNo);
        //+NPR5.26
    end;

    local procedure InitCleanCashData(var AuditRoll2: Record "Audit Roll"): Boolean
    begin
        //-NPR5.26
        //IF NOT IsCleanCashPossible THEN
        //  EXIT(FALSE);

        //+NPR5.26
        CleanCashAuditRoll.SetRange("Register No.", AuditRoll2."Register No.");
        CleanCashAuditRoll.SetRange("Sales Ticket No.", AuditRoll2."Sales Ticket No.");
        CleanCashAuditRoll.SetRange("Sale Date", AuditRoll2."Sale Date");
        if not CleanCashAuditRoll.FindSet then
          if not IsRegisterCleanCash(AuditRoll2) then
            exit(false);

        LastReceiptNo := '0';
        exit(true);
    end;

    local procedure GetLines(): Integer
    begin
        exit(CleanCashAuditRoll.Count);
    end;

    local procedure GetCleanCashInformation(var ReceiptNo: Code[10];var SerialNo: Text[30];var ControlCode: Text[100];var CopySerialNo: Text[30];var CopyControlCode: Text[100])
    var
        Stop: Boolean;
    begin
        ReceiptNo := '';
        SerialNo := '';
        ControlCode := '';
        CopySerialNo := '';
        CopyControlCode := '';


        Stop := false;
        if CleanCashAuditRoll.FindSet then
          repeat
            if LastReceiptNo <> CleanCashAuditRoll."CleanCash Reciept No." then begin
              Stop := true;
              LastReceiptNo := CleanCashAuditRoll."CleanCash Reciept No.";
              ReceiptNo :=   CleanCashAuditRoll."CleanCash Reciept No.";
              SerialNo := CleanCashAuditRoll."CleanCash Serial No.";
              ControlCode := CleanCashAuditRoll."CleanCash Control Code";
              CopySerialNo := CleanCashAuditRoll."CleanCash Copy Serial No.";
              CopyControlCode := CleanCashAuditRoll."CleanCash Copy Control Code";
            end;
          until (CleanCashAuditRoll.Next = 0) or Stop;
    end;

    local procedure IsRegisterCleanCash(var AuditRoll2: Record "Audit Roll"): Boolean
    var
        CleanCashRegister: Record "CleanCash Register";
    begin
        CleanCashRegister.SetRange("Register No.", AuditRoll2."Register No.");
        CleanCashRegister.SetRange("CleanCash Integration",true);
        if CleanCashRegister.FindFirst then
          exit(true);
        exit(false);
    end;

    local procedure IsCleanCashPossible(): Boolean
    var
        "Object": Record "Object";
    begin
        //-NPR5.26
        /*
        Object.SETRANGE(Type,Object.Type::Table);
        Object.SETRANGE(ID,6184500);
        IF Object.FINDFIRST THEN
          EXIT(TRUE);
        EXIT(FALSE);
        */
        //+NPR5.26

    end;

    [EventSubscriber(ObjectType::Codeunit, 6014560, 'OnPrintCleanCash', '', true, false)]
    local procedure CreateOnPrintCleanCash(var LinePrintMgt: Codeunit "RP Line Print Mgt.";var AuditRoll: Record "Audit Roll")
    begin
        //-NPR5.26
        PrintCleanCash(LinePrintMgt, AuditRoll);
        //+NPR5.26
    end;

    local procedure PrintCleanCash(var LinePrintMgt: Codeunit "RP Line Print Mgt.";var AuditRoll: Record "Audit Roll")
    var
        CleanCashWrapper: Codeunit "CleanCash Wrapper";
        AuditRollCleanCash: Record "Audit Roll";
        Lines: Integer;
        i: Integer;
        ReceiptNo: Code[10];
        SerialNo: Text[30];
        ControlCode: Text[100];
        CopySerialNo: Text[30];
        CopyControlCode: Text[100];
        txtReceiptNo: Label 'Receipt No.';
        txtSerialNo: Label 'Serial No.';
        txtControlCode: Label 'Control Code';
    begin
        //-NPR5.26
        AuditRollCleanCash.Copy(AuditRoll);
        if AuditRollCleanCash.FindFirst then
          if InitCleanCashData(AuditRollCleanCash) then begin
            Lines := GetLines();
            for i := 1 to Lines do begin
              GetCleanCashInformation(ReceiptNo, SerialNo, ControlCode, CopySerialNo, CopyControlCode);
              LinePrintMgt.NewLine;
              LinePrintMgt.AddLine(txtReceiptNo);
              LinePrintMgt.AddLine(ReceiptNo);
              LinePrintMgt.NewLine;
              LinePrintMgt.AddLine(txtSerialNo);
              if CopySerialNo = '' then
                LinePrintMgt.AddLine(SerialNo)
              else
                LinePrintMgt.AddLine(CopySerialNo);
              LinePrintMgt.NewLine;
              LinePrintMgt.AddLine(txtControlCode);
              if CopySerialNo = '' then begin
                LinePrintMgt.AddLine(CopyStr(ControlCode,1,30));
                LinePrintMgt.AddLine(CopyStr(ControlCode,31,60));
              end else begin
                LinePrintMgt.AddLine(CopyStr(CopyControlCode,1,30));
                LinePrintMgt.AddLine(CopyStr(CopyControlCode,31,60));
              end;

            end;
          end;
        //+NPR5.26
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014534, 'OnSalesReceiptFooter', '', true, false)]
    local procedure OnReceiptFooter(var TemplateLine: Record "RP Template Line";ReceiptNo: Text)
    var
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        AuditRoll: Record "Audit Roll";
    begin
        //-NPR5.32 [241995]
        LinePrintMgt.SetFont(TemplateLine."Type Option");
        LinePrintMgt.SetBold(TemplateLine.Bold);
        LinePrintMgt.SetUnderLine(TemplateLine.Underline);

        //-NPR5.40 [304639]
        AuditRoll.SetRange("Sales Ticket No.", ReceiptNo);
        AuditRoll.FindSet;
        //+NPR5.40 [304639]

        PrintCleanCash(LinePrintMgt, AuditRoll);
        //+NPR5.32 [241995]
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        //-NPR5.39 [302779]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;
        if Rec."Subscriber Function" <>  'CreateCleanCashOnSale' then
          exit;

        Rec.Description := Text000;
        Rec."Sequence No." := 10;
        //+NPR5.39 [302779]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.39 [302779]
        exit(CODEUNIT::"CleanCash Wrapper");
        //+NPR5.39 [302779]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure CreateCleanCashOnSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
    begin
        //-NPR5.39 [302779]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'CreateCleanCashOnSale' then
          exit;

        AuditRoll.SetRange("Register No.",SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if not AuditRoll.FindFirst then
          exit;

        if not IsRegisterCleanCash(AuditRoll) then
          exit;

        RunSalesTicket(AuditRoll);
        //+NPR5.39 [302779]
    end;
}

