report 6014472 "NPR TM Block Unused Tickets"
{
    Caption = 'Block Unused Expired Tickets';
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = true;
    Extensible = false;

    dataset
    {
        dataitem(Ticket; "NPR TM Ticket")
        {
            DataItemTableView = sorting("Document Date");
            RequestFilterFields = "Document Date", "Ticket Type Code", "Valid To Date";

            trigger OnPreDataItem()
            var
                RetentionTicketData: Codeunit "NPR TM Retention Ticket Data";
            begin
                // Whatever the user filters on, only tickets the cleanup would consider can be blocked here.
                Ticket.FilterGroup(2);
                Ticket.SetFilter("Valid To Date", '<%1', RetentionTicketData.GetCutoffDate());
                Ticket.SetFilter(Blocked, '=%1', false);
                Ticket.FilterGroup(0);

                // Once the transaction has written a ticket, the scan would otherwise lock every ticket it reads.
                Ticket.ReadIsolation := IsolationLevel::ReadUncommitted;
            end;

            trigger OnAfterGetRecord()
            var
                TicketUpdate: Record "NPR TM Ticket";
            begin
                // A fully used ticket is already deleted by the cleanup.
                if (not HasUnusedAdmission(Ticket."No.")) then
                    CurrReport.Skip();

                TicketUpdate.ReadIsolation := IsolationLevel::UpdLock;
                if (not TicketUpdate.Get(Ticket."No.")) then
                    CurrReport.Skip();

                TicketUpdate.Blocked := true;
                TicketUpdate."Blocked Date" := Today();
                TicketUpdate.Modify();

                _BlockedCount += 1;
                // A single transaction over this many tickets would escalate to a lock on the whole ticket table.
                if (_BlockedCount mod 1000 = 0) then
                    Commit();
            end;
        }
    }

    trigger OnPostReport()
    begin
        Message(BlockedMsg, _BlockedCount);
    end;

    local procedure HasUnusedAdmission(TicketNo: Code[20]): Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Access Date", '=%1', 0D);
        exit(not TicketAccessEntry.IsEmpty());
    end;

    var
        _BlockedCount: Integer;
        BlockedMsg: Label '%1 ticket(s) were blocked.', Comment = '%1 = the number of tickets blocked';
}
