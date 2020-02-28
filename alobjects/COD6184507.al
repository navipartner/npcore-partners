codeunit 6184507 "EFT Shopper Recognition"
{
    // NPR5.53/TSA /20191126 CASE 378812 Initial Version


    trigger OnRun()
    begin
    end;

    procedure GetShopperReference(var EFTShopperRecognition: Record "EFT Shopper Recognition") ReferenceFound: Boolean
    var
        TmpShopperReference: Record "EFT Shopper Recognition" temporary;
    begin

        TmpShopperReference.Init;

        with EFTShopperRecognition do
          if (not GetShopperReferenceWorker ("Entity Type", "Entity Key", "Integration Type", "Contract Type", "Contract ID", TmpShopperReference)) then
            exit (false);

        if (EFTShopperRecognition."Shopper Reference" <> '') then
          if (EFTShopperRecognition."Shopper Reference" <> TmpShopperReference."Shopper Reference") then
            exit (false);

        if (EFTShopperRecognition.IsTemporary ()) then begin
          EFTShopperRecognition.Delete ();
          EFTShopperRecognition.TransferFields (TmpShopperReference, true);
          EFTShopperRecognition.Insert ();
        end else begin
          EFTShopperRecognition."Shopper Reference" := TmpShopperReference."Shopper Reference";
        end;

        exit (true);
    end;

    procedure CreateShopperReference(var EFTShopperRecognition: Record "EFT Shopper Recognition"): Boolean
    var
        ShopperReference: Text[50];
    begin

        ShopperReference := EFTShopperRecognition."Shopper Reference";

        with EFTShopperRecognition do
          if (not CreateShopperReferenceWorker ("Entity Type", "Entity Key", "Integration Type", "Contract Type", "Contract ID", ShopperReference)) then
            exit (false);

        if (EFTShopperRecognition.IsTemporary ()) then begin
          EFTShopperRecognition.Delete ();
          EFTShopperRecognition."Shopper Reference" := ShopperReference;
          EFTShopperRecognition.Insert ();
        end else begin
          EFTShopperRecognition."Shopper Reference" := ShopperReference;
        end;

        exit (true);
    end;

    local procedure GetShopperReferenceWorker(EntityType: Option;EntityKey: Code[20];IntegrationType: Text[50];ContractType: Text[50];ContractId: Text[50];var TmpEFTShopperRecognition: Record "EFT Shopper Recognition" temporary) ReferenceFound: Boolean
    var
        EFTShopperRecognition: Record "EFT Shopper Recognition";
    begin

        EFTShopperRecognition.SetFilter ("Entity Type", '=%1', EntityType);
        EFTShopperRecognition.SetFilter ("Entity Key", '=%1', EntityKey);
        EFTShopperRecognition.SetFilter ("Integration Type", '=%1', IntegrationType);

        if (ContractId <> '') then
          EFTShopperRecognition.SetFilter ("Contract ID", '=%1', ContractId);

        if (ContractType <> '') then
          EFTShopperRecognition.SetFilter ("Contract Type", '=%1', ContractType);

        if (not EFTShopperRecognition.FindFirst ()) then
          exit (false);

        TmpEFTShopperRecognition.TransferFields (EFTShopperRecognition, true);
        TmpEFTShopperRecognition.Insert ();
        exit (true);
    end;

    local procedure CreateShopperReferenceWorker(EntityType: Option;EntityKey: Code[20];IntegrationType: Text[50];ContractType: Text[50];ContractId: Text[50];var ShopperReference: Text[50]): Boolean
    var
        EFTShopperRecognition: Record "EFT Shopper Recognition";
        TmpEFTShopperRecognition: Record "EFT Shopper Recognition" temporary;
    begin

        if (ShopperReference <> '') then
          if (GetShopperReferenceWorker (EntityType, EntityKey, IntegrationType, ContractType, ContractId, TmpEFTShopperRecognition)) then
            exit (ShopperReference = TmpEFTShopperRecognition."Shopper Reference");

        if (ShopperReference = '') then
          ShopperReference := UpperCase (DelChr (Format (CreateGuid), '=', '{}-'));

        EFTShopperRecognition."Entity Type" := EntityType;
        EFTShopperRecognition.Validate ("Entity Key", EntityKey);
        EFTShopperRecognition."Integration Type" := IntegrationType;
        EFTShopperRecognition."Contract Type" := ContractType;
        EFTShopperRecognition."Contract ID" := ContractId;
        EFTShopperRecognition."Shopper Reference" := ShopperReference;
        exit (EFTShopperRecognition.Insert ());
    end;
}

