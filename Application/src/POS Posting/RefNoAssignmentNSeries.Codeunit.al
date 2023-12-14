codeunit 6184679 "NPR Ref.No. Assignment-NSeries" implements "NPR Reference No. Assignment"
{
    Access = Internal;

    procedure GetReferenceNo(POSEndofDayProfile: Record "NPR POS End of Day Profile"; RefNoTarget: Enum "NPR Reference No. Target"; Parameters: Dictionary of [Text, Text]): Text[50]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
        ReferenceNo: Code[20];
        MissingNoSeriesCodeErr: label 'Number series code must be specified when assigning reference number for %1 transaction.', Comment = 'transaction type';
    begin
        case RefNoTarget of
            RefNoTarget::EOD_BankDeposit:
                begin
                    POSEndofDayProfile.TestField("Bank Deposit Ref. Nos.");
                    NoSeriesCode := POSEndofDayProfile."Bank Deposit Ref. Nos.";
                end;
            RefNoTarget::EOD_MoveToBin:
                begin
                    POSEndofDayProfile.TestField("Move to Bin Ref. Nos.");
                    NoSeriesCode := POSEndofDayProfile."Move to Bin Ref. Nos.";
                end;
            RefNoTarget::BT_OUT_BankDeposit:
                begin
                    POSEndofDayProfile.TestField("BT OUT: Bank Deposit Ref. Nos.");
                    NoSeriesCode := POSEndofDayProfile."BT OUT: Bank Deposit Ref. Nos.";
                end;
            RefNoTarget::BT_OUT_MoveToBin:
                begin
                    POSEndofDayProfile.TestField("BT OUT: Move to Bin Ref. Nos.");
                    NoSeriesCode := POSEndofDayProfile."BT OUT: Move to Bin Ref. Nos.";
                end;
            RefNoTarget::BT_IN_FromBank:
                begin
                    POSEndofDayProfile.TestField("BT IN: Tr.from Bank Ref. Nos.");
                    NoSeriesCode := POSEndofDayProfile."BT IN: Tr.from Bank Ref. Nos.";
                end;
            RefNoTarget::BT_IN_FromBin:
                begin
                    POSEndofDayProfile.TestField("BT IN: Move fr. Bin Ref. Nos.");
                    NoSeriesCode := POSEndofDayProfile."BT IN: Move fr. Bin Ref. Nos.";
                end;
        end;
        if NoSeriesCode = '' then
            Error(MissingNoSeriesCodeErr, Format(RefNoTarget));
        POSEndofDayProfile.ValidateNoSeries(NoSeriesCode);

        NoSeriesMgt.InitSeries(NoSeriesCode, '', 0D, ReferenceNo, NoSeriesCode);
        exit(ReferenceNo);
    end;
}