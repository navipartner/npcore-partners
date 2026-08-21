#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151467 "NPR Entria Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
    begin
        UPGEcomSalesDocs.SetEntriaOrderImpFailureStatus();
    end;
}
#endif
