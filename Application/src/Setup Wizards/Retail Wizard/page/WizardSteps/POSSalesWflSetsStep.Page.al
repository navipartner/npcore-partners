page 6014657 "NPR POS Sales Wfl. Sets Step"
{
    Extensible = False;
    Caption = 'POS Sales Workflow Sets';
    PageType = ListPart;
    SourceTable = "NPR POS Sales Workflow Set";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInPOSSalesWorkflowSet(TempExistingPOSSalesWorkflowSet, Rec.Code);
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;

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
                TempExistingPOSSalesWorkflowSet := POSSalesWorkflowSet;
                TempExistingPOSSalesWorkflowSet.Insert();
            until POSSalesWorkflowSet.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInPOSSalesWorkflowSet(var POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSSalesWorkflowSet.SetRange(Code, CalculatedNo);

        if POSSalesWorkflowSet.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSSalesWorkflowSet(POSSalesWorkflowSet, WantedStartingNo);
        end;
    end;
}
