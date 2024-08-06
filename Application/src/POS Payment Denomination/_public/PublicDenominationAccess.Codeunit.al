codeunit 6184981 "NPR Public Denomination Access"
{
    Access = Public;

    procedure GetDenominations(AttachedToRecordID: RecordId; AttachedToID: Enum "NPR Denomination Target"; var EntryDenomination: Record "NPR Entry Denomination")
    var
        BinTransferDenom: Record "NPR BinTransferDenomination";
        BinTransferJournal: Record "NPR BinTransferJournal";
        PaymentMethodDenom: Record "NPR Payment Method Denom";
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
        PostedBinTransferEntry: Record "NPR PostedBinTransferEntry";
        RecRef: RecordRef;
    begin
        Clear(EntryDenomination);
        EntryDenomination.DeleteAll();

        case AttachedToRecordID.TableNo() of
            Database::"NPR POS Payment Bin Checkp.":
                begin
                    RecRef.Get(AttachedToRecordID);
                    RecRef.SetTable(POSPaymentBinCheckp);
                    POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", POSPaymentBinCheckp."Entry No.");
                    POSPmtBinCheckpDenom.SetRange("Attached-to ID", AttachedToID);
                    if POSPmtBinCheckpDenom.FindSet() then
                        repeat
                            EntryDenomination.Init();
                            EntryDenomination."Denomination Type" := POSPmtBinCheckpDenom."Denomination Type";
                            EntryDenomination.Denomination := POSPmtBinCheckpDenom.Denomination;
                            EntryDenomination."Denomination Variant ID" := POSPmtBinCheckpDenom."Denomination Variant ID";
                            EntryDenomination."POS Payment Method Code" := POSPaymentBinCheckp."Payment Method No.";
                            EntryDenomination."Currency Code" := POSPmtBinCheckpDenom."Currency Code";
                            EntryDenomination.Quantity := POSPmtBinCheckpDenom.Quantity;
                            EntryDenomination.Amount := POSPmtBinCheckpDenom.Amount;
                            EntryDenomination.Insert();
                        until POSPmtBinCheckpDenom.Next() = 0;
                end;

            Database::"NPR POS Payment Method":
                begin
                    RecRef.Get(AttachedToRecordID);
                    RecRef.SetTable(POSPaymentMethod);
                    PaymentMethodDenom.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
                    PaymentMethodDenom.SetRange(Blocked, false);
                    if PaymentMethodDenom.FindSet() then
                        repeat
                            EntryDenomination.Init();
                            EntryDenomination."Denomination Type" := PaymentMethodDenom."Denomination Type";
                            EntryDenomination.Denomination := PaymentMethodDenom.Denomination;
                            EntryDenomination."Denomination Variant ID" := PaymentMethodDenom."Denomination Variant ID";
                            EntryDenomination."POS Payment Method Code" := PaymentMethodDenom."POS Payment Method Code";
                            EntryDenomination."Currency Code" := POSPaymentMethod."Currency Code";
                            EntryDenomination.Insert();
                        until PaymentMethodDenom.Next() = 0;
                end;

            Database::"NPR BinTransferJournal",
            Database::"NPR PostedBinTransferEntry":
                begin
                    RecRef.Get(AttachedToRecordID);
                    case AttachedToRecordID.TableNo() of
                        Database::"NPR BinTransferJournal":
                            begin
                                RecRef.SetTable(BinTransferJournal);
                                BinTransferDenom.SetRange(EntryNo, BinTransferJournal.EntryNo);
                                if POSPaymentMethod.Get(BinTransferJournal.PaymentMethod) then;
                            end;
                        Database::"NPR PostedBinTransferEntry":
                            begin
                                RecRef.SetTable(PostedBinTransferEntry);
                                BinTransferDenom.SetRange(EntryNo, PostedBinTransferEntry.EntryNo);
                                if POSPaymentMethod.Get(PostedBinTransferEntry.PaymentMethod) then;
                            end;
                    end;
                    if BinTransferDenom.FindSet() then
                        repeat
                            EntryDenomination.Init();
                            EntryDenomination."Denomination Type" := BinTransferDenom.DenominationType;
                            EntryDenomination.Denomination := BinTransferDenom.Denomination;
                            EntryDenomination."Denomination Variant ID" := BinTransferDenom.DenominationVariantID;
                            EntryDenomination."POS Payment Method Code" := POSPaymentMethod.Code;
                            EntryDenomination."Currency Code" := POSPaymentMethod."Currency Code";
                            EntryDenomination.Quantity := BinTransferDenom.Quantity;
                            EntryDenomination.Amount := BinTransferDenom.Amount;
                            EntryDenomination.Insert();
                        until BinTransferDenom.Next() = 0;
                end;
        end;
    end;
}