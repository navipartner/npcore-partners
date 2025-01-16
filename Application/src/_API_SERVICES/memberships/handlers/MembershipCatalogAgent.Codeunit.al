#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22   
codeunit 6248219 "NPR MembershipCatalogAgent"
{
    Access = Internal;


    internal procedure GetMembershipCatalog(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipSalesSetupFilter: Record "NPR MM Members. Sales Setup";
        StoreCode: Code[32];
        ItemNumber: Code[20];
    begin
        StoreCode := '';
        ItemNumber := '';
        if (Request.Paths().Count() = 3) then
            StoreCode := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(StoreCode));

        if (Request.QueryParams().ContainsKey('itemNumber')) then begin
            ItemNumber := CopyStr(UpperCase(Request.QueryParams().Get('itemNumber')), 1, MaxStrLen(ItemNumber));
            MembershipSalesSetupFilter.SetFilter("No.", '=%1', ItemNumber);
        end;

        exit(Response.RespondOK(GetCatalogDTO(MembershipSalesSetupFilter, StoreCode).Build()));

    end;

    local procedure GetCatalogDTO(var MembershipSalesSetupFilter: Record "NPR MM Members. Sales Setup"; StoreCode: Code[32]) ResponseJson: Codeunit "NPR JSON Builder";
    var
    begin
        ResponseJson.StartObject()
            .AddProperty('storeCode', StoreCode)
            .AddArray(CatalogItems('items', MembershipSalesSetupFilter, ResponseJson))
            .EndObject();
    end;

    local procedure CatalogItems(ArrayName: Text; var MembershipSalesSetupFilter: Record "NPR MM Members. Sales Setup"; ResponseJson: Codeunit "NPR JSON Builder"): Codeunit "NPR JSON Builder"
    var
        Item: Record "Item";
    begin
        ResponseJson.StartArray(ArrayName);
        if (MembershipSalesSetupFilter.FindSet()) then begin
            repeat
                if (not Item.Get(MembershipSalesSetupFilter."No.")) then
                    Item.Init();

                ResponseJson.StartObject()
                    .AddProperty('itemNumber', MembershipSalesSetupFilter."No.")
                    .AddProperty('type', BusinessFlowToText(MembershipSalesSetupFilter."Business Flow Type"))
                    .AddProperty('recommendedPrice', Item."Unit Price")
                    .AddProperty('membershipCode', MembershipSalesSetupFilter."Membership Code")
                    .AddProperty('itemDescription', Item.Description)
                    .AddProperty('shortDescription', GetShortDescription(Item))
                    .AddProperty('fullDescription', GetFullDescription(Item))
                    .EndObject();
            until (MembershipSalesSetupFilter.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    local procedure GetShortDescription(var Item: Record "Item") Description: Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        if (not Item."NPR Magento Short Desc.".HasValue()) then
            exit('');

        TempBlob.CreateOutStream(OutStr);
        Item."NPR Magento Short Desc.".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);
        InStr.Read(Description);
    end;

    local procedure GetFullDescription(var Item: Record "Item") Description: Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        if (not Item."NPR Magento Desc.".HasValue()) then
            exit('');

        TempBlob.CreateOutStream(OutStr);
        Item."NPR Magento Desc.".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);
        InStr.Read(Description);
    end;

    local procedure BusinessFlowToText(BusinessFlowType: Option): Text
    var
        SalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        case BusinessFlowType of
            SalesSetup."Business Flow Type"::MEMBERSHIP:
                exit('newMembership');
            SalesSetup."Business Flow Type"::ADD_CARD:
                exit('addCard');
            SalesSetup."Business Flow Type"::REPLACE_CARD:
                exit('replaceCard');
            SalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                exit('addAnonymousMember');
            SalesSetup."Business Flow Type"::ADD_NAMED_MEMBER:
                exit('addNamedMember');
        end;
    end;
}
#endif