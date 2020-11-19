codeunit 6014570 "NPR Report: Order Sales Ticket"
{
    // Report - Order Sales Ticket
    //  Work started by Jerome Cader on 08-05-2013
    //  Implements the functionality of the Order Sales Ticket IV report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060114.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Retail Document Header".

    TableNo = "NPR Retail Document Header";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        RetailDocumentHeader.CopyFilters(Rec);
        GetRecords;

        Printer.SetFont('A11');
        Printer.SetBold(false);

        for CurrPageNo := 1 to 1 do begin
            PrintRetailDocumentHeader;

            PrintRetailDocumentLines;

            PrintFooter;
        end;

        Printer.SetFont('A11');
        Printer.AddLine('');
        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        CurrPageNo: Integer;
        RetailDocumentHeader: Record "NPR Retail Document Header";
        RetailDocumentLines: Record "NPR Retail Document Lines";
        CommentLine: Record "Comment Line";
        CommentLine2: Record "Comment Line";
        Text0000: Label 'A';
        Text0001: Label 'G';
        Text0002: Label 'P';
        RetailSetup: Record "NPR Retail Setup";
        Register: Record "NPR Register";
        description: Label 'Description';
        CopyTXT: Label 'Copy No:';
        OrderTXT: Label 'Order Ticket';
        DateTxt: Label 'Date:';
        OrderNoTxt: Label 'Order No:';

    procedure PrintRetailDocumentHeader()
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        Printer.SetFont('Control');
        Printer.AddLine('A');
        Printer.AddLine('G');
        Printer.AddLine('h');

        Printer.SetFont('B21');
        Printer.SetBold(false);
        if POSSession.IsActiveSession(POSFrontEnd) then begin
            POSFrontEnd.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSStore(POSStore);
        end else begin
            if POSUnit.get(Register."Register No.") then
                POSStore.get(POSUnit."POS Store Code");
        end;
        Printer.AddLine(POSStore.Name);
        if POSStore."Name 2" <> '' then
            Printer.AddLine(POSStore."Name 2");
        Printer.AddLine(POSStore.Address);
        Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City);
        if POSStore."Phone No." <> '' then
            Printer.AddLine(POSStore.FieldCaption("Phone No.") + ' ' + POSStore."Phone No.");
        if Register."VAT No." <> '' then
            Printer.AddLine(Register.FieldCaption("VAT No.") + ' ' + Register."VAT No.");
        if POSStore."E-mail" <> '' then
            Printer.AddLine(POSStore.FieldCaption("E-mail") + ' ' + POSStore."E-mail");
        if POSStore."Home Page" <> '' then
            Printer.AddLine(POSStore."Home Page");

        Printer.SetFont('B21');
        Printer.SetBold(false);
        Printer.AddLine('');
        Printer.AddTextField(1, 1, OrderTXT);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, RetailDocumentHeader.Name);
        Printer.AddTextField(1, 0, RetailDocumentHeader.Address);
        Printer.AddTextField(1, 0, Format(RetailDocumentHeader."Post Code") + ' ' + Format(RetailDocumentHeader.City));
        Printer.AddTextField(1, 0, DateTxt + ' ' + Format(RetailDocumentHeader.Date));
        Printer.AddTextField(1, 0, OrderNoTxt + ' ' + Format(RetailDocumentHeader."No."));

        if RetailDocumentHeader."Copy No." > 0 then
            Printer.AddTextField(1, 0, CopyTXT + ' ' + Format(RetailDocumentHeader."Copy No."));
        Printer.AddLine('');

        Printer.SetFont('B21');
        Printer.SetBold(false);
        Printer.AddTextField(1, 0, description);
        Printer.SetPadChar('_');
        Printer.AddLine('');

        PrintCommentLines2;

        Printer.SetFont('A11');
        Printer.AddLine('');
    end;

    procedure PrintRetailDocumentLines()
    begin
        RetailDocumentLines.SetCurrentKey("Document Type", "Document No.", "Line No.");
        RetailDocumentLines.SetRange("Document Type", RetailDocumentHeader."Document Type");
        RetailDocumentLines.SetRange("Document No.", RetailDocumentHeader."No.");

        if RetailDocumentLines.FindSet then
            repeat
                Printer.SetFont('A11');
                Printer.AddTextField(1, 0, RetailDocumentLines."No." + ' ' + RetailDocumentLines.Description);
                Printer.AddDecimalField(2, 2, RetailDocumentLines."Amount Including VAT");
                PrintCommentLines;
            until RetailDocumentLines.Next = 0;

        Printer.SetPadChar('_');
        Printer.AddLine('');
        Printer.SetPadChar(' ');
    end;

    procedure PrintCommentLines()
    begin
        CommentLine.SetCurrentKey("Table Name", "No.", "Line No.");
        CommentLine.SetRange("No.", RetailDocumentHeader."No.");
        CommentLine.SetRange(Code, Format(RetailDocumentLines."Line No."));

        Printer.SetFont('A11');
        if CommentLine.FindSet then begin
            Printer.AddLine('');
            repeat
                Printer.AddTextField(1, 0, ' ' + CommentLine.Comment);
            until CommentLine.Next = 0;
        end;
    end;

    procedure PrintCommentLines2()
    begin
        CommentLine.SetCurrentKey("Table Name", "No.", "Line No.");
        CommentLine2.SetRange("No.", RetailDocumentHeader."No.");
        CommentLine2.SetRange(Code, '');

        Printer.SetFont('A11');
        if CommentLine2.FindSet then
            repeat
                Printer.AddTextField(1, 0, ' ' + CommentLine2.Comment);
            until CommentLine2.Next = 0;
    end;

    procedure PrintFooter()
    var
        TempRetailComments: Record "NPR Retail Comment" temporary;
        Utility: Codeunit "NPR Utility";
    begin
        if RetailSetup."Bar Code on Sales Ticket Print" and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::"TM-T88") then begin
            Printer.AddLine('');
            Printer.AddBarcode('Code39', RetailDocumentHeader."No.", 4);
            Printer.AddLine('');
        end;

        Printer.SetFont('A11');
        Utility.GetTicketText(TempRetailComments, Register);
        if TempRetailComments.FindSet then
            repeat
                Printer.AddTextField(1, 1, TempRetailComments.Comment)
            until TempRetailComments.Next = 0;
    end;

    //Record Triggers
    //Init

    procedure GetRecords()
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        RetailDocumentHeader.FindSet;
        Register.Get(RetailFormCode.FetchRegisterNumber);
        RetailSetup.Get;
    end;
}

