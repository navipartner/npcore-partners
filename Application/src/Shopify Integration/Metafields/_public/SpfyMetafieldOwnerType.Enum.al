#if not BC17
enum 6059814 "NPR Spfy Metafield Owner Type"
{
    Access = Public;
    Extensible = true;

    value(0; " ") { Caption = '<Undefined>'; }
    value(1; PRODUCT) { Caption = 'Product'; }
    value(2; PRODUCTVARIANT) { Caption = 'Product Variant'; }
    value(3; CUSTOMER) { Caption = 'Customer'; }
}
#endif