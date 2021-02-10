page 6014657 "NPR POS Sales Wfl. Sets Step"
{
    Caption = 'POS Sales Workflow Sets';
    PageType = ListPart;
    SourceTable = "NPR POS Sales Workflow Set";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';

                    trigger OnValidate()
                    var
                        TempPOSViewProfile: Record "NPR POS View Profile" temporary;
                    begin
                        CheckIfNoAvailableInPOSSalesWorkflowSet(ExistingPOSSalesWorkflowSet, Code);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        ExistingPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;

    procedure GetRec(var TempPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set")
    begin
        TempPOSSalesWorkflowSet.Copy(Rec);
    end;

    procedure CreatePOSSalesWorkflowSetData()
    var
        POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set";
    begin
        if Rec.FindSet() then
            repeat
                POSSalesWorkflowSet := Rec;
                if not POSSalesWorkflowSet.Insert() then
                    POSSalesWorkflowSet.Modify();
            until Rec.Next() = 0;
    end;

    procedure POSSalesWorkflowSetDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set")
    var
        POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set";
    begin
        TempPOSSalesWorkflowSet.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSSalesWorkflowSet := Rec;
                TempPOSSalesWorkflowSet.Insert();
            until Rec.Next() = 0;

        TempPOSSalesWorkflowSet.Init();
        if POSSalesWorkflowSet.FindSet() then
            repeat
                TempPOSSalesWorkflowSet.TransferFields(POSSalesWorkflowSet);
                TempPOSSalesWorkflowSet.Insert();
            until POSSalesWorkflowSet.Next() = 0;
    end;

    local procedure CopyReal()
    var
        POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set";
    begin
        if POSSalesWorkflowSet.FindSet() then
            repeat
                ExistingPOSSalesWorkflowSet := POSSalesWorkflowSet;
                ExistingPOSSalesWorkflowSet.Insert();
            until POSSalesWorkflowSet.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInPOSSalesWorkflowSet(var POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSSalesWorkflowSet.SetRange(Code, CalculatedNo);

        if POSSalesWorkflowSet.FindFirst() then begin
            HelperFunctions.FormatCode(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSSalesWorkflowSet(POSSalesWorkflowSet, WantedStartingNo);
        end;
    end;
}