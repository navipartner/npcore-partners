page 6150906 "NPR POS HC Endpoint Setup"
{
    Caption = 'Endpoint Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS HC Endpoint Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            group(Endpoint)
            {
                field("Endpoint URI"; Rec."Endpoint URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint URI field';
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                }
                group(Credentials)
                {
                    field("Credentials Type"; Rec."Credentials Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credentials Type field';
                    }
                    field("User Domain"; Rec."User Domain")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the User Domain field';
                    }
                    field("User Account"; Rec."User Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the User Account field';
                    }
                    field("User Password"; Rec."User Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the User Password field';
                    }
                }
            }
        }
    }
}

