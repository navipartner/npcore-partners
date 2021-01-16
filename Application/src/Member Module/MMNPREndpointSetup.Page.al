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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
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
                field("Endpoint URI"; "Endpoint URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint URI field';
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Connection Timeout (ms)"; "Connection Timeout (ms)")
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

