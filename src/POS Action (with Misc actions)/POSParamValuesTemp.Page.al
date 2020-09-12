page 6150727 "NPR POS Param. Values Temp."
{
    // NPR5.40/NPKNAV/20180330  CASE 306347 Transport NPR5.40 - 30 March 2018

    Caption = 'POS Parameter Values';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Parameter Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Reset Values")
            {
                Caption = 'Reset Values';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ParameterIsNotDefault := not IsDefault;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ParameterIsNotDefault := not IsDefault;
        CurrPage.Update(false);
    end;

    var
        ParameterIsNotDefault: Boolean;

    procedure GetEditedData(var TempParam: Record "NPR POS Parameter Value" temporary)
    begin
        TempParam.DeleteAll();
        if Rec.FindSet then
            repeat
                TempParam := Rec;
                TempParam.Insert();
            until Rec.Next = 0;
    end;

    procedure SetDataToEdit(var TempParam: Record "NPR POS Parameter Value" temporary)
    begin
        Rec.DeleteAll();
        if TempParam.FindSet then
            repeat
                Rec := TempParam;
                Rec.Insert();
            until TempParam.Next = 0;
    end;

    local procedure IsDefault(): Boolean
    var
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        if POSActionParameter.Get("Action Code", Name) then
            exit(POSActionParameter."Default Value" = Value);
        exit(false);
    end;
}

