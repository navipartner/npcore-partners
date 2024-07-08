codeunit 6059865 NPRDemoHelper
{
    Access = Public;

    procedure CreateMPOSUser(Username: Text; Password: Text; Company_Name: text; URL: text; POSUnit: code[20])
    begin
        DemoHelperImple.CreateMPOSUser(Username, Password, Company_Name, URL, PosUnit);
    end;

    procedure UpdatePasswordPaymentGateway(PaymentCode: code[20]; DemoPassword: text)
    begin
        DemoHelperImple.UpdatePasswordPaymentGateway(PaymentCode, DemoPassword);
    end;

    procedure UpdatePasswordCollectStores(StoreCode: code[20]; DemoPassword: text)
    begin
        DemoHelperImple.UpdatePasswordCollectStore(StoreCode, DemoPassword);
    end;

    var
        DemoHelperImple: codeunit NPRDemoHelperImplementation;
}