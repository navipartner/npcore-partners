page 6014644 "NPR Tax Free POS Units"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free POS Units';
    PageType = List;
    SourceTable = "NPR Tax Free POS Unit";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Handler ID"; "Handler ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handler ID field';
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
                field("Check POS Terminal IIN"; "Check POS Terminal IIN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Check POS Terminal IIN field';
                }
                field("Request Timeout (ms)"; "Request Timeout (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Timeout (ms) field';
                }
                field("Store Voucher Prints"; "Store Voucher Prints")
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Set Parameters action';

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    //TaxFreeManagement.SetGenericHandlerParameters(Rec);
                    TaxFreeManagement.SetParameters(Rec);
                end;
            }
            action("Test Connection")
            {
                Caption = 'Test Connection';
                Image = Process;
                Promoted = true;
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

