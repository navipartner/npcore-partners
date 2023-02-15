table 6151587 "NPR BinTransferDenomination"
{
    DataClassification = ToBeClassified;
    Access = Internal;
    Caption = 'Bin Transfer Denomination';
    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; POSPaymentMethodCode; Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "NPR POS Payment Method".Code;
            DataClassification = CustomerContent;
        }
        field(20; DenominationType; Enum "NPR Denomination Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(22; DenominationVariantID; Code[20])
        {
            Caption = 'Denomination Variant ID';
            DataClassification = CustomerContent;
        }
        field(40; Denomination; Decimal)
        {
            Caption = 'Denomination';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(30; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                Amount := Quantity * Denomination;
            end;
        }
        field(31; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = POSPaymentMethodCode;
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField(Denomination);
                Validate(Quantity, Round(Amount / Denomination, 1, '<'));
            end;
        }
    }
    keys
    {
        key(Key1; EntryNo, POSPaymentMethodCode, DenominationType, Denomination, DenominationVariantID)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        BinTransferJournal: Record "NPR BinTransferJournal";
        NotAllowed: Label '%1 must be in status %2 to allow delete.';
    begin

        if (BinTransferJournal.Get(Rec.EntryNo)) then
            if (BinTransferJournal.Status <> BinTransferJournal.Status::OPEN) then
                Error(NotAllowed, BinTransferJournal.TableCaption, BinTransferJournal.Status::OPEN);

    end;

}