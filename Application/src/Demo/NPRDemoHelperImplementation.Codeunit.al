codeunit 6059866 "NPRDemoHelperImplementation"
{
    Access = Internal;

    procedure CreateMPOSUser(Username: Text; Password: Text; Company_Name: text; URL: text; POSUnit: code[20])
    var
        MPOSUser: Record "NPR MPOS QR Codes";
        Usersetup: Record "User Setup";
    begin

        if not UserSetup.Get(Username) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(Username, 1, MaxStrLen(Usersetup."User ID"));
            Usersetup."NPR POS Unit No." := CopyStr(POSUnit, 1, MaxStrLen(Usersetup."NPR POS Unit No."));
            UserSetup.Insert(true);
        end;

        if not MPOSUser.Get(Username, Company_Name) then begin
            MPOSUser.init();
            MPOSUser.validate("User ID", CopyStr(Username, 1, MaxStrLen(MPOSUser."User ID")));
            MPOSUser.validate(Password, CopyStr(Password, 1, MaxStrLen(MPOSUser.Password)));
            MPOSUser.validate(Company, CopyStr(Company_Name, 1, MaxStrLen(MPOSUser.Company)));
            MPOSUser.validate(Url, CopyStr(Url, 1, MaxStrLen(MPOSUser.Url)));
            MPOSUser.Insert(true);
            Commit();
        end;

        MPOSUser.SetDefaults(MPOSUser);
        MPOSUser.modify(true);
        Commit();

        MPOSUser.CreateQRCode(MPOSUser);
        MPOSUser.modify(true);
    end;

    procedure UpdatePasswordPaymentGateway(PaymentCode: code[20]; "Demo Password": text)
    var
        MagPaymentGateway: Record "NPR Magento Payment Gateway";
        AdyenSetup: Record "NPR PG Adyen Setup";
    begin
        if (not MagPaymentGateway.Get(PaymentCode)) then
            exit;

        if (PaymentCode <> 'ADYEN') then
            exit;

        if (not AdyenSetup.Get(PaymentCode)) then
            exit;

        AdyenSetup.SetAPIPassword("Demo Password");
        AdyenSetup.Modify(true);
    end;

    procedure UpdatePasswordCollectStore(StoreCode: code[20]; Password: text)
    var
        NPRNpCsStore: record "NPR NpCs Store";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
    begin
        if not NPRNpCsStore.get(StoreCode) then
            exit;

        if Password <> '' then
            WebServiceAuthHelper.SetApiPassword(Password, NPRNpCsStore."API Password Key");

        if NpCsStoreMgt.TryGetCollectService(NPRNpCsStore) then;
    end;

}