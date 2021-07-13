page 6150906 "NPR POS HC Endpoint Setup"
{
    Caption = 'Endpoint Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR POS HC Endpoint Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Endpoint)
            {
                field("Endpoint URI"; Rec."Endpoint URI")
                {

                    ToolTip = 'Specifies the value of the Endpoint URI field';
                    ApplicationArea = NPRRetail;
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {

                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                    ApplicationArea = NPRRetail;
                }
                group(Credentials)
                {
                    field("Credentials Type"; Rec."Credentials Type")
                    {

                        ToolTip = 'Specifies the value of the Credentials Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("User Domain"; Rec."User Domain")
                    {

                        ToolTip = 'Specifies the value of the User Domain field';
                        ApplicationArea = NPRRetail;
                    }
                    field("User Account"; Rec."User Account")
                    {

                        ToolTip = 'Specifies the value of the User Account field';
                        ApplicationArea = NPRRetail;
                    }
                    field("User Password"; Rec."User Password")
                    {

                        ToolTip = 'Specifies the value of the User Password field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}

