report 6014534 "NPR TM DeferBatchAddTicket"
{
    Caption = 'Add Tickets to Deferral';
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = true;
#if not BC17
    Extensible = false;
#endif

    dataset
    {
        dataitem(TicketType; "NPR TM Ticket Type")
        {
            DataItemTableView = SORTING(Code) ORDER(Ascending);
            RequestFilterFields = Code, DeferRevenueProfileCode;
            RequestFilterHeading = 'Ticket Type Code,Defer Revenue Profile Code';

            trigger OnAfterGetRecord()
            begin
                _TicketsCount += BatchAddTicketsToDeferral(TicketType.Code, _FromTicketIssuedDate);
            end;

            trigger OnPreDataItem()
            begin
                SetFilter("Defer Revenue", '=%1', true);
            end;
        }

    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(IncludeFromDate; _FromTicketIssuedDate)
                    {
                        Caption = 'From Ticket Issued Date';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the From Ticket Issued Date field.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            _FromTicketIssuedDate := Today();
        end;
    }

    trigger OnPostReport()
    var
        ConfirmMessage: Label '%1 Tickets Added to Deferral, do you want to view the unhandled Deferral Entries?';
        NothingAddedMessage: Label 'No Tickets Added to Deferral.';
        DeferEntriesPage: Page "NPR TM RevenueRecognition";
        RevenueRecognition: Record "NPR TM DeferRevenueRequest";
    begin
        if (_TicketsCount > 0) then begin
            if (Confirm(ConfirmMessage, true, _TicketsCount)) then begin
                RevenueRecognition.SetCurrentKey(Status);
                RevenueRecognition.SetFilter(Status, '=%1', RevenueRecognition.Status::REGISTERED);
                DeferEntriesPage.SetTableView(RevenueRecognition);
                DeferEntriesPage.Run();
            end;
        end else begin
            Message(NothingAddedMessage);
        end;
    end;

    var
        _FromTicketIssuedDate: Date;
        _TicketsCount: Integer;

    local procedure BatchAddTicketsToDeferral(TicketTypeCode: Code[20]; FromTicketIssuedDate: Date): Integer
    var
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        RequiredDate: Label 'From Ticket Issued Date is required.';
    begin
        if (FromTicketIssuedDate = 0D) then
            Error(RequiredDate);

        exit(DeferRevenue.AddAllTicketsToDeferral(TicketTypeCode, FromTicketIssuedDate));
    end;
}