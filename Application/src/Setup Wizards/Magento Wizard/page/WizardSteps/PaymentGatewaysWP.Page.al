page 6014528 "NPR Payment Gateways WP"
{
    Extensible = False;
    Caption = 'Payment Gateways';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Payment Gateway";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Desctiption; Rec.Description)
                {

                    ToolTip = 'Specifies description';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Type"; Rec."Integration Type")
                {

                    ToolTip = 'Specifies the payment gateway integration type';
                    ApplicationArea = NPRRetail;
                }
                field("Api Url"; Rec."Api Url")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Username"; Rec."Api Username")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                }
                field(Password; Password)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.SetApiPassword(Password);
                        Commit();
                    end;
                }
                field("Merchant ID"; Rec."Merchant ID")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Capture Codeunit Id"; Rec."Capture Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Capture]';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "NPR All Objects Select";
                    begin
                        AllObjects.LookupMode := true;
                        AllObjects.Editable := false;

                        if Rec."Capture Codeunit Id" = 0 then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                        if AllObj.FindSet() then;
                        AllObjects.SetRec(AllObj);

                        if Rec."Capture Codeunit Id" <> 0 then
                            if AllObj.Get(Rec."Capture Codeunit Id") then
                                AllObjects.SetRecord(AllObj);

                        if AllObjects.RunModal() = Action::LookupOK then begin
                            AllObjects.GetRecord(AllObj);
                            Rec."Capture Codeunit Id" := AllObj."Object ID";
                        end;
                    end;
                }
                field("Refund Codeunit Id"; Rec."Refund Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Refund]';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "NPR All Objects Select";
                    begin
                        AllObjects.LookupMode := true;
                        AllObjects.Editable := false;

                        if Rec."Refund Codeunit Id" = 0 then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                        if AllObj.FindSet() then;
                        AllObjects.SetRec(AllObj);

                        if Rec."Refund Codeunit Id" <> 0 then
                            if AllObj.Get(Rec."Refund Codeunit Id") then
                                AllObjects.SetRecord(AllObj);

                        if AllObjects.RunModal() = Action::LookupOK then begin
                            AllObjects.GetRecord(AllObj);
                            Rec."Refund Codeunit Id" := AllObj."Object ID";
                        end;
                    end;
                }
                field("Cancel Codeunit Id"; Rec."Cancel Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Cancel]';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Cancel Codeunit Id field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "NPR All Objects Select";
                    begin
                        AllObjects.LookupMode := true;
                        AllObjects.Editable := false;

                        if Rec."Cancel Codeunit Id" = 0 then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                        if AllObj.FindSet() then;
                        AllObjects.SetRec(AllObj);

                        if Rec."Cancel Codeunit Id" <> 0 then
                            if AllObj.Get(Rec."Cancel Codeunit Id") then
                                AllObjects.SetRecord(AllObj);

                        if AllObjects.RunModal() = Action::LookupOK then begin
                            AllObjects.GetRecord(AllObj);
                            Rec."Cancel Codeunit Id" := AllObj."Object ID";
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Password := '';
        if not IsNullGuid(Rec."Api Password Key") then
            Password := '***';
    end;

    var
        Password: Text[200];

    internal procedure CreateMagentoPaymentGatewayData()
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

    internal procedure MagentoPaymentGatewayDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CopyRealAndTemp(var TempMagentoPaymentGateway: Record "NPR Magento Payment Gateway")
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
