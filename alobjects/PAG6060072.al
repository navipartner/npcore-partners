page 6060072 "MM NPR Endpoint Setup"
{
    // MM1.23/NPKNAV/20171025  CASE 257011 Transport MM1.23 - 25 October 2017

    Caption = 'NPR Endpoint Setup';
    PageType = List;
    SourceTable = "MM NPR Remote Endpoint Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Type;Type)
                {
                }
                field("Community Code";"Community Code")
                {
                }
                field(Description;Description)
                {
                }
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
                field("Endpoint URI";"Endpoint URI")
                {
                }
                field(Disabled;Disabled)
                {
                }
                field("Connection Timeout (ms)";"Connection Timeout (ms)")
                {
                }
            }
        }
    }

    actions
    {
    }
}

