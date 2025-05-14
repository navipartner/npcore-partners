#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248435 "NPR APIPOSStore"
{
    Access = Internal;

    internal procedure GetPOSStores(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSStore: Record "NPR POS Store";
        POSStoreFields: Dictionary of [Integer, Text];
    begin
        POSStoreFields.Add(POSStore.FieldNo(SystemId), 'id');
        POSStoreFields.Add(POSStore.FieldNo(Code), 'code');
        POSStoreFields.Add(POSStore.FieldNo(Name), 'name');
        POSStoreFields.Add(POSStore.FieldNo(Address), 'address');
        POSStoreFields.Add(POSStore.FieldNo("Address 2"), 'address2');
        POSStoreFields.Add(POSStore.FieldNo("Post Code"), 'postCode');
        POSStoreFields.Add(POSStore.FieldNo(City), 'city');
        POSStoreFields.Add(POSStore.FieldNo(County), 'county');
        POSStoreFields.Add(POSStore.FieldNo("Country/Region Code"), 'countryCode');
        POSStoreFields.Add(POSStore.FieldNo("VAT Registration No."), 'vatRegistrationNo');
        exit(Response.RespondOK(Request.GetData(Database::"NPR POS Store", POSStoreFields)));
    end;
}
#endif