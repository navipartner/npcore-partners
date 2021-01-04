page 6150906 "NPR POS HC Endpoint Setup"
{
    // NPR5.38/TSA /20171205 CASE 297946 Initial Version
    // NPR5.38/NPKNAV/20180126  CASE 297859 Transport NPR5.38 - 26 January 2018

    Caption = 'Endpoint Setup';
    PageType = Card;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            group(Endpoint)
            {
                field("Endpoint URI"; "Endpoint URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint URI field';
                }
                field("Connection Timeout (ms)"; "Connection Timeout (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                }
                group(Credentials)
                {
                    field("Credentials Type"; "Credentials Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credentials Type field';
                    }
                    field("User Domain"; "User Domain")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the User Domain field';
                    }
                    field("User Account"; "User Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the User Account field';
                    }
                    field("User Password"; "User Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the User Password field';
                    }
                }
            }
        }
    }

    actions
    {
    }
}

