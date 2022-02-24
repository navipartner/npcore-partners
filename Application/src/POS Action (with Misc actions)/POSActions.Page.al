page 6150703 "NPR POS Actions"
{
    Extensible = False;
    Caption = 'POS Actions';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Action";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code for the POS Action';
                    ApplicationArea = NPRRetail;
                }
                field(Description; ActionDescription)
                {
                    ToolTip = 'Specifies what the POS Action does.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Description';
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies whether or not the POS Action is blocked';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Defined"; Rec.Workflow.HasValue())
                {

                    Caption = 'Workflow Defined';
                    ToolTip = 'Specifies the workflow that can be can be defined for a POS Action. Currently not used.';
                    ApplicationArea = NPRRetail;
                }
                field("Data Source Name"; Rec."Data Source Name")
                {

                    ToolTip = 'Specifies the data source that is used for/by the POS action.Currently there are 4 values:BUILTIN_PAYMENTLINE, BUILTIN_REGISTER_BALANCING, BUILTIN_SALE & BUILTIN_SALELINE';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Implementation"; Rec."Workflow Implementation")
                {
                    ToolTip = 'The workflow implementation codeunit for this action';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Refresh Workflow")
            {
                Caption = 'Refresh Workflow';
                Image = RefreshLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Refreshes the workflow';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RefreshActions();
                end;
            }
            action(ToggleBlocked)
            {
                Caption = 'Toggle Blocked';
                ToolTip = 'Toggles Blocked state for the POS action. If a POS action is blocked, it will not appear on the POS.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = DefaultFault;

                trigger OnAction()
                var
                    POSAction: Record "NPR POS Action";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(POSAction);
                    Codeunit.Run(Codeunit::"NPR Block/Unblock POS Action", POSAction);
                    CurrPage.Update(false);
                end;
            }
        }
        area(navigation)
        {
            action(Parameters)
            {
                Caption = 'Parameters';
                Image = Answers;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Action Param.";
                RunPageLink = "POS Action Code" = FIELD(Code);

                ToolTip = 'View/edit parameters';
                ApplicationArea = NPRRetail;
            }
            action(Workflow)
            {
                Caption = 'Workflow';
                Ellipsis = true;
                Image = Debug;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Action Workflow";
                RunPageLink = "POS Action Code" = FIELD(Code);

                ToolTip = 'View/edit workflow';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Type := 3;
    end;

    trigger OnOpenPage()
    begin
        if not SkipDiscovery then begin
            Rec.DiscoverActions();
        end;

        if ActionSpecified then begin
            Rec.Code := POSActionCode;
            Rec.Find('=><');
        end else
            if Rec.FindFirst() then;
    end;

    trigger OnAfterGetRecord()
    var
        WorkflowCaptionBuffer: Codeunit "NPR Workflow Caption Buffer";
    begin
        if Rec."Workflow Implementation" = Enum::"NPR POS Workflow"::LEGACY then begin
            ActionDescription := Rec.Description;
        end else begin
            ActionDescription := WorkflowCaptionBuffer.GetActionDescription(Rec.Code);
        end;
    end;

    var
        Text001: Label 'Action workflow for selected %1 action(s) has been successfully refreshed.';
        POSActionCode: Code[20];
        SkipDiscovery: Boolean;
        ActionSpecified: Boolean;
        ActionDescription: Text;

    [Obsolete('Delete once all actions are v3. Manual refresh requirement is a bug.')]
    local procedure RefreshActions()
    var
        "Action": Record "NPR POS Action";
        ActionCopy: Record "NPR POS Action";
    begin
        CurrPage.SetSelectionFilter(Action);
        if Action.FindSet() then begin
            repeat
                ActionCopy := Action;
                ActionCopy.RefreshWorkflow();
            until Action.Next() = 0;
            Message(Text001, Action.Count());
        end;
    end;

    procedure SetAction(POSActionCodeIn: Code[20])
    begin
        POSActionCode := POSActionCodeIn;
        ActionSpecified := true;
    end;

    procedure SetSkipDiscovery(SkipDiscoveryIn: Boolean)
    begin
        SkipDiscovery := SkipDiscoveryIn;
    end;
}

