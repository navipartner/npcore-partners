xmlport 6151143 "NPR M2 Get Simple Budget"
{
    // MAG2.24/TSA /20191022 CASE 354183 Initial Version

    Caption = 'Get Simple Budget';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(SimpleBudget)
        {
            tableelement(tmpcustomerrequest; Customer)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Budget)
                {
                    MaxOccurs = Once;
                    textattribute(budgetcode)
                    {
                        Occurrence = Optional;
                        XmlName = 'BudgetName';
                    }
                    fieldattribute(CustomerId; TmpCustomerRequest."No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(SalespersonCode; TmpCustomerRequest."Salesperson Code")
                    {
                        Occurrence = Optional;
                    }
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;
                    }
                }
                tableelement(tmpcustomerresponse; Customer)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'Budget';
                    UseTemporary = true;
                    textattribute(budgetcodeout)
                    {
                        XmlName = 'BudgetName';

                        trigger OnBeforePassVariable()
                        begin
                            BudgetCodeOut := BudgetCode;
                        end;
                    }
                    fieldattribute(CustomerId; TmpCustomerResponse."No.")
                    {
                    }
                    fieldattribute(SalespersonCode; TmpCustomerResponse."Salesperson Code")
                    {
                    }
                    textelement(SellToCustomer)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        textelement(selltostatistics)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Statistics';
                            tableelement(tmpsellagingbandbuffery2d; "Aging Band Buffer")
                            {
                                LinkTable = TmpCustomerResponse;
                                XmlName = 'YearToDate';
                                UseTemporary = true;
                                fieldattribute(BudgetAmount; TmpSellAgingBandBufferY2D."Column 1 Amt.")
                                {
                                }
                                fieldattribute(InvoicedAmount; TmpSellAgingBandBufferY2D."Column 2 Amt.")
                                {
                                }
                                fieldattribute(OutstandingAmount; TmpSellAgingBandBufferY2D."Column 3 Amt.")
                                {
                                }
                            }
                            tableelement(tmpsellagingbandbuffercq; "Aging Band Buffer")
                            {
                                XmlName = 'CurrentQuarter';
                                UseTemporary = true;
                                fieldattribute(BudgetAmount; TmpSellAgingBandBufferCQ."Column 1 Amt.")
                                {
                                }
                                fieldattribute(InvoicedAmount; TmpSellAgingBandBufferCQ."Column 2 Amt.")
                                {
                                }
                                fieldattribute(OutstandingAmount; TmpSellAgingBandBufferCQ."Column 3 Amt.")
                                {
                                }
                            }
                            tableelement(tmpsellagingbandbuffercm; "Aging Band Buffer")
                            {
                                XmlName = 'CurrentMonth';
                                UseTemporary = true;
                                fieldattribute(BudgetAmount; TmpSellAgingBandBufferCM."Column 1 Amt.")
                                {
                                }
                                fieldattribute(InvoicedAmount; TmpSellAgingBandBufferCM."Column 2 Amt.")
                                {
                                }
                                fieldattribute(OutstandingAmount; TmpSellAgingBandBufferCM."Column 3 Amt.")
                                {
                                }
                            }
                        }
                    }
                    textelement(BillToCustomer)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        textelement(billtostatistics)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Statistics';
                            tableelement(tmpbillagingbandbuffery2d; "Aging Band Buffer")
                            {
                                XmlName = 'YearToDate';
                                UseTemporary = true;
                                fieldattribute(BudgetAmount; TmpBillAgingBandBufferY2D."Column 1 Amt.")
                                {
                                }
                                fieldattribute(InvoicedAmount; TmpBillAgingBandBufferY2D."Column 2 Amt.")
                                {
                                }
                                fieldattribute(OutstandingAmount; TmpBillAgingBandBufferY2D."Column 3 Amt.")
                                {
                                }
                            }
                            tableelement(tmpbillagingbandbuffercq; "Aging Band Buffer")
                            {
                                XmlName = 'CurrentQuarter';
                                UseTemporary = true;
                                fieldattribute(BudgetAmount; TmpBillAgingBandBufferCQ."Column 1 Amt.")
                                {
                                }
                                fieldattribute(InvoicedAmount; TmpBillAgingBandBufferCQ."Column 2 Amt.")
                                {
                                }
                                fieldattribute(OutstandingAmount; TmpBillAgingBandBufferCQ."Column 3 Amt.")
                                {
                                }
                            }
                            tableelement(tmpbillagingbandbuffercm; "Aging Band Buffer")
                            {
                                XmlName = 'CurrentMonth';
                                UseTemporary = true;
                                fieldattribute(BudgetAmount; TmpBillAgingBandBufferCM."Column 1 Amt.")
                                {
                                }
                                fieldattribute(InvoicedAmount; TmpBillAgingBandBufferCM."Column 2 Amt.")
                                {
                                }
                                fieldattribute(OutstandingAmount; TmpBillAgingBandBufferCM."Column 3 Amt.")
                                {
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        StartTime: Time;

    procedure GetRequest()
    begin

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'No result.';

        TmpCustomerRequest.FindFirst();
        exit;
    end;

    procedure CreateResponse()
    begin

        TmpCustomerRequest.FindFirst();
        TmpCustomerResponse.TransferFields(TmpCustomerRequest, true);
        TmpCustomerResponse.Insert();

        CalculateStatistics(TmpCustomerRequest."Salesperson Code", TmpCustomerRequest."No.");

        ResponseCode := 'OK';
        ResponseMessage := ''; //STRSUBSTNO ('%1 %2', TmpBillToCustomer.COUNT, TmpSellToCustomer.count);

        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin

        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;

    local procedure CalculateStatistics(SalesPersonCode: Code[10]; CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin

        TmpBillAgingBandBufferY2D.DeleteAll;
        TmpBillAgingBandBufferCQ.DeleteAll;
        TmpBillAgingBandBufferCM.DeleteAll;
        TmpSellAgingBandBufferY2D.DeleteAll;
        TmpSellAgingBandBufferCQ.DeleteAll;
        TmpSellAgingBandBufferCM.DeleteAll;

        if (SalesPersonCode <> '') then
            Customer.SetFilter("Salesperson Code", '=%1', SalesPersonCode);
        if (CustomerNo <> '') then
            Customer.SetFilter("No.", '=%1', CustomerNo);

        if (not Customer.FindSet()) then
            exit;

        repeat
            if (Customer."Bill-to Customer No." = '') then
                Customer."Bill-to Customer No." := Customer."No.";

            TmpBillAgingBandBufferY2D."Column 1 Amt." += CalculateBudgetAmount(Customer."Bill-to Customer No.", CreateY2DFilter());
            TmpBillAgingBandBufferY2D."Column 2 Amt." += CalculateInvoicedAmount(Customer."Bill-to Customer No.", CreateY2DFilter());
            TmpBillAgingBandBufferY2D."Column 3 Amt." += CalculateOustandingAmount(Customer."Bill-to Customer No.", CreateY2DFilter(), true);

            TmpBillAgingBandBufferCQ."Column 1 Amt." += CalculateBudgetAmount(Customer."Bill-to Customer No.", CreateCQFilter());
            TmpBillAgingBandBufferCQ."Column 2 Amt." += CalculateInvoicedAmount(Customer."Bill-to Customer No.", CreateCQFilter());
            TmpBillAgingBandBufferCQ."Column 3 Amt." += CalculateOustandingAmount(Customer."Bill-to Customer No.", CreateCQFilter(), true);

            TmpBillAgingBandBufferCM."Column 1 Amt." += CalculateBudgetAmount(Customer."Bill-to Customer No.", CreateCMFilter());
            TmpBillAgingBandBufferCM."Column 2 Amt." += CalculateInvoicedAmount(Customer."Bill-to Customer No.", CreateCMFilter());
            TmpBillAgingBandBufferCM."Column 3 Amt." += CalculateOustandingAmount(Customer."Bill-to Customer No.", CreateCMFilter(), true);

            TmpSellAgingBandBufferY2D."Column 1 Amt." += CalculateBudgetAmount(Customer."No.", CreateY2DFilter());
            TmpSellAgingBandBufferY2D."Column 2 Amt." += CalculateInvoicedAmount(Customer."No.", CreateY2DFilter());
            TmpSellAgingBandBufferY2D."Column 3 Amt." += CalculateOustandingAmount(Customer."No.", CreateY2DFilter(), false);

            TmpSellAgingBandBufferCQ."Column 1 Amt." += CalculateBudgetAmount(Customer."No.", CreateCQFilter());
            TmpSellAgingBandBufferCQ."Column 2 Amt." += CalculateInvoicedAmount(Customer."No.", CreateCQFilter());
            TmpSellAgingBandBufferCQ."Column 3 Amt." += CalculateOustandingAmount(Customer."No.", CreateCQFilter(), false);

            TmpSellAgingBandBufferCM."Column 1 Amt." += CalculateBudgetAmount(Customer."No.", CreateCMFilter());
            TmpSellAgingBandBufferCM."Column 2 Amt." += CalculateInvoicedAmount(Customer."No.", CreateCMFilter());
            TmpSellAgingBandBufferCM."Column 3 Amt." += CalculateOustandingAmount(Customer."No.", CreateCMFilter(), false);

        until (Customer.Next() = 0);

        TmpBillAgingBandBufferY2D.Insert;
        TmpBillAgingBandBufferCQ.Insert;
        TmpBillAgingBandBufferCM.Insert;

        TmpSellAgingBandBufferY2D.Insert;
        TmpSellAgingBandBufferCQ.Insert;
        TmpSellAgingBandBufferCM.Insert;
    end;

    local procedure CalculateBudgetAmount(CustomerNo: Code[20]; DateFilter: Text) SalesAmount: Decimal
    var
        ItemBudgetEntry: Record "Item Budget Entry";
    begin

        ItemBudgetEntry.SetRange("Analysis Area", ItemBudgetEntry."Analysis Area"::Sales);
        ItemBudgetEntry.SetRange("Budget Name", FindBudgetName());
        ItemBudgetEntry.SetFilter(Date, DateFilter);
        ItemBudgetEntry.SetRange("Source Type", ItemBudgetEntry."Source Type"::Customer);
        ItemBudgetEntry.SetRange("Source No.", CustomerNo);
        if ItemBudgetEntry.FindSet then
            repeat
                SalesAmount += ItemBudgetEntry."Sales Amount";
            until ItemBudgetEntry.Next = 0;
        exit(SalesAmount);
    end;

    local procedure CalculateInvoicedAmount(CustomerNo: Code[20]; DateFilter: Text): Decimal
    var
        Customer: Record Customer;
    begin

        Customer.SetRange("No.", CustomerNo);
        Customer.SetFilter("Date Filter", DateFilter);
        if Customer.FindFirst then begin
            Customer.CalcFields("Net Change (LCY)");
            exit(Customer."Net Change (LCY)");
        end;
        exit(0);
    end;

    local procedure CalculateOustandingAmount(CustomerNo: Code[20]; DateFilter: Text; UseAsBillTo: Boolean) OutstandingAmt: Decimal
    var
        SalesLine: Record "Sales Line";
    begin

        SalesLine.SetFilter("Document Type", '<>%1', SalesLine."Document Type"::Quote);
        if UseAsBillTo then
            SalesLine.SetRange("Bill-to Customer No.", CustomerNo)
        else
            SalesLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesLine.SetFilter("Requested Delivery Date", DateFilter);
        if SalesLine.FindSet then
            repeat
                OutstandingAmt += CalculateOutstAmtExclVAT(SalesLine);
            until SalesLine.Next = 0;
        SalesLine.SetRange("Requested Delivery Date", 0D);
        if SalesLine.FindSet then
            repeat
                OutstandingAmt += CalculateOutstAmtExclVAT(SalesLine);
            until SalesLine.Next = 0;
        exit(OutstandingAmt);
    end;

    local procedure FindBudgetName(): Code[10]
    var
        ItemBudgetEntry: Record "Item Budget Entry";
        StartDate: Date;
        EndDate: Date;
    begin

        if (BudgetCode <> '') then
            exit(BudgetCode);

        StartDate := CalcDate('<CY-1Y+1D>', Today);
        EndDate := CalcDate('<CY>', Today);
        ItemBudgetEntry.SetFilter(Date, '%1..%2', StartDate, EndDate);
        ItemBudgetEntry.SetRange("Source Type", ItemBudgetEntry."Source Type"::Customer);
        if ItemBudgetEntry.FindFirst then
            exit(ItemBudgetEntry."Budget Name");
        exit('');
    end;

    local procedure CreateY2DFilter(): Text
    var
        Date: Record Date;
        EndDate: Date;
    begin

        EndDate := CalcDate('<CY>', Today);
        Date.SetRange("Period Type", Date."Period Type"::Year);
        Date.SetRange("Period End", ClosingDate(EndDate));
        if Date.FindFirst then
            exit(StrSubstNo('%1..%2', Date."Period Start", Today));
    end;

    local procedure CreateCQFilter(): Text
    var
        Date: Record Date;
        EndDate: Date;
    begin

        EndDate := CalcDate('<CQ>', Today);
        Date.SetRange("Period Type", Date."Period Type"::Quarter);
        Date.SetRange("Period End", ClosingDate(EndDate));
        if Date.FindFirst then
            exit(StrSubstNo('%1..%2', Date."Period Start", EndDate));
    end;

    local procedure CreateCMFilter(): Text
    var
        Date: Record Date;
        EndDate: Date;
    begin

        EndDate := CalcDate('<CM>', Today);
        Date.SetRange("Period Type", Date."Period Type"::Month);
        Date.SetRange("Period End", ClosingDate(EndDate));
        if Date.FindFirst then
            exit(StrSubstNo('%1..%2', Date."Period Start", EndDate));
    end;

    local procedure CalculateOutstAmtExclVAT(SalesLine: Record "Sales Line"): Decimal
    begin

        if (SalesLine.Amount <> 0) and (SalesLine."Amount Including VAT" <> 0) then
            exit(SalesLine."Outstanding Amount (LCY)" / (SalesLine."Amount Including VAT" / SalesLine.Amount));
        exit(0);
    end;
}

