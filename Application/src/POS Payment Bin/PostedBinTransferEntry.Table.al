table 6151585 "NPR PostedBinTransferEntry"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Posted POS Payment Bin Transfer Journal';

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
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
        }

        Field(15; TransferFromBinCode; Code[10])
        {
            Caption = 'Transfer from Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin"."No.";
        }

        field(20; ReceiveAtPosUnitCode; Code[10])
        {
            Caption = 'Receive at POS Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pos Unit"."No.";
        }

        Field(25; TransferToBinCode; Code[10])
        {
            Caption = 'Transfer to Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin"."No.";
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
        }

        Field(60; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
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
        field(101; TransferredBy; Code[100])
        {
            Caption = 'Transferred By';
            DataClassification = CustomerContent;
        }

        Field(105; TransferredAt; Datetime)
        {
            Caption = 'Transfer Datetime';
            DataClassification = CustomerContent;
        }

        field(200; HasDenomination; Boolean)
        {
            Caption = 'Has Denomination';
            FieldClass = FlowField;
            CalcFormula = exist("NPR BinTransferDenomination" where(EntryNo = Field(EntryNo)));
        }

    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
    }

}