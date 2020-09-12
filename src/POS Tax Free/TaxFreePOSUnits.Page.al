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
                }
                field("Handler ID"; "Handler ID")
                {
                    ApplicationArea = All;
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                }
                field("Check POS Terminal IIN"; "Check POS Terminal IIN")
                {
                    ApplicationArea = All;
                }
                field("Request Timeout (ms)"; "Request Timeout (ms)")
                {
                    ApplicationArea = All;
                }
                field("Store Voucher Prints"; "Store Voucher Prints")
                {
                    ApplicationArea = All;
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
            }
        }
    }
}

