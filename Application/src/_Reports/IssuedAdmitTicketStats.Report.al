report 6014422 "NPR Issued/Admit. Ticket Stats"
{
    RDLCLayout = './src/_Reports/layouts/IssuedAdmitted Ticket Stats.rdlc';
    Caption = 'Issued/Admitted Ticket Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(TMTicketType; "NPR TM Ticket Type")
        {
            column(Code_TMTicketType; Code)
            {
            }
            column(Description_TMTicketType; Description)
            {
            }
            column(SkipLineWithZero; SkipLineWithZero)
            {
            }
            column(FilterStartDate; FilterStartDate)
            {
            }
            column(FilterEndDate; FilterEndDate)
            {
            }
            column(FilterCustomer; FilterCustomer)
            {
            }
            column(Getfilters; GetFilters)
            {
            }
            column(VariantCodeLbl; VariantCodeLbl)
            {
            }
            column(VariantVisibility; VariantVisibility)
            {
            }
            column(ShowVariantLine; ShowVariantLine)
            {
            }
            column(AdmissionCode; AdmissionCodeFilter)
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "NPR Ticket Type" = FIELD(Code);
                DataItemTableView = SORTING("No.");
                RequestFilterFields = "No.";
                column(No_Item; "No.")
                {
                }
                column(Description_Item; Description)
                {
                }
                column(VariantCode; VariantCode)
                {
                }
                dataitem(CalcTicketAmount; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(TotalIssuedTicketPerItem; TotalIssuedTicketPerItem)
                    {
                    }
                    column(TotalAdmittedTicketPerItem; TotalAdmittedTicketPerItem)
                    {
                    }
                    column(TicketTypeAvailable; TicketTypeAvailable)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        TMTicket: Record "NPR TM Ticket";
                        TMTicketAccessStatistics: Record "NPR TM Ticket Access Stats";
                        AdmittedTicket: Decimal;
                        IssuedTicket: Decimal;
                    begin
                        TMTicket.SetRange(Blocked, false);
                        TMTicket.SetRange("Item No.", Item."No.");
                        TMTicketAccessStatistics.SetRange("Item No.", Item."No.");

                        if (StartDate <> 0D) and (EndDate <> 0D) then begin
                            TMTicket.SetFilter("Valid From Date", '%1..%2', InitialStartDate, EndDate);
                            TMTicketAccessStatistics.SetFilter("Admission Date", '%1..%2', StartDate, EndDate);
                        end;

                        if EndDate = 0D then begin
                            TMTicket.SetFilter("Valid From Date", '%1..%2', InitialStartDate, StartDate);
                            TMTicketAccessStatistics.SetFilter("Admission Date", '%1', StartDate);
                        end;

                        if CustomerFilter <> '' then
                            TMTicket.SetFilter("Customer No.", CustomerFilter);
                        if AdmissionCode <> '' then
                            TMTicketAccessStatistics.SetFilter("Admission Code", '%1', AdmissionCode);
                        if TMTicket.FindSet() then
                            repeat
                                Clear(IssuedTicket);
                                if TMTicket."Valid From Date" in [StartDate .. EndDate] then
                                    GetIssuedTicket(TMTicket, IssuedTicket);
                                TotalIssuedTicketPerItem += IssuedTicket;
                                Clear(AdmittedTicket);
                                GetAdmittedTicket(TMTicket, AdmittedTicket);
                                TotalAdmittedTicketPerItem += AdmittedTicket;
                            until TMTicket.Next() = 0;

                        if SkipLineWithZero then
                            if (IssuedTicket = 0) and (AdmittedTicket = 0) then
                                CurrReport.Skip();
                        TicketTypeAvailable := true;

                        TotalIssuedTicketType += TotalIssuedTicketPerItem;
                        TotalAdmittedTicketType += TotalAdmittedTicketPerItem;
                    end;
                }
                dataitem("TM Ticket Access Statistics"; "NPR TM Ticket Access Stats")
                {
                    DataItemTableView = SORTING("Entry No.");
                    column(Variant; "TM Ticket Access Statistics"."Variant Code" + '  ' + VariantDesc)
                    {
                    }
                    column(TotalIssuedTicketPerVariant; TotalIssuedTicketPervariant)
                    {
                    }
                    column(TotalAdmittedTicketPerVariant; TotalAdmittedTicketPerVariant)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        TMTicket: Record "NPR TM Ticket";
                        TMTicketAccessStatistics: Record "NPR TM Ticket Access Stats";
                        AdmittedTicket: Decimal;
                        IssuedTicket: Decimal;
                    begin
                        TMTicket.SetRange(Blocked, false);
                        TMTicket.SetRange("Item No.", Item."No.");
                        TMTicketAccessStatistics.SetRange("Item No.", Item."No.");
                        TotalIssuedTicketPervariant := 0;
                        TotalAdmittedTicketPerVariant := 0;
                        Clear(VariantDesc);
                        if "Variant Code" <> '' then begin
                            if Itemvariant.Get("TM Ticket Access Statistics"."Item No.", "TM Ticket Access Statistics"."Variant Code") then
                                VariantDesc := Itemvariant.Description
                        end;
                        TMTicket.SetRange("Variant Code", "TM Ticket Access Statistics"."Variant Code");

                        if (StartDate <> 0D) and (EndDate <> 0D) then begin
                            TMTicket.SetFilter("Valid From Date", '%1..%2', StartDate, EndDate);
                            TMTicketAccessStatistics.SetFilter("Admission Date", '%1..%2', StartDate, EndDate);
                        end;

                        if EndDate = 0D then begin
                            TMTicket.SetFilter("Valid From Date", '%1', StartDate);
                            TMTicketAccessStatistics.SetFilter("Admission Date", '%1', StartDate);
                        end;
                        if AdmissionCode <> '' then
                            TMTicketAccessStatistics.SetFilter("Admission Code", '%1', AdmissionCode);
                        if CustomerFilter <> '' then
                            TMTicket.SetFilter("Customer No.", CustomerFilter);
                        if TMTicket.FindSet() then
                            repeat
                                Clear(IssuedTicket);
                                Clear(AdmittedTicket);
                                GetIssuedTicketVariant(TMTicket, IssuedTicket);
                                TotalIssuedTicketPervariant += IssuedTicket;
                                GetAdmittedTicketVariant(TMTicket, AdmittedTicket);
                                TotalAdmittedTicketPerVariant += AdmittedTicket;
                            until TMTicket.Next() = 0;

                        if SkipLineWithZero then
                            if (IssuedTicket = 0) and (AdmittedTicket = 0) then
                                CurrReport.Skip();
                        TicketTypeAvailable := true;
                    end;

                    trigger OnPreDataItem()
                    begin
                        "TM Ticket Access Statistics".SetRange("Item No.", Item."No.");
                        "TM Ticket Access Statistics".SetFilter("Admission Date", '%1..%2', StartDate, EndDate);
                        "TM Ticket Access Statistics".SetFilter("Variant Code", '<>%1', '');
                        if AdmissionCode <> '' then
                            "TM Ticket Access Statistics".SetFilter("Admission Code", '%1', AdmissionCode);
                        Clear(VariantDesc);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TotalIssuedTicketPerItem);
                    Clear(TotalAdmittedTicketPerItem);
                end;

                trigger OnPreDataItem()
                begin
                    Clear(VariantCode);
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemCheck: Record Item;
            begin
                ItemCheck.SetRange("NPR Ticket Type", Code);
                if not ItemCheck.FindFirst() then
                    CurrReport.Skip();

                Clear(TicketTypeAvailable);
            end;

            trigger OnPreDataItem()
            begin
                Clear(TotalIssuedTicketType);
                Clear(TotalAdmittedTicketType);
            end;
        }
        dataitem(CalcTicketTypeAmount; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(TotalIssuedTicketType; TotalIssuedTicketType)
            {
            }
            column(TotalAdmittedTicketType; TotalAdmittedTicketType)
            {
            }
        }
    }

    requestpage
    {
        SaveValues = true;
        Caption = 'Issued/Admitted Ticket Stats';
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Start Date"; StartDate)
                    {
                        Caption = 'Start Date';

                        ToolTip = 'Specifies the value of the Start Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("End Date"; EndDate)
                    {
                        Caption = 'End Date';

                        ToolTip = 'Specifies the value of the End Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Skip Line With Zero"; SkipLineWithZero)
                    {
                        Caption = 'Skip Zero Amt Lines';

                        ToolTip = 'Specifies the value of the Skip Zero Amt Lines field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Filter"; CustomerFilter)
                    {
                        Caption = 'Customer No.';

                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Customer: Record Customer;
                        begin
                            if PAGE.RunModal(22, Customer) = ACTION::LookupOK then
                                CustomerFilter := Customer."No.";
                        end;
                    }
                    field("Variant Visibility"; VariantVisibility)
                    {
                        Caption = 'Show Variant';

                        ToolTip = 'Specifies the value of the Show Variant field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Admission Code"; AdmissionCode)
                    {
                        Caption = 'Admission Code';
                        TableRelation = "NPR TM Ticket Access Fact"."Fact Code" WHERE("Fact Name" = FILTER(ADMISSION_CODE));

                        ToolTip = 'Specifies the value of the Admission Code field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            StartDate := Today();
            EndDate := Today();
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
        Year: Integer;
    begin
        if CustomerFilter <> '' then
            if not Cust.Get(CustomerFilter) then
                Clear(Cust);

        FilterStartDate := StrSubstNo(StartDateCaption, Format(StartDate));
        FilterEndDate := StrSubstNo(EndDateCaption, Format(EndDate));
        if EndDate = 0D then
            EndDate := StartDate;
        Year := Date2DMY(StartDate, 3);
        InitialStartDate := DMY2Date(1, 1, Year);
        FilterCustomer := StrSubstNo(CustomerCaption, CustomerFilter) + ' ' + Cust.Name;
        AdmissionCodeFilter := AdmissionCodeLbl + ' ' + AdmissionCode;
    end;

    var
        Itemvariant: Record "Item Variant";
        ShowVariantLine: Boolean;
        SkipLineWithZero: Boolean;
        TicketTypeAvailable: Boolean;
        VariantVisibility: Boolean;
        VariantCode: Code[10];
        AdmissionCode: Code[100];
        EndDate: Date;
        InitialStartDate: Date;
        StartDate: Date;
        TotalAdmittedTicketPerItem: Decimal;
        TotalAdmittedTicketPerVariant: Decimal;
        TotalIssuedTicketPerItem: Decimal;
        TotalIssuedTicketPervariant: Decimal;
        TotalIssuedTicketType: Decimal;
        TotalAdmittedTicketType: Integer;
        AdmissionCodeLbl: Label 'Admission Code: ';
        CustomerCaption: Label 'Customer Filter: %1';
        EndDateCaption: Label 'End Date: %1';
        StartDateCaption: Label 'Start Date: %1';
        VariantCodeLbl: Label 'Variant Code : ';
        AdmissionCodeFilter: Text;
        CustomerFilter: Text;
        FilterCustomer: Text;
        FilterEndDate: Text;
        FilterStartDate: Text;
        VariantDesc: Text;

    local procedure GetIssuedTicket(Ticket: Record "NPR TM Ticket"; var IssuedAmount: Decimal)
    var
        TMTicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        if AdmissionCode <> '' then
            TMTicketAccessEntry.SetFilter("Admission Code", '%1', AdmissionCode);
        TMTicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        if TMTicketAccessEntry.FindSet() then
            repeat
                IssuedAmount += TMTicketAccessEntry.Quantity;
            until TMTicketAccessEntry.Next() = 0;
    end;

    local procedure GetAdmittedTicket(Ticket: Record "NPR TM Ticket"; var AdmittedAmount: Decimal)
    var
        TMTicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TMTicketAccessStatistics: Record "NPR TM Ticket Access Stats";
        ItemFactCode: Code[20];
        TicketTypeFactCode: Code[20];
        AdmissionHour: Integer;
    begin
        TMTicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        TMTicketAccessEntry.SetFilter("Access Date", '%1..%2', StartDate, EndDate);
        if AdmissionCode <> '' then
            TMTicketAccessEntry.SetFilter("Admission Code", '%1', AdmissionCode);
        if TMTicketAccessEntry.FindSet() then
            repeat
                ItemFactCode := '';
                if (ItemFactCode = '') then
                    ItemFactCode := Ticket."Item No.";
                if (ItemFactCode = '') then
                    ItemFactCode := '<BLANK>';
                TicketTypeFactCode := TMTicketAccessEntry."Ticket Type Code";
                if (TicketTypeFactCode = '') then
                    TicketTypeFactCode := '<BLANK>';
                Evaluate(AdmissionHour, Format(TMTicketAccessEntry."Access Time", 0, '<Hours24>'));
                TMTicketAccessStatistics.Reset();
                TMTicketAccessStatistics.SetFilter("Item No.", '=%1', ItemFactCode);
                TMTicketAccessStatistics.SetFilter("Ticket Type", '=%1', TicketTypeFactCode);
                TMTicketAccessStatistics.SetFilter("Admission Code", '=%1', TMTicketAccessEntry."Admission Code");
                TMTicketAccessStatistics.SetFilter("Admission Date", '=%1', TMTicketAccessEntry."Access Date");
                TMTicketAccessStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);
                if (TMTicketAccessStatistics.FindFirst()) then
                    AdmittedAmount += TMTicketAccessEntry.Quantity;
            until TMTicketAccessEntry.Next() = 0;
    end;

    local procedure GetIssuedTicketVariant(Ticket: Record "NPR TM Ticket"; var IssuedAmount: Decimal)
    var
        TMTicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        if AdmissionCode <> '' then
            TMTicketAccessEntry.SetFilter("Admission Code", '%1', AdmissionCode);
        TMTicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        if TMTicketAccessEntry.FindSet() then
            repeat
                IssuedAmount += TMTicketAccessEntry.Quantity;
            until TMTicketAccessEntry.Next() = 0;
    end;

    local procedure GetAdmittedTicketVariant(Ticket: Record "NPR TM Ticket"; var AdmittedAmount: Decimal)
    var
        TMTicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TMTicketAccessStatistics: Record "NPR TM Ticket Access Stats";
        ItemFactCode: Code[20];
        TicketTypeFactCode: Code[20];
        AdmissionHour: Integer;
    begin
        TMTicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        if AdmissionCode <> '' then
            TMTicketAccessEntry.SetFilter("Admission Code", '%1', AdmissionCode);
        if TMTicketAccessEntry.FindSet() then
            repeat
                ItemFactCode := '';
                if (ItemFactCode = '') then
                    ItemFactCode := Ticket."Item No.";
                if (ItemFactCode = '') then
                    ItemFactCode := '<BLANK>';
                TicketTypeFactCode := TMTicketAccessEntry."Ticket Type Code";
                if (TicketTypeFactCode = '') then
                    TicketTypeFactCode := '<BLANK>';
                Evaluate(AdmissionHour, Format(TMTicketAccessEntry."Access Time", 0, '<Hours24>'));
                TMTicketAccessStatistics.Reset();
                TMTicketAccessStatistics.SetFilter("Item No.", '=%1', ItemFactCode);
                TMTicketAccessStatistics.SetFilter("Ticket Type", '=%1', TicketTypeFactCode);
                TMTicketAccessStatistics.SetFilter("Admission Code", '=%1', TMTicketAccessEntry."Admission Code");
                TMTicketAccessStatistics.SetFilter("Admission Date", '=%1', TMTicketAccessEntry."Access Date");
                TMTicketAccessStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);
                if (TMTicketAccessStatistics.FindFirst()) then
                    AdmittedAmount += TMTicketAccessEntry.Quantity;
            until TMTicketAccessEntry.Next() = 0;
    end;
}

