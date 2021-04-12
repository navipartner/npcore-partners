page 6060072 "NPR MM NPR Endpoint Setup"
{

    Caption = 'NPR Endpoint Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM NPR Remote Endp. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
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
                field("Endpoint URI"; Rec."Endpoint URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint URI field';
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                }
            }
        }
    }

    actions
    {
    }
}

