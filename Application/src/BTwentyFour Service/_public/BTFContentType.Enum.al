enum 6014409 "NPR BTF Content Type" implements "NPR BTF IFormatResponse"
{
    Extensible = true;

    value(0; "application/json")
    {
        Caption = 'application/json';
        Implementation = "NPR BTF IFormatResponse" = "NPR BTF JSON Response";
    }
    value(1; "application/xml")
    {
        Caption = 'application/xml';
        Implementation = "NPR BTF IFormatResponse" = "NPR BTF Xml Response";
    }
}
