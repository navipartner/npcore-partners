page 6150703 "NPR POS Actions"
{
    Caption = 'POS Actions';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Action";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Workflow Defined"; Rec.Workflow.HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Workflow Defined';
                    ToolTip = 'Specifies the value of the Workflow Defined field';
                }
                field("Data Source Name"; Rec."Data Source Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Source Name field';
                }
                field("Blocking UI"; Rec."Blocking UI")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocking UI field';
                }
                field("<Blocking UI>"; Rec."Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
                field("Secure Method Code"; Rec."Secure Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Secure Method Code field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Refresh Workflow action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Parameters action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Workflow action';
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Type := 3;
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.40 [306347]
        if not SkipDiscovery then begin
            //+NPR5.40 [306347]
            //-NPR5.32.11 [281618]
            //-NPR5.40 [306347]
            //  CodeunitInstanceDetector.InitializeActionDiscovery();
            //  BINDSUBSCRIPTION(CodeunitInstanceDetector);
            //+NPR5.40 [306347]
            //-NPR5.32.11 [281618]
            //-NPR5.39 [299114]
            Rec.DiscoverActions();
            //Rec.OnDiscoverActions();
            //+NPR5.39 [299114]
            //-NPR5.40 [306347]
        end;

        if ActionSpecified then begin
            Rec.Code := POSActionCode;
            Rec.Find('=><');
        end else
            if Rec.FindFirst() then;
        //+NPR5.40 [306347]
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
        //-NPR5.40 [306347]
        POSActionCode := POSActionCodeIn;
        ActionSpecified := true;
        //+NPR5.40 [306347]
    end;

    procedure SetSkipDiscovery(SkipDiscoveryIn: Boolean)
    begin
        //-NPR5.40 [306347]
        SkipDiscovery := SkipDiscoveryIn;
        //+NPR5.40 [306347]
    end;
}

