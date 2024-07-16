report 6014467 "NPR Sales Price Maint. Process"
{
    Caption = 'Sales Price Maintenance Process';
#IF NOT BC17
    Extensible = False;
#ENDIF
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(SalesPriceMaintSetup; "NPR Sales Price Maint. Setup")
        {
            RequestFilterFields = id;
        }
        dataitem(i; Integer)
        {
            MaxIteration = 1;
            DataItemTableView = sorting(Number);
            trigger OnPreDataItem()
            begin
                if GuiAllowed then
                    if not Confirm(RunProcessConfirmLbl, false) then
                        Error('');
            end;

            trigger OnPostDataItem()
            var
                Item: Record Item;
                SalesPriceMaintEvent: Codeunit "NPR Sales Price Maint. Event";
                ItemCounter: Integer;
            begin
                SetBackgroundJobOnHold();

                Item.SetRange(Blocked, false);

                if GuiAllowed then begin
                    Window.Open(ProgressLbl);
                    Window.Update(2, Item.Count());
                end;

                if Item.FindSet() then
                    repeat
                        if GuiAllowed then begin
                            ItemCounter += 1;
                            Window.Update(1, ItemCounter);
                            Window.Update(3, Item."No.");
                        end;
                        if CheckShouldUpdateItemPrice(Item) then
                            SalesPriceMaintEvent.UpdateSalesPricesForStaff(Item, SalesPriceMaintSetup, false);
                    until Item.Next() = 0;

                SetBackgroundJobReady();

                if GuiAllowed then begin
                    Window.Close();
                    Message(DoneLbl);
                end;
            end;
        }
    }

    var
        Window: Dialog;
        RunProcessConfirmLbl: Label 'This action will directly start updating prices for all existing items. It is recommended to schedule this report to run in the background, during the night instead. Are you sure you want to continue?';
        DoneLbl: Label 'Process completed successfully.';
        ProgressLbl: Label 'Processing #1 of #2\\ Current Item No.: #3';

    local procedure CheckShouldUpdateItemPrice(Item: Record Item): Boolean
    begin
        exit((Item."Unit Cost" <> 0) or
         (Item."Last Direct Cost" <> 0) or
         (Item."Unit Price" <> 0) or
         (Item."Standard Cost" <> 0) or
         (Item."Item Category Code" <> ''));
    end;

    local procedure SetBackgroundJobOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if FindBackgroundJob(JobQueueEntry) then
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
    end;

    local procedure SetBackgroundJobReady()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if FindBackgroundJob(JobQueueEntry) then
            JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;

    local procedure FindBackgroundJob(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Sales Price Maint. Event");
        exit(JobQueueEntry.FindFirst());
    end;

}
