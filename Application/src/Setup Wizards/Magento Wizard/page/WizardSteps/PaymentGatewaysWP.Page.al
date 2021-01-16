page 6014528 "NPR Payment Gateways WP"
{
    Caption = 'Payment Gateways';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Password field';
                }
                field("Merchant ID"; "Merchant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                }
                field("Merchant Name"; "Merchant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Name field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Capture Codeunit Id"; "Capture Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
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
                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
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
                    ToolTip = 'Specifies the value of the Cancel Codeunit Id field';
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
