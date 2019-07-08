page 6150620 "POS Payment Bins"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.36/BR/20170810 CASE 277096 Added Action to navigate to POS Posting Setup
    // NPR5.40/MMV /20180302 CASE 300660 Added field opening method and action for setting parameters
    // NPR5.40/TSA /20180306 CASE 307267 Added transfer content button
    // NPR5.40/TSA /20180306 CASE 307267 Added Bin Type field
    // NPR5.41/MMV /20180425 CASE 312990 Renamed action

    Caption = 'POS Payment Bins';
    PageType = List;
    SourceTable = "POS Payment Bin";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("Attached to POS Unit No.";"Attached to POS Unit No.")
                {
                }
                field("Eject Method";"Eject Method")
                {
                }
                field("Bin Type";"Bin Type")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(POSPostingSetup)
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Posting Setup";
                RunPageLink = "POS Payment Bin Code"=FIELD("No.");
            }
            action(EjectMethodParameters)
            {
                Caption = 'Eject Method Parameters';
                Image = Answers;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POSPaymentBinInvokeMgt: Codeunit "POS Payment Bin Eject Mgt.";
                begin
                    //-NPR5.40 [300660]
                    POSPaymentBinInvokeMgt.OnShowInvokeParameters(Rec);
                    //+NPR5.40 [300660]
                end;
            }
        }
        area(processing)
        {
            action("Transfer Out From Bin")
            {
                Caption = 'Transfer Out From Bin';
                Ellipsis = true;
                Image = TransferFunds;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    TransferContentsToBin ("No.");
                end;
            }
        }
    }

    local procedure TransferContentsToBin(FromBinNo: Code[10])
    var
        CheckpointEntryNo: Integer;
        PaymentBinCheckpoint: Codeunit "POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Codeunit "POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "POS Create Entry";
        PaymentBinCheckpointPage: Page "POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        PageAction: Action;
        SalePOS: Record "Sale POS";
    begin

        //-NPR5.40 [307267]
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry ('');
        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint ('', "No.", CheckpointEntryNo);
        Commit;

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset ();
        POSPaymentBinCheckpoint.FilterGroup (2);
        POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup (0);
        PaymentBinCheckpointPage.SetTableView (POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode (true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit;

        if (PageAction = ACTION::LookupOK) then begin
          POSPaymentBinCheckpoint.Reset ();
          POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
          POSPaymentBinCheckpoint.SetFilter (Status, '=%1' , POSPaymentBinCheckpoint.Status::READY);
          if (POSPaymentBinCheckpoint.FindFirst ()) then begin
            SalePOS."Register No." := 'TMP';
            SalePOS."POS Store Code" := 'TMP';
            SalePOS.Date := Today;
            SalePOS."Sales Ticket No." := DelChr (Format (CurrentDateTime(), 0, 9), '<=>', DelChr (Format (CurrentDateTime(), 0, 9), '<=>', '01234567890'));

            POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, true, CheckpointEntryNo);
          end;
        end;
        //+NPR5.40 [307267]
    end;
}

