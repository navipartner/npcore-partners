page 6150705 "NPR POS Parameter Values"
{
    Caption = 'POS Parameter Values';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Parameter Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ParameterName; ParameterName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(ParameterDescription; ParameterDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(ParameterValue; ParameterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                    ToolTip = 'Specifies the value of the Value field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupValue();
                        Rec.Modify();
                        SetParameterValue();
                    end;

                    trigger OnValidate()
                    begin
                        Rec.Validate(Value, ParameterValue);
                        Rec.Modify();
                        SetParameterValue();
                    end;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Reset Values action';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ParameterIsNotDefault := not IsDefault();

        SetParameterName();
        SetParameterDescription();
        SetParameterValue();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ParameterIsNotDefault := not IsDefault();
        CurrPage.Update(false);
    end;

    var
        ParameterIsNotDefault: Boolean;
        ParameterName: Text;
        ParameterDescription: Text;
        ParameterValue: Text;

    local procedure IsDefault(): Boolean
    var
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        if POSActionParameter.Get(Rec."Action Code", Rec.Name) then
            exit(POSActionParameter."Default Value" = Rec.Value);
        exit(false);
    end;

    local procedure SetParameterName()
    begin
        Clear(ParameterName);
        Rec.OnGetParameterNameCaption(Rec, ParameterName);
        if (ParameterName = '') then
            ParameterName := Rec.Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        Rec.OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;

    local procedure SetParameterValue()
    var
        ParameterOptionString: Text;
    begin
        Clear(ParameterOptionString);
        Clear(ParameterValue);
        Rec.OnGetParameterOptionStringCaption(Rec, ParameterOptionString);
        if Rec."Data Type" = Rec."Data Type"::Boolean then
            ParameterValue := Rec.GetBooleanStringCaption()
        else
            if (ParameterOptionString = '') or (Rec."Data Type" <> Rec."Data Type"::Option) then
                ParameterValue := Rec.Value
            else
                ParameterValue := Rec.GetOptionStringCaption(ParameterOptionString)
    end;
}

