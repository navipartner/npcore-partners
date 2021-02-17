page 6150903 "NPR HC Register List"
{
    Caption = 'HC Register List';
    PageType = List;
    SourceTable = "NPR HC Register";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Opening Cash"; Rec."Opening Cash")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Cash field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Account; Rec.Account)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account field';
                }
                field("Difference Account"; Rec."Difference Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Account field';
                }
                field("Balanced Type"; Rec."Balanced Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Type field';
                }
                field("Balance Account"; Rec."Balance Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance Account field';
                }
                field("Difference Account - Neg."; Rec."Difference Account - Neg.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Account - Neg. field';
                }
                field(Rounding; Rec.Rounding)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding field';
                }
                field("Register Change Account"; Rec."Register Change Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change G/L Account No. field';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Payment Posting Setup")
            {
                Caption = 'Payment Posting Setup';
                Image = GeneralPostingSetup;
                RunObject = Page "NPR HC Paym.Types Post. Setup";
                RunPageLink = "BC Register No." = FIELD("Register No.");
                RunPageView = SORTING("BC Payment Type POS No.", "BC Register No.")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Payment Posting Setup action';
            }
            action("Default Dimension")
            {
                Caption = 'Default Dimension';
                Image = DefaultDimension;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6150902),
                              "No." = FIELD("Register No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Default Dimension action';
            }
        }
    }
}