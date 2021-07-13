page 6150703 "NPR POS Actions"
{
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Defined"; Rec.Workflow.HasValue())
                {

                    Caption = 'Workflow Defined';
                    ToolTip = 'Specifies the value of the Workflow Defined field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Source Name"; Rec."Data Source Name")
                {

                    ToolTip = 'Specifies the value of the Data Source Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocking UI"; Rec."Blocking UI")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocking UI field';
                    ApplicationArea = NPRRetail;
                }
                field("<Blocking UI>"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Secure Method Code"; Rec."Secure Method Code")
                {

                    ToolTip = 'Specifies the value of the Secure Method Code field';
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

                ToolTip = 'Executes the Refresh Workflow action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RefreshActions();
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

                ToolTip = 'Executes the Parameters action';
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

                ToolTip = 'Executes the Workflow action';
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

    var
        Text001: Label 'Action workflow for selected %1 action(s) has been successfully refreshed.';
        POSActionCode: Code[20];
        SkipDiscovery: Boolean;
        ActionSpecified: Boolean;

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

