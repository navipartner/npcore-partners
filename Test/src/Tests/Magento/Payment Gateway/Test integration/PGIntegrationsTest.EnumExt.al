enumextension 85001 "NPR PG Integrations Test" extends "NPR PG Integrations"
{
    value(85000; "CI Test Integration")
    {
        Caption = 'CI Test Integration';
        Implementation = "NPR IPaymentGateway" = "NPR PG CI Test Integration",
                          "NPR Pay by Link" = "NPR Unknown PayByLink";
    }
}