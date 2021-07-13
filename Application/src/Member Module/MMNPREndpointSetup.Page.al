page 6060072 "NPR MM NPR Endpoint Setup"
{

    Caption = 'NPR Endpoint Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM NPR Remote Endp. Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
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
                field("Endpoint URI"; Rec."Endpoint URI")
                {

                    ToolTip = 'Specifies the value of the Endpoint URI field';
                    ApplicationArea = NPRRetail;
                }
                field(Disabled; Rec.Disabled)
                {

                    ToolTip = 'Specifies the value of the Disabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {

                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

