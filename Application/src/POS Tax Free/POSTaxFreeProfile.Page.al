page 6059966 "NPR POS Tax Free Profile"
{
    Caption = 'POS Tax Free Profile';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Tax Free POS Unit";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Handler ID Enum"; Rec."Handler ID Enum")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handler ID field';
                    ValuesAllowed = PREMIER_PI, GLOBALBLUE_I2;
                }
                field(Mode; Rec.Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field("Log Level"; Rec."Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
                field("Check POS Terminal IIN"; Rec."Check POS Terminal IIN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Check POS Terminal IIN field';
                }
                field("Request Timeout (ms)"; Rec."Request Timeout (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Timeout (ms) field';
                }
                field("Store Voucher Prints"; Rec."Store Voucher Prints")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Voucher Prints field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Parameters")
            {
                Caption = 'Set Parameters';
                Image = Answers;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Set Parameters action';

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    TaxFreeManagement.SetParameters(Rec);
                end;
            }
            action("Test Connection")
            {
                Caption = 'Test Connection';
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Test Connection action';

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    TaxFreeManagement.UnitTestConnection(Rec);
                end;
            }
            action("Auto Configure")
            {
                Caption = 'Auto Configure';
                Image = TestDatabase;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Auto Configure action';

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    TaxFreeManagement.UnitAutoConfigure(Rec, false);
                end;
            }
            action("View Log")
            {
                Caption = 'View Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Tax Free Requests";
                RunPageLink = "POS Unit No." = FIELD("POS Unit No.");
                ApplicationArea = All;
                ToolTip = 'Executes the View Log action';
            }
        }
    }
}

