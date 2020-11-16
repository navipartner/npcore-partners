page 6014528 "NPR Payment Gateways WP"
{
    Caption = 'Payment Gateways';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Payment Gateway";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                }
                field("Merchant ID"; "Merchant ID")
                {
                    ApplicationArea = All;
                }
                field("Merchant Name"; "Merchant Name")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Capture Codeunit Id"; "Capture Codeunit Id")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "NPR All Objects Select";
                    begin
                        AllObjects.LookupMode := true;
                        AllObjects.Editable := false;

                        if "Capture Codeunit Id" = 0 then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                        if AllObj.FindSet() then;
                        AllObjects.SetRec(AllObj);

                        if "Capture Codeunit Id" <> 0 then
                            if AllObj.Get("Capture Codeunit Id") then
                                AllObjects.SetRecord(AllObj);

                        if AllObjects.RunModal() = Action::LookupOK then begin
                            AllObjects.GetRecord(AllObj);
                            "Capture Codeunit Id" := AllObj."Object ID";
                        end;
                    end;
                }
                field("Refund Codeunit Id"; "Refund Codeunit Id")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "NPR All Objects Select";
                    begin
                        AllObjects.LookupMode := true;
                        AllObjects.Editable := false;

                        if "Refund Codeunit Id" = 0 then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                        if AllObj.FindSet() then;
                        AllObjects.SetRec(AllObj);

                        if "Refund Codeunit Id" <> 0 then
                            if AllObj.Get("Refund Codeunit Id") then
                                AllObjects.SetRecord(AllObj);

                        if AllObjects.RunModal() = Action::LookupOK then begin
                            AllObjects.GetRecord(AllObj);
                            "Refund Codeunit Id" := AllObj."Object ID";
                        end;
                    end;
                }
                field("Cancel Codeunit Id"; "Cancel Codeunit Id")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "NPR All Objects Select";
                    begin
                        AllObjects.LookupMode := true;
                        AllObjects.Editable := false;

                        if "Cancel Codeunit Id" = 0 then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                        if AllObj.FindSet() then;
                        AllObjects.SetRec(AllObj);

                        if "Cancel Codeunit Id" <> 0 then
                            if AllObj.Get("Cancel Codeunit Id") then
                                AllObjects.SetRecord(AllObj);

                        if AllObjects.RunModal() = Action::LookupOK then begin
                            AllObjects.GetRecord(AllObj);
                            "Cancel Codeunit Id" := AllObj."Object ID";
                        end;
                    end;
                }
            }
        }
    }
    procedure CreateMagentoPaymentGatewayData()
    var
        MagentoCustomerGateway: Record "NPR Magento Payment Gateway";
    begin
        if Rec.FindSet() then
            repeat
                MagentoCustomerGateway := Rec;
                if not MagentoCustomerGateway.Insert() then
                    MagentoCustomerGateway.Modify();
            until Rec.Next() = 0;
    end;

    procedure MagentoPaymentGatewayDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempMagentoPaymentGateway: Record "NPR Magento Payment Gateway")
    var
        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        TempMagentoPaymentGateway.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMagentoPaymentGateway := Rec;
                TempMagentoPaymentGateway.Insert();
            until Rec.Next() = 0;

        TempMagentoPaymentGateway.Init();
        if MagentoPaymentGateway.FindSet() then
            repeat
                TempMagentoPaymentGateway.TransferFields(MagentoPaymentGateway);
                TempMagentoPaymentGateway.Insert();
            until MagentoPaymentGateway.Next() = 0;
    end;
}