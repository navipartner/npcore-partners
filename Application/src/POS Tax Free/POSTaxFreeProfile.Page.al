﻿page 6059966 "NPR POS Tax Free Profile"
{
    Extensible = False;
    Caption = 'POS Tax Free Profile';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Tax Free Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Tax Free Profile"; Rec."Tax Free Profile")
                {
                    ToolTip = 'Specifies the value of the Tax Free Profile field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Handler ID Enum"; Rec."Handler ID Enum")
                {

                    ToolTip = 'Specifies the value of the Handler ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the value of the Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Level"; Rec."Log Level")
                {

                    ToolTip = 'Specifies the value of the Log Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Check POS Terminal IIN"; Rec."Check POS Terminal IIN")
                {

                    ToolTip = 'Specifies the value of the Check POS Terminal IIN field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Timeout (ms)"; Rec."Request Timeout (ms)")
                {

                    ToolTip = 'Specifies the value of the Request Timeout (ms) field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Voucher Prints"; Rec."Store Voucher Prints")
                {

                    ToolTip = 'Specifies the value of the Store Voucher Prints field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Set Parameters action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Test Connection action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Auto Configure action';
                ApplicationArea = NPRRetail;

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
                RunPageLink = "Tax Free Profile" = FIELD("Tax Free Profile");

                ToolTip = 'Executes the View Log action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

