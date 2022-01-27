table 6184485 "NPR EFT Setup"
{
    Access = Internal;
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Setup';
    DataClassification = CustomerContent;
    LookupPageID = "NPR EFT Setup";

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(2; "EFT Integration Type"; Code[20])
        {
            Caption = 'EFT Integration Type';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupIntegrationType();
            end;

            trigger OnValidate()
            var
                EFTInterface: Codeunit "NPR EFT Interface";
                TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
            begin
                EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
                TempEFTIntegrationType.Get("EFT Integration Type");
            end;
        }
        field(3; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
    }

    keys
    {
        key(Key1; "Payment Type POS", "POS Unit No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ClearSetupParameters();
    end;

    trigger OnInsert()
    begin
        TestField("Payment Type POS");
        TestField("EFT Integration Type");
    end;

    trigger OnModify()
    begin
        if xRec."EFT Integration Type" <> '' then
            if "EFT Integration Type" <> xRec."EFT Integration Type" then
                ClearSetupParameters();
    end;

    local procedure LookupIntegrationType()
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
    begin
        EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
        if PAGE.RunModal(0, TempEFTIntegrationType) = ACTION::LookupOK then
            "EFT Integration Type" := TempEFTIntegrationType.Code;
    end;

    procedure ShowEftPOSUnitParameters()
    begin
        Commit(); //In case any parameters were just injected
        PAGE.RunModal(PAGE::"NPR EFT POSUnit Param. Setup", Rec);
    end;

    procedure ShowEftPaymentParameters()
    begin
        Commit(); //In case any parameters were just injected
        PAGE.RunModal(PAGE::"NPR EFT Payment Param. Setup", Rec);
    end;

    procedure FindSetup(POSUnitNo: Code[10]; PaymentTypePOS: Code[10])
    begin
        if Get(PaymentTypePOS, POSUnitNo) then
            exit;
        Get(PaymentTypePOS, '');
    end;

    local procedure ClearSetupParameters()
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        EFTTypePOSUnitGenParam.SetRange("Integration Type", "EFT Integration Type");
        EFTTypePOSUnitGenParam.SetRange("POS Unit No.", "POS Unit No.");
        EFTTypePOSUnitGenParam.DeleteAll();

        EFTTypePOSUnitBLOBParam.SetRange("Integration Type", "EFT Integration Type");
        EFTTypePOSUnitBLOBParam.SetRange("POS Unit No.", "POS Unit No.");
        EFTTypePOSUnitBLOBParam.DeleteAll();
    end;
}

