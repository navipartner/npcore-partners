table 6151584 "NPR BinTransferJournal"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Bin Payment Transfer Journal';

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(5; DocumentNo; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        Field(10; StoreCode; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(12; ReceiveFromPosUnitCode; Code[10])
        {
            Caption = 'Receive from POS Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pos Unit"."No.";

            trigger OnValidate()
            var
                PosUnit: Record "NPR POS Unit";
            begin
                if not PosUnit.Get(Rec.ReceiveFromPosUnitCode) then
                    exit;
                TransferFromBinCode := PosUnit."Default POS Payment Bin";
            end;
        }
        Field(15; TransferFromBinCode; Code[10])
        {
            Caption = 'Transfer from Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin"."No." where("Attached to POS Unit No." = field(ReceiveFromPosUnitCode));
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                Bin: Record "NPR POS Payment Bin";
            begin
                if TransferFromBinCode = '' then
                    exit;
                Bin.Get(TransferFromBinCode);
                if Bin."Bin Type" = Bin."Bin Type"::CASH_DRAWER then
                    TestField(ReceiveFromPosUnitCode)
                else
                    ReceiveFromPosUnitCode := '';
            end;
        }
        field(20; ReceiveAtPosUnitCode; Code[10])
        {
            Caption = 'Receive at POS Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pos Unit"."No." where("POS Store Code" = field(StoreCode));

            trigger OnValidate()
            var
                PosUnit: Record "NPR POS Unit";
            begin
                if not PosUnit.Get(ReceiveFromPosUnitCode) then
                    exit;
                ReceiveAtPosUnitCode := PosUnit."Default POS Payment Bin";
            end;
        }
        Field(25; TransferToBinCode; Code[10])
        {
            Caption = 'Transfer to Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin"."No." where("Attached to POS Unit No." = field(ReceiveAtPosUnitCode));
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                Bin: Record "NPR POS Payment Bin";
            begin
                if TransferToBinCode = '' then
                    exit;
                Bin.Get(TransferToBinCode);
                if Bin."Bin Type" = Bin."Bin Type"::CASH_DRAWER then
                    TestField(ReceiveAtPosUnitCode)
                else
                    ReceiveAtPosUnitCode := '';
            end;
        }
        Field(30; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        Field(50; PaymentMethod; Code[10])
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method"."Code";
            ValidateTableRelation = true;
        }
        Field(60; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        Field(90; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = OPEN,RELEASED,RECEIVED;
            OptionCaption = 'Open,Released,Received';
        }
        field(91; ExternalDocumentNo; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(100; CreatedBy; Code[100])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        Field(110; "Original TransferFromBinCode"; Code[10])
        {
            Caption = 'Original Trans. from Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin"."No." where("Bin Type" = const(CASH_DRAWER));
        }
        field(200; HasDenomination; Boolean)
        {
            Caption = 'Has Denomination';
            FieldClass = FlowField;
            CalcFormula = exist("NPR BinTransferDenomination" where(EntryNo = Field(EntryNo)));
        }
        field(201; DenominationSum; Decimal)
        {
            Caption = 'Has Denomination';
            FieldClass = FlowField;
            CalcFormula = sum("NPR BinTransferDenomination".Amount where(EntryNo = Field(EntryNo)));
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        BinTransferSetup: Record "NPR Bin Transfer Profile";
        BinTransferJournal: Record "NPR BinTransferJournal";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin
        if (Rec.IsTemporary()) then
            exit;

        if (not BinTransferSetup.Get()) then
            BinTransferSetup.Init();

        CreatedBy := CopyStr(UserId(), 1, MaxStrLen(CreatedBy));
        Description := DefaultDescription();

        if (Rec.DocumentNo = '') then
            if (BinTransferJournal.FindLast()) then
                Rec.DocumentNo := BinTransferJournal.DocumentNo;

        if ((Rec.DocumentNo = '') and (BinTransferSetup.DocumentNoSeries <> '')) then
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            Rec.DocumentNo := NoSeriesManagement.GetNextNo(BinTransferSetup.DocumentNoSeries, Today(), false);
#ELSE
            Rec.DocumentNo := NoSeriesManagement.GetNextNo(BinTransferSetup.DocumentNoSeries, Today(), true);
#ENDIF
    end;

    trigger OnModify()
    begin
        if (Rec.IsTemporary()) then
            exit;

        TestField(Status, Rec.Status::OPEN);
        Description := DefaultDescription();
    end;

    trigger OnDelete()
    var
        TransferDenomination: Record "NPR BinTransferDenomination";
    begin
        if (Rec.IsTemporary()) then
            exit;

        Rec.TestField(Status, Rec.Status::OPEN);
        Rec.CalcFields(HasDenomination);
        if (HasDenomination) then begin
            TransferDenomination.SetFilter(EntryNo, '=%1', Rec.EntryNo);
            TransferDenomination.DeleteAll();
        end;
    end;

    internal procedure DefaultDescription() AutoDesc: Text[80]
    begin
        if "Original TransferFromBinCode" <> '' then
            exit(CopyStr(StrSubstNo('Transfer %2 %1 / %3 -> %4', PaymentMethod, Amount, "Original TransferFromBinCode", TransferToBinCode), 1, MaxStrLen(AutoDesc)));
        exit(CopyStr(StrSubstNo('Transfer %2 %1 / %3 -> %4', PaymentMethod, Amount, TransferFromBinCode, TransferToBinCode), 1, MaxStrLen(AutoDesc)));
    end;
}