tableextension 70000038 tableextension70000038 extends "CRM Account" 
{
    // Dynamics CRM Version: 7.1.0.2040
    // NPR5.36/TS  /20170912  CASE 277715  Adding new fields for CRM Integration
    fields
    {
        field(6014400;nav_searchname;Text[100])
        {
            Caption = 'nav_searchname';
            Description = 'NPR5.36';
            ExternalName = 'nav_searchname';
            ExternalType = 'String';
        }
        field(6014402;nav_name2;Text[50])
        {
            Caption = 'nav_name2';
            Description = 'NPR5.36';
            ExternalName = 'nav_name2';
            ExternalType = 'String';
        }
        field(6014404;nav_documentsendingprofile;Text[100])
        {
            Caption = 'nav_documentsendingprofile';
            Description = 'NPR5.36';
            ExternalName = 'nav_documentsendingprofile';
            ExternalType = 'String';
        }
        field(6014406;nav_customerpostinggroup;Text[100])
        {
            Caption = 'nav_customerpostinggroup';
            Description = 'NPR5.36';
            ExternalName = 'nav_customerpostinggroup';
            ExternalType = 'String';
        }
        field(6014408;nav_customerpricegroup;Text[100])
        {
            Caption = 'nav_customerpricegroup';
            Description = 'NPR5.36';
            ExternalName = 'nav_customerpricegroup';
            ExternalType = 'String';
        }
        field(6014410;nav_vatregistrationno;Text[100])
        {
            Caption = 'nav_vatregistrationno';
            Description = 'NPR5.36';
            ExternalName = 'nav_vatregistrationno';
            ExternalType = 'String';
        }
        field(6014412;nav_genbuspostinggroup;Text[100])
        {
            Caption = 'nav_genbuspostinggroup';
            Description = 'NPR5.36';
            ExternalName = 'nav_genbuspostinggroup';
            ExternalType = 'String';
        }
        field(6014414;nav_eanno;Text[100])
        {
            Caption = 'nav_eanno';
            Description = 'NPR5.36';
            ExternalName = 'nav_eanno';
            ExternalType = 'String';
        }
        field(6014416;nav_accountcode;Text[100])
        {
            Caption = 'nav_accountcode';
            Description = 'NPR5.36';
            ExternalName = 'nav_accountcode';
            ExternalType = 'String';
        }
        field(6014418;nav_loyaltycustomer;Boolean)
        {
            Caption = 'nav_loyaltycustomer';
            Description = 'NPR5.36';
            ExternalName = 'nav_loyaltycustomer';
            ExternalType = 'Boolean';
        }
        field(6014420;nav_externalcustomerno;Text[100])
        {
            Caption = 'nav_externalcustomerno';
            Description = 'NPR5.36';
            ExternalName = 'nav_externalcustomerno';
            ExternalType = 'String';
        }
        field(6014422;nav_magentodisplaygroup;Text[100])
        {
            Caption = 'nav_magentodisplaygroup';
            Description = 'NPR5.36';
            ExternalName = 'nav_magentodisplaygroup';
            ExternalType = 'String';
        }
    }
}

