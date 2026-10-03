enum 6014638 "NPR Spfy Legacy Return Status"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Shopify Legacy Return Status';

    value(0; New) { Caption = 'New'; }
    value(5; Dismissed) { Caption = 'Dismissed'; }
    value(10; Processing) { Caption = 'Processing'; }
    value(15; "Draft Created") { Caption = 'Draft Created'; }
    value(20; Imported) { Caption = 'Imported'; }
    value(30; Error) { Caption = 'Error'; }
}
