enum 6151500 "NPR Nc IL Update Handler" implements "NPR Nc Import List IUpdate"
{
    Extensible = true;

    value(0; Default)
    {
        Caption = 'Default';
        Implementation = "NPR Nc Import List IUpdate" = "NPR Nc IL Update Default";
    }
    value(10; "B24API")
    {
        Caption = 'B24 API';
        Implementation = "NPR Nc Import List IUpdate" = "NPR BTF Nc Import Type";
    }
}