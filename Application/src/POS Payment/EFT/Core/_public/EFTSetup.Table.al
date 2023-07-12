table 6184485 "NPR EFT Setup"
{
    Caption = 'EFT Setup';
    DataClassification = CustomerContent;
    LookupPageID = "NPR EFT Setup";
    DrillDownPageId = "NPR EFT Setup";

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

        field(10; Integration; Option)
        {
            OptionMembers = SG,HWC;
            OptionCaption = 'Stargate,HardwareConnector';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'No longer needed';
        }

        field(20; "Created on version"; Text[250])
        {
            Caption = 'Created on version';
            DataClassification = CustomerContent;
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
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        TestField("Payment Type POS");
        TestField("EFT Integration Type");

        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        "Created on version" := Format(CurrentModuleInfo.AppVersion);
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

    internal procedure ShowEftPOSUnitParameters()
    begin
        Commit(); //In case any parameters were just injected
        PAGE.RunModal(PAGE::"NPR EFT POSUnit Param. Setup", Rec);
    end;

    internal procedure ShowEftPaymentParameters()
    begin
        Commit(); //In case any parameters were just injected
        PAGE.RunModal(PAGE::"NPR EFT Payment Param. Setup", Rec);
    end;

    internal procedure FindSetup(POSUnitNo: Code[10]; PaymentTypePOS: Code[10])
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

    internal procedure UseAccountPostingForServices(): Boolean
    begin
        //Start enforcing new surcharge & tip G/L fields on the integration payment method to avoid receiving unpostable money from external result.
        //Only enforced starting with records created from version 13 and forward.

        if Rec."Created on version" = '' then
            exit(false);
        exit(Version.Create(Rec."Created on version").Minor >= 13);
    end;
}

