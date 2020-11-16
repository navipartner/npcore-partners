codeunit 6014572 "NPR Report: Open drawer IV"
{
    // Report - Open drawer IV
    //  Work started by Jerome Cader on 03-05-2013
    //  Implements the functionality of the Open drawer IV report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060116.
    // 
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.


    trigger OnRun()
    begin
        Printer.SetFont('Control');
        //-NPR5.26 [249408]
        //Printer.AddLine(Text10600000);
        Printer.AddLine('A');
        //+NPR5.26 [249408]
    end;

    var
        Text10600000: Label 'A';
        Printer: Codeunit "NPR RP Line Print Mgt.";
}

