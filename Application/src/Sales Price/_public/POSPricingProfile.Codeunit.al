codeunit 6059945 "NPR POS Pricing Profile"
{
    procedure ProfileExist(POSPricingProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        Rec.SetRange(Code, POSPricingProfileCode);
        exit(not Rec.IsEmpty());
    end;

    procedure GetItemPriceFunctionIfProfileExist(POSPricingProfileCode: Code[20]; var ItemPriceCodeunitId: Integer; var ItemPriceFunction: Text[250])
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        if not Rec.Get(POSPricingProfileCode) then
            Rec.Init();
        ItemPriceCodeunitId := Rec."Item Price Codeunit ID";
        ItemPriceFunction := Rec."Item Price Function";
    end;

    procedure GetItemPriceFunction(POSPricingProfileCode: Code[20]; var ItemPriceCodeunitId: Integer; var ItemPriceFunction: Text[250])
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        Rec.Get(POSPricingProfileCode);
        ItemPriceCodeunitId := Rec."Item Price Codeunit ID";
        ItemPriceFunction := Rec."Item Price Function";
    end;

    procedure SetItemPriceFunction(POSPricingProfileCode: Code[20]; ItemPriceCodeunit: Integer; ItemPriceFunction: Text[250])
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        Rec.Get(POSPricingProfileCode);
        Rec."Item Price Codeunit ID" := ItemPriceCodeunit;
        Rec.Validate("Item Price Function", ItemPriceFunction);
        Rec.Modify();
    end;

    procedure GetCustomerPriceGroup(POSPricingProfileCode: Code[20]): Code[10]
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        Rec.Get(POSPricingProfileCode);
        exit(Rec."Customer Price Group");
    end;

    procedure GetCustomerPriceGroupIfProfileExist(POSPricingProfileCode: Code[20]): Code[10]
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        if not Rec.Get(POSPricingProfileCode) then
            Rec.Init();
        exit(Rec."Customer Price Group");
    end;

    procedure GetCustomerDiscountGroup(POSPricingProfileCode: Code[20]): Code[20]
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        Rec.Get(POSPricingProfileCode);
        exit(Rec."Customer Disc. Group");
    end;

    procedure GetCustomerDiscountGroupIfProfileExist(POSPricingProfileCode: Code[20]): Code[20]
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        if not Rec.Get(POSPricingProfileCode) then
            Rec.Init();
        exit(Rec."Customer Disc. Group");
    end;

    procedure GetCustomerGroups(POSPricingProfileCode: Code[20]; var CustomerDiscGroup: Code[20]; var CustomerPriceGroup: Code[10])
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        Rec.Get(POSPricingProfileCode);
        CustomerDiscGroup := Rec."Customer Disc. Group";
        CustomerPriceGroup := Rec."Customer Price Group";
    end;

    procedure GetCustomerGroupsIfProfileExist(POSPricingProfileCode: Code[20]; var CustomerDiscGroup: Code[20]; var CustomerPriceGroup: Code[10])
    var
        Rec: Record "NPR POS Pricing Profile";
    begin
        if not Rec.Get(POSPricingProfileCode) then
            Rec.Init();
        CustomerDiscGroup := Rec."Customer Disc. Group";
        CustomerPriceGroup := Rec."Customer Price Group";
    end;

    [IntegrationEvent(false, false)]
    procedure OnFindItemPrice(ItemPriceCodeunitId: Integer; ItemPriceFunctionName: Text[250]; SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    begin
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Line - Price", 'OnAfterAddSources', '', true, true)]
    local procedure NPRSalesLinePriceOnAfterAddSources(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; PriceType: Enum "Price Type"; var PriceSourceList: Codeunit "Price Source List")
    begin
        if PriceType = PriceType::Sale then begin
            PriceSourceList.Add("Price Source Type"::"NPR POS Price Profile", SalesHeader."NPR POS Pricing Profile");
        end;
    end;
}