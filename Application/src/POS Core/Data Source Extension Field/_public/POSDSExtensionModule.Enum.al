enum 6014598 "NPR POS DS Extension Module" implements "NPR POS DS Exten. Field Setup"
{
    Extensible = true;
    DefaultImplementation = "NPR POS DS Exten. Field Setup" = "NPR DS Ext.Field Default Impl.";

    value(0; Undefined)
    {
        Caption = '', Locked = true;
    }
    value(1; DocImport)
    {
        Caption = 'Doc. Import';
        Implementation = "NPR POS DS Exten. Field Setup" = "NPR Doc. Import DataSource Ext";
    }
    value(2; ClickCollect)
    {
        Caption = 'Click & Collect';
        Implementation = "NPR POS DS Exten. Field Setup" = "NPR NpCs Data Source Extension";
    }
}