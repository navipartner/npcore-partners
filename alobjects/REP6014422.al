report 6014422 "Issued/Admitted Ticket Stats"
{
    // NPR5.36/JLK /20170817  CASE 286201 Object created
    // NPR5.37/JLK /20171010  CASE 286201 Changed ENU Report Caption
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer in Request Page
    // NPR5.40/JLK /20180322  CASE 308825 Added Customer Filter
    // NPR5.41/JLK /20180406  CASE 308825 Added Customer Name in Filter
    // NPR5.49/BHR /20190207  CASE 343119 Correct Report as per OMA
    DefaultLayout = RDLC;
    RDLCLayout = './IssuedAdmitted Ticket Stats.rdlc';

    Caption = 'Issued/Admitted Ticket Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(TMTicketType;"TM Ticket Type")
        {
            column(Code_TMTicketType;Code)
            {
            }
            column(Description_TMTicketType;Description)
            {
            }
            column(SkipLineWithZero;SkipLineWithZero)
            {
            }
            column(FilterStartDate;FilterStartDate)
            {
            }
            column(FilterEndDate;FilterEndDate)
            {
            }
            column(FilterCustomer;FilterCustomer)
            {
            }
            column(Getfilters;GetFilters)
            {
            }
            dataitem(Item;Item)
            {
                DataItemLink = "Ticket Type"=FIELD(Code);
                DataItemTableView = SORTING("No.");
                column(No_Item;"No.")
                {
                }
                column(Description_Item;Description)
                {
                }
                dataitem(CalcTicketAmount;"Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                    column(TotalIssuedTicketPerItem;TotalIssuedTicketPerItem)
                    {
                    }
                    column(TotalAdmittedTicketPerItem;TotalAdmittedTicketPerItem)
                    {
                    }
                    column(TicketTypeAvailable;TicketTypeAvailable)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        TMTicket: Record "TM Ticket";
                        AdmittedTicket: Decimal;
                        IssuedTicket: Decimal;
                        TMTicketAccessStatistics: Record "TM Ticket Access Statistics";
                    begin
                        TMTicket.SetRange(Blocked,false);
                        TMTicket.SetRange("Item No.",Item."No.");
                        TMTicketAccessStatistics.SetRange("Item No.",Item."No.");

                        if (StartDate <> 0D) and (EndDate <> 0D) then begin
                          TMTicket.SetFilter("Valid From Date",'%1..%2',StartDate,EndDate);
                          TMTicketAccessStatistics.SetFilter("Admission Date",'%1..%2',StartDate,EndDate);
                        end;

                        if EndDate = 0D then begin
                          TMTicket.SetFilter("Valid From Date",'%1',StartDate);
                          TMTicketAccessStatistics.SetFilter("Admission Date",'%1',StartDate);
                        end;

                        //-NPR5.40
                        if CustomerFilter <> '' then
                          TMTicket.SetFilter("Customer No.",CustomerFilter);
                        //+308825

                        if TMTicket.FindSet then repeat
                          Clear(IssuedTicket);
                          GetIssuedTicket(TMTicket,IssuedTicket);
                          TotalIssuedTicketPerItem += IssuedTicket;
                          //-NPR5.40
                          Clear(AdmittedTicket);
                          GetAdmittedTicket(TMTicket,AdmittedTicket);
                          TotalAdmittedTicketPerItem += AdmittedTicket;
                          //+NPR5.40
                        until TMTicket.Next = 0;

                        //-NPR5.40
                        // IF TMTicketAccessStatistics.FINDSET THEN REPEAT
                        //  CLEAR(AdmittedTicket);
                        //  AdmittedTicket += TMTicketAccessStatistics."Admission Count";
                        //  TotalAdmittedTicketPerItem += AdmittedTicket;
                        // UNTIL TMTicketAccessStatistics.NEXT = 0;
                        //+NPR5.40

                        if SkipLineWithZero then
                          if (IssuedTicket = 0) and (AdmittedTicket = 0) then
                            CurrReport.Skip;
                        TicketTypeAvailable := true;

                        TotalIssuedTicketType += TotalIssuedTicketPerItem;
                        TotalAdmittedTicketType += TotalAdmittedTicketPerItem;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TotalIssuedTicketPerItem);
                    Clear(TotalAdmittedTicketPerItem);
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemCheck: Record Item;
            begin
                ItemCheck.SetRange("Ticket Type",Code);
                if not ItemCheck.FindFirst then
                  CurrReport.Skip;

                Clear(TicketTypeAvailable);
            end;

            trigger OnPreDataItem()
            begin
                Clear(TotalIssuedTicketType);
                Clear(TotalAdmittedTicketType);
            end;
        }
        dataitem(CalcTicketTypeAmount;"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
            column(TotalIssuedTicketType;TotalIssuedTicketType)
            {
            }
            column(TotalAdmittedTicketType;TotalAdmittedTicketType)
            {
            }
        }
    }

    requestpage
    {
        Caption = 'Issued/Admitted Ticket Stats';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartDate;StartDate)
                    {
                        Caption = 'Start Date';
                    }
                    field(EndDate;EndDate)
                    {
                        Caption = 'End Date';
                    }
                    field(SkipLineWithZero;SkipLineWithZero)
                    {
                        Caption = 'Skip Zero Amt Lines';
                    }
                    field(CustomerFilter;CustomerFilter)
                    {
                        Caption = 'Customer No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Customer: Record Customer;
                        begin
                            //-NPR5.40
                            if PAGE.RunModal(22, Customer) = ACTION::LookupOK then
                              CustomerFilter := Customer."No.";
                            //+NPR5.40
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            StartDate := Today;
            EndDate := Today;
        end;
    }

    labels
    {
        ReportCaption = 'Ticket Issued and Admitted Report';
        ItemCaption = 'Item #';
        DescriptionCaption = 'Description';
        IssuedCaption = 'Issued';
        AdmittedCaption = 'Admitted';
        TotalCaption = 'Total';
        TicketTypeCaption = 'Ticket Type - %1';
        TotalAllTicketTypeCaption = 'Total All Ticket Types';
        PageCaption = 'Page %1 of %2';
    }

    trigger OnPreReport()
    var
        Cust: Record Customer;
    begin
        //-NPR5.41
        if CustomerFilter <> '' then
          if not Cust.Get(CustomerFilter) then
            Clear(Cust);
        //+NPR5.41

        FilterStartDate := StrSubstNo(StartDateCaption,Format(StartDate));
        FilterEndDate := StrSubstNo(EndDateCaption,Format(EndDate));
        //-NPR5.41
        //FilterCustomer := STRSUBSTNO(CustomerCaption,CustomerFilter);
        FilterCustomer := StrSubstNo(CustomerCaption,CustomerFilter) + ' - ' + Cust.Name;
        //+NPR5.41
    end;

    var
        TotalAdmittedTicketPerItem: Decimal;
        TotalIssuedTicketPerItem: Decimal;
        StartDate: Date;
        EndDate: Date;
        TotalIssuedTicketType: Decimal;
        TotalAdmittedTicketType: Integer;
        SkipLineWithZero: Boolean;
        FilterStartDate: Text;
        FilterEndDate: Text;
        StartDateCaption: Label 'Start Date: %1';
        EndDateCaption: Label 'End Date: %1';
        TicketTypeAvailable: Boolean;
        CustomerFilter: Text;
        CustomerCaption: Label 'Customer Filter: %1';
        FilterCustomer: Text;

    local procedure GetIssuedTicket(Ticket: Record "TM Ticket";var IssuedAmount: Decimal)
    var
        TMTicketAccessEntry: Record "TM Ticket Access Entry";
    begin
        TMTicketAccessEntry.SetRange("Ticket No.",Ticket."No.");
        if TMTicketAccessEntry.FindSet then repeat
          IssuedAmount += TMTicketAccessEntry.Quantity;
        until TMTicketAccessEntry.Next = 0;
    end;

    local procedure GetAdmittedTicket(Ticket: Record "TM Ticket";var AdmittedAmount: Decimal)
    var
        TMTicketAccessEntry: Record "TM Ticket Access Entry";
        TMTicketAccessStatistics: Record "TM Ticket Access Statistics";
        ItemFactCode: Code[20];
        TicketTypeFactCode: Code[20];
        AdmissionHour: Integer;
    begin
        //-NPR5.40
        TMTicketAccessEntry.SetRange("Ticket No.",Ticket."No.");
        if TMTicketAccessEntry.FindSet then repeat
          ItemFactCode := '';
          if (ItemFactCode = '') then
            ItemFactCode := Ticket."Item No.";
          if (ItemFactCode = '') then
            ItemFactCode := '<BLANK>';
          TicketTypeFactCode := TMTicketAccessEntry."Ticket Type Code";
          if (TicketTypeFactCode = '') then
            TicketTypeFactCode := '<BLANK>';
          Evaluate (AdmissionHour, Format (TMTicketAccessEntry."Access Time", 0, '<Hours24>'));
          TMTicketAccessStatistics.Reset;
          TMTicketAccessStatistics.SetFilter ("Item No.", '=%1', ItemFactCode);
          TMTicketAccessStatistics.SetFilter ("Ticket Type", '=%1', TicketTypeFactCode);
          TMTicketAccessStatistics.SetFilter ("Admission Code", '=%1',TMTicketAccessEntry."Admission Code");
          TMTicketAccessStatistics.SetFilter ("Admission Date", '=%1', TMTicketAccessEntry."Access Date");
          TMTicketAccessStatistics.SetFilter ("Admission Hour", '=%1', AdmissionHour);
          if (TMTicketAccessStatistics.FindFirst ()) then
            AdmittedAmount += TMTicketAccessEntry.Quantity;
        until TMTicketAccessEntry.Next = 0;
        //+NPR5.40
    end;
}

