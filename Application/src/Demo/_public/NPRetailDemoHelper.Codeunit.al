codeunit 6059865 NPRDemoHelper
{
    Access = Public;

    Procedure ResetLogs()
    begin
        DemoHelperImple.ResetLogs();
    end;

    Procedure CreateMPOSUser(Username: Text; Password: Text; Company_Name: text; URL: text; POSUnit: code[20])
    begin
        DemoHelperImple.CreateMPOSUser(Username, Password, Company_Name, URL, PosUnit);
    end;

    Procedure UpdatePasswordPaymentGateway(PaymentCode: code[20]; DemoPassword: text)
    begin
        DemoHelperImple.UpdatePasswordPaymentGateway(PaymentCode, DemoPassword);
    end;

    var
        DemoHelperImple: codeunit NPRDemoHelperImplementation;
}