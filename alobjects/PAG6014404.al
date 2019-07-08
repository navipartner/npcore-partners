page 6014404 Periods
{
    // NPR4.14/MMV/20150807 CASE 220160 Changed print code to call CU with updated version.
    // NPR5.48/BHR /20181120 CASE 329505 Add fields 165..168

    Caption = 'Periods';
    Editable = false;
    PageType = List;
    SourceTable = Period;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Balancing Time";"Balancing Time")
                {
                }
                field(Comment;Comment)
                {
                }
                field("Last Date Active";"Last Date Active")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Date Opened";"Date Opened")
                {
                }
                field("Date Closed";"Date Closed")
                {
                }
                field("Date Saved";"Date Saved")
                {
                }
                field("Opening Time";"Opening Time")
                {
                }
                field("Closing Time";"Closing Time")
                {
                }
                field("Saving  Time";"Saving  Time")
                {
                }
                field("Sales Ticket No.2";"Sales Ticket No.")
                {
                }
                field("Opening Sales Ticket No.";"Opening Sales Ticket No.")
                {
                }
                field("Opening Cash";"Opening Cash")
                {
                }
                field("Net. Cash Change";"Net. Cash Change")
                {
                }
                field("Net. Credit Voucher Change";"Net. Credit Voucher Change")
                {
                }
                field("Net. Gift Voucher Change";"Net. Gift Voucher Change")
                {
                }
                field("Net. Terminal Change";"Net. Terminal Change")
                {
                }
                field("Net. Dankort Change";"Net. Dankort Change")
                {
                }
                field("Net. VisaCard Change";"Net. VisaCard Change")
                {
                }
                field("Net. Change Other Cedit Cards";"Net. Change Other Cedit Cards")
                {
                }
                field("Gift Voucher Sales";"Gift Voucher Sales")
                {
                }
                field("Credit Voucher issuing";"Credit Voucher issuing")
                {
                }
                field("Cash Received";"Cash Received")
                {
                }
                field("Pay Out";"Pay Out")
                {
                }
                field("Debit Sale";"Debit Sale")
                {
                }
                field("Order Amount";"Order Amount")
                {
                }
                field("Invoice Amount";"Invoice Amount")
                {
                }
                field("Return Amount";"Return Amount")
                {
                }
                field("Credit Memo Amount";"Credit Memo Amount")
                {
                }
                field("Negative Sales Count";"Negative Sales Count")
                {
                }
                field("Negative Sales Amount";"Negative Sales Amount")
                {
                }
                field(Cheque;Cheque)
                {
                }
                field("Balanced Cash Amount";"Balanced Cash Amount")
                {
                }
                field("Closing Cash";"Closing Cash")
                {
                }
                field(Difference;Difference)
                {
                }
                field("Deposit in Bank";"Deposit in Bank")
                {
                }
                field("Balance Per Denomination";"Balance Per Denomination")
                {
                }
                field("Balanced Sec. Currency";"Balanced Sec. Currency")
                {
                }
                field("Balanced Euro";"Balanced Euro")
                {
                }
                field("Change Register";"Change Register")
                {
                }
                field("Gift Voucher Debit";"Gift Voucher Debit")
                {
                }
                field("Euro Difference";"Euro Difference")
                {
                }
                field("LCY Count";"LCY Count")
                {
                }
                field("Euro Count";"Euro Count")
                {
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Money bag no.";"Money bag no.")
                {
                }
                field("Alternative Register No.";"Alternative Register No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                Caption = '&Print';
                action("Register Report")
                {
                    Caption = 'Register report';
                    Image = "Report";

                    trigger OnAction()
                    var
                        Reports: Record "Report Selection Retail";
                        RetailFormCode: Codeunit "Retail Form Code";
                        AuditRoll: Record "Audit Roll";
                        StdCodeunitCode: Codeunit "Std. Codeunit Code";
                    begin
                        AuditRoll.SetRange("Register No.", "Register No.");
                        AuditRoll.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        //-NPR4.14
                        //AuditRoll.FIND('-');
                        AuditRoll.FindFirst;
                        StdCodeunitCode.PrintRegisterReceipt(AuditRoll);

                        //Reports.SETRANGE("Report Type", Reports."Report Type"::Kasseafslut);
                        //Reports.SETFILTER("Register No.", '%1|%2', RetailFormCode.HentKassenummer, '');
                        //IF Reports.FIND('-') THEN REPEAT
                        //  REPORT.RUNMODAL(Reports."Report ID", TRUE, TRUE, AuditRoll);
                        //UNTIL Reports.NEXT = 0;

                        //-NPR4.14
                    end;
                }
            }
        }
    }
}

