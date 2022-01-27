page 6150903 "NPR HC Register List"
{
    Extensible = False;
    Caption = 'HC Register List';
    PageType = List;
    SourceTable = "NPR HC Register";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Opening Cash"; Rec."Opening Cash")
                {

                    ToolTip = 'Specifies the value of the Opening Cash field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Account; Rec.Account)
                {

                    ToolTip = 'Specifies the value of the Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Account"; Rec."Difference Account")
                {

                    ToolTip = 'Specifies the value of the Difference Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Balanced Type"; Rec."Balanced Type")
                {

                    ToolTip = 'Specifies the value of the Balanced Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Balance Account"; Rec."Balance Account")
                {

                    ToolTip = 'Specifies the value of the Balance Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Account - Neg."; Rec."Difference Account - Neg.")
                {

                    ToolTip = 'Specifies the value of the Difference Account - Neg. field';
                    ApplicationArea = NPRRetail;
                }
                field(Rounding; Rec.Rounding)
                {

                    ToolTip = 'Specifies the value of the Rounding field';
                    ApplicationArea = NPRRetail;
                }
                field("Register Change Account"; Rec."Register Change Account")
                {

                    ToolTip = 'Specifies the value of the Change G/L Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Payment Posting Setup action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Default Dimension action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
