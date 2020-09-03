page 6150906 "NPR POS HC Endpoint Setup"
{
    // NPR5.38/TSA /20171205 CASE 297946 Initial Version
    // NPR5.38/NPKNAV/20180126  CASE 297859 Transport NPR5.38 - 26 January 2018

    Caption = 'Endpoint Setup';
    PageType = Card;
    SourceTable = "NPR POS HC Endpoint Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
            group(Endpoint)
            {
                field("Endpoint URI"; "Endpoint URI")
                {
                    ApplicationArea = All;
                }
                field("Connection Timeout (ms)"; "Connection Timeout (ms)")
                {
                    ApplicationArea = All;
                }
                group(Credentials)
                {
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
                }
            }
        }
    }

    actions
    {
    }
}

