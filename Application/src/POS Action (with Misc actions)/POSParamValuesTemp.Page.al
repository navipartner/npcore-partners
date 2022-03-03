page 6150727 "NPR POS Param. Values Temp."
{
    Extensible = False;
    Caption = 'POS Parameter Values';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR POS Parameter Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type"; Rec."Data Type")
                {

                    Editable = false;
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Reset Values action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ParameterIsNotDefault := not IsDefault();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ParameterIsNotDefault := not IsDefault();
        CurrPage.Update(false);
    end;

    var
        ParameterIsNotDefault: Boolean;

    procedure GetEditedData(var TempParam: Record "NPR POS Parameter Value" temporary)
    begin
        TempParam.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempParam := Rec;
                TempParam.Insert();
            until Rec.Next() = 0;
    end;

    procedure SetDataToEdit(var TempParam: Record "NPR POS Parameter Value" temporary)
    begin
        Rec.DeleteAll();
        if TempParam.FindSet() then
            repeat
                Rec := TempParam;
                Rec.Insert();
            until TempParam.Next() = 0;
    end;

    local procedure IsDefault(): Boolean
    var
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        if POSActionParameter.Get(Rec."Action Code", Rec.Name) then
            exit(POSActionParameter."Default Value" = Rec.Value);
        exit(false);
    end;
}

