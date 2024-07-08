page 6150695 "NPR NPRE Serv. Flow Prof. Card"
{
    Extensible = False;
    Caption = 'Rest. Service Flow Profile Card';
    PageType = Card;
    SourceTable = "NPR NPRE Serv.Flow Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this restaurant service flow profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the restaurant service flow profile.';
                    ApplicationArea = NPRRetail;
                }
                group(AutoCreateWaiterPad)
                {
                    ShowCaption = false;
                    field("AutoSave to W/Pad on Sale End"; Rec."AutoSave to W/Pad on Sale End")
                    {
                        ToolTip = 'Specifies whether or not the system should automatically save items that exist in the POS sale to a waiter pad at the end of the sale.';
                        ApplicationArea = NPRRetail;
                    }
                    field("New Waiter Pad Action"; Rec."New Waiter Pad Action")
                    {
                        ToolTip = 'Specifies the code for the POS action that is used when a new waiter pad is created at the end of a sale. Recommended value is "NEW_WAITER_PAD"';
                        ApplicationArea = NPRRetail;
                        Enabled = Rec."AutoSave to W/Pad on Sale End";
                        Style = Unfavorable;
                        StyleExpr = NewWaiterPadActionRefreshNeeded;

                        trigger OnAssistEdit()
                        var
                            ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
                        begin
                            ParamMgt.EditParametersForField(Rec."New Waiter Pad Action", Rec.RecordId(), Rec.FieldNo("New Waiter Pad Action"));
                        end;
                    }
                }
                group(CloseWaiterPad)
                {
                    ShowCaption = false;
                    field("Close Waiter Pad On"; Rec."Close Waiter Pad On")
                    {
                        ToolTip = 'Specifies whether and when system should automatically close waiter pads.';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            UpdateControls();
                        end;
                    }
                    field("Only if Fully Paid"; Rec."Only if Fully Paid")
                    {
                        Enabled = IsCloseOnPayment;
                        ToolTip = 'Specifies whether waiter pads will only be automatically closed after full payment is recieved. If not enabled, system will automatically close waiter pads after the first payment, even if the sale remains partialy unpaid after that.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(ClearSeating)
                {
                    ShowCaption = false;
                    field("Clear Seating On"; Rec."Clear Seating On")
                    {
                        ToolTip = 'Specifies when system should clear seatings. System will assign to the seating the status, specified in "Seating Status after Clearing".';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seating Status after Clearing"; Rec."Seating Status after Clearing")
                    {
                        ToolTip = 'Specifies the status code, which is going to be assigned to seatings on clearing.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(WPadReadyForPmtStatus)
                {
                    ShowCaption = false;
                    field("Set W/Pad Ready for Pmt. On"; Rec."Set W/Pad Ready for Pmt. On")
                    {
                        ToolTip = 'Specifies whether and when system should automatically change waiter pad status to "ready for payment" (the status specified in field "W/Pad Ready for Pmt. Status").';
                        ApplicationArea = NPRRetail;
                    }
                    field("W/Pad Ready for Pmt. Status"; Rec."W/Pad Ready for Pmt. Status")
                    {
                        ToolTip = 'Specifies the "ready for payment" waiter pad status code.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Refresh Invalid Action Parameters")
            {
                Caption = 'Refresh Invalid Action Parameters';
                Enabled = RefreshEnabled;
                Image = RefreshText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Refresh Invalid Action Parameters action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RefreshInvalidActions();
                end;
            }
        }
    }

    var
        IsCloseOnPayment: Boolean;
        NewWaiterPadActionRefreshNeeded: Boolean;
        RefreshEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
        UpdateActionsStyles();
    end;

    local procedure UpdateControls()
    begin
        IsCloseOnPayment := Rec."Close Waiter Pad On" in [Rec."Close Waiter Pad On"::Payment, Rec."Close Waiter Pad On"::"Payment if Served"];
    end;

    local procedure UpdateActionsStyles()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        NewWaiterPadActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId(), '', Rec.FieldNo("New Waiter Pad Action"), Rec."New Waiter Pad Action");
        RefreshEnabled := NewWaiterPadActionRefreshNeeded;
    end;

    local procedure RefreshInvalidActions()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if NewWaiterPadActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId(), '', Rec.FieldNo("New Waiter Pad Action"), Rec."New Waiter Pad Action");
    end;
}
