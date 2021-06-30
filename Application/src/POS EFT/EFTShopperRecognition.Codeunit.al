codeunit 6184507 "NPR EFT Shopper Recognition"
{
    // NPR5.53/TSA /20191126 CASE 378812 Initial Version


    trigger OnRun()
    begin
    end;

    procedure GetShopperReference(var EFTShopperRecognition: Record "NPR EFT Shopper Recognition") ReferenceFound: Boolean
    var
        TempShopperReference: Record "NPR EFT Shopper Recognition" temporary;
    begin

        TempShopperReference.Init();

        if (not GetShopperReferenceWorker(EFTShopperRecognition."Entity Type", EFTShopperRecognition."Entity Key", EFTShopperRecognition."Integration Type", EFTShopperRecognition."Contract Type", EFTShopperRecognition."Contract ID", TempShopperReference)) then
            exit(false);

        if (EFTShopperRecognition."Shopper Reference" <> '') then
            if (EFTShopperRecognition."Shopper Reference" <> TempShopperReference."Shopper Reference") then
                exit(false);

        if (EFTShopperRecognition.IsTemporary()) then begin
            EFTShopperRecognition.Delete();
            EFTShopperRecognition.TransferFields(TempShopperReference, true);
            EFTShopperRecognition.Insert();
        end else begin
            EFTShopperRecognition."Shopper Reference" := TempShopperReference."Shopper Reference";
        end;

        exit(true);
    end;

    procedure CreateShopperReference(var EFTShopperRecognition: Record "NPR EFT Shopper Recognition"): Boolean
    var
        ShopperReference: Text[50];
    begin

        ShopperReference := EFTShopperRecognition."Shopper Reference";

        if (not CreateShopperReferenceWorker(EFTShopperRecognition."Entity Type", EFTShopperRecognition."Entity Key", EFTShopperRecognition."Integration Type", EFTShopperRecognition."Contract Type", EFTShopperRecognition."Contract ID", ShopperReference)) then
            exit(false);

        if (EFTShopperRecognition.IsTemporary()) then begin
            EFTShopperRecognition.Delete();
            EFTShopperRecognition."Shopper Reference" := ShopperReference;
            EFTShopperRecognition.Insert();
        end else begin
            EFTShopperRecognition."Shopper Reference" := ShopperReference;
        end;

        exit(true);
    end;

    local procedure GetShopperReferenceWorker(EntityType: Option; EntityKey: Code[20]; IntegrationType: Text[50]; ContractType: Text[50]; ContractId: Text[50]; var TmpEFTShopperRecognition: Record "NPR EFT Shopper Recognition" temporary): Boolean
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
    begin

        EFTShopperRecognition.SetFilter("Entity Type", '=%1', EntityType);
        EFTShopperRecognition.SetFilter("Entity Key", '=%1', EntityKey);
        EFTShopperRecognition.SetFilter("Integration Type", '=%1', IntegrationType);

        if (ContractId <> '') then
            EFTShopperRecognition.SetFilter("Contract ID", '=%1', ContractId);

        if (ContractType <> '') then
            EFTShopperRecognition.SetFilter("Contract Type", '=%1', ContractType);

        if (not EFTShopperRecognition.FindFirst()) then
            exit(false);

        TmpEFTShopperRecognition.TransferFields(EFTShopperRecognition, true);
        TmpEFTShopperRecognition.Insert();
        exit(true);
    end;

    local procedure CreateShopperReferenceWorker(EntityType: Option; EntityKey: Code[20]; IntegrationType: Text[50]; ContractType: Text[50]; ContractId: Text[50]; var ShopperReference: Text[50]): Boolean
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        TempEFTShopperRecognition: Record "NPR EFT Shopper Recognition" temporary;
    begin

        if (ShopperReference <> '') then
            if (GetShopperReferenceWorker(EntityType, EntityKey, IntegrationType, ContractType, ContractId, TempEFTShopperRecognition)) then
                exit(ShopperReference = TempEFTShopperRecognition."Shopper Reference");

        if (ShopperReference = '') then
            ShopperReference := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        EFTShopperRecognition."Entity Type" := EntityType;
        EFTShopperRecognition.Validate("Entity Key", EntityKey);
        EFTShopperRecognition."Integration Type" := IntegrationType;
        EFTShopperRecognition."Contract Type" := ContractType;
        EFTShopperRecognition."Contract ID" := ContractId;
        EFTShopperRecognition."Shopper Reference" := ShopperReference;
        exit(EFTShopperRecognition.Insert());
    end;
}

