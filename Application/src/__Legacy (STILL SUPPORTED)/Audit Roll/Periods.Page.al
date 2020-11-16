page 6014404 "NPR Periods"
{
    // NPR4.14/MMV/20150807 CASE 220160 Changed print code to call CU with updated version.
    // NPR5.48/BHR /20181120 CASE 329505 Add fields 165..168

    Caption = 'Periods';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Period";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Balancing Time"; "Balancing Time")
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("Last Date Active"; "Last Date Active")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Date Opened"; "Date Opened")
                {
                    ApplicationArea = All;
                }
                field("Date Closed"; "Date Closed")
                {
                    ApplicationArea = All;
                }
                field("Date Saved"; "Date Saved")
                {
                    ApplicationArea = All;
                }
                field("Opening Time"; "Opening Time")
                {
                    ApplicationArea = All;
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                }
                field("Saving  Time"; "Saving  Time")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No.2"; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Opening Sales Ticket No."; "Opening Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Opening Cash"; "Opening Cash")
                {
                    ApplicationArea = All;
                }
                field("Net. Cash Change"; "Net. Cash Change")
                {
                    ApplicationArea = All;
                }
                field("Net. Credit Voucher Change"; "Net. Credit Voucher Change")
                {
                    ApplicationArea = All;
                }
                field("Net. Gift Voucher Change"; "Net. Gift Voucher Change")
                {
                    ApplicationArea = All;
                }
                field("Net. Terminal Change"; "Net. Terminal Change")
                {
                    ApplicationArea = All;
                }
                field("Net. Dankort Change"; "Net. Dankort Change")
                {
                    ApplicationArea = All;
                }
                field("Net. VisaCard Change"; "Net. VisaCard Change")
                {
                    ApplicationArea = All;
                }
                field("Net. Change Other Cedit Cards"; "Net. Change Other Cedit Cards")
                {
                    ApplicationArea = All;
                }
                field("Gift Voucher Sales"; "Gift Voucher Sales")
                {
                    ApplicationArea = All;
                }
                field("Credit Voucher issuing"; "Credit Voucher issuing")
                {
                    ApplicationArea = All;
                }
                field("Cash Received"; "Cash Received")
                {
                    ApplicationArea = All;
                }
                field("Pay Out"; "Pay Out")
                {
                    ApplicationArea = All;
                }
                field("Debit Sale"; "Debit Sale")
                {
                    ApplicationArea = All;
                }
                field("Order Amount"; "Order Amount")
                {
                    ApplicationArea = All;
                }
                field("Invoice Amount"; "Invoice Amount")
                {
                    ApplicationArea = All;
                }
                field("Return Amount"; "Return Amount")
                {
                    ApplicationArea = All;
                }
                field("Credit Memo Amount"; "Credit Memo Amount")
                {
                    ApplicationArea = All;
                }
                field("Negative Sales Count"; "Negative Sales Count")
                {
                    ApplicationArea = All;
                }
                field("Negative Sales Amount"; "Negative Sales Amount")
                {
                    ApplicationArea = All;
                }
                field(Cheque; Cheque)
                {
                    ApplicationArea = All;
                }
                field("Balanced Cash Amount"; "Balanced Cash Amount")
                {
                    ApplicationArea = All;
                }
                field("Closing Cash"; "Closing Cash")
                {
                    ApplicationArea = All;
                }
                field(Difference; Difference)
                {
                    ApplicationArea = All;
                }
                field("Deposit in Bank"; "Deposit in Bank")
                {
                    ApplicationArea = All;
                }
                field("Balance Per Denomination"; "Balance Per Denomination")
                {
                    ApplicationArea = All;
                }
                field("Balanced Sec. Currency"; "Balanced Sec. Currency")
                {
                    ApplicationArea = All;
                }
                field("Balanced Euro"; "Balanced Euro")
                {
                    ApplicationArea = All;
                }
                field("Change Register"; "Change Register")
                {
                    ApplicationArea = All;
                }
                field("Gift Voucher Debit"; "Gift Voucher Debit")
                {
                    ApplicationArea = All;
                }
                field("Euro Difference"; "Euro Difference")
                {
                    ApplicationArea = All;
                }
                field("LCY Count"; "LCY Count")
                {
                    ApplicationArea = All;
                }
                field("Euro Count"; "Euro Count")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Money bag no."; "Money bag no.")
                {
                    ApplicationArea = All;
                }
                field("Alternative Register No."; "Alternative Register No.")
                {
                    ApplicationArea = All;
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
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Reports: Record "NPR Report Selection Retail";
                        RetailFormCode: Codeunit "NPR Retail Form Code";
                        AuditRoll: Record "NPR Audit Roll";
                        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
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

