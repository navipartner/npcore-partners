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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Credentials Type"; "Credentials Type")
                {
                    ApplicationArea = All;
                }
                field("User Domain"; "User Domain")
                {
                    ApplicationArea = All;
                }
                field("User Account"; "User Account")
                {
                    ApplicationArea = All;
                }
                field("User Password"; "User Password")
                {
                    ApplicationArea = All;
                }
                field("Endpoint URI"; "Endpoint URI")
                {
                    ApplicationArea = All;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                }
                field("Connection Timeout (ms)"; "Connection Timeout (ms)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

