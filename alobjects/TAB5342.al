tableextension 50040 tableextension50040 extends "CRM Contact" 
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
        field(6014402;nav_name2;Text[100])
        {
            Caption = 'nav_name2';
            Description = 'NPR5.36';
            ExternalName = 'nav_name2';
            ExternalType = 'String';
        }
        field(6014404;nav_telexno;Text[100])
        {
            Caption = 'nav_telexno';
            Description = 'NPR5.36';
            ExternalName = 'nav_telexno';
            ExternalType = 'String';
        }
        field(6014406;nav_languagecode;Text[100])
        {
            Caption = 'nav_languagecode';
            Description = 'NPR5.36';
            ExternalName = 'nav_languagecode';
            ExternalType = 'String';
        }
        field(6014408;nav_lastdatemodified;Date)
        {
            Caption = 'nav_lastdatemodified';
            Description = 'NPR5.36';
            ExternalName = 'nav_lastdatemodified';
            ExternalType = 'DateTime';
        }
        field(6014410;nav_initials;Text[100])
        {
            Caption = 'nav_initials';
            Description = 'NPR5.36';
            ExternalName = 'nav_initials';
            ExternalType = 'String';
        }
        field(6014412;nav_extensionno;Text[100])
        {
            Caption = 'nav_extensionno';
            Description = 'NPR5.36';
            ExternalName = 'nav_extensionno';
            ExternalType = 'String';
        }
        field(6014414;nav_organizationallevelcode;Text[100])
        {
            Caption = 'nav_organizationallevelcode';
            Description = 'NPR5.36';
            ExternalName = 'nav_organizationallevelcode';
            ExternalType = 'String';
        }
        field(6014416;nav_excludefromsegments;Boolean)
        {
            Caption = 'nav_excludefromsegments';
            Description = 'NPR5.36';
            ExternalName = 'nav_excludefromsegments';
            ExternalType = 'Boolean';
        }
        field(6014418;nav_comments;Boolean)
        {
            Caption = 'nav_comments';
            Description = 'NPR5.36';
            ExternalName = 'nav_comments';
            ExternalType = 'Boolean';
        }
    }
}

