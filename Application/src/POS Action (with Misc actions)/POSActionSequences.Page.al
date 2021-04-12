page 6150726 "NPR POS Action Sequences"
{
    // NPR5.53/VB  /20190917  CASE 362777 Support for workflow sequencing (configuring/registering "before" and "after" workflow sequences that execute before or after another workflow)

    Caption = 'POS Action Sequences';
    PageType = List;
    SourceTable = "NPR POS Action Sequence";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference Type"; Rec."Reference Type")
                {
                    ApplicationArea = All;
                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Reference Type field';
                }
                field("Reference POS Action Code"; Rec."Reference POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Reference POS Action Code field';
                }
                field("POS Action Code"; Rec."POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the POS Action Code field';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Source Type field';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DiscoverSequences)
            {
                Caption = 'Discover Sequences';
                Image = CopyBOM;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Discover Sequences action';

                trigger OnAction()
                begin
                    RunDiscovery(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RunDiscovery(false);
    end;

    var
        Text001: Label 'Discovery failed. Fix the problem and re-run POS action sequence discovery.\\Error details are: %1';

    local procedure RunDiscovery(Fail: Boolean)
    var
        MsgText: Text;
    begin
        if not CODEUNIT.Run(CODEUNIT::"NPR Discover POSAction Seq.") then begin
            MsgText := StrSubstNo(Text001, GetLastErrorText);
            if Fail then
                Error(MsgText)
            else
                Message(MsgText);
        end;
    end;
}

