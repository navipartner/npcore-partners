page 6150906 "POS HC Endpoint Setup"
{
    // NPR5.38/TSA /20171205 CASE 297946 Initial Version
    // NPR5.38/NPKNAV/20180126  CASE 297859 Transport NPR5.38 - 26 January 2018

    Caption = 'Endpoint Setup';
    PageType = Card;
    SourceTable = "POS HC Endpoint Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Active;Active)
                {
                }
                field(Description;Description)
                {
                }
            }
            group(Endpoint)
            {
                field("Endpoint URI";"Endpoint URI")
                {
                }
                field("Connection Timeout (ms)";"Connection Timeout (ms)")
                {
                }
                group(Credentials)
                {
                    field("Credentials Type";"Credentials Type")
                    {
                    }
                    field("User Domain";"User Domain")
                    {
                    }
                    field("User Account";"User Account")
                    {
                    }
                    field("User Password";"User Password")
                    {
                    }
                }
            }
        }
    }

    actions
    {
    }
}

